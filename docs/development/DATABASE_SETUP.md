# 🗄️ Database Setup - SQLite vs MySQL dalam Docker

## 📋 **Current Database Configuration**

Room Booking System memiliki dual database setup:

### **Local Development (SQLite)**
```python
# settings.py - Local mode
DATABASES = {
    "default": {
        "ENGINE": "django.db.backends.sqlite3",
        "NAME": BASE_DIR / "db.sqlite3",
    }
}
```

### **Docker Production (MySQL)**
```python
# settings.py - Docker mode (DB_HOST=db)
DATABASES = {
    "default": {
        "ENGINE": "django.db.backends.mysql",
        "NAME": config('DB_NAME', default='room_usage_db'),
        "USER": config('DB_USER', default='django_user'),
        "PASSWORD": config('DB_PASSWORD', default='django_password'),
        "HOST": config('DB_HOST', default='localhost'),
        "PORT": config('DB_PORT', default='3306'),
    }
}
```

---

## 🎯 **Recommended: Docker-First Approach**

Untuk konsistensi dan production parity, gunakan **Docker dengan MySQL** untuk semua development:

### **1. Remove SQLite File (Optional)**
```bash
# SQLite tidak digunakan dalam Docker setup
rm db.sqlite3

# File sudah di .gitignore, jadi aman untuk dihapus
```

### **2. Always Use Docker Database**
```bash
# Start MySQL container
./tools/docker_django.sh up

# Run migrations di MySQL
./tools/docker_django.sh migrate

# Create superuser di MySQL
./tools/docker_django.sh createsuperuser
```

---

## 🔄 **Migration dari SQLite ke MySQL**

Jika Anda punya data di SQLite yang ingin migrate:

### **Step 1: Export Data dari SQLite**
```bash
# Backup current .env
cp .env .env.backup

# Set untuk SQLite mode (comment DB_HOST)
# .env: #DB_HOST=db

# Export data (Docker-only)
./tools/docker_django.sh exec "python manage.py dumpdata > data_backup.json"
```

### **Step 2: Import ke MySQL Docker**
```bash
# Restore Docker .env
cp .env.backup .env

# Start Docker
./tools/docker_django.sh up
./tools/docker_django.sh migrate

# Load data
./tools/docker_django.sh exec "python manage.py loaddata data_backup.json"
```

---

## 🛠️ **Database Management Tools**

### **MySQL dalam Docker:**
```bash
# Database shell
./tools/docker_django.sh dbshell

# Create backup
./tools/docker_django.sh dbbackup

# View database
./tools/docker_django.sh exec "python manage.py dbshell"
```

### **Database Persistent Storage:**
- Data MySQL disimpan di Docker volume `mysql_data`
- Data persistent meskipun container di-restart
- Volume di-manage otomatis oleh Docker Compose

---

## ⚙️ **Environment Configuration**

### **Current .env for Docker:**
```bash
# Docker MySQL mode
DB_HOST=db
DB_NAME=room_usage_db
DB_USER=django_user
DB_PASSWORD=django_password
```

### **For Local SQLite (if needed):**
```bash
# Local SQLite mode
#DB_HOST=db  # Comment out this line
DB_NAME=room_usage_db
DB_USER=django_user
DB_PASSWORD=django_password
```

---

## 🎯 **Recommendations**

### **For Production-Ready Development:**
1. ✅ **Use Docker MySQL** - Consistent dengan production
2. ✅ **Remove db.sqlite3** - Clean up unused files
3. ✅ **All development via Docker** - Consistent environment

### **For Backward Compatibility:**
1. ✅ **Keep dual setup** - Support both SQLite dan MySQL
2. ✅ **Keep db.sqlite3 in .gitignore** - Don't commit database files
3. ✅ **Document switching process** - Clear instructions

---

## 🚀 **Quick Decision Guide**

**Choose Docker MySQL if:**
- ✅ Production consistency important
- ✅ Team collaboration 
- ✅ CI/CD deployment
- ✅ Scaling considerations

**Choose SQLite if:**
- ✅ Quick local testing
- ✅ Offline development
- ✅ Simple prototyping
- ✅ No Docker available

**Recommended:** Use Docker MySQL untuk semua development work.
