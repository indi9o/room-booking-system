# Sistem Booking Ruangan

Aplikasi web untuk manajemen booking ruangan yang dibangun menggunakan Django, MySQL, dan Docker.

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

### 1. Development (Local dengan SQLite)

```bash
# Clone atau extract project
cd room-booking-system

# Buat virtual environment
python -m venv venv
source venv/bin/activate  # Linux/Mac
# atau
venv\Scripts\activate     # Windows

# Install dependencies
pip install -r requirements.txt

# Setup database
python manage.py makemigrations
python manage.py migrate

# Buat superuser
python manage.py createsuperuser

# Jalankan server
python manage.py runserver
```

### 2. Production (Docker dengan MySQL)

```bash
# Jalankan dengan Docker Compose
docker-compose up -d

# Akses aplikasi di http://localhost:8000
```

### 3. Quick Start Script

```bash
# Jalankan script startup otomatis
./start_app.sh
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
