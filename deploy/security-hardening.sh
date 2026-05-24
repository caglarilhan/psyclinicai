#!/usr/bin/env bash
# PsyClinicAI Hetzner Security Hardening
# Safe: Other projects (ilhanostranscript, kumarbazlar, tradeflow) untouched.
# Usage: ssh root@46.225.181.130 'bash -s' < security-hardening.sh

set -euo pipefail

NGINX_CONF_DIR="/opt/ilhanostranscript/nginx/conf.d"
NGINX_CONTAINER="ilhanostranscript-nginx"
DOMAIN="psyclinicai.com"

echo "==================================="
echo "1/4: fail2ban kurulum"
echo "==================================="
if ! command -v fail2ban-client >/dev/null 2>&1; then
  apt-get update -qq
  apt-get install -y fail2ban
fi

cat > /etc/fail2ban/jail.local <<'F2B_EOF'
[DEFAULT]
bantime = 3600
findtime = 600
maxretry = 5
backend = systemd

[sshd]
enabled = true
port = 22
logpath = %(sshd_log)s
maxretry = 5
F2B_EOF

systemctl enable fail2ban
systemctl restart fail2ban
sleep 2
fail2ban-client status sshd | head -10
echo "  OK - fail2ban sshd jail aktif"

echo ""
echo "==================================="
echo "2/4: Nginx rate limit + CSP (sadece psyclinicai)"
echo "==================================="

cat > "${NGINX_CONF_DIR}/00-psyclinicai-ratelimit.conf" <<'RL_EOF'
# PsyClinicAI rate limit zones
limit_req_zone $binary_remote_addr zone=psyclinicai_general:10m rate=10r/s;
limit_req_zone $binary_remote_addr zone=psyclinicai_strict:10m rate=2r/s;
limit_conn_zone $binary_remote_addr zone=psyclinicai_conn:10m;
RL_EOF

cat > "${NGINX_CONF_DIR}/psyclinicai.conf" <<'NGINX_EOF'
# PsyClinicAI - HTTPS production config with security headers
server {
    listen 80;
    listen [::]:80;
    server_name psyclinicai.com www.psyclinicai.com;

    location /.well-known/acme-challenge/ {
        root /var/www/certbot;
    }

    location / {
        return 301 https://$host$request_uri;
    }
}

server {
    listen 443 ssl;
    listen [::]:443 ssl;
    http2 on;
    server_name psyclinicai.com www.psyclinicai.com;

    ssl_certificate /etc/letsencrypt/live/psyclinicai.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/psyclinicai.com/privkey.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers on;
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;

    # Security headers
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains; preload" always;
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;
    add_header Permissions-Policy "geolocation=(), microphone=(self), camera=(self), payment=(self)" always;

    # CSP report-only (Flutter web canvaskit + Firebase + Stripe + Anthropic icin permissive)
    add_header Content-Security-Policy-Report-Only "default-src 'self'; script-src 'self' 'unsafe-inline' 'unsafe-eval' https://www.googletagmanager.com https://browser.sentry-cdn.com https://js.stripe.com https://www.gstatic.com; style-src 'self' 'unsafe-inline' https://fonts.googleapis.com; font-src 'self' data: https://fonts.gstatic.com; img-src 'self' data: blob: https:; connect-src 'self' https://api.anthropic.com https://api.openai.com https://*.firebaseio.com https://*.googleapis.com https://api.stripe.com https://*.sentry.io https://o0.ingest.sentry.io wss: blob:; frame-src https://js.stripe.com; worker-src 'self' blob:; object-src 'none'; base-uri 'self'; form-action 'self'; frame-ancestors 'self';" always;

    # Rate limiting
    limit_req zone=psyclinicai_general burst=20 nodelay;
    limit_conn psyclinicai_conn 10;
    limit_req_status 429;
    limit_conn_status 429;

    # Block common attack patterns
    location ~* \.(env|git|sql|bak|backup|swp|orig)$ { deny all; access_log off; log_not_found off; }
    location ~ /\.(git|env|ssh|aws|docker) { deny all; access_log off; log_not_found off; }

    location / {
        proxy_pass http://psyclinicai-web:80;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_http_version 1.1;
        proxy_connect_timeout 10s;
        proxy_read_timeout 60s;
    }

    location = /healthz {
        access_log off;
        return 200 "ok\n";
        add_header Content-Type text/plain;
    }
}
NGINX_EOF

docker exec "$NGINX_CONTAINER" nginx -t 2>&1 | tail -5
docker exec "$NGINX_CONTAINER" nginx -s reload
echo "  OK - nginx rate limit + CSP yuklu"

echo ""
echo "==================================="
echo "3/4: SSH hardening (mevcut session korunur)"
echo "==================================="

cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup-$(date +%Y%m%d-%H%M%S)

sed -i 's/^#*PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config
sed -i 's/^#*PermitRootLogin.*/PermitRootLogin prohibit-password/' /etc/ssh/sshd_config
sed -i 's/^#*ChallengeResponseAuthentication.*/ChallengeResponseAuthentication no/' /etc/ssh/sshd_config
sed -i 's/^#*KbdInteractiveAuthentication.*/KbdInteractiveAuthentication no/' /etc/ssh/sshd_config
sed -i 's/^#*UsePAM.*/UsePAM no/' /etc/ssh/sshd_config

grep -q '^MaxAuthTries' /etc/ssh/sshd_config || echo 'MaxAuthTries 3' >> /etc/ssh/sshd_config
grep -q '^LoginGraceTime' /etc/ssh/sshd_config || echo 'LoginGraceTime 30' >> /etc/ssh/sshd_config
grep -q '^ClientAliveInterval' /etc/ssh/sshd_config || echo 'ClientAliveInterval 300' >> /etc/ssh/sshd_config
grep -q '^ClientAliveCountMax' /etc/ssh/sshd_config || echo 'ClientAliveCountMax 2' >> /etc/ssh/sshd_config
grep -q '^X11Forwarding' /etc/ssh/sshd_config || echo 'X11Forwarding no' >> /etc/ssh/sshd_config

sshd -t && echo "  sshd_config syntax OK"
systemctl restart ssh
echo "  OK - SSH password auth disabled. Mevcut session etkilenmedi."

echo ""
echo "==================================="
echo "4/4: Durum raporu"
echo "==================================="
echo "fail2ban:"
fail2ban-client status sshd 2>&1 | grep -E "Currently|Total" | head -4
echo ""
echo "SSH config (kritik):"
grep -E "^(PasswordAuthentication|PermitRootLogin|MaxAuthTries|KbdInteractiveAuthentication)" /etc/ssh/sshd_config
echo ""
echo "Public HTTPS:"
curl -s -o /dev/null -w "  https://psyclinicai.com -> HTTP %{http_code}\n" https://psyclinicai.com/

echo ""
echo "=== HARDENING BASARILI ==="
echo "Etkilenen: SADECE psyclinicai.com + SSH (genel)"
echo "Etkilenmeyen: ilhanostranscript, kumarbazlar, tradeflow, postgres"
