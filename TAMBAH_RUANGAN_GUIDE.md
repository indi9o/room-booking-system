# 📋 Panduan Fitur Tambah Ruangan

## 🎯 Overview
Fitur tambah ruangan memungkinkan admin/staff untuk menambahkan ruangan baru ke dalam sistem booking. Fitur ini dilengkapi dengan validasi form dan kontrol akses.

## 🔐 Persyaratan Akses
- **User harus login** sebagai staff atau admin
- **User biasa** tidak dapat mengakses fitur ini
- Jika user biasa mencoba akses, akan diarahkan kembali ke daftar ruangan

## 🚀 Cara Menggunakan

### 1. Login sebagai Staff/Admin
```
Username: admin
Password: admin123
```
atau
```
Username: user1  (sudah dijadikan staff)
Password: password123
```

### 2. Akses Fitur Tambah Ruangan
Ada beberapa cara untuk mengakses:

#### Via Navbar (untuk staff/admin)
- Klik menu **"Tambah Ruangan"** di navigation bar

#### Via Daftar Ruangan
- Buka halaman **"Ruangan"**
- Klik tombol **"Tambah Ruangan"** (hijau) di bagian atas

#### Via URL Langsung
- Akses: `http://localhost:8001/rooms/create/`

### 3. Mengisi Form Ruangan Baru

#### Field Wajib (Required) ⭐
- **Nama Ruangan**: Nama unik untuk ruangan
- **Kapasitas**: Jumlah maksimal orang (minimal 1)
- **Lokasi**: Lokasi/alamat ruangan

#### Field Opsional
- **Deskripsi**: Penjelasan detail tentang ruangan
- **Fasilitas**: Daftar fasilitas yang tersedia (pisahkan dengan koma)
- **Foto Ruangan**: Upload gambar ruangan (JPG, PNG, GIF - Max: 5MB)
- **Ruangan Aktif**: Centang jika ruangan tersedia untuk booking

### 4. Contoh Pengisian Form
```
Nama Ruangan: Ruang Diskusi D
Kapasitas: 15
Lokasi: Lantai 2, Gedung A
Deskripsi: Ruang diskusi kecil dengan suasana nyaman untuk meeting tim
Fasilitas: Proyektor, Whiteboard, AC, WiFi, Sound System
Foto: [Upload foto ruangan]
Ruangan Aktif: ✓ Checked
```

## ✅ Validasi Form

### Validasi yang Diterapkan:
- **Nama Ruangan**: Tidak boleh kosong
- **Kapasitas**: Harus angka positif (minimal 1)
- **Lokasi**: Tidak boleh kosong
- **Foto**: Format yang didukung (JPG, PNG, GIF)
- **Ukuran File**: Maksimal 5MB

### Error Handling:
- Jika ada error, akan ditampilkan pesan error di bawah field terkait
- Form tidak akan disubmit jika ada field yang tidak valid
- Data yang sudah diisi akan tetap ada jika terjadi error

## 🎨 Fitur UI

### Bootstrap Styling
- Form menggunakan Bootstrap untuk tampilan yang responsif
- Icon FontAwesome untuk mempercantik interface
- Styling khusus untuk form elements

### User Experience
- **Placeholder text** untuk membantu user
- **Help text** untuk memberikan panduan
- **Responsive design** untuk mobile dan desktop
- **Loading states** dan feedback visual

## 🔧 Technical Details

### Backend Implementation
- **View**: `create_room()` di `rooms/views.py`
- **Form**: `RoomForm` di `rooms/forms.py` dengan validasi custom
- **URL**: `/rooms/create/` di `rooms/urls.py`
- **Template**: `templates/rooms/create_room.html`

### Security
- **Login Required**: Decorator `@login_required`
- **Staff Check**: Validasi `request.user.is_staff`
- **CSRF Protection**: Django built-in CSRF protection
- **File Upload Security**: Validasi tipe dan ukuran file

### Database
- Data disimpan ke model `Room` di database MySQL
- Auto-increment ID untuk primary key
- Timestamp untuk tracking created/updated

## 📝 Setelah Menambah Ruangan

### Redirect Success
Setelah berhasil menambah ruangan, user akan:
1. Diarahkan ke halaman detail ruangan yang baru dibuat
2. Melihat pesan sukses "Ruangan [nama] berhasil ditambahkan!"

### Ruangan Baru Akan Tampil
- Di halaman **Daftar Ruangan**
- Di **Admin Panel** Django
- Tersedia untuk **booking** (jika diset aktif)

## 🛠 Troubleshooting

### User Tidak Bisa Akses
- Pastikan user sudah login
- Pastikan user memiliki status staff (`is_staff = True`)
- Gunakan script `make_staff.py` untuk mengubah user menjadi staff

### Error Upload Foto
- Periksa format file (harus JPG, PNG, atau GIF)
- Periksa ukuran file (maksimal 5MB)
- Pastikan direktori media sudah dikonfigurasi

### Form Tidak Bisa Disubmit
- Periksa field yang wajib diisi (marked dengan *)
- Pastikan kapasitas berupa angka positif
- Refresh halaman jika terjadi error CSRF

## 📊 Management Commands

### Mengubah User Menjadi Staff
```bash
docker-compose exec web python make_staff.py
```

### Via Django Shell
```bash
docker-compose exec web python manage.py shell
```
```python
from django.contrib.auth.models import User
user = User.objects.get(username='username')
user.is_staff = True
user.save()
```

---

## ✨ Ready to Use!
Fitur tambah ruangan siap digunakan dan terintegrasi penuh dengan sistem booking yang ada!
