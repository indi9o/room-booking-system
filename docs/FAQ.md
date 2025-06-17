# ❓ Frequently Asked Questions (FAQ)

> **📍 Navigation**: [📋 Documentation Index](README.md) | [📚 User Manual](DOCUMENTATION.md) | [🔧 Developer Guide](DEVELOPER.md)

Kumpulan pertanyaan yang sering diajukan tentang Room Booking System.

## 🏗️ Installation & Setup

### Q: Apa saja persyaratan sistem untuk menjalankan aplikasi ini?
**A:** Persyaratan minimum:
- Docker 20.10+ dan Docker Compose 2.0+
- 2GB RAM
- 5GB storage space
- OS: Linux, macOS, atau Windows dengan WSL2

### Q: Bagaimana cara menginstall aplikasi ini?
**A:** Ikuti langkah berikut:
```bash
git clone https://github.com/YOUR_USERNAME/room-booking-system.git
cd room-booking-system
chmod +x start.sh
./start.sh
```

### Q: Aplikasi tidak bisa diakses setelah instalasi, apa yang harus dilakukan?
**A:** Periksa beberapa hal:
1. Pastikan Docker berjalan: `docker ps`
2. Cek logs: `docker-compose logs -f`
3. Periksa port 8001 tidak digunakan: `sudo lsof -i :8001`
4. Restart containers: `docker-compose restart`

### Q: Bagaimana cara mengubah port aplikasi?
**A:** Edit file `docker-compose.yml`:
```yaml
services:
  web:
    ports:
      - "8080:8000"  # Ubah dari 8001 ke 8080
```

## 🔐 Authentication & Users

### Q: Bagaimana cara login sebagai admin pertama kali?
**A:** Gunakan kredensial default:
- Username: `admin`
- Password: `admin123`
- URL: http://localhost:8001/admin

**Penting:** Segera ubah password default ini!

### Q: Bagaimana cara membuat user admin baru?
**A:** Ada dua cara:
1. **Via Admin Panel:**
   - Login sebagai admin
   - Buka Users di admin panel
   - Edit user yang diinginkan
   - Centang "Staff status" dan "Superuser status"

2. **Via Command Line:**
   ```bash
   docker-compose exec web python manage.py createsuperuser
   ```

### Q: User tidak bisa login, kenapa?
**A:** Periksa:
1. Pastikan user account aktif (is_active=True)
2. Cek username dan password benar
3. Periksa di admin panel apakah user ada
4. Clear browser cache dan cookies

### Q: Bagaimana cara reset password user?
**A:** 
1. **Via Admin Panel:** Login admin → Users → pilih user → set new password
2. **Via Email:** Implementasikan forgot password feature (perlu konfigurasi email)

## 🏢 Room Management

### Q: Bagaimana cara menambah ruangan baru?
**A:** 
1. Login sebagai admin
2. Buka admin panel: http://localhost:8001/admin
3. Klik "Rooms" → "Add Room"
4. Isi semua informasi ruangan
5. Upload gambar (opsional)
6. Pastikan "Is active" tercentang

### Q: Format gambar apa yang didukung untuk foto ruangan?
**A:** Format yang didukung:
- JPG/JPEG
- PNG
- GIF
- Maksimal ukuran: 5MB

### Q: Bagaimana cara menonaktifkan ruangan sementara?
**A:** 
1. Buka admin panel → Rooms
2. Pilih ruangan yang ingin dinonaktifkan
3. Uncheck "Is active"
4. Save

Ruangan yang tidak aktif tidak akan muncul di daftar booking.

### Q: Bisakah mengatur kapasitas maksimal ruangan?
**A:** Ya, field "Capacity" di model Room digunakan untuk ini. Saat ini hanya informational, tapi bisa ditambahkan validasi.

## 📅 Booking System

### Q: Bagaimana sistem approval booking bekerja?
**A:** Alur booking:
1. User membuat booking → Status: "Pending"
2. Admin review di admin panel
3. Admin approve/reject → Status: "Approved"/"Rejected"
4. User mendapat notifikasi (jika email dikonfigurasi)

### Q: Bisakah user membatalkan booking yang sudah diapprove?
**A:** Ya, user bisa cancel booking mereka sendiri. Status akan berubah menjadi "Cancelled".

### Q: Bagaimana mencegah double booking?
**A:** Sistem otomatis memeriksa konflik jadwal:
- Tidak bisa booking ruangan yang sudah dibooking di waktu yang sama
- Validasi dilakukan saat submit form
- Cek ulang saat admin approve

### Q: Bisakah booking berulang (recurring)?
**A:** Saat ini belum tersedia. Fitur ini bisa dikembangkan di versi mendatang.

### Q: Bagaimana cara melihat jadwal ruangan?
**A:** 
1. Klik ruangan di homepage
2. Lihat detail ruangan
3. Akan tampil booking yang sudah terjadwal

## 🔧 Technical Issues

### Q: Database error "Access denied for user"?
**A:** Periksa konfigurasi database di file `.env`:
```env
DB_USER=django_user
DB_PASSWORD=your-strong-password
MYSQL_ROOT_PASSWORD=your-mysql-root-password
```

### Q: Error "ALLOWED_HOSTS" saat deploy?
**A:** Update `ALLOWED_HOSTS` di `.env`:
```env
ALLOWED_HOSTS=localhost,127.0.0.1,yourdomain.com,www.yourdomain.com
```

### Q: Static files tidak muncul?
**A:** Jalankan collectstatic:
```bash
docker-compose exec web python manage.py collectstatic --noinput
```

### Q: Migrations error?
**A:** Reset dan jalankan ulang migrations:
```bash
docker-compose exec web python manage.py migrate --fake-initial
docker-compose exec web python manage.py migrate
```

### Q: Container memory usage tinggi?
**A:** Optimasi beberapa hal:
1. Kurangi jumlah Gunicorn workers di `gunicorn.conf.py`
2. Tambahkan swap space di server
3. Monitor dengan `docker stats`

## 📧 Email Configuration

### Q: Bagaimana mengaktifkan email notifications?
**A:** Konfigurasi email di `.env`:
```env
EMAIL_BACKEND=django.core.mail.backends.smtp.EmailBackend
EMAIL_HOST=smtp.gmail.com
EMAIL_PORT=587
EMAIL_USE_TLS=True
EMAIL_HOST_USER=your-email@gmail.com
EMAIL_HOST_PASSWORD=your-app-password
```

### Q: Email tidak terkirim?
**A:** Periksa:
1. Kredensial email benar
2. Gmail: gunakan App Password, bukan password biasa
3. Firewall tidak memblokir port 587
4. Test dengan: `docker-compose exec web python manage.py shell`
   ```python
   from django.core.mail import send_mail
   send_mail('Test', 'Message', 'from@email.com', ['to@email.com'])
   ```

## 🚀 Deployment & Production

### Q: Bagaimana deploy ke production server?
**A:** Ikuti [DEPLOYMENT.md](DEPLOYMENT.md) untuk panduan lengkap. Singkatnya:
1. Setup server dengan Docker
2. Clone repository
3. Konfigurasi environment production
4. Jalankan `./start.sh`
5. Setup SSL dan domain

### Q: Bagaimana cara backup data?
**A:** 
```bash
# Backup database
docker-compose exec db mysqldump -u root -p room_usage_db > backup_$(date +%Y%m%d).sql

# Backup media files
tar -czf media_backup_$(date +%Y%m%d).tar.gz media/
```

### Q: Bagaimana cara restore backup?
**A:**
```bash
# Restore database
docker-compose exec -T db mysql -u root -p room_usage_db < backup_20240101.sql

# Restore media files
tar -xzf media_backup_20240101.tar.gz
```

### Q: SSL certificate expired, bagaimana renewal?
**A:**
```bash
# Let's Encrypt auto-renewal
sudo certbot renew --dry-run

# Manual renewal
sudo certbot renew
sudo systemctl reload nginx
```

## 🔒 Security

### Q: Bagaimana mengamankan aplikasi untuk production?
**A:** Checklist keamanan:
1. Set `DEBUG=False`
2. Generate SECRET_KEY yang kuat
3. Gunakan HTTPS
4. Password database yang kuat
5. Update dependencies secara berkala
6. Setup firewall
7. Baca [SECURITY.md](SECURITY.md) untuk detail

### Q: Bagaimana cara mengubah secret key?
**A:**
```bash
# Generate new secret key
python -c "from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())"

# Update di .env
SECRET_KEY=your-new-secret-key
```

## 📱 Mobile & Responsive

### Q: Apakah aplikasi responsive untuk mobile?
**A:** Ya, aplikasi menggunakan Bootstrap 5 yang fully responsive dan mobile-friendly.

### Q: Bisakah membuat mobile app native?
**A:** Saat ini belum tersedia. Aplikasi web responsive sudah cukup untuk mobile usage.

## 🔧 Customization

### Q: Bagaimana cara mengubah tampilan/theme?
**A:** 
1. Edit file CSS di `staticfiles/css/`
2. Modifikasi template di `templates/`
3. Restart container: `docker-compose restart`

### Q: Bagaimana menambah field baru di booking form?
**A:** 
1. Update model di `rooms/models.py`
2. Create migration: `python manage.py makemigrations`
3. Run migration: `python manage.py migrate`
4. Update form di `rooms/forms.py`
5. Update template

### Q: Bisakah integrasi dengan sistem lain?
**A:** Ya, aplikasi menyediakan API endpoints. Lihat [API.md](API.md) untuk dokumentasi lengkap.

## 📊 Reporting & Analytics

### Q: Bagaimana melihat laporan penggunaan ruangan?
**A:** Saat ini laporan dasar tersedia di admin panel. Untuk laporan advanced, bisa develop custom views atau gunakan tools seperti Grafana.

### Q: Bisakah export data ke Excel/CSV?
**A:** Fitur ini belum tersedia out-of-the-box, tapi bisa dikembangkan. Admin bisa export via Django admin action.

## 🛠️ Development

### Q: Bagaimana setup development environment?
**A:** Baca [DEVELOPER.md](DEVELOPER.md) untuk panduan lengkap development setup.

### Q: Bagaimana cara contribute ke project?
**A:**
1. Fork repository
2. Create feature branch
3. Make changes
4. Submit pull request
5. Follow coding standards

### Q: Testing framework apa yang digunakan?
**A:** Django built-in testing framework. Run tests dengan:
```bash
docker-compose exec web python manage.py test
```

## 🆘 Getting Help

### Q: Dimana bisa mendapat bantuan lebih lanjut?
**A:** 
1. Baca dokumentasi lengkap: [DOCUMENTATION.md](DOCUMENTATION.md)
2. Check troubleshooting: bagian bawah FAQ ini
3. Create issue di GitHub repository
4. Contact administrator

### Q: Bagaimana cara melaporkan bug?
**A:**
1. Buat issue di GitHub dengan template:
   - Deskripsi bug
   - Steps to reproduce
   - Expected vs actual behavior
   - Screenshots (jika perlu)
   - Environment info

### Q: Feature request bisa disubmit dimana?
**A:** Submit feature request via GitHub issues dengan label "enhancement".

---

## 🔧 Quick Troubleshooting

### Container Issues
```bash
# Check container status
docker-compose ps

# View logs
docker-compose logs -f

# Restart services
docker-compose restart

# Full reset
docker-compose down -v
docker-compose up -d --build
```

### Permission Issues
```bash
# Fix file permissions
sudo chown -R $USER:$USER .
chmod +x start.sh
```

### Database Issues
```bash
# Reset database
docker-compose down -v
docker-compose up -d

# Manual migration
docker-compose exec web python manage.py migrate --fake-initial
```

### Performance Issues
```bash
# Monitor resources
docker stats

# Check slow queries
docker-compose logs db | grep "long query time"
```

---

**❓ FAQ - Room Booking System**

**Navigation**: [📋 Index](README.md) | [📚 User Manual](DOCUMENTATION.md) | [🔧 Developer](DEVELOPER.md) | [🚀 Deployment](DEPLOYMENT.md)

*Tidak menemukan jawaban yang dicari? Silakan buat issue di GitHub repository atau baca [User Manual](DOCUMENTATION.md) untuk panduan lengkap.*
