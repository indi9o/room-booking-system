# 🏢 Room Booking System

![### 🛠 Development Tools
- **🎯 [Development Tools](docs/development/tools.md)** - Complete tools guide
- **⚡ [Start App Script](tools/start_app.sh)** - One-click setup & run
- **👤 [User Management](tools/make_staff.py)** - Make users staff/admin
- **⚡ [Performance Testing](tools/performance_test.sh)** - System performance validation
- **🌐 [GitHub Setup](tools/github_setup.sh)** - Repository setup guideo](https://img.shields.io/badge/Django-4.2.7-green) ![Python](https://img.shields.io/badge/Python-3.11-blue) ![MySQL](https://img.shields.io/badge/MySQL-8.0-orange) ![Docker](https://img.shields.io/badge/Docker-Compose-blue) ![Bootstrap](https://img.shields.io/badge/Bootstrap-5-purple)

A complete **Room Booking System** built with Django 4.2.7, MySQL 8.0, and Docker. This application provides a modern, responsive interface for managing room reservations with user authentication, admin panel, and comprehensive booking management.

## 🚀 Quick Start

### ⚡ 30-Second Setup
```bash
git clone https://github.com/YOUR_USERNAME/room-booking-system.git
cd room-booking-system
docker-compose up -d
```

**Access Application**: http://localhost:8001  
**Admin Panel**: http://localhost:8001/admin (admin/admin123)

## 📚 Complete Documentation

**📖 [Full Documentation](DOCUMENTATION.md)** - Start here for comprehensive guides

### 🎯 Quick Navigation
- **🚀 [Quick Start Guide](docs/setup/quick-start.md)** - Get running in 5 minutes
- **🏢 [Room Management](docs/features/room-management.md)** - Complete room management guide
- ** [Troubleshooting](docs/troubleshooting.md)** - Fix common issues
- **❓ [FAQ](docs/faq.md)** - Frequently asked questions

### 🛠 Development Tools
- **🎯 [Development Tools](docs/development/tools.md)** - Complete tools guide
- **⚡ [Start App Script](tools/start_app.sh)** - One-click setup & run
- **� [User Management](tools/make_staff.py)** - Make users staff/admin
- **🌐 [GitHub Setup](tools/github_setup.sh)** - Repository setup guide

### 🛠 Setup & Deployment
- **💻 [System Requirements](docs/setup/requirements.md)** - What you need
- **🚀 [Production Deployment](docs/deployment/production.md)** - Deploy to production
- **🌐 [Remote Repository Setup](docs/setup/remote-repository.md)** - GitHub/GitLab setup

## Fitur Utama

- **Manajemen Ruangan**: CRUD ruangan dengan informasi lengkap (nama, lokasi, kapasitas, fasilitas, gambar)
- **Sistem Booking**: User dapat membuat, melihat, edit, dan batalkan booking
- **Status Management**: Sistem persetujuan booking (pending, approved, rejected, cancelled, completed)
- **User Authentication**: Registrasi, login, logout dengan Django Auth
- **Admin Panel**: Interface admin untuk mengelola ruangan dan booking
- **Responsive Design**: UI modern dengan Bootstrap 5
- **Real-time Validation**: Cek ketersediaan ruangan secara real-time
- **History Tracking**: Riwayat perubahan status booking

## Teknologi yang Digunakan

- **Backend**: Django 4.2.7, Python 3.11+
- **Database**: MySQL 8.0 (production), SQLite (development)
- **Frontend**: Bootstrap 5, HTML5, CSS3, JavaScript
- **Containerization**: Docker & Docker Compose
- **Dependencies**: 
  - django-crispy-forms (form styling)
  - django-bootstrap-datepicker-plus (date/time picker)
  - Pillow (image handling)
  - python-decouple (environment variables)

## Struktur Project

```
room_usage_project/
├── room_usage_project/     # Project settings
│   ├── settings.py
│   ├── urls.py
│   └── wsgi.py
├── rooms/                  # Main application
│   ├── models.py          # Database models
│   ├── views.py           # View logic
│   ├── forms.py           # Form definitions
│   ├── admin.py           # Admin configuration
│   └── urls.py            # URL patterns
├── templates/             # HTML templates
│   ├── base.html
│   ├── rooms/
│   └── registration/
├── static/               # Static files (CSS, JS, images)
├── media/               # User uploaded files
├── requirements.txt     # Python dependencies
├── docker-compose.yml   # Docker configuration
├── Dockerfile          # Docker image definition
└── README.md           # This file
```

## Instalasi dan Setup

### 1. Docker Development (Recommended)

```bash
# Clone project
git clone <repository-url>
cd room-booking-system

# Start with Docker (one command!)
./tools/start_app.sh

# Or use Docker management tool
./tools/docker_django.sh up
```

**Access:**
- 🌐 Application: http://localhost:8001
- 👨‍💼 Admin: http://localhost:8001/admin
- 📊 Admin credentials: admin/admin123

### 2. Manual Docker Commands

```bash
# Start services
docker-compose up -d

# Run migrations
docker-compose exec web python manage.py migrate

# Create superuser
docker-compose exec web python manage.py createsuperuser

# Access container shell
docker-compose exec web bash
```

### 3. Environment Configuration

File `.env` akan dibuat otomatis saat pertama kali menjalankan `./tools/start_app.sh`.

Manual setup (opsional):

```bash
# Copy template
cp .env.example .env

# Edit sesuai kebutuhan
nano .env
```

## Development Tools

### Quick Tools Launcher
```bash
./tools.sh  # Interactive tool launcher
```

### Docker Management
```bash
./tools/docker_django.sh up        # Start services
./tools/docker_django.sh down      # Stop services
./tools/docker_django.sh migrate   # Run migrations
./tools/docker_django.sh test      # Run tests
./tools/docker_django.sh shell     # Django shell
```

## Konfigurasi Environment

Buat file `.env` di root project:

```env
DEBUG=1
SECRET_KEY=your-secret-key-here
DB_HOST=localhost
DB_NAME=room_usage_db
DB_USER=django_user
DB_PASSWORD=django_password
DB_PORT=3306
```

## Model Database

### Room (Ruangan)
- name: Nama ruangan
- description: Deskripsi ruangan
- capacity: Kapasitas maksimal
- location: Lokasi ruangan
- facilities: Fasilitas yang tersedia
- image: Gambar ruangan
- is_active: Status aktif/nonaktif

### Booking (Pemesanan)
- user: User yang membuat booking
- room: Ruangan yang dibooking
- title: Judul acara
- description: Deskripsi acara
- start_datetime: Waktu mulai
- end_datetime: Waktu selesai
- participants: Jumlah peserta
- status: Status booking (pending/approved/rejected/cancelled/completed)
- notes: Catatan tambahan

### BookingHistory (Riwayat)
- booking: Referensi ke booking
- old_status: Status lama
- new_status: Status baru
- changed_by: User yang mengubah
- notes: Catatan perubahan

## API Endpoints

### Authentication
- `/accounts/login/` - Login page
- `/accounts/logout/` - Logout
- `/register/` - User registration

### Rooms
- `/` - Homepage
- `/rooms/` - Daftar ruangan
- `/rooms/<id>/` - Detail ruangan

### Bookings
- `/bookings/` - Daftar booking user
- `/bookings/<id>/` - Detail booking
- `/bookings/create/` - Form booking baru
- `/bookings/create/<room_id>/` - Booking untuk ruangan tertentu
- `/bookings/<id>/update/` - Edit booking
- `/bookings/<id>/cancel/` - Batalkan booking

### AJAX
- `/ajax/check-availability/` - Cek ketersediaan ruangan

## Admin Panel

Akses admin panel di `/admin/` dengan kredensial superuser.

Features:
- Manajemen ruangan (CRUD)
- Manajemen booking (view, approve, reject)
- User management
- Riwayat booking

## Docker Commands

```bash
# Build dan jalankan
docker-compose up --build

# Jalankan di background
docker-compose up -d

# Stop containers
docker-compose down

# Lihat logs
docker-compose logs web

# Akses shell container
docker-compose exec web python manage.py shell
```

## Development

### Struktur URL
- Root URL (`/`) mengarah ke homepage
- Authentication URLs menggunakan Django built-in views
- Room dan Booking URLs di dalam `rooms/urls.py`

### Form Validation
- Client-side validation dengan Bootstrap
- Server-side validation di Django forms
- Real-time availability checking via AJAX

### Security
- CSRF protection pada semua forms
- User authentication required untuk booking
- Object-level permissions (user hanya bisa edit booking sendiri)

## Production Deployment

1. Update `settings.py` untuk production
2. Set environment variables yang sesuai
3. Gunakan proper web server (nginx + gunicorn)
4. Setup SSL certificate
5. Configure database backup

## 📚 Dokumentasi

Dokumentasi lengkap tersedia di folder [`docs/`](docs/):

### 🚀 Quick Access
- **[📋 Index Dokumentasi](docs/INDEX.md)** - Panduan navigasi lengkap
- **[🔧 Installation Guide](docs/setup/INSTALLATION.md)** - Panduan instalasi
- **[🐳 Docker Setup](docs/setup/DOCKER.md)** - Setup dengan Docker
- **[👤 User Guide](docs/guides/USER_GUIDE.md)** - Panduan pengguna
- **[👨‍💼 Staff Guide](docs/guides/STAFF_GUIDE.md)** - Panduan staff

### 📖 Dokumentasi Utama
- **[Setup & Installation](docs/setup/)** - Instalasi dan konfigurasi
- **[Features](docs/features/)** - Dokumentasi fitur-fitur
- **[Deployment](docs/deployment/)** - Panduan deployment
- **[Development](docs/development/)** - Setup development
- **[Guides](docs/guides/)** - Panduan penggunaan
- **[References](docs/references/)** - Referensi teknis
- **[Admin](docs/admin/)** - Dokumentasi admin

### ❓ Bantuan
- **[FAQ](docs/faq.md)** - Pertanyaan yang sering diajukan
- **[Troubleshooting](docs/troubleshooting.md)** - Penyelesaian masalah

## Troubleshooting

### Common Issues

1. **MySQL Connection Error**
   - Pastikan MySQL service running
   - Check credentials di `.env`
   - Untuk development, bisa gunakan SQLite

2. **Static Files Not Loading**
   - Jalankan `python manage.py collectstatic`
   - Check `STATIC_ROOT` setting

3. **Permission Denied**
   - Check file permissions
   - Untuk Docker, pastikan user permissions correct

## Contributing

1. Fork repository
2. Create feature branch
3. Make changes
4. Test thoroughly
5. Submit pull request

## Contact
Punya pertanyaan? Bingung? Atau cuma pengen curhat soal bug?
- Email: sudemo@codebuddy.ai
- Project Repository: [GitHub Link]
