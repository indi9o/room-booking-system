# 🏢 Sistem Booking Ruangan - Panduan Lengkap

## ✅ Aplikasi Berhasil Dibuat!

Aplikasi sistem booking ruangan telah berhasil dibuat dengan fitur lengkap menggunakan Django, MySQL, dan Docker.

## 🚀 Cara Menjalankan Aplikasi

### Option 1: Menggunakan Script Otomatis
```bash
./start_app.sh
```

### Option 2: Manual Development
```bash
# Aktivasi virtual environment
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Migrasi database
python manage.py migrate

# Load sample data
python manage.py load_sample_data

# Jalankan server
python manage.py runserver 0.0.0.0:8000
```

### Option 3: Menggunakan Docker
```bash
# Untuk production dengan MySQL
docker-compose up -d
```

## 🌐 Akses Aplikasi

- **Website**: http://localhost:8000
- **Admin Panel**: http://localhost:8000/admin

## 👤 Login Credentials

### Admin
- Username: `admin`
- Password: `admin123`
- Email: `alan@ub.ac.id`

### Sample Users
- Username: `user1`, `user2`, `user3`
- Password: `password123`

## 📁 Struktur Project

```
room_usage_project/
├── 📁 room_usage_project/    # Django settings
├── 📁 rooms/                 # Main app
│   ├── 📄 models.py         # Room, Booking, BookingHistory
│   ├── 📄 views.py          # View logic
│   ├── 📄 forms.py          # Form definitions
│   ├── 📄 admin.py          # Admin panel config
│   └── 📄 urls.py           # URL routing
├── 📁 templates/            # HTML templates
├── 📁 static/              # CSS, JS, images
├── 📁 media/               # User uploads
├── 📄 requirements.txt     # Dependencies
├── 📄 docker-compose.yml   # Docker config
├── 📄 Dockerfile          # Docker image
└── 📄 README.md           # Documentation
```

## ✨ Fitur Utama

### 🏠 Homepage
- Overview ruangan tersedia
- Recent bookings (untuk logged users)
- Quick access untuk booking

### 🏢 Manajemen Ruangan
- Daftar ruangan dengan search
- Detail ruangan dengan gambar
- Informasi kapasitas dan fasilitas
- Jadwal booking yang akan datang

### 📅 Sistem Booking
- Form booking dengan date/time picker
- Real-time availability checking
- Status management (pending/approved/rejected/cancelled)
- Edit dan cancel booking
- History tracking

### 👑 Admin Panel
- Manajemen ruangan (CRUD)
- Approve/reject bookings
- User management
- Dashboard dengan filter

### 🔐 Authentication
- User registration
- Login/logout
- Permission-based access

## 🎨 UI/UX Features

- **Responsive Design** dengan Bootstrap 5
- **Modern Interface** dengan Font Awesome icons
- **Interactive Forms** dengan crispy forms
- **Date/Time Picker** untuk booking
- **Real-time Validation** via AJAX
- **Status Badges** dengan color coding
- **Pagination** untuk large datasets

## 🗄️ Database Models

### Room (Ruangan)
```python
- name: CharField (Nama ruangan)
- description: TextField (Deskripsi)
- capacity: PositiveIntegerField (Kapasitas)
- location: CharField (Lokasi)
- facilities: TextField (Fasilitas)
- image: ImageField (Gambar)
- is_active: BooleanField (Status aktif)
```

### Booking (Pemesanan)
```python
- user: ForeignKey(User) (Pengguna)
- room: ForeignKey(Room) (Ruangan)
- title: CharField (Judul acara)
- description: TextField (Deskripsi acara)
- start_datetime: DateTimeField (Waktu mulai)
- end_datetime: DateTimeField (Waktu selesai)
- participants: PositiveIntegerField (Jumlah peserta)
- status: CharField (Status booking)
- notes: TextField (Catatan)
```

### BookingHistory (Riwayat)
```python
- booking: ForeignKey(Booking) (Referensi booking)
- old_status: CharField (Status lama)
- new_status: CharField (Status baru)
- changed_by: ForeignKey(User) (Yang mengubah)
- notes: TextField (Catatan perubahan)
```

## 🛠️ Tech Stack

- **Backend**: Django 4.2.7, Python 3.11+
- **Database**: MySQL 8.0 (production), SQLite (development)
- **Frontend**: Bootstrap 5, HTML5, CSS3, JavaScript/jQuery
- **Forms**: django-crispy-forms, crispy-bootstrap5
- **Date/Time**: django-bootstrap-datepicker-plus
- **Images**: Pillow
- **Config**: python-decouple
- **Containerization**: Docker & Docker Compose

## 📋 Sample Data

Aplikasi sudah termasuk sample data:
- 5 ruangan dengan berbagai kapasitas
- 3 sample users
- 4 sample bookings dengan berbagai status
- 1 admin user

## 🔧 Environment Configuration

File `.env` sudah dikonfigurasi untuk:
- Development (SQLite)
- Production (MySQL dengan Docker)
- Debug settings
- Database credentials

## 🐳 Docker Setup

- **Web service**: Django app
- **Database service**: MySQL 8.0
- **Volumes**: Persistent MySQL data
- **Networks**: Internal communication
- **Ports**: 8000 (web), 3306 (MySQL)

## 🚨 Security Features

- CSRF protection
- User authentication required
- Object-level permissions
- SQL injection prevention
- XSS protection
- Secure file uploads

## 📱 Responsive Design

- Mobile-first approach
- Tablet optimized
- Desktop enhanced
- Cross-browser compatible

## 🔄 Real-time Features

- Availability checking via AJAX
- Form validation
- Status updates
- Conflict detection

## 📊 Business Logic

- Conflict prevention
- Capacity validation
- Time validation
- Status workflow
- History tracking
- Permission checking

## 🎯 Next Steps

Untuk development lanjutan:
1. **Email notifications** untuk status changes
2. **Calendar integration** (Google Calendar, Outlook)
3. **Recurring bookings** untuk event berulang
4. **Advanced reporting** dan analytics
5. **Mobile app** dengan REST API
6. **QR code** untuk quick room access
7. **Integration** dengan sistem HR/LDAP

## 📞 Support

Untuk bantuan atau pertanyaan:
- Email: alan@ub.ac.id
- Documentation: README.md
- Admin panel: /admin/

---

**🎉 Aplikasi siap digunakan! Selamat mencoba!**
