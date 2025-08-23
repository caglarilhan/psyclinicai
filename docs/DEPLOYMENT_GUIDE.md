# 🚀 PsyClinicAI Deployment Guide

## 🎯 Overview

This guide provides comprehensive instructions for deploying PsyClinicAI to various environments, from development to production. Whether you're setting up a local development environment or deploying to cloud infrastructure, this guide covers all the necessary steps.

## 📋 Table of Contents

1. [Prerequisites](#prerequisites)
2. [Local Development Setup](#local-development-setup)
3. [Docker Deployment](#docker-deployment)
4. [Cloud Deployment](#cloud-deployment)
5. [Production Configuration](#production-configuration)
6. [Monitoring & Logging](#monitoring--logging)
7. [Security Configuration](#security-configuration)
8. [Backup & Recovery](#backup--recovery)
9. [Scaling & Performance](#scaling--performance)
10. [Troubleshooting](#troubleshooting)

## ✅ Prerequisites

### System Requirements

#### **Minimum Requirements**
- **OS**: Ubuntu 20.04 LTS, CentOS 8, or macOS 12+
- **CPU**: 4 cores (2.4 GHz)
- **RAM**: 8GB
- **Storage**: 50GB SSD
- **Network**: 100 Mbps internet connection

#### **Recommended Requirements**
- **OS**: Ubuntu 22.04 LTS
- **CPU**: 8+ cores (3.0 GHz)
- **RAM**: 16GB+
- **Storage**: 100GB+ NVMe SSD
- **Network**: 1 Gbps internet connection

### Software Dependencies

#### **Core Software**
```bash
# Operating System
Ubuntu 22.04 LTS (recommended)

# Database
PostgreSQL 15+
Redis 7+

# Container Runtime
Docker 20.10+
Docker Compose 2.0+

# Web Server
Nginx 1.20+

# SSL Certificates
Let's Encrypt (certbot)
```

#### **Development Tools**
```bash
# Flutter SDK
flutter --version  # 3.29.0+

# Dart SDK
dart --version     # 3.0.0+

# Git
git --version      # 2.30+

# Node.js (for build tools)
node --version     # 18.0+
```

## 🏠 Local Development Setup

### Step 1: Environment Preparation

#### **Clone Repository**
```bash
git clone https://github.com/caglarilhan/psyclinicai.git
cd psyclinicai
```

#### **Install Dependencies**
```bash
# Flutter dependencies
flutter pub get

# Generate code
flutter packages pub run build_runner build

# Install development tools
dart pub global activate dart_style
dart pub global activate dart_analyzer
```

### Step 2: Database Setup

#### **PostgreSQL Installation**
```bash
# Update package list
sudo apt update

# Install PostgreSQL
sudo apt install postgresql postgresql-contrib

# Start and enable PostgreSQL
sudo systemctl start postgresql
sudo systemctl enable postgresql

# Switch to postgres user
sudo -u postgres psql

# Create database and user
postgres=# CREATE DATABASE psyclinicai_dev;
postgres=# CREATE USER psyclinicai_dev WITH PASSWORD 'dev_password';
postgres=# GRANT ALL PRIVILEGES ON DATABASE psyclinicai_dev TO psyclinicai_dev;
postgres=# ALTER USER psyclinicai_dev CREATEDB;
postgres=# \q
```

#### **Redis Installation**
```bash
# Install Redis
sudo apt install redis-server

# Start and enable Redis
sudo systemctl start redis-server
sudo systemctl enable redis-server

# Test Redis connection
redis-cli ping  # Should return PONG
```

### Step 3: Environment Configuration

#### **Create Environment File**
```bash
# Copy template
cp .env.example .env

# Edit environment variables
nano .env
```

**Environment Variables**:
```bash
# Database Configuration
DATABASE_URL=postgresql://psyclinicai_dev:dev_password@localhost:5432/psyclinicai_dev
DATABASE_POOL_SIZE=10
DATABASE_MAX_CONNECTIONS=20

# Redis Configuration
REDIS_URL=redis://localhost:6379
REDIS_POOL_SIZE=5

# Security Configuration
JWT_SECRET=your-super-secret-jwt-key-here-change-in-production
ENCRYPTION_KEY=your-32-character-encryption-key-here
ENCRYPTION_IV=your-16-character-iv-here
JWT_EXPIRATION=3600
REFRESH_TOKEN_EXPIRATION=604800

# AI Services
AI_MODEL_PATH=./models/
AI_API_KEY=your-ai-service-key
AI_MODEL_CACHE_SIZE=1000

# External Services
FHIR_SERVER_URL=https://fhir.example.com
PAYMENT_GATEWAY_KEY=your-payment-key
EMAIL_SERVICE_KEY=your-email-key

# Logging
LOG_LEVEL=INFO
LOG_FORMAT=json
LOG_FILE_PATH=./logs/

# Development
DEBUG=true
ENVIRONMENT=development
```

### Step 4: Run Application

#### **Development Mode**
```bash
# Run in development mode
flutter run --debug

# Or run specific platform
flutter run -d chrome    # Web
flutter run -d android   # Android
flutter run -d ios        # iOS
```

#### **Test Application**
```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/simple_test.dart

# Run with coverage
flutter test --coverage
```

## 🐳 Docker Deployment

### Step 1: Docker Setup

#### **Install Docker**
```bash
# Update package list
sudo apt update

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Add user to docker group
sudo usermod -aG docker $USER

# Start and enable Docker
sudo systemctl start docker
sudo systemctl enable docker

# Verify installation
docker --version
docker-compose --version
```

#### **Install Docker Compose**
```bash
# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/v2.20.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

# Make executable
sudo chmod +x /usr/local/bin/docker-compose

# Verify installation
docker-compose --version
```

### Step 2: Docker Configuration

#### **Environment Configuration**
```bash
# Copy Docker environment template
cp .env.docker.example .env.docker

# Edit Docker environment
nano .env.docker
```

**Docker Environment Variables**:
```bash
# Application
APP_NAME=PsyClinicAI
APP_VERSION=2.0.0
APP_ENVIRONMENT=production

# Database
POSTGRES_DB=psyclinicai
POSTGRES_USER=psyclinicai
POSTGRES_PASSWORD=secure_password_here
POSTGRES_HOST=postgres
POSTGRES_PORT=5432

# Redis
REDIS_HOST=redis
REDIS_PORT=6379
REDIS_PASSWORD=redis_password_here

# Security
JWT_SECRET=your-super-secret-jwt-key-here
ENCRYPTION_KEY=your-32-character-encryption-key
ENCRYPTION_IV=your-16-character-iv

# AI Services
AI_MODEL_PATH=/app/models/
AI_API_KEY=your-ai-service-key

# Monitoring
PROMETHEUS_ENABLED=true
GRAFANA_ENABLED=true
ELK_ENABLED=true
```

#### **Docker Compose Configuration**
```yaml
# docker-compose.yml
version: '3.8'

services:
  # Main Application
  psyclinicai-app:
    build:
      context: .
      dockerfile: Dockerfile
      args:
        - BUILD_ENV=production
    container_name: psyclinicai-app
    ports:
      - "8080:8080"
    environment:
      - NODE_ENV=production
      - DATABASE_URL=postgresql://${POSTGRES_USER}:${POSTGRES_PASSWORD}@${POSTGRES_HOST}:${POSTGRES_PORT}/${POSTGRES_DB}
      - REDIS_URL=redis://${REDIS_HOST}:${REDIS_PORT}
      - JWT_SECRET=${JWT_SECRET}
      - ENCRYPTION_KEY=${ENCRYPTION_KEY}
      - ENCRYPTION_IV=${ENCRYPTION_IV}
    depends_on:
      - postgres
      - redis
    volumes:
      - ./logs:/app/logs
      - ./uploads:/app/uploads
      - ./models:/app/models
    restart: unless-stopped
    networks:
      - psyclinicai-network
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8080/health"]
      interval: 30s
      timeout: 10s
      retries: 3

  # PostgreSQL Database
  postgres:
    image: postgres:15-alpine
    container_name: psyclinicai-postgres
    environment:
      - POSTGRES_DB=${POSTGRES_DB}
      - POSTGRES_USER=${POSTGRES_USER}
      - POSTGRES_PASSWORD=${POSTGRES_PASSWORD}
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./init-scripts:/docker-entrypoint-initdb.d
    ports:
      - "5432:5432"
    restart: unless-stopped
    networks:
      - psyclinicai-network
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${POSTGRES_USER} -d ${POSTGRES_DB}"]
      interval: 30s
      timeout: 10s
      retries: 3

  # Redis Cache
  redis:
    image: redis:7-alpine
    container_name: psyclinicai-redis
    command: redis-server --requirepass ${REDIS_PASSWORD}
    volumes:
      - redis_data:/data
    ports:
      - "6379:6379"
    restart: unless-stopped
    networks:
      - psyclinicai-network
    healthcheck:
      test: ["CMD", "redis-cli", "-a", "${REDIS_PASSWORD}", "ping"]
      interval: 30s
      timeout: 10s
      retries: 3

  # Nginx Reverse Proxy
  nginx:
    image: nginx:alpine
    container_name: psyclinicai-nginx
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx/nginx.conf:/etc/nginx/nginx.conf
      - ./nginx/ssl:/etc/nginx/ssl
      - ./logs/nginx:/var/log/nginx
    depends_on:
      - psyclinicai-app
    restart: unless-stopped
    networks:
      - psyclinicai-network

volumes:
  postgres_data:
    driver: local
  redis_data:
    driver: local

networks:
  psyclinicai-network:
    driver: bridge
    ipam:
      config:
        - subnet: 172.20.0.0/16
```

### Step 3: Build and Deploy

#### **Build Application**
```bash
# Build Docker image
docker-compose build

# Or build specific service
docker-compose build psyclinicai-app
```

#### **Start Services**
```bash
# Start all services
docker-compose up -d

# Check service status
docker-compose ps

# View logs
docker-compose logs -f psyclinicai-app
```

#### **Stop Services**
```bash
# Stop all services
docker-compose down

# Stop and remove volumes
docker-compose down -v

# Stop specific service
docker-compose stop psyclinicai-app
```

## ☁️ Cloud Deployment

### AWS Deployment

#### **EC2 Instance Setup**
```bash
# Launch EC2 instance
aws ec2 run-instances \
  --image-id ami-0c02fb55956c7d316 \
  --count 1 \
  --instance-type t3.medium \
  --key-name your-key-pair \
  --security-group-ids sg-xxxxxxxxx \
  --subnet-id subnet-xxxxxxxxx \
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=PsyClinicAI}]'
```

#### **Security Group Configuration**
```bash
# Create security group
aws ec2 create-security-group \
  --group-name PsyClinicAI-SG \
  --description "Security group for PsyClinicAI"

# Add inbound rules
aws ec2 authorize-security-group-ingress \
  --group-name PsyClinicAI-SG \
  --protocol tcp \
  --port 22 \
  --cidr 0.0.0.0/0

aws ec2 authorize-security-group-ingress \
  --group-name PsyClinicAI-SG \
  --protocol tcp \
  --port 80 \
  --cidr 0.0.0.0/0

aws ec2 authorize-security-group-ingress \
  --group-name PsyClinicAI-SG \
  --protocol tcp \
  --port 443 \
  --cidr 0.0.0.0/0
```

#### **RDS Database Setup**
```bash
# Create RDS instance
aws rds create-db-instance \
  --db-instance-identifier psyclinicai-db \
  --db-instance-class db.t3.micro \
  --engine postgres \
  --master-username psyclinicai \
  --master-user-password secure_password_here \
  --allocated-storage 20 \
  --vpc-security-group-ids sg-xxxxxxxxx \
  --db-subnet-group-name default
```

#### **S3 Storage Setup**
```bash
# Create S3 bucket
aws s3 mb s3://psyclinicai-storage

# Configure bucket policy
aws s3api put-bucket-policy \
  --bucket psyclinicai-storage \
  --policy file://s3-bucket-policy.json
```

### Google Cloud Platform

#### **Compute Engine Setup**
```bash
# Create VM instance
gcloud compute instances create psyclinicai-vm \
  --zone=us-central1-a \
  --machine-type=e2-medium \
  --image-family=ubuntu-2204-lts \
  --image-project=ubuntu-os-cloud \
  --tags=http-server,https-server \
  --metadata=startup-script='#! /bin/bash
    sudo apt-get update
    sudo apt-get install -y docker.io docker-compose
    sudo systemctl start docker
    sudo systemctl enable docker
    git clone https://github.com/caglarilhan/psyclinicai.git
    cd psyclinicai
    sudo docker-compose up -d'
```

#### **Cloud SQL Setup**
```bash
# Create Cloud SQL instance
gcloud sql instances create psyclinicai-db \
  --database-version=POSTGRES_15 \
  --tier=db-f1-micro \
  --region=us-central1 \
  --root-password=secure_password_here
```

### Azure Deployment

#### **Virtual Machine Setup**
```bash
# Create resource group
az group create --name PsyClinicAI-RG --location eastus

# Create virtual machine
az vm create \
  --resource-group PsyClinicAI-RG \
  --name PsyClinicAI-VM \
  --image Ubuntu2204 \
  --size Standard_B2s \
  --admin-username azureuser \
  --generate-ssh-keys
```

#### **Azure Database Setup**
```bash
# Create PostgreSQL server
az postgres flexible-server create \
  --resource-group PsyClinicAI-RG \
  --name psyclinicai-db \
  --admin-user psyclinicai \
  --admin-password secure_password_here \
  --sku-name Standard_B1ms \
  --tier Burstable \
  --storage-size 32
```

## ⚙️ Production Configuration

### Environment Variables

#### **Production Environment File**
```bash
# .env.production
APP_NAME=PsyClinicAI
APP_VERSION=2.0.0
APP_ENVIRONMENT=production
APP_DEBUG=false
APP_URL=https://psyclinicai.com

# Database
DATABASE_URL=postgresql://psyclinicai:secure_password@db.psyclinicai.com:5432/psyclinicai
DATABASE_POOL_SIZE=20
DATABASE_MAX_CONNECTIONS=100
DATABASE_SSL_MODE=require

# Redis
REDIS_URL=redis://:redis_password@redis.psyclinicai.com:6379
REDIS_POOL_SIZE=10

# Security
JWT_SECRET=your-super-secret-jwt-key-here-change-in-production
ENCRYPTION_KEY=your-32-character-encryption-key-here
ENCRYPTION_IV=your-16-character-iv-here
JWT_EXPIRATION=3600
REFRESH_TOKEN_EXPIRATION=604800
SESSION_TIMEOUT=1800

# AI Services
AI_MODEL_PATH=/app/models/
AI_API_KEY=your-ai-service-key
AI_MODEL_CACHE_SIZE=5000

# External Services
FHIR_SERVER_URL=https://fhir.psyclinicai.com
PAYMENT_GATEWAY_KEY=your-payment-key
EMAIL_SERVICE_KEY=your-email-key

# Logging
LOG_LEVEL=WARNING
LOG_FORMAT=json
LOG_FILE_PATH=/var/log/psyclinicai/
LOG_ROTATION_SIZE=100MB
LOG_RETENTION_DAYS=30

# Monitoring
MONITORING_ENABLED=true
METRICS_ENDPOINT=/metrics
HEALTH_CHECK_ENDPOINT=/health
```

### Nginx Configuration

#### **Production Nginx Config**
```nginx
# /etc/nginx/sites-available/psyclinicai
server {
    listen 80;
    server_name psyclinicai.com www.psyclinicai.com;
    
    # Redirect HTTP to HTTPS
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name psyclinicai.com www.psyclinicai.com;
    
    # SSL Configuration
    ssl_certificate /etc/letsencrypt/live/psyclinicai.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/psyclinicai.com/privkey.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES256-GCM-SHA384;
    ssl_prefer_server_ciphers off;
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;
    
    # Security Headers
    add_header X-Frame-Options DENY;
    add_header X-Content-Type-Options nosniff;
    add_header X-XSS-Protection "1; mode=block";
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    add_header Content-Security-Policy "default-src 'self'; script-src 'self' 'unsafe-inline' 'unsafe-eval'; style-src 'self' 'unsafe-inline';";
    
    # Rate Limiting
    limit_req_zone $binary_remote_addr zone=api:10m rate=10r/s;
    limit_req_zone $binary_remote_addr zone=login:10m rate=5r/m;
    
    # Client Max Body Size
    client_max_body_size 100M;
    
    # Gzip Compression
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_proxied any;
    gzip_comp_level 6;
    gzip_types
        text/plain
        text/css
        text/xml
        text/javascript
        application/json
        application/javascript
        application/xml+rss
        application/atom+xml
        image/svg+xml;
    
    # Main Application
    location / {
        proxy_pass http://localhost:8080;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
        proxy_read_timeout 300s;
        proxy_connect_timeout 75s;
    }
    
    # API Rate Limiting
    location /api/ {
        limit_req zone=api burst=20 nodelay;
        proxy_pass http://localhost:8080;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
    
    # Login Rate Limiting
    location /auth/login {
        limit_req zone=login burst=5 nodelay;
        proxy_pass http://localhost:8080;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
    
    # Static Files
    location /static/ {
        alias /var/www/psyclinicai/static/;
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
    
    # Health Check
    location /health {
        access_log off;
        return 200 "healthy\n";
        add_header Content-Type text/plain;
    }
    
    # Metrics (Protected)
    location /metrics {
        allow 127.0.0.1;
        allow 10.0.0.0/8;
        deny all;
        proxy_pass http://localhost:8080;
    }
}
```

### SSL Certificate Setup

#### **Let's Encrypt Configuration**
```bash
# Install Certbot
sudo apt install certbot python3-certbot-nginx

# Obtain SSL certificate
sudo certbot --nginx -d psyclinicai.com -d www.psyclinicai.com

# Test automatic renewal
sudo certbot renew --dry-run

# Set up automatic renewal
sudo crontab -e

# Add this line for automatic renewal
0 12 * * * /usr/bin/certbot renew --quiet
```

## 📊 Monitoring & Logging

### Prometheus Configuration

#### **Prometheus Config**
```yaml
# prometheus.yml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

rule_files:
  - "rules/*.yml"

alerting:
  alertmanagers:
    - static_configs:
        - targets:
          - alertmanager:9093

scrape_configs:
  - job_name: 'psyclinicai'
    static_configs:
      - targets: ['localhost:8080']
    metrics_path: '/metrics'
    scrape_interval: 5s
    
  - job_name: 'postgres'
    static_configs:
      - targets: ['localhost:9187']
      
  - job_name: 'redis'
    static_configs:
      - targets: ['localhost:9121']
      
  - job_name: 'nginx'
    static_configs:
      - targets: ['localhost:9113']
```

#### **Grafana Dashboard**
```json
{
  "dashboard": {
    "title": "PsyClinicAI Dashboard",
    "panels": [
      {
        "title": "Request Rate",
        "type": "graph",
        "targets": [
          {
            "expr": "rate(http_requests_total[5m])",
            "legendFormat": "{{method}} {{endpoint}}"
          }
        ]
      },
      {
        "title": "Response Time",
        "type": "graph",
        "targets": [
          {
            "expr": "histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m]))",
            "legendFormat": "95th percentile"
          }
        ]
      },
      {
        "title": "Error Rate",
        "type": "graph",
        "targets": [
          {
            "expr": "rate(http_requests_total{status=~\"5..\"}[5m])",
            "legendFormat": "5xx errors"
          }
        ]
      }
    ]
  }
}
```

### ELK Stack Configuration

#### **Logstash Pipeline**
```ruby
# logstash.conf
input {
  beats {
    port => 5044
  }
}

filter {
  if [fields][service] == "psyclinicai" {
    grok {
      match => { "message" => "%{TIMESTAMP_ISO8601:timestamp} %{LOGLEVEL:level} %{GREEDYDATA:message}" }
    }
    
    date {
      match => [ "timestamp", "ISO8601" ]
    }
    
    if [level] == "ERROR" {
      mutate {
        add_tag => [ "error" ]
      }
    }
  }
}

output {
  elasticsearch {
    hosts => ["elasticsearch:9200"]
    index => "psyclinicai-%{+YYYY.MM.dd}"
  }
}
```

## 🔐 Security Configuration

### Firewall Setup

#### **UFW Configuration**
```bash
# Install UFW
sudo apt install ufw

# Set default policies
sudo ufw default deny incoming
sudo ufw default allow outgoing

# Allow SSH
sudo ufw allow ssh

# Allow HTTP/HTTPS
sudo ufw allow 80
sudo ufw allow 443

# Allow application port (if not behind reverse proxy)
sudo ufw allow 8080

# Enable UFW
sudo ufw enable

# Check status
sudo ufw status verbose
```

#### **Fail2ban Configuration**
```bash
# Install Fail2ban
sudo apt install fail2ban

# Create configuration
sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local

# Edit configuration
sudo nano /etc/fail2ban/jail.local
```

**Fail2ban Config**:
```ini
[sshd]
enabled = true
port = ssh
filter = sshd
logpath = /var/log/auth.log
maxretry = 3
bantime = 3600
findtime = 600

[nginx-http-auth]
enabled = true
filter = nginx-http-auth
port = http,https
logpath = /var/log/nginx/error.log
maxretry = 3
bantime = 3600
findtime = 600
```

### Security Headers

#### **Security Middleware**
```dart
class SecurityMiddleware {
  static Map<String, String> getSecurityHeaders() {
    return {
      'X-Frame-Options': 'DENY',
      'X-Content-Type-Options': 'nosniff',
      'X-XSS-Protection': '1; mode=block',
      'Strict-Transport-Security': 'max-age=31536000; includeSubDomains',
      'Content-Security-Policy': "default-src 'self'; script-src 'self' 'unsafe-inline' 'unsafe-eval'; style-src 'self' 'unsafe-inline';",
      'Referrer-Policy': 'strict-origin-when-cross-origin',
      'Permissions-Policy': 'geolocation=(), microphone=(), camera=()',
    };
  }
}
```

## 💾 Backup & Recovery

### Database Backup

#### **Automated Backup Script**
```bash
#!/bin/bash
# backup-database.sh

set -e

# Configuration
BACKUP_DIR="/backups/database"
DB_NAME="psyclinicai"
DB_USER="psyclinicai"
DB_HOST="localhost"
RETENTION_DAYS=30

# Create backup directory
mkdir -p $BACKUP_DIR

# Generate backup filename
BACKUP_FILE="$BACKUP_DIR/psyclinicai_$(date +%Y%m%d_%H%M%S).sql"

# Create backup
pg_dump -h $DB_HOST -U $DB_USER -d $DB_NAME > $BACKUP_FILE

# Compress backup
gzip $BACKUP_FILE

# Remove old backups
find $BACKUP_DIR -name "*.sql.gz" -mtime +$RETENTION_DAYS -delete

echo "Database backup completed: $BACKUP_FILE.gz"
```

#### **Backup Cron Job**
```bash
# Add to crontab
sudo crontab -e

# Daily backup at 2 AM
0 2 * * * /path/to/backup-database.sh

# Weekly full backup on Sunday at 3 AM
0 3 * * 0 /path/to/backup-database-full.sh
```

### File Backup

#### **File Backup Script**
```bash
#!/bin/bash
# backup-files.sh

set -e

# Configuration
SOURCE_DIR="/var/www/psyclinicai"
BACKUP_DIR="/backups/files"
RETENTION_DAYS=7

# Create backup directory
mkdir -p $BACKUP_DIR

# Generate backup filename
BACKUP_FILE="$BACKUP_DIR/psyclinicai_files_$(date +%Y%m%d_%H%M%S).tar.gz"

# Create backup
tar -czf $BACKUP_FILE -C $SOURCE_DIR .

# Remove old backups
find $BACKUP_DIR -name "*.tar.gz" -mtime +$RETENTION_DAYS -delete

echo "File backup completed: $BACKUP_FILE"
```

### Recovery Procedures

#### **Database Recovery**
```bash
# Stop application
sudo systemctl stop psyclinicai

# Restore database
psql -h localhost -U psyclinicai -d psyclinicai < backup_file.sql

# Start application
sudo systemctl start psyclinicai

# Verify recovery
curl http://localhost:8080/health
```

#### **File Recovery**
```bash
# Stop application
sudo systemctl stop psyclinicai

# Restore files
tar -xzf backup_file.tar.gz -C /var/www/psyclinicai/

# Set permissions
sudo chown -R psyclinicai:psyclinicai /var/www/psyclinicai/
sudo chmod -R 755 /var/www/psyclinicai/

# Start application
sudo systemctl start psyclinicai
```

## 📈 Scaling & Performance

### Horizontal Scaling

#### **Load Balancer Configuration**
```nginx
# nginx.conf
upstream psyclinicai_backend {
    least_conn;
    server 192.168.1.10:8080 max_fails=3 fail_timeout=30s;
    server 192.168.1.11:8080 max_fails=3 fail_timeout=30s;
    server 192.168.1.12:8080 max_fails=3 fail_timeout=30s;
    keepalive 32;
}

server {
    listen 80;
    server_name psyclinicai.com;
    
    location / {
        proxy_pass http://psyclinicai_backend;
        proxy_http_version 1.1;
        proxy_set_header Connection "";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

#### **Docker Swarm Configuration**
```yaml
# docker-stack.yml
version: '3.8'

services:
  psyclinicai-app:
    image: psyclinicai:latest
    deploy:
      replicas: 3
      update_config:
        parallelism: 1
        delay: 10s
      restart_policy:
        condition: on-failure
    ports:
      - "8080:8080"
    environment:
      - DATABASE_URL=postgresql://psyclinicai:password@postgres:5432/psyclinicai
    networks:
      - psyclinicai-network

  postgres:
    image: postgres:15-alpine
    deploy:
      placement:
        constraints:
          - node.role == manager
    environment:
      - POSTGRES_DB=psyclinicai
      - POSTGRES_USER=psyclinicai
      - POSTGRES_PASSWORD=password
    volumes:
      - postgres_data:/var/lib/postgresql/data
    networks:
      - psyclinicai-network

volumes:
  postgres_data:

networks:
  psyclinicai-network:
    driver: overlay
```

### Performance Optimization

#### **Database Optimization**
```sql
-- Create indexes for common queries
CREATE INDEX idx_patients_email ON patients(email);
CREATE INDEX idx_sessions_patient_id ON sessions(patient_id);
CREATE INDEX idx_sessions_date ON sessions(session_date);

-- Partition large tables
CREATE TABLE sessions_partitioned (
    LIKE sessions INCLUDING ALL
) PARTITION BY RANGE (session_date);

-- Create partitions for each month
CREATE TABLE sessions_2024_01 PARTITION OF sessions_partitioned
    FOR VALUES FROM ('2024-01-01') TO ('2024-02-01');

-- Optimize queries
EXPLAIN ANALYZE SELECT * FROM patients WHERE email = 'test@example.com';
```

#### **Caching Strategy**
```dart
class CacheService {
  static final CacheService _instance = CacheService._internal();
  factory CacheService() => _instance;
  CacheService._internal();
  
  final Map<String, dynamic> _memoryCache = {};
  final Duration _defaultTTL = Duration(minutes: 30);
  
  Future<T?> get<T>(String key) async {
    // Check memory cache first
    if (_memoryCache.containsKey(key)) {
      final cached = _memoryCache[key];
      if (cached['expiresAt'].isAfter(DateTime.now())) {
        return cached['data'] as T;
      } else {
        _memoryCache.remove(key);
      }
    }
    
    // Check Redis cache
    final redis = RedisService();
    final cached = await redis.get(key);
    if (cached != null) {
      final data = json.decode(cached);
      _memoryCache[key] = {
        'data': data,
        'expiresAt': DateTime.now().add(_defaultTTL),
      };
      return data as T;
    }
    
    return null;
  }
  
  Future<void> set<T>(String key, T value, {Duration? ttl}) async {
    final expiresAt = DateTime.now().add(ttl ?? _defaultTTL);
    
    // Set in memory cache
    _memoryCache[key] = {
      'data': value,
      'expiresAt': expiresAt,
    };
    
    // Set in Redis cache
    final redis = RedisService();
    await redis.set(key, json.encode(value), ttl: ttl ?? _defaultTTL);
  }
}
```

## 🆘 Troubleshooting

### Common Issues

#### **Application Won't Start**
```bash
# Check application logs
docker-compose logs psyclinicai-app

# Check if ports are in use
sudo netstat -tlnp | grep :8080

# Check environment variables
docker-compose exec psyclinicai-app env

# Restart services
docker-compose restart
```

#### **Database Connection Issues**
```bash
# Check database status
docker-compose exec postgres pg_isready

# Check database logs
docker-compose logs postgres

# Test database connection
docker-compose exec psyclinicai-app psql $DATABASE_URL

# Check database configuration
docker-compose exec postgres cat /var/lib/postgresql/data/postgresql.conf
```

#### **Performance Issues**
```bash
# Check system resources
htop
df -h
free -h

# Check application metrics
curl http://localhost:8080/metrics

# Check database performance
docker-compose exec postgres psql -c "SELECT * FROM pg_stat_activity;"

# Check slow queries
docker-compose exec postgres psql -c "SELECT * FROM pg_stat_statements ORDER BY mean_time DESC LIMIT 10;"
```

### Debug Mode

#### **Enable Debug Logging**
```bash
# Set debug environment variable
export LOG_LEVEL=DEBUG

# Restart application
docker-compose restart psyclinicai-app

# Check debug logs
docker-compose logs -f psyclinicai-app
```

#### **Performance Profiling**
```bash
# Enable profiling
export ENABLE_PROFILING=true

# Restart application
docker-compose restart psyclinicai-app

# Access profiling data
curl http://localhost:8080/debug/pprof/
```

---

## 📞 Support & Resources

### Deployment Support
- **Documentation**: [docs.psyclinicai.com/deployment](https://docs.psyclinicai.com/deployment)
- **Community Forum**: [community.psyclinicai.com](https://community.psyclinicai.com)
- **GitHub Issues**: [github.com/psyclinicai/issues](https://github.com/psyclinicai/issues)
- **Email Support**: deployment-support@psyclinicai.com

### Additional Resources
- **Docker Documentation**: [docs.docker.com](https://docs.docker.com)
- **Nginx Documentation**: [nginx.org/en/docs](https://nginx.org/en/docs)
- **PostgreSQL Documentation**: [postgresql.org/docs](https://postgresql.org/docs)
- **Redis Documentation**: [redis.io/documentation](https://redis.io/documentation)

---

**Last Updated**: January 2024  
**Version**: 2.0.0  
**For**: DevOps Engineers & System Administrators  
**Maintained by**: PsyClinicAI Operations Team
