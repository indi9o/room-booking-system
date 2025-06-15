# 🚀 Production Deployment Guide

Panduan lengkap untuk deploy Room Booking System ke production environment dengan berbagai opsi deployment.

## 🎯 Deployment Options

### 🐳 Docker Deployment (Recommended)
- **Pros**: Isolated, reproducible, easy scaling
- **Use Case**: Most production environments
- **Complexity**: Low to Medium

### ☁️ Cloud Platform Deployment
- **Heroku**: Simple platform-as-a-service
- **DigitalOcean**: VPS with Docker
- **AWS/GCP/Azure**: Enterprise cloud solutions

### 🖥️ Traditional Server Deployment
- **Ubuntu/CentOS**: Direct installation on Linux
- **Use Case**: Legacy infrastructure or specific requirements

## 🐳 Docker Production Deployment

### Prerequisites
- **Server**: Linux VPS (Ubuntu 20.04+ recommended)
- **RAM**: 4GB minimum, 8GB recommended
- **CPU**: 2 cores minimum
- **Storage**: 20GB SSD
- **Domain**: Optional but recommended

### 1. Server Preparation

#### Update System
```bash
# Ubuntu/Debian
sudo apt update && sudo apt upgrade -y

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

#### Configure Firewall
```bash
# UFW (Ubuntu)
sudo ufw allow 22/tcp      # SSH
sudo ufw allow 80/tcp      # HTTP
sudo ufw allow 443/tcp     # HTTPS
sudo ufw --force enable

# Or iptables
sudo iptables -A INPUT -p tcp --dport 22 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 80 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 443 -j ACCEPT
```

### 2. Application Deployment

#### Clone Repository
```bash
# Create application directory
sudo mkdir -p /opt/room-booking
sudo chown $USER:$USER /opt/room-booking
cd /opt/room-booking

# Clone repository
git clone https://github.com/YOUR_USERNAME/room-booking-system.git .

# Or upload files via SCP/SFTP
```

#### Production Configuration
```bash
# Create production environment file
cat > .env.production << EOF
DEBUG=0
SECRET_KEY=your-super-secret-production-key-here
ALLOWED_HOSTS=your-domain.com,www.your-domain.com,localhost

# Database
DB_HOST=db
DB_NAME=room_usage_db
DB_USER=django_user
DB_PASSWORD=secure-production-password
DB_PORT=3306

# MySQL Root
MYSQL_ROOT_PASSWORD=super-secure-root-password

# Email (optional)
EMAIL_HOST=smtp.gmail.com
EMAIL_PORT=587
EMAIL_USE_TLS=True
EMAIL_HOST_USER=your-email@gmail.com
EMAIL_HOST_PASSWORD=your-app-password
EOF

# Secure environment file
chmod 600 .env.production
```

#### Production Docker Compose
```yaml
# docker-compose.prod.yml
version: '3.8'

services:
  db:
    image: mysql:8.0
    container_name: room_booking_db_prod
    restart: always
    environment:
      MYSQL_DATABASE: room_usage_db
      MYSQL_USER: django_user
      MYSQL_PASSWORD: ${DB_PASSWORD}
      MYSQL_ROOT_PASSWORD: ${MYSQL_ROOT_PASSWORD}
    volumes:
      - mysql_data_prod:/var/lib/mysql
    networks:
      - room_booking_network
    command: --default-authentication-plugin=mysql_native_password

  web:
    build: .
    container_name: room_booking_web_prod
    restart: always
    env_file: .env.production
    volumes:
      - static_volume:/code/staticfiles
      - media_volume:/code/media
    depends_on:
      - db
    networks:
      - room_booking_network

  nginx:
    image: nginx:alpine
    container_name: room_booking_nginx_prod
    restart: always
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx/nginx.conf:/etc/nginx/nginx.conf
      - ./nginx/sites-enabled:/etc/nginx/sites-enabled
      - static_volume:/code/staticfiles
      - media_volume:/code/media
      - ./ssl:/etc/nginx/ssl
    depends_on:
      - web
    networks:
      - room_booking_network

volumes:
  mysql_data_prod:
  static_volume:
  media_volume:

networks:
  room_booking_network:
    driver: bridge
```

### 3. Nginx Configuration

#### Create Nginx Config
```bash
# Create nginx directory
mkdir -p nginx/sites-enabled

# Main nginx config
cat > nginx/nginx.conf << 'EOF'
user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log warn;
pid /var/run/nginx.pid;

events {
    worker_connections 1024;
}

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;
    
    log_format main '$remote_addr - $remote_user [$time_local] "$request" '
                    '$status $body_bytes_sent "$http_referer" '
                    '"$http_user_agent" "$http_x_forwarded_for"';
    
    access_log /var/log/nginx/access.log main;
    
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    types_hash_max_size 2048;
    
    client_max_body_size 10M;
    
    gzip on;
    gzip_vary on;
    gzip_min_length 10240;
    gzip_proxied expired no-cache no-store private must-revalidate;
    gzip_types
        text/plain
        text/css
        text/xml
        text/javascript
        application/x-javascript
        application/xml+rss
        application/javascript;
    
    include /etc/nginx/sites-enabled/*;
}
EOF

# Site configuration
cat > nginx/sites-enabled/room-booking.conf << 'EOF'
upstream web {
    server web:8000;
}

server {
    listen 80;
    server_name your-domain.com www.your-domain.com;
    
    # Redirect HTTP to HTTPS
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name your-domain.com www.your-domain.com;
    
    # SSL Configuration
    ssl_certificate /etc/nginx/ssl/cert.pem;
    ssl_certificate_key /etc/nginx/ssl/key.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    
    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    
    # Static files
    location /static/ {
        alias /code/staticfiles/;
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
    
    # Media files
    location /media/ {
        alias /code/media/;
        expires 1y;
        add_header Cache-Control "public";
    }
    
    # Main application
    location / {
        proxy_pass http://web;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header Host $host;
        proxy_redirect off;
        
        # Timeouts
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }
}
EOF
```

### 4. SSL Certificate Setup

#### Let's Encrypt (Free SSL)
```bash
# Install certbot
sudo apt install certbot python3-certbot-nginx

# Get certificate (replace with your domain)
sudo certbot --nginx -d your-domain.com -d www.your-domain.com

# Auto-renewal
sudo crontab -e
# Add line:
0 12 * * * /usr/bin/certbot renew --quiet
```

#### Manual SSL Setup
```bash
# Create SSL directory
mkdir -p ssl

# Copy your SSL certificate files
cp your-certificate.crt ssl/cert.pem
cp your-private-key.key ssl/key.pem

# Set proper permissions
chmod 600 ssl/key.pem
chmod 644 ssl/cert.pem
```

### 5. Deploy Application

#### Start Services
```bash
# Build and start containers
docker-compose -f docker-compose.prod.yml up -d --build

# Check status
docker-compose -f docker-compose.prod.yml ps

# View logs
docker-compose -f docker-compose.prod.yml logs -f
```

#### Initialize Application
```bash
# Run migrations
docker-compose -f docker-compose.prod.yml exec web python manage.py migrate

# Collect static files
docker-compose -f docker-compose.prod.yml exec web python manage.py collectstatic --noinput

# Create superuser
docker-compose -f docker-compose.prod.yml exec web python manage.py createsuperuser

# Load sample data (optional)
docker-compose -f docker-compose.prod.yml exec web python manage.py load_sample_data
```

## ☁️ Cloud Platform Deployment

### Heroku Deployment

#### Prerequisites
```bash
# Install Heroku CLI
curl https://cli-assets.heroku.com/install.sh | sh

# Login to Heroku
heroku login
```

#### Prepare Application
```python
# Procfile
web: gunicorn room_usage_project.wsgi:application --bind 0.0.0.0:$PORT

# requirements.txt (add)
gunicorn==20.1.0
psycopg2==2.9.5
whitenoise==6.4.0
dj-database-url==1.3.0
```

#### Deploy to Heroku
```bash
# Create Heroku app
heroku create your-app-name

# Add PostgreSQL addon
heroku addons:create heroku-postgresql:hobby-dev

# Set environment variables
heroku config:set DEBUG=0
heroku config:set SECRET_KEY=your-secret-key
heroku config:set ALLOWED_HOSTS=your-app-name.herokuapp.com

# Deploy
git push heroku main

# Run migrations
heroku run python manage.py migrate

# Create superuser
heroku run python manage.py createsuperuser
```

### DigitalOcean Droplet

#### Create Droplet
1. **Choose**: Ubuntu 20.04 LTS
2. **Size**: 4GB RAM, 2 CPUs minimum
3. **Add**: SSH key for security
4. **Enable**: Monitoring and backups

#### Deploy with Docker
```bash
# Connect to droplet
ssh root@your-droplet-ip

# Follow Docker deployment steps above
# Configure domain and SSL
```

## 🔒 Security Hardening

### Server Security
```bash
# Disable root login
sudo sed -i 's/PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config

# Change SSH port (optional)
sudo sed -i 's/#Port 22/Port 2222/' /etc/ssh/sshd_config

# Restart SSH
sudo systemctl restart ssh

# Install fail2ban
sudo apt install fail2ban

# Configure fail2ban
sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
sudo systemctl enable fail2ban
sudo systemctl start fail2ban
```

### Application Security
```python
# settings.py production additions
SECURE_BROWSER_XSS_FILTER = True
SECURE_CONTENT_TYPE_NOSNIFF = True
SECURE_HSTS_SECONDS = 31536000
SECURE_HSTS_INCLUDE_SUBDOMAINS = True
SECURE_HSTS_PRELOAD = True
X_FRAME_OPTIONS = 'DENY'
SECURE_SSL_REDIRECT = True
SESSION_COOKIE_SECURE = True
CSRF_COOKIE_SECURE = True
```

## 📊 Monitoring & Maintenance

### Health Checks
```bash
# Application health check
curl -f http://localhost/health/ || exit 1

# Database health check
docker-compose -f docker-compose.prod.yml exec db mysql -u root -p$MYSQL_ROOT_PASSWORD -e "SELECT 1"

# Disk space check
df -h
```

### Log Management
```bash
# Rotate logs
sudo logrotate -f /etc/logrotate.conf

# View application logs
docker-compose -f docker-compose.prod.yml logs --tail=100 web

# Monitor real-time logs
docker-compose -f docker-compose.prod.yml logs -f
```

### Backup Strategy
```bash
# Database backup script
#!/bin/bash
BACKUP_DIR="/opt/backups"
DATE=$(date +%Y%m%d_%H%M%S)

# Create backup directory
mkdir -p $BACKUP_DIR

# Backup database
docker-compose -f docker-compose.prod.yml exec db mysqldump -u root -p$MYSQL_ROOT_PASSWORD room_usage_db > $BACKUP_DIR/db_backup_$DATE.sql

# Backup media files
tar -czf $BACKUP_DIR/media_backup_$DATE.tar.gz media/

# Keep only last 30 days of backups
find $BACKUP_DIR -name "*.sql" -mtime +30 -delete
find $BACKUP_DIR -name "*.tar.gz" -mtime +30 -delete
```

### Automated Backup Cron
```bash
# Add to crontab
crontab -e

# Daily backup at 2 AM
0 2 * * * /opt/room-booking/backup.sh

# Weekly restart (Sunday 3 AM)
0 3 * * 0 cd /opt/room-booking && docker-compose -f docker-compose.prod.yml restart
```

## 🚀 Scaling & Performance

### Horizontal Scaling
```yaml
# docker-compose.scale.yml
services:
  web:
    deploy:
      replicas: 3
    
  nginx:
    # Load balancer configuration
    volumes:
      - ./nginx/upstream.conf:/etc/nginx/conf.d/upstream.conf
```

### Performance Optimization
```python
# Django settings optimization
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.mysql',
        'OPTIONS': {
            'init_command': "SET sql_mode='STRICT_TRANS_TABLES'",
            'charset': 'utf8mb4',
        },
        'CONN_MAX_AGE': 600,  # Connection pooling
    }
}

# Cache configuration
CACHES = {
    'default': {
        'BACKEND': 'django.core.cache.backends.redis.RedisCache',
        'LOCATION': 'redis://redis:6379/1',
    }
}
```

## 🆘 Troubleshooting

### Common Issues
```bash
# Container won't start
docker-compose -f docker-compose.prod.yml logs web

# Database connection issues
docker-compose -f docker-compose.prod.yml exec web python manage.py check --database default

# SSL certificate issues
sudo certbot certificates
sudo nginx -t

# Performance issues
docker stats
htop
iotop
```

### Emergency Recovery
```bash
# Quick rollback
git checkout previous-stable-tag
docker-compose -f docker-compose.prod.yml up -d --build

# Database recovery
docker-compose -f docker-compose.prod.yml exec -i db mysql -u root -p$MYSQL_ROOT_PASSWORD room_usage_db < backup.sql
```

---

## ✅ Production Deployment Checklist

### Pre-Deployment
- [ ] Server meets requirements
- [ ] Domain configured with DNS
- [ ] SSL certificate ready
- [ ] Environment variables set
- [ ] Database backup strategy planned

### Deployment
- [ ] Application deployed successfully
- [ ] Database migrated and seeded
- [ ] Static files collected
- [ ] SSL/HTTPS working
- [ ] All services running

### Post-Deployment
- [ ] Health checks passing
- [ ] Monitoring configured
- [ ] Backup automation set up
- [ ] Security hardening applied
- [ ] Performance baseline established

---

## 🎉 Production Ready!

Your Room Booking System is now running in production with:
- ✅ **High availability** with Docker
- ✅ **Security hardening** applied
- ✅ **SSL encryption** enabled
- ✅ **Automated backups** configured
- ✅ **Monitoring** in place

**Next Steps:**
- Monitor application performance
- Set up alerting for issues
- Plan regular maintenance windows
- Consider implementing CI/CD pipeline

**🚀 Your production deployment is complete and ready to serve users!**
