# 🏢 Room Booking System

Sistem pemesanan ruangan berbasis web yang dibangun dengan Django, MySQL, dan Docker. Aplikasi ini memungkinkan pengguna untuk memesan ruangan secara online dengan sistem persetujuan admin.

![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)
![Django](https://img.shields.io/badge/Django-4.2.7-green.svg)
![Python](https://img.shields.io/badge/Python-3.11+-blue.svg)
![Docker](https://img.shields.io/badge/Docker-Compose-2496ED.svg)
![MySQL](https://img.shields.io/badge/MySQL-8.0-orange.svg)

## 🌟 Fitur Utama

- ✅ **Manajemen Ruangan**: CRUD ruangan dengan informasi lengkap
- 📅 **Sistem Booking**: Pemesanan dengan validasi konflik jadwal
- 👥 **User Management**: Registrasi, login, dan manajemen pengguna
- 🔐 **Authorization**: Role-based access (User, Staff, Admin)
- 📱 **Responsive Design**: Interface modern dengan Bootstrap 5
- 🎛️ **Admin Panel**: Dashboard lengkap untuk administrator
- 📧 **Email Notifications**: Notifikasi booking via email
- 🐳 **Docker Ready**: Deployment mudah dengan Docker Compose

## 🚀 Quick Start

### 1. Clone Repository
```bash
git clone https://github.com/YOUR_USERNAME/room-booking-system.git
cd room-booking-system
```

### 2. Konfigurasi Environment

⚠️ **PENTING**: Jangan pernah commit file `.env` ke repository!

```bash
# Copy template dan edit sesuai kebutuhan
cp .env.example .env

# Edit file .env dengan editor favorit
nano .env
```

**🔐 Security Tips:**
- Generate SECRET_KEY yang kuat: `python -c "from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())"`
- Gunakan password yang kompleks untuk database
- Jangan gunakan kredensial default di production
- Set `DEBUG=False` untuk production
- Configure `ALLOWED_HOSTS` dengan domain yang tepat
- Set `CSRF_TRUSTED_ORIGINS` untuk akses eksternal

### 3. Jalankan Aplikasi

**🚀 Method 1: Docker Compose (Recommended)**
```bash
# Build dan start containers
docker-compose up -d

# Monitor logs (optional)
docker-compose logs -f web
```

**🔄 Method 2: Development Mode**
```bash
# Set DEBUG=True in .env first
echo "DEBUG=True" >> .env

# Start with development server
docker-compose up -d
```

**⚡ Method 3: Production Mode**
```bash
# Ensure DEBUG=False in .env
# Start with Gunicorn
docker-compose up -d
```

### 4. Akses Aplikasi
- **Web App**: http://localhost:8001
- **Admin Panel**: http://localhost:8001/admin
- **Health Check**: http://localhost:8001/health/
- **Default Admin**: username: `admin`, password: `admin123` (⚠️ Change in production!)

### 5. External Access
Untuk akses dari IP eksternal, update `.env`:
```env
ALLOWED_HOSTS=localhost,127.0.0.1,YOUR_SERVER_IP
CSRF_TRUSTED_ORIGINS=http://localhost:8001,http://YOUR_SERVER_IP:8001
```

## 📦 Prasyarat

- [Docker](https://docs.docker.com/get-docker/) 20.10+
- [Docker Compose](https://docs.docker.com/compose/install/) 2.0+
- Git
- 2GB RAM minimum
- 5GB storage space

## ⚙️ Konfigurasi

### Environment Variables (.env)

```env
# Debug Mode
DEBUG=False

# Security
SECRET_KEY=your-super-secret-key-here
ALLOWED_HOSTS=localhost,127.0.0.1,yourdomain.com

# Database
DB_HOST=db
DB_NAME=room_usage_db
DB_USER=django_user
DB_PASSWORD=your-strong-password
DB_PORT=3306
MYSQL_ROOT_PASSWORD=your-mysql-root-password

# Email (Optional)
EMAIL_BACKEND=django.core.mail.backends.console.EmailBackend
EMAIL_HOST=smtp.gmail.com
EMAIL_PORT=587
EMAIL_USE_TLS=True
EMAIL_HOST_USER=your-email@gmail.com
EMAIL_HOST_PASSWORD=your-app-password

# Default Admin
DJANGO_SUPERUSER_USERNAME=admin
DJANGO_SUPERUSER_EMAIL=admin@example.com
DJANGO_SUPERUSER_PASSWORD=admin123
```

## 📚 Struktur Proyek

```
room-booking-system/
├── 🐳 docker-compose.yml      # Docker services
├── 🐳 Dockerfile              # Container definition
├── 🔧 docker-entrypoint.sh    # Container startup script
├── ⚙️ .env                    # Environment variables
├── 📋 requirements.txt        # Python dependencies
├── 🎨 templates/              # HTML templates
├── 📁 staticfiles/            # Static assets
├── 🏠 room_usage_project/     # Django project settings
├── 🏢 rooms/                  # Main application
├── 🛠️ scripts/                # Utility scripts
│   ├── setup.sh                   # Complete setup automation
│   ├── run-development.sh         # Development environment
│   ├── run-production.sh          # Production deployment
│   ├── dev-tools.sh               # Development utilities
│   ├── monitor.sh                 # Monitoring and logs
│   ├── backup.sh                  # Backup utilities
│   └── README.md                  # Scripts documentation
├── 📋 checklists/             # Development & deployment checklists
│   ├── SECURITY_CHECKLIST.md      # Security guidelines
│   ├── DEPLOYMENT_CHECKLIST.md    # Deployment steps
│   ├── DEVELOPMENT_CHECKLIST.md   # Development workflow
│   └── CODE_REVIEW_CHECKLIST.md   # Code review standards
└── 📚 docs/                   # Detailed documentation
```

## 📋 Quick References

**🛠️ Utility Scripts:**
- 🚀 **[Setup Script](scripts/README.md)** - Complete automation setup
- 🔧 **[Dev Tools](scripts/README.md#dev-toolssh)** - Development utilities  
- 📊 **[Monitor](scripts/README.md#monitorsh)** - Application monitoring
- 🗄️ **[Backup](scripts/README.md#backupsh)** - Data backup utilities

**📋 Quality Checklists:**
- 🔐 **[Security Checklist](checklists/SECURITY_CHECKLIST.md)** - Sebelum upload ke GitHub
- 🚀 **[Deployment Checklist](checklists/DEPLOYMENT_CHECKLIST.md)** - Sebelum deploy production
- 🔄 **[Development Checklist](checklists/DEVELOPMENT_CHECKLIST.md)** - Setup development
- 📋 **[Code Review Checklist](checklists/CODE_REVIEW_CHECKLIST.md)** - Quality assurance

## 🎯 Cara Penggunaan

### Untuk User Biasa

1. **Registrasi & Login**
   - Buka http://localhost:8001
   - Klik "Register" untuk membuat akun
   - Login dengan kredensial yang dibuat

2. **Melihat Ruangan**
   - Browse daftar ruangan di homepage
   - Klik ruangan untuk melihat detail
   - Gunakan fitur search untuk mencari ruangan

3. **Membuat Booking**
   - Pilih ruangan yang diinginkan
   - Klik "Book This Room"
   - Isi form booking dengan lengkap
   - Submit dan tunggu approval admin

4. **Mengelola Booking**
   - Akses "My Bookings" di menu
   - Lihat status booking
   - Edit atau cancel booking jika diperlukan

### Untuk Admin

1. **Akses Admin Panel**
   - Login sebagai admin
   - Buka http://localhost:8001/admin

2. **Mengelola Ruangan**
   - Tambah, edit, atau hapus ruangan
   - Upload gambar ruangan
   - Set status aktif/tidak aktif

3. **Mengelola Booking**
   - Review booking pending
   - Approve atau reject pemesanan
   - Tambah catatan untuk user

## 🔧 Development

### Setup Development Environment

```bash
# Clone repository
git clone https://github.com/YOUR_USERNAME/room-booking-system.git
cd room-booking-system

# Setup virtual environment
python -m venv venv
source venv/bin/activate  # Linux/Mac

# Install dependencies
pip install -r requirements.txt

# Setup local database (SQLite)
export DEBUG=True
python manage.py migrate
python manage.py createsuperuser
python manage.py runserver
```

### Menjalankan Tests

```bash
# Run all tests
python manage.py test

# Run specific app tests
python manage.py test rooms

# Run with coverage
pip install coverage
coverage run --source='.' manage.py test
coverage report
```

### Code Style

Proyek ini menggunakan:
- **PEP 8** untuk Python code style
- **Black** untuk code formatting
- **isort** untuk import sorting

```bash
# Format code
black .
isort .
```

## 🚀 Deployment

### Development
```bash
# Complete setup (recommended)
./scripts/setup.sh

# Quick development start
./scripts/run-development.sh
```

### Production

1. **Setup Server**
   - Install Docker & Docker Compose
   - Clone repository
   - Konfigurasi environment variables

2. **Deploy**
   ```bash
   # Set production settings
   export DEBUG=False
   export ALLOWED_HOSTS=yourdomain.com
   
   # Start services
   docker-compose up -d --build
   ```

3. **SSL Setup (Optional)**
   - Setup reverse proxy (Nginx)
   - Configure SSL certificates
   - Update ALLOWED_HOSTS

## 🛠️ Maintenance

### Backup Database
```bash
# Create backup
docker-compose exec db mysqldump -u root -p room_usage_db > backup_$(date +%Y%m%d).sql

# Restore backup
docker-compose exec -T db mysql -u root -p room_usage_db < backup_20240101.sql
```

### Update Application
```bash
# Pull latest changes
git pull origin main

# Rebuild and restart
docker-compose down
docker-compose up -d --build

# Run migrations
docker-compose exec web python manage.py migrate
```

### Monitor Application
```bash
# View logs
docker-compose logs -f

# Check container status
docker-compose ps

# Monitor resources
docker stats
```

## 🐛 Troubleshooting

### Common Issues

**Container fails to start:**
```bash
docker-compose logs
docker-compose down && docker-compose up -d
```

**Database connection error:**
```bash
docker-compose ps
docker-compose restart db
```

**Port already in use:**
```bash
sudo lsof -i :8001
# Kill process or change port in docker-compose.yml
```

**Permission issues:**
```bash
sudo chown -R $USER:$USER .
chmod +x start.sh
```

## 📖 Dokumentasi

📚 **[📋 Buka Portal Dokumentasi →](docs/README.md)**

### 🚀 Quick Access
- **[� User Manual](docs/DOCUMENTATION.md)** - Panduan penggunaan lengkap
- **[❓ FAQ](docs/FAQ.md)** - Pertanyaan yang sering diajukan  
- **[🔧 Developer Guide](docs/DEVELOPER.md)** - Setup development environment
- **[🚀 Deployment Guide](docs/DEPLOYMENT.md)** - Deploy ke production
- **[📡 API Documentation](docs/API.md)** - REST API reference

### 📋 All Documentation
**[📋 Complete Documentation Index](docs/README.md)** - Portal utama dengan navigasi lengkap berdasarkan peran Anda (User/Developer/Admin)

## 🤝 Contributing

1. Fork repository
2. Create feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Open Pull Request

## 📝 License

Distributed under the MIT License. See `LICENSE` for more information.

## 👥 Team

- **Developer**: Your Name
- **Email**: your.email@domain.com
- **GitHub**: [@yourusername](https://github.com/yourusername)

## 🙏 Acknowledgments

- Django Framework
- Bootstrap CSS Framework
- Docker & Docker Compose
- MySQL Database
- Font Awesome Icons

---

**🏢 Room Booking System - Simplifying room reservations for modern organizations**

⭐ Don't forget to star this repository if you found it helpful!
