#!/usr/bin/env bash
# PsyClinicAI Hetzner System Update + Reboot
# Safe: All containers auto-restart with `restart: unless-stopped`
# Usage: ssh root@46.225.181.130 'bash -s' < system-update.sh

set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

echo "==================================="
echo "1/5: needrestart non-interactive ayarla"
echo "==================================="
mkdir -p /etc/needrestart/conf.d
cat > /etc/needrestart/conf.d/90-psyclinic.conf <<'NR_EOF'
$nrconf{restart} = 'a';
$nrconf{kernelhints} = 0;
NR_EOF
echo "  OK"

echo ""
echo "==================================="
echo "2/5: Apt update + upgrade (auto-confirm)"
echo "==================================="
apt-get update -qq
echo ""
echo "Upgradable packages:"
apt list --upgradable 2>/dev/null | head -10
echo ""

apt-get upgrade -y \
  -o Dpkg::Options::="--force-confdef" \
  -o Dpkg::Options::="--force-confold" \
  2>&1 | tail -20

echo ""
echo "==================================="
echo "3/5: Unattended-upgrades (otomatik security patch)"
echo "==================================="
apt-get install -y unattended-upgrades apt-listchanges

cat > /etc/apt/apt.conf.d/20auto-upgrades <<'AU_EOF'
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Unattended-Upgrade "1";
APT::Periodic::AutocleanInterval "7";
AU_EOF

cat > /etc/apt/apt.conf.d/50unattended-upgrades-custom <<'UU_EOF'
Unattended-Upgrade::Allowed-Origins {
    "${distro_id}:${distro_codename}";
    "${distro_id}:${distro_codename}-security";
    "${distro_id}ESMApps:${distro_codename}-apps-security";
    "${distro_id}ESM:${distro_codename}-infra-security";
    "${distro_id}:${distro_codename}-updates";
};
Unattended-Upgrade::Automatic-Reboot "false";
Unattended-Upgrade::Remove-Unused-Kernel-Packages "true";
Unattended-Upgrade::Remove-Unused-Dependencies "true";
Unattended-Upgrade::Mail "";
UU_EOF

systemctl enable unattended-upgrades
systemctl restart unattended-upgrades
echo "  OK - unattended-upgrades aktif (haftalik otomatik patch)"

echo ""
echo "==================================="
echo "4/5: Apt autoremove + clean"
echo "==================================="
apt-get autoremove -y 2>&1 | tail -3
apt-get autoclean 2>&1 | tail -3
echo "  OK - kullanilmayan paketler temizlendi"

echo ""
echo "==================================="
echo "5/5: Restart kontrol"
echo "==================================="
if [ -f /var/run/reboot-required ]; then
  echo "  REBOOT GEREKLI: $(cat /var/run/reboot-required)"
  echo ""
  echo "=== Container state (reboot oncesi) ==="
  docker ps --format "  {{.Names}} | {{.Status}}" | head -10
  echo ""
  echo "Reboot 1 dakika sonra. SSH kopar, 2-3 dk sonra tekrar baglan."
  shutdown -r +1 "PsyClinicAI scheduled update reboot in 1 minute"
  echo "  OK - shutdown -r +1 scheduled"
else
  echo "  Reboot gerekmez, sistem guncel."
  docker ps --format "  {{.Names}} | {{.Status}}" | head -10
fi
