# 🔧 Environment Management Guide

## 📋 **Multiple Environment Files Overview**

Room Booking System menggunakan multiple environment files untuk mengelola konfigurasi yang berbeda untuk setiap environment.

---

## 📁 **Environment Files Structure**

```
room-booking-system/
├── .env                    # Active environment (gitignored)
├── .env.example           # Template lengkap dengan dokumentasi
├── .env.development       # Development configuration
├── .env.production        # Production configuration (secure)
├── .env.test              # Testing configuration
├── .env.backup*           # Backup files (gitignored)
└── tools/env_manager.sh   # Environment management tool
```

---

## 🛠️ **Environment Manager Tool**

### **Quick Commands:**
```bash
# List all available environments
./tools/env_manager.sh list

# Switch environments
./tools/env_manager.sh use development
./tools/env_manager.sh use production
./tools/env_manager.sh use test

# Validate configuration
./tools/env_manager.sh validate current
./tools/env_manager.sh validate production

# Show environment content
./tools/env_manager.sh show current
./tools/env_manager.sh show production

# Compare environments
./tools/env_manager.sh diff development production

# Backup & restore
./tools/env_manager.sh backup
./tools/env_manager.sh restore
```

---

## 🌍 **Environment Descriptions**

### **1. Development (.env.development)**
- **Purpose**: Local development dengan Docker
- **Database**: Docker MySQL (`DB_HOST=db`)
- **Debug**: Enabled (`DEBUG=1`)
- **Security**: Relaxed settings
- **Email**: Console backend
- **Logging**: Verbose (`DEBUG` level)
- **Features**: All enabled, debug toolbar

**Usage:**
```bash
./tools/env_manager.sh use development
./tools/docker_django.sh up
```

### **2. Production (.env.production)**
- **Purpose**: Production deployment
- **Database**: Production MySQL
- **Debug**: Disabled (`DEBUG=0`)
- **Security**: Strict HTTPS, HSTS, secure cookies
- **Email**: SMTP backend
- **Logging**: Minimal (`WARNING` level)
- **Features**: Optimized for performance

**Usage:**
```bash
./tools/env_manager.sh use production
# ⚠️ Change all default passwords before deployment
```

### **3. Test (.env.test)**
- **Purpose**: Automated testing & CI/CD
- **Database**: Test database (fast)
- **Debug**: Disabled for test accuracy
- **Security**: Minimal for speed
- **Email**: Console backend
- **Logging**: Error only
- **Features**: Essential features only

**Usage:**
```bash
./tools/env_manager.sh use test
./tools/docker_django.sh test
```

### **4. Template (.env.example)**
- **Purpose**: Template dengan semua opsi konfigurasi
- **Usage**: Base untuk membuat environment baru
- **Documentation**: Lengkap dengan comments

---

## 📊 **Configuration Comparison**

| Setting | Development | Production | Test |
|---------|-------------|------------|------|
| **DEBUG** | `1` | `0` | `0` |
| **SECRET_KEY** | Dev key | Secure random | Test key |
| **DB_HOST** | `db` | `db` | `127.0.0.1` |
| **LOG_LEVEL** | `DEBUG` | `WARNING` | `ERROR` |
| **EMAIL_BACKEND** | Console | SMTP | Console |
| **SECURITY** | Relaxed | Strict | Minimal |
| **CACHE** | Local memory | Redis | Memory |
| **SSL** | Disabled | Enabled | Disabled |

---

## 🔄 **Workflow Examples**

### **Development Workflow:**
```bash
# 1. Use development environment
./tools/env_manager.sh use development

# 2. Start development
./tools/start_app.sh

# 3. Validate configuration
./tools/env_manager.sh validate current
```

### **Production Deployment:**
```bash
# 1. Switch to production
./tools/env_manager.sh use production

# 2. Customize secure values
nano .env

# 3. Validate before deploy
./tools/env_manager.sh validate current

# 4. Deploy
./tools/docker_django.sh up --build
```

### **Testing Setup:**
```bash
# 1. Switch to test environment
./tools/env_manager.sh use test

# 2. Run tests
./tools/docker_django.sh test

# 3. Switch back to development
./tools/env_manager.sh use development
```

---

## 🔒 **Security Guidelines**

### **Development Security:**
- ✅ Use default passwords (safe for local development)
- ✅ DEBUG enabled for easier debugging
- ✅ Console email backend
- ⚠️ Never commit `.env` with real credentials

### **Production Security:**
- ✅ **MUST** change all default passwords
- ✅ **MUST** use secure SECRET_KEY (50+ characters)
- ✅ **MUST** configure proper ALLOWED_HOSTS
- ✅ **MUST** enable HTTPS settings
- ✅ **MUST** use encrypted email credentials
- ❌ Never use DEBUG=1 in production

### **Security Checklist:**
```bash
# Before production deployment
./tools/env_manager.sh validate production

# Check for default values
grep -E "(default|example|test|dev)" .env

# Ensure strong passwords
grep -E "(password|secret)" .env
```

---

## 🎯 **Best Practices**

### **1. Environment Switching:**
```bash
# Always validate after switching
./tools/env_manager.sh use production
./tools/env_manager.sh validate current

# Restart Docker after switching
./tools/docker_django.sh restart
```

### **2. Backup Management:**
```bash
# Backup before major changes
./tools/env_manager.sh backup

# Auto-backup when switching
# (done automatically by env_manager.sh)
```

### **3. Version Control:**
- ✅ Commit environment templates (`.env.development`, `.env.production`, `.env.test`)
- ❌ Never commit active `.env` file
- ❌ Never commit files with real credentials
- ✅ Use `.env.example` for documentation

### **4. Team Collaboration:**
```bash
# Team member setup
cp .env.development .env
./tools/env_manager.sh validate current
./tools/docker_django.sh up
```

---

## 🚨 **Troubleshooting**

### **Common Issues:**

**1. Missing environment file:**
```bash
./tools/env_manager.sh create custom
# Edit the new .env.custom file
./tools/env_manager.sh use custom
```

**2. Configuration validation errors:**
```bash
./tools/env_manager.sh validate current
# Fix reported issues
./tools/docker_django.sh restart
```

**3. Database connection issues:**
```bash
# Check database configuration
./tools/env_manager.sh show current | grep DB_

# Switch to known working environment
./tools/env_manager.sh use development
```

**4. Permission issues:**
```bash
# Fix permissions
chmod +x tools/env_manager.sh
chown -R $USER:$USER .env*
```

---

## 📖 **Related Documentation**

- **[Docker Setup](DOCKER_SETUP.md)** - Docker configuration
- **[Development Tools](tools.md)** - Development utilities
- **[Database Setup](DATABASE_SETUP.md)** - Database configuration
- **[Production Deployment](../deployment/production.md)** - Production setup

---

**💡 Pro Tip**: Always use `./tools/env_manager.sh validate` before deployment to ensure configuration is correct!
