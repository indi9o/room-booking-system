# 📚 Room Booking System - User Manual

> **📍 Navigation**: [📋 Documentation Index](README.md) | [❓ FAQ](FAQ.md) | [🔧 Developer Guide](DEVELOPER.md)

Dokumentasi lengkap untuk sistem pemesanan ruangan yang dibangun dengan Django, MySQL, dan Docker.

## 📑 Daftar Isi

1. [Overview](#overview)
2. [Instalasi](#instalasi)
3. [Konfigurasi](#konfigurasi)
4. [Fitur Aplikasi](#fitur-aplikasi)
5. [Penggunaan](#penggunaan)
6. [Deployment Production](#deployment-production)
7. [Maintenance](#maintenance)
8. [Troubleshooting](#troubleshooting)
9. [API Reference](#api-reference)

## Overview

### Tentang Aplikasi
Room Booking System adalah aplikasi web untuk mengelola pemesanan ruangan dengan fitur:
- Manajemen ruangan (CRUD)
- Sistem booking dengan validasi
- User authentication dan authorization
- Admin panel untuk pengelolaan
- Interface responsive dengan Bootstrap 5

### Teknologi
- **Backend**: Django 4.2.7, Python 3.11+
- **Database**: MySQL 8.0
- **Frontend**: Bootstrap 5, HTML5, CSS3, JavaScript
- **Containerization**: Docker & Docker Compose
- **Web Server**: Gunicorn (production), Django dev server (development)

### Arsitektur
```
User Interface (Bootstrap 5)
    ↓
Django Web Framework
    ↓
MySQL Database
    ↓
Docker Containers
```

## Instalasi

### Prasyarat
- Docker Desktop atau Docker + Docker Compose
- Git (untuk clone repository)
- Text editor (untuk edit konfigurasi)

### Langkah Instalasi

#### 1. Clone Repository
```bash
git clone https://github.com/YOUR_USERNAME/room-booking-system.git
cd room-booking-system
```

#### 2. Konfigurasi Environment
```bash
# Edit file .env sesuai kebutuhan
nano .env
```

#### 3. Jalankan Aplikasi
```bash
# Menggunakan script otomatis
./start.sh

# Atau manual
docker-compose up -d
```

#### 4. Verifikasi Instalasi
- Buka browser: http://localhost:8001
- Login admin: http://localhost:8001/admin (admin/admin123)

## Konfigurasi

### File Environment (.env)

```env
# Debug Mode
DEBUG=False  # True untuk development, False untuk production

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

# Superuser Default
DJANGO_SUPERUSER_USERNAME=admin
DJANGO_SUPERUSER_EMAIL=admin@example.com
DJANGO_SUPERUSER_PASSWORD=admin123
```

### Konfigurasi Production

Untuk deployment production, pastikan:

1. **Security Settings**:
   ```env
   DEBUG=False
   SECRET_KEY=generate-strong-secret-key
   ALLOWED_HOSTS=yourdomain.com,www.yourdomain.com
   ```

2. **Database Security**:
   ```env
   DB_PASSWORD=very-strong-password-here
   MYSQL_ROOT_PASSWORD=another-strong-password
   ```

3. **Email Configuration**:
   ```env
   EMAIL_BACKEND=django.core.mail.backends.smtp.EmailBackend
   EMAIL_HOST=your-smtp-server.com
   EMAIL_HOST_USER=your-email@yourdomain.com
   EMAIL_HOST_PASSWORD=your-email-password
   ```

## Fitur Aplikasi

### 1. User Management
- **Registrasi**: User dapat mendaftar akun baru
- **Login/Logout**: Sistem autentikasi Django
- **Profile**: Mengelola informasi user
- **Roles**: User, Staff, Admin dengan permission berbeda

### 2. Room Management
- **CRUD Ruangan**: Tambah, edit, hapus, lihat ruangan
- **Informasi Lengkap**: Nama, lokasi, kapasitas, fasilitas, gambar
- **Status Ruangan**: Aktif/tidak aktif
- **Search & Filter**: Pencarian berdasarkan nama, lokasi

### 3. Booking System
- **Pemesanan**: User dapat memesan ruangan dengan datetime
- **Validasi Real-time**: Cek konflik jadwal otomatis
- **Status Management**: Pending, Approved, Rejected, Cancelled, Completed
- **History**: Riwayat pemesanan user

### 4. Admin Panel
- **Dashboard**: Overview sistem
- **User Management**: Kelola user dan permission
- **Room Management**: Kelola ruangan
- **Booking Management**: Approve/reject pemesanan
- **Reports**: Laporan penggunaan ruangan

## Penggunaan

### Untuk User Biasa

#### 1. Registrasi dan Login
1. Buka http://localhost:8001
2. Klik "Register" untuk membuat akun
3. Isi form registrasi
4. Login dengan username/password

#### 2. Melihat Ruangan
1. Di homepage, lihat daftar ruangan tersedia
2. Klik ruangan untuk melihat detail
3. Gunakan search untuk mencari ruangan spesifik

#### 3. Membuat Booking
1. Pilih ruangan yang diinginkan
2. Klik "Book This Room"
3. Isi form booking:
   - Judul acara
   - Deskripsi
   - Tanggal dan waktu mulai
   - Tanggal dan waktu selesai
   - Jumlah peserta
4. Submit booking
5. Tunggu approval dari admin

#### 4. Mengelola Booking
1. Akses "My Bookings" di menu
2. Lihat status booking (pending/approved/rejected)
3. Edit atau cancel booking jika diperlukan

### Untuk Admin

#### 1. Akses Admin Panel
1. Login sebagai admin
2. Akses http://localhost:8001/admin
3. Username: admin, Password: admin123

#### 2. Mengelola Ruangan
1. Buka "Rooms" di admin panel
2. Tambah ruangan baru dengan "Add Room"
3. Isi informasi lengkap ruangan
4. Upload gambar ruangan
5. Set status aktif/tidak aktif

#### 3. Mengelola Booking
1. Buka "Bookings" di admin panel
2. Lihat semua booking pending
3. Approve atau reject booking
4. Tambah notes jika diperlukan

#### 4. Mengelola User
1. Buka "Users" di admin panel
2. Edit user information
3. Set user sebagai staff/admin
4. Activate/deactivate user

## Deployment Production

### 1. Persiapan Server
```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

### 2. Upload dan Konfigurasi
```bash
# Upload files ke server
scp -r room-booking-system/ user@your-server:/path/to/app/

# Konfigurasi environment
cd /path/to/app/room-booking-system
cp .env .env.production
nano .env.production
```

### 3. Deployment
```bash
# Build dan start
docker-compose up -d --build

# Verifikasi
docker-compose ps
docker-compose logs -f
```

### 4. Setup SSL (Optional)
```bash
# Install Certbot
sudo apt install certbot

# Generate SSL certificate
sudo certbot certonly --standalone -d yourdomain.com

# Copy certificates
sudo cp /etc/letsencrypt/live/yourdomain.com/fullchain.pem ./ssl/
sudo cp /etc/letsencrypt/live/yourdomain.com/privkey.pem ./ssl/
```

## Maintenance

### Backup Database
```bash
# Backup
docker-compose exec db mysqldump -u root -p room_usage_db > backup_$(date +%Y%m%d).sql

# Restore
docker-compose exec -T db mysql -u root -p room_usage_db < backup_20240101.sql
```

### Update Aplikasi
```bash
# Pull latest code
git pull origin main

# Rebuild containers
docker-compose down
docker-compose up -d --build

# Run migrations
docker-compose exec web python manage.py migrate
```

### Monitoring
```bash
# View logs
docker-compose logs -f

# Check container status
docker-compose ps

# Monitor resources
docker stats
```

### Database Maintenance
```bash
# Django admin commands
docker-compose exec web python manage.py clearsessions
docker-compose exec web python manage.py collectstatic --noinput

# Database optimization
docker-compose exec db mysql -u root -p -e "OPTIMIZE TABLE room_usage_db.*;"
```

## Troubleshooting

### Common Issues

#### 1. Container Gagal Start
```bash
# Check logs
docker-compose logs

# Restart containers
docker-compose down
docker-compose up -d
```

#### 2. Database Connection Error
```bash
# Check database container
docker-compose ps
docker-compose logs db

# Reset database
docker-compose down -v
docker-compose up -d
```

#### 3. Permission Issues
```bash
# Fix file permissions
sudo chown -R $USER:$USER .
chmod +x start.sh
```

#### 4. Port Already in Use
```bash
# Check what's using port 8001
sudo lsof -i :8001

# Kill process or change port in docker-compose.yml
```

### Performance Issues

#### 1. Slow Database Queries
```bash
# Enable MySQL slow query log
docker-compose exec db mysql -u root -p -e "SET GLOBAL slow_query_log = 'ON';"
```

#### 2. High Memory Usage
```bash
# Monitor container resources
docker stats

# Restart containers if needed
docker-compose restart
```

## API Reference

### Authentication Endpoints
```
POST /accounts/login/       # Login
POST /accounts/logout/      # Logout
POST /accounts/register/    # Register
```

### Room Endpoints
```
GET  /rooms/               # List rooms
GET  /rooms/{id}/          # Room detail
POST /rooms/create/        # Create room (admin only)
PUT  /rooms/{id}/edit/     # Edit room (admin only)
DELETE /rooms/{id}/delete/ # Delete room (admin only)
```

### Booking Endpoints
```
GET  /bookings/            # User bookings
GET  /bookings/{id}/       # Booking detail
POST /bookings/create/     # Create booking
PUT  /bookings/{id}/edit/  # Edit booking
DELETE /bookings/{id}/cancel/ # Cancel booking
```

### Admin Endpoints
```
GET  /admin/               # Admin panel
GET  /admin/rooms/         # Manage rooms
GET  /admin/bookings/      # Manage bookings
GET  /admin/users/         # Manage users
```

### Response Format
```json
{
    "status": "success|error",
    "message": "Human readable message",
    "data": {...}
}
```

---

## Support

Untuk bantuan lebih lanjut:
1. Periksa file README.md
2. Lihat issues di GitHub repository
3. Check troubleshooting section di atas
4. Contact administrator

---

**📚 Room Booking System Documentation**

**Navigation**: [📋 Index](README.md) | [❓ FAQ](FAQ.md) | [🔧 Developer](DEVELOPER.md) | [🚀 Deployment](DEPLOYMENT.md) | [📡 API](API.md)

*Complete user manual for Room Booking System - Last Updated: June 17, 2025*
