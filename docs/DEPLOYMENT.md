# 🚀 Deployment Guide

> **📍 Navigation**: [📋 Documentation Index](README.md) | [🔒 Security Guide](SECURITY.md) | [📈 Performance Guide](PERFORMANCE.md)

Panduan lengkap untuk deploy Room Booking System ke berbagai environment.

## 🌐 Deployment Options

### 1. 🐳 Docker Compose (Recommended)
### 2. ☁️ Cloud Platforms
### 3. 🖥️ VPS/Dedicated Server
### 4. 🏗️ Kubernetes

---

## 🐳 Docker Compose Deployment

### Quick Deploy
```bash
# Clone repository
git clone https://github.com/YOUR_USERNAME/room-booking-system.git
cd room-booking-system

# Configure environment
cp .env.example .env
nano .env

# Deploy
chmod +x start.sh
./start.sh
```

### Manual Deploy
```bash
# Build and start services
docker-compose up -d --build

# Check status
docker-compose ps

# View logs
docker-compose logs -f
```

### Production Configuration
```yaml
# docker-compose.prod.yml
version: '3.8'

services:
  web:
    build: .
    restart: unless-stopped
    environment:
      - DEBUG=False
      - ALLOWED_HOSTS=yourdomain.com
    volumes:
      - static_volume:/app/staticfiles
      - media_volume:/app/media
    depends_on:
      - db
    networks:
      - internal

  db:
    image: mysql:8.0
    restart: unless-stopped
    environment:
      MYSQL_DATABASE: ${DB_NAME}
      MYSQL_USER: ${DB_USER}
      MYSQL_PASSWORD: ${DB_PASSWORD}
      MYSQL_ROOT_PASSWORD: ${MYSQL_ROOT_PASSWORD}
    volumes:
      - mysql_data:/var/lib/mysql
    networks:
      - internal

  nginx:
    image: nginx:alpine
    restart: unless-stopped
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf
      - static_volume:/app/staticfiles
      - media_volume:/app/media
      - ./ssl:/etc/nginx/ssl
    depends_on:
      - web
    networks:
      - internal

volumes:
  mysql_data:
  static_volume:
  media_volume:

networks:
  internal:
    driver: bridge
```

---

## ☁️ Cloud Platform Deployment

### AWS EC2

#### 1. Launch EC2 Instance
```bash
# Choose Ubuntu 22.04 LTS
# Instance type: t3.medium (2 vCPU, 4GB RAM)
# Security Group: HTTP (80), HTTPS (443), SSH (22)
```

#### 2. Install Dependencies
```bash
# Connect to instance
ssh -i your-key.pem ubuntu@your-ec2-ip

# Update system
sudo apt update && sudo apt upgrade -y

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker ubuntu

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

#### 3. Deploy Application
```bash
# Clone repository
git clone https://github.com/YOUR_USERNAME/room-booking-system.git
cd room-booking-system

# Configure environment
cp .env.example .env
nano .env

# Set production values
export DEBUG=False
export ALLOWED_HOSTS=your-ec2-public-dns.amazonaws.com

# Deploy
./start.sh
```

#### 4. Setup Domain & SSL
```bash
# Install Certbot
sudo apt install certbot

# Get SSL certificate
sudo certbot certonly --standalone -d yourdomain.com

# Update nginx configuration
# Add SSL configuration to nginx.conf
```

### Google Cloud Platform

#### 1. Create VM Instance
```bash
# Using gcloud CLI
gcloud compute instances create room-booking-vm \
  --image-family=ubuntu-2204-lts \
  --image-project=ubuntu-os-cloud \
  --machine-type=e2-medium \
  --tags=http-server,https-server
```

#### 2. Configure Firewall
```bash
# Allow HTTP/HTTPS traffic
gcloud compute firewall-rules create allow-http-https \
  --allow tcp:80,tcp:443 \
  --source-ranges 0.0.0.0/0 \
  --target-tags http-server,https-server
```

#### 3. Deploy Application
```bash
# SSH to instance
gcloud compute ssh room-booking-vm

# Follow same steps as AWS EC2
```

### DigitalOcean Droplet

#### 1. Create Droplet
- Choose Ubuntu 22.04 LTS
- Size: 2GB RAM, 1 vCPU ($12/month)
- Add your SSH key

#### 2. Deploy with Docker
```bash
# SSH to droplet
ssh root@your-droplet-ip

# Install Docker (one-click app available)
# Or follow manual installation steps

# Deploy application
git clone https://github.com/YOUR_USERNAME/room-booking-system.git
cd room-booking-system
./start.sh
```

---

## 🖥️ VPS/Dedicated Server

### Ubuntu 22.04 Setup

#### 1. System Preparation
```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install required packages
sudo apt install -y curl git ufw fail2ban

# Configure firewall
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw allow 80
sudo ufw allow 443
sudo ufw enable
```

#### 2. Install Docker
```bash
# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Add user to docker group
sudo usermod -aG docker $USER
newgrp docker
```

#### 3. Deploy Application
```bash
# Clone and configure
git clone https://github.com/YOUR_USERNAME/room-booking-system.git
cd room-booking-system

# Production environment
cp .env.example .env
nano .env

# Deploy
./start.sh
```

#### 4. Setup Nginx Reverse Proxy
```bash
# Install Nginx
sudo apt install nginx

# Configure Nginx
sudo nano /etc/nginx/sites-available/room-booking
```

```nginx
# /etc/nginx/sites-available/room-booking
server {
    listen 80;
    server_name yourdomain.com www.yourdomain.com;

    location / {
        proxy_pass http://localhost:8001;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    location /static/ {
        alias /path/to/room-booking-system/staticfiles/;
    }

    location /media/ {
        alias /path/to/room-booking-system/media/;
    }
}
```

```bash
# Enable site
sudo ln -s /etc/nginx/sites-available/room-booking /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
```

#### 5. SSL with Let's Encrypt
```bash
# Install Certbot
sudo apt install certbot python3-certbot-nginx

# Get certificate
sudo certbot --nginx -d yourdomain.com -d www.yourdomain.com

# Auto-renewal
echo "0 12 * * * /usr/bin/certbot renew --quiet" | sudo crontab -
```

---

## 🏗️ Kubernetes Deployment

### Prerequisites
- Kubernetes cluster (minikube, GKE, EKS, AKS)
- kubectl configured
- Docker registry access

### 1. Build and Push Image
```bash
# Build image
docker build -t your-registry/room-booking-system:latest .

# Push to registry
docker push your-registry/room-booking-system:latest
```

### 2. Create Kubernetes Manifests

#### Namespace
```yaml
# k8s/namespace.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: room-booking
```

#### ConfigMap
```yaml
# k8s/configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: room-booking-config
  namespace: room-booking
data:
  DEBUG: "False"
  ALLOWED_HOSTS: "yourdomain.com,www.yourdomain.com"
  DB_HOST: "mysql-service"
  DB_NAME: "room_usage_db"
  DB_PORT: "3306"
```

#### Secret
```yaml
# k8s/secret.yaml
apiVersion: v1
kind: Secret
metadata:
  name: room-booking-secret
  namespace: room-booking
type: Opaque
data:
  SECRET_KEY: <base64-encoded-secret>
  DB_PASSWORD: <base64-encoded-password>
  MYSQL_ROOT_PASSWORD: <base64-encoded-password>
```

#### MySQL Deployment
```yaml
# k8s/mysql-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mysql
  namespace: room-booking
spec:
  replicas: 1
  selector:
    matchLabels:
      app: mysql
  template:
    metadata:
      labels:
        app: mysql
    spec:
      containers:
      - name: mysql
        image: mysql:8.0
        env:
        - name: MYSQL_ROOT_PASSWORD
          valueFrom:
            secretKeyRef:
              name: room-booking-secret
              key: MYSQL_ROOT_PASSWORD
        - name: MYSQL_DATABASE
          valueFrom:
            configMapKeyRef:
              name: room-booking-config
              key: DB_NAME
        ports:
        - containerPort: 3306
        volumeMounts:
        - name: mysql-storage
          mountPath: /var/lib/mysql
      volumes:
      - name: mysql-storage
        persistentVolumeClaim:
          claimName: mysql-pvc
---
apiVersion: v1
kind: Service
metadata:
  name: mysql-service
  namespace: room-booking
spec:
  selector:
    app: mysql
  ports:
  - port: 3306
    targetPort: 3306
```

#### App Deployment
```yaml
# k8s/app-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: room-booking-app
  namespace: room-booking
spec:
  replicas: 3
  selector:
    matchLabels:
      app: room-booking-app
  template:
    metadata:
      labels:
        app: room-booking-app
    spec:
      containers:
      - name: room-booking
        image: your-registry/room-booking-system:latest
        ports:
        - containerPort: 8000
        envFrom:
        - configMapRef:
            name: room-booking-config
        env:
        - name: SECRET_KEY
          valueFrom:
            secretKeyRef:
              name: room-booking-secret
              key: SECRET_KEY
        - name: DB_PASSWORD
          valueFrom:
            secretKeyRef:
              name: room-booking-secret
              key: DB_PASSWORD
        livenessProbe:
          httpGet:
            path: /health/
            port: 8000
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /health/
            port: 8000
          initialDelaySeconds: 5
          periodSeconds: 5
---
apiVersion: v1
kind: Service
metadata:
  name: room-booking-service
  namespace: room-booking
spec:
  selector:
    app: room-booking-app
  ports:
  - port: 80
    targetPort: 8000
  type: ClusterIP
```

#### Ingress
```yaml
# k8s/ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: room-booking-ingress
  namespace: room-booking
  annotations:
    kubernetes.io/ingress.class: nginx
    cert-manager.io/cluster-issuer: letsencrypt-prod
spec:
  tls:
  - hosts:
    - yourdomain.com
    secretName: room-booking-tls
  rules:
  - host: yourdomain.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: room-booking-service
            port:
              number: 80
```

### 3. Deploy to Kubernetes
```bash
# Apply manifests
kubectl apply -f k8s/

# Check deployment
kubectl get pods -n room-booking
kubectl get services -n room-booking

# View logs
kubectl logs -f deployment/room-booking-app -n room-booking
```

---

## 🔧 Production Optimizations

### Performance Tuning

#### 1. Gunicorn Configuration
```python
# gunicorn.conf.py
bind = "0.0.0.0:8000"
workers = 4
worker_class = "gevent"
worker_connections = 1000
max_requests = 1000
max_requests_jitter = 100
timeout = 30
keepalive = 5
```

#### 2. Database Optimization
```sql
-- MySQL optimizations
SET innodb_buffer_pool_size = 1G;
SET query_cache_size = 256M;
SET max_connections = 100;
```

#### 3. Redis Caching
```yaml
# Add Redis to docker-compose.yml
redis:
  image: redis:7-alpine
  restart: unless-stopped
  networks:
    - internal
```

```python
# settings.py
CACHES = {
    'default': {
        'BACKEND': 'django_redis.cache.RedisCache',
        'LOCATION': 'redis://redis:6379/1',
        'OPTIONS': {
            'CLIENT_CLASS': 'django_redis.client.DefaultClient',
        }
    }
}
```

### Security Hardening

#### 1. Environment Security
```bash
# Set file permissions
chmod 600 .env
chown root:root .env

# Secure Docker daemon
echo '{"live-restore": true, "userland-proxy": false}' | sudo tee /etc/docker/daemon.json
sudo systemctl restart docker
```

#### 2. Network Security
```bash
# Configure fail2ban
sudo nano /etc/fail2ban/jail.local
```

```ini
[DEFAULT]
bantime = 3600
findtime = 600
maxretry = 5

[sshd]
enabled = true

[nginx-http-auth]
enabled = true
```

### Monitoring & Logging

#### 1. Application Monitoring
```yaml
# Add to docker-compose.yml
prometheus:
  image: prom/prometheus
  volumes:
    - ./prometheus.yml:/etc/prometheus/prometheus.yml

grafana:
  image: grafana/grafana
  environment:
    - GF_SECURITY_ADMIN_PASSWORD=admin
  ports:
    - "3000:3000"
```

#### 2. Log Management
```python
# settings.py
LOGGING = {
    'version': 1,
    'disable_existing_loggers': False,
    'formatters': {
        'verbose': {
            'format': '{levelname} {asctime} {module} {process:d} {thread:d} {message}',
            'style': '{',
        },
    },
    'handlers': {
        'file': {
            'level': 'INFO',
            'class': 'logging.handlers.RotatingFileHandler',
            'filename': '/var/log/django/app.log',
            'maxBytes': 1024*1024*15,  # 15MB
            'backupCount': 10,
            'formatter': 'verbose',
        },
    },
    'root': {
        'handlers': ['file'],
        'level': 'INFO',
    },
}
```

---

## 📊 Deployment Checklist

### Pre-deployment
- [ ] Environment variables configured
- [ ] Database credentials secure
- [ ] Secret key generated
- [ ] ALLOWED_HOSTS set correctly
- [ ] DEBUG=False in production
- [ ] Static files configured
- [ ] Media files path set
- [ ] Email configuration (if needed)
- [ ] Backup strategy planned

### During Deployment
- [ ] Build successful
- [ ] Containers starting properly
- [ ] Database migrations applied
- [ ] Static files collected
- [ ] Health checks passing
- [ ] Logs showing no errors

### Post-deployment
- [ ] Application accessible
- [ ] Admin panel working
- [ ] User registration working
- [ ] Booking system functional
- [ ] Email notifications working
- [ ] SSL certificate installed
- [ ] Monitoring configured
- [ ] Backup system tested
- [ ] Performance tested
- [ ] Security scan completed

---

**🚀 Deployment Guide - Room Booking System**

Choose the deployment option that best fits your needs and infrastructure requirements.
