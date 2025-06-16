# 🔗 Keterkaitan .env dan Docker Compose

> Panduan lengkap integrasi file environment (.env) dengan Docker Compose dalam Room Booking System

## 📋 Overview

File `.env` dan `docker-compose.yml` bekerja sama untuk mengelola konfigurasi aplikasi yang fleksibel dan aman. Integrasi ini memungkinkan:

- **Konfigurasi Terpusat**: Satu tempat untuk semua environment variables
- **Keamanan**: Sensitive data tidak hardcoded di kode
- **Fleksibilitas**: Mudah switch antara development, testing, dan production
- **Konsistensi**: Konfigurasi yang sama di berbagai environment

---

## 🏗️ Arsitektur Saat Ini

### 📁 Struktur File
```
room-booking-system/
├── docker-compose.yml      # 🐳 Container orchestration
├── .env.example            # 📋 Template environment variables
├── .env                    # 🔒 Actual environment (gitignored)
└── room_usage_project/
    └── settings.py         # ⚙️ Django configuration
```

### 🔄 Flow Konfigurasi
```
.env file → Docker Compose → Container Environment → Django Settings
```

---

## 📊 Analisis Current State

### 🐳 **Docker Compose Configuration**
```yaml
# Current docker-compose.yml
services:
  db:
    environment:
      MYSQL_DATABASE: room_usage_db        # ❌ Hardcoded
      MYSQL_USER: django_user             # ❌ Hardcoded
      MYSQL_PASSWORD: django_password     # ❌ Hardcoded
      MYSQL_ROOT_PASSWORD: root_password  # ❌ Hardcoded
  
  web:
    environment:
      - DEBUG=1                           # ❌ Hardcoded
      - DB_HOST=db                        # ✅ Dynamic
      - DB_NAME=room_usage_db             # ❌ Hardcoded
      - DB_USER=django_user               # ❌ Hardcoded
      - DB_PASSWORD=django_password       # ❌ Hardcoded
```

### 🔧 **Django Settings Integration**
```python
# Current settings.py
from decouple import config

SECRET_KEY = config('SECRET_KEY', default="...")     # ✅ Uses .env
DEBUG = config('DEBUG', default=True, cast=bool)    # ✅ Uses .env

# Database configuration
if config('DB_HOST', default='') == 'db':           # ✅ Uses .env
    DATABASES = {
        'default': {
            'ENGINE': 'django.db.backends.mysql',
            'NAME': config('DB_NAME', default='room_usage_db'),      # ✅ Uses .env
            'USER': config('DB_USER', default='django_user'),        # ✅ Uses .env
            'PASSWORD': config('DB_PASSWORD', default='django_password'), # ✅ Uses .env
            'HOST': config('DB_HOST', default='localhost'),          # ✅ Uses .env
            'PORT': config('DB_PORT', default='3306'),               # ✅ Uses .env
        }
    }
```

---

## ⚠️ **MASALAH YANG DITEMUKAN**

### 🔴 **1. Inconsistent Configuration**
- Docker Compose menggunakan hardcoded values
- Django Settings menggunakan .env variables
- Tidak ada sinkronisasi antara keduanya

### 🔴 **2. Security Issues**
- Passwords ter-expose di docker-compose.yml
- Tidak ada separation antara development dan production config

### 🔴 **3. Maintenance Problems**
- Perubahan config harus dilakukan di 2 tempat
- Risk inconsistency antara environments

---

## ✅ **SOLUSI YANG DIREKOMENDASIKAN**

### 🎯 **Improved Docker Compose**
```yaml
# Recommended docker-compose.yml
version: '3.8'

services:
  db:
    image: mysql:8.0
    container_name: room_usage_db
    restart: always
    environment:
      MYSQL_DATABASE: ${DB_NAME}
      MYSQL_USER: ${DB_USER}
      MYSQL_PASSWORD: ${DB_PASSWORD}
      MYSQL_ROOT_PASSWORD: ${MYSQL_ROOT_PASSWORD}
    ports:
      - "${DB_PORT}:3306"
    volumes:
      - mysql_data:/var/lib/mysql
    command: --default-authentication-plugin=mysql_native_password
    env_file:
      - .env

  web:
    build: .
    container_name: room_usage_web
    command: ./docker-entrypoint.sh
    volumes:
      - .:/code
    ports:
      - "${WEB_PORT}:8000"
    depends_on:
      - db
    env_file:
      - .env
    environment:
      - DB_HOST=db

volumes:
  mysql_data:
```

### 🎯 **Complete .env Template**
```bash
# .env.example (Recommended)

# ===========================================
# CORE APPLICATION SETTINGS
# ===========================================
DEBUG=1
SECRET_KEY=your-secret-key-here
ALLOWED_HOSTS=localhost,127.0.0.1,0.0.0.0

# ===========================================
# DATABASE CONFIGURATION
# ===========================================
DB_ENGINE=django.db.backends.mysql
DB_NAME=room_usage_db
DB_USER=django_user
DB_PASSWORD=django_password
DB_HOST=localhost
DB_PORT=3306

# ===========================================
# MYSQL DOCKER CONFIGURATION
# ===========================================
MYSQL_ROOT_PASSWORD=root_password
MYSQL_DATABASE=${DB_NAME}
MYSQL_USER=${DB_USER}
MYSQL_PASSWORD=${DB_PASSWORD}

# ===========================================
# DOCKER PORTS
# ===========================================
WEB_PORT=8001
DB_PORT=3306

# ===========================================
# EMAIL CONFIGURATION
# ===========================================
EMAIL_BACKEND=django.core.mail.backends.console.EmailBackend
EMAIL_HOST=smtp.gmail.com
EMAIL_PORT=587
EMAIL_USE_TLS=True
EMAIL_HOST_USER=
EMAIL_HOST_PASSWORD=

# ===========================================
# STATIC & MEDIA FILES
# ===========================================
STATIC_URL=/static/
MEDIA_URL=/media/
STATIC_ROOT=staticfiles
MEDIA_ROOT=media

# ===========================================
# SECURITY SETTINGS
# ===========================================
SECURE_SSL_REDIRECT=False
SECURE_HSTS_SECONDS=0
SESSION_COOKIE_SECURE=False
CSRF_COOKIE_SECURE=False

# ===========================================
# LOGGING & MONITORING
# ===========================================
LOG_LEVEL=DEBUG
SENTRY_DSN=

# ===========================================
# EXTERNAL SERVICES
# ===========================================
REDIS_URL=redis://localhost:6379/0
```

---

## 🚀 **IMPLEMENTATION STEPS**

### **Step 1: Update Docker Compose**
1. Replace hardcoded values dengan environment variables
2. Add `env_file: - .env` directive
3. Use `${VARIABLE}` syntax untuk references

### **Step 2: Create Complete .env**
1. Copy dari `.env.example`
2. Fill actual values untuk local development
3. Ensure `.env` is gitignored

### **Step 3: Update Django Settings**
1. Remove defaults yang tidak diperlukan
2. Add validation untuk required environment variables
3. Add environment-specific configurations

### **Step 4: Create Environment Variants**
```
.env.development    # Local development
.env.testing       # Testing environment  
.env.staging       # Staging environment
.env.production    # Production environment
```

---

## 🎯 **BEST PRACTICES**

### 🔒 **Security**
- ✅ Never commit `.env` files dengan actual credentials
- ✅ Use different passwords untuk setiap environment
- ✅ Rotate secrets regularly
- ✅ Use secrets management untuk production

### 🏗️ **Structure**
- ✅ Group variables by functionality
- ✅ Use consistent naming conventions
- ✅ Add comments untuk complex configurations
- ✅ Provide meaningful defaults

### 🔄 **Maintenance**
- ✅ Keep `.env.example` updated
- ✅ Document all variables
- ✅ Validate required variables
- ✅ Use type casting where appropriate

---

## 📋 **CHECKLIST IMPLEMENTATION**

### Phase 1: Basic Integration
- [ ] Update docker-compose.yml dengan env variables
- [ ] Create comprehensive .env.example
- [ ] Update documentation
- [ ] Test local development environment

### Phase 2: Enhanced Configuration
- [ ] Add environment validation
- [ ] Create environment-specific configs
- [ ] Implement secrets management
- [ ] Add configuration testing

### Phase 3: Production Ready
- [ ] Setup CI/CD environment handling
- [ ] Implement secrets rotation
- [ ] Add monitoring configurations
- [ ] Create deployment automation

---

## 🔍 **CURRENT VS IMPROVED**

| Aspek | Current State | Improved State |
|-------|---------------|----------------|
| **Configuration** | Split between docker-compose & .env | Unified in .env |
| **Security** | Passwords in docker-compose | All secrets in .env |
| **Maintenance** | Manual sync required | Single source of truth |
| **Flexibility** | Limited environment support | Multiple environment configs |
| **Documentation** | Basic .env.example | Comprehensive templates |

---

## 🛠️ **Quick Implementation**

Untuk implementasi cepat, jalankan:

```bash
# 1. Backup current config
cp docker-compose.yml docker-compose.yml.backup

# 2. Create .env from example
cp .env.example .env

# 3. Edit .env dengan values yang sesuai
nano .env

# 4. Update docker-compose.yml
# (gunakan improved version di atas)

# 5. Test the integration
docker-compose down
docker-compose up --build
```

---

**💡 Pro Tip**: Implementasi bertahap lebih aman. Mulai dengan environment variables yang non-critical, lalu gradually migrate semua configurations.

*Untuk implementasi lengkap, lihat [Docker Guide](../setup/DOCKER.md) dan [Development Setup](../development/DEV_SETUP.md).*
