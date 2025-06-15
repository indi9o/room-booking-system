# 📑 FAQ - Frequently Asked Questions

Kumpulan pertanyaan yang sering diajukan tentang Room Booking System beserta jawabannya.

## 🏢 Room Management

### Q: Bagaimana cara menambah ruangan baru?
**A:** Hanya staff/admin yang bisa menambah ruangan baru:
1. Login sebagai staff atau admin
2. Klik "Tambah Ruangan" di navbar atau halaman Ruangan
3. Isi form dengan detail ruangan (nama, kapasitas, lokasi wajib diisi)
4. Upload foto ruangan (opsional)
5. Klik "Simpan Ruangan"

### Q: Mengapa tombol "Tambah Ruangan" tidak muncul?
**A:** Tombol hanya muncul untuk user dengan status staff. Hubungi admin untuk mengubah status akun Anda.

### Q: Ukuran file foto maksimal berapa?
**A:** Maksimal 5MB dengan format JPG, PNG, atau GIF.

### Q: Bisakah mengedit ruangan yang sudah dibuat?
**A:** Ya, staff/admin bisa mengedit semua detail ruangan termasuk nama, kapasitas, lokasi, dan foto.

## 📅 Booking System

### Q: Bagaimana cara membuat booking ruangan?
**A:** 
1. Login ke sistem
2. Pilih "Buat Booking" atau pilih ruangan yang diinginkan
3. Isi detail booking (tanggal, waktu, jumlah peserta)
4. Submit booking
5. Tunggu approval jika diperlukan

### Q: Mengapa booking saya ditolak?
**A:** Beberapa kemungkinan:
- Ruangan sudah dibooking di waktu yang sama
- Jumlah peserta melebihi kapasitas ruangan
- Booking dibuat terlalu mendekati waktu acara
- Admin menolak karena alasan tertentu

### Q: Bisakah mengubah booking yang sudah dibuat?
**A:** Ya, Anda bisa mengubah booking selama:
- Booking masih berstatus "pending" atau "approved"
- Perubahan tidak menyebabkan konflik dengan booking lain
- Masih dalam batas waktu yang diizinkan

### Q: Kapan booking otomatis diapprove?
**A:** Saat ini semua booking perlu approval manual dari admin. Fitur auto-approve mungkin ditambahkan di versi mendatang.

## 👤 User Management

### Q: Bagaimana cara mendaftar akun baru?
**A:**
1. Klik "Daftar" di halaman login
2. Isi form registrasi (username, email, nama, password)
3. Submit form
4. Login dengan akun yang baru dibuat

### Q: Lupa password, bagaimana reset?
**A:** Saat ini fitur reset password belum tersedia. Hubungi admin untuk reset password manual.

### Q: Bagaimana cara menjadi staff/admin?
**A:** Hanya admin yang bisa mengubah status user. Hubungi admin sistem untuk upgrade akun.

### Q: Bisakah mengubah informasi profil?
**A:** Saat ini perubahan profil hanya bisa dilakukan melalui admin panel. Fitur edit profil user akan ditambahkan di versi mendatang.

## 🐳 Technical Issues

### Q: Aplikasi tidak bisa diakses di localhost:8001
**A:** Cek beberapa hal:
- Pastikan Docker containers berjalan: `docker-compose ps`
- Cek logs untuk error: `docker-compose logs web`
- Pastikan port 8001 tidak digunakan aplikasi lain
- Restart containers: `docker-compose restart`

### Q: Error "Port already in use" saat menjalankan docker-compose
**A:** 
1. Cek aplikasi yang menggunakan port: `sudo lsof -i :8001`
2. Stop aplikasi tersebut atau ubah port di docker-compose.yml
3. Restart docker-compose

### Q: Database connection error
**A:**
1. Pastikan MySQL container berjalan: `docker-compose ps`
2. Cek database logs: `docker-compose logs db`
3. Restart database: `docker-compose restart db`
4. Jika masih bermasalah, rebuild containers: `docker-compose down && docker-compose up --build`

### Q: Static files (CSS/JS) tidak load
**A:**
1. Jalankan collectstatic: `docker-compose exec web python manage.py collectstatic`
2. Restart web container: `docker-compose restart web`
3. Clear browser cache

## 🚀 Deployment

### Q: Bagaimana cara deploy ke production?
**A:** Lihat [Production Deployment Guide](docs/deployment/production.md) untuk panduan lengkap.

### Q: Bisakah run tanpa Docker?
**A:** Ya, ikuti [Local Development Guide](docs/setup/local-development.md) untuk setup tanpa Docker.

### Q: Bagaimana backup database?
**A:**
```bash
# Backup MySQL
docker-compose exec db mysqldump -u root -proot_password room_usage_db > backup.sql

# Restore backup
docker-compose exec -i db mysql -u root -proot_password room_usage_db < backup.sql
```

### Q: Environment variables apa saja yang penting?
**A:** Lihat [Environment Configuration](docs/deployment/environment.md) untuk daftar lengkap.

## 🎨 Customization

### Q: Bagaimana mengubah tampilan/theme?
**A:** 
1. Edit file CSS di folder `static/`
2. Modify template files di folder `templates/`
3. Jalankan `collectstatic` setelah perubahan
4. Restart application

### Q: Bisakah menambah field custom di ruangan?
**A:** Ya, tapi perlu modifikasi kode:
1. Update model `Room` di `rooms/models.py`
2. Buat migration: `python manage.py makemigrations`
3. Apply migration: `python manage.py migrate`
4. Update forms dan templates

### Q: Bagaimana mengubah logo aplikasi?
**A:**
1. Ganti file logo di `static/images/`
2. Update reference di `templates/base.html`
3. Jalankan `collectstatic`

## 📧 Notifications

### Q: Apakah ada notifikasi email?
**A:** Fitur email notification belum tersedia di v1.0.0, tapi ada di roadmap pengembangan.

### Q: Bagaimana mengetahui booking diapprove/reject?
**A:** Saat ini hanya bisa dicek di halaman "Booking Saya". Notifikasi real-time akan ditambahkan di versi mendatang.

## 📱 Mobile Support

### Q: Apakah aplikasi mobile-friendly?
**A:** Ya, menggunakan Bootstrap responsive design yang bekerja baik di mobile browser.

### Q: Apakah ada mobile app?
**A:** Belum ada mobile app native. Gunakan mobile browser untuk mengakses aplikasi.

## 🔐 Security

### Q: Bagaimana keamanan data user?
**A:** 
- Password di-hash menggunakan Django built-in hashing
- CSRF protection untuk semua forms
- SQL injection protection via Django ORM
- Session-based authentication

### Q: Bisakah setup HTTPS?
**A:** Ya, untuk production setup SSL certificate dan configure reverse proxy (Nginx/Apache).

### Q: Bagaimana mengubah secret key?
**A:** Update `SECRET_KEY` di environment variables dan restart aplikasi.

## 🔧 Development

### Q: Bagaimana cara contribute ke project?
**A:** Lihat [Contributing Guide](docs/development/contributing.md) untuk panduan lengkap.

### Q: Bagaimana setup development environment?
**A:** Ikuti [Local Development Setup](docs/setup/local-development.md).

### Q: Apakah ada API endpoints?
**A:** Saat ini belum ada REST API. Fitur ini ada di roadmap untuk versi mendatang.

### Q: Bagaimana menjalankan tests?
**A:**
```bash
# Via Docker
docker-compose exec web python manage.py test

# Local development
python manage.py test
```

## 🆘 Getting More Help

### Q: Dimana mencari bantuan lebih lanjut?
**A:** 
1. **Documentation**: Baca [dokumentasi lengkap](DOCUMENTATION.md)
2. **GitHub Issues**: Buat issue untuk bug reports atau feature requests
3. **Troubleshooting**: Cek [Troubleshooting Guide](docs/troubleshooting.md)

### Q: Bagaimana melaporkan bug?
**A:**
1. Buat GitHub issue dengan template bug report
2. Sertakan steps to reproduce
3. Include error logs jika ada
4. Mention environment details (OS, browser, etc.)

### Q: Bagaimana request feature baru?
**A:**
1. Cek existing issues dulu
2. Buat feature request issue
3. Jelaskan use case dan benefit
4. Consider contributing implementation

---

## 💡 Tidak menemukan jawaban?

Jika pertanyaan Anda tidak ada di FAQ ini:

1. **Search Documentation**: Gunakan search di [dokumentasi lengkap](DOCUMENTATION.md)
2. **Check Issues**: Lihat [GitHub issues](https://github.com/YOUR_USERNAME/room-booking-system/issues)
3. **Create Issue**: Buat issue baru dengan label "question"
4. **Discussion**: Start discussion di GitHub Discussions

**📝 Help us improve**: Jika Anda menemukan pertanyaan yang sering muncul, silakan suggest untuk ditambahkan ke FAQ ini!
