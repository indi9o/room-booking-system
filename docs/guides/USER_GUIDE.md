# 📖 User Guide - Room Booking System

Panduan lengkap penggunaan Room Booking System untuk pengguna umum.

## 🎯 Pendahuluan

Room Booking System adalah aplikasi web untuk memesan ruangan secara online. Aplikasi ini memungkinkan pengguna untuk:
- Melihat daftar ruangan yang tersedia
- Membuat booking ruangan
- Mengelola booking yang sudah dibuat
- Melihat status persetujuan booking

## 🚀 Memulai

### 1. Akses Aplikasi
- Buka browser dan akses: `http://localhost:8001`
- Atau sesuai URL yang diberikan admin

### 2. Registrasi Akun
1. Klik **"Register"** di halaman utama
2. Isi form registrasi:
   - Username
   - Email
   - Password
   - Konfirmasi Password
3. Klik **"Daftar"**
4. Anda akan otomatis login setelah registrasi berhasil

### 3. Login
1. Klik **"Login"** 
2. Masukkan username dan password
3. Klik **"Masuk"**

## 🏢 Melihat Ruangan

### Daftar Ruangan
- Klik **"Ruangan"** di menu navigasi
- Lihat daftar ruangan dengan informasi:
  - Nama ruangan
  - Lokasi
  - Kapasitas
  - Fasilitas

### Detail Ruangan
- Klik ruangan untuk melihat detail lengkap
- Informasi yang tersedia:
  - Foto ruangan
  - Deskripsi detail
  - Fasilitas lengkap
  - Kapasitas maksimal

### Pencarian Ruangan
- Gunakan kotak pencarian di halaman daftar ruangan
- Pencarian berdasarkan:
  - Nama ruangan
  - Lokasi
  - Deskripsi

## 📅 Membuat Booking

### Cara Booking Ruangan

#### Metode 1: Dari Detail Ruangan
1. Buka detail ruangan yang ingin dipesan
2. Klik **"Pesan Ruangan"**
3. Isi form booking

#### Metode 2: Dari Menu Booking
1. Klik **"Buat Booking"** di menu navigasi
2. Pilih ruangan dari dropdown
3. Isi form booking

### Form Booking
Isi semua field yang diperlukan:

- **Judul Acara**: Nama acara/kegiatan
- **Ruangan**: Pilih ruangan yang diinginkan
- **Tanggal Mulai**: Tanggal dan jam mulai
- **Tanggal Selesai**: Tanggal dan jam selesai
- **Jumlah Peserta**: Jumlah orang yang akan hadir
- **Deskripsi**: Detail tambahan acara (opsional)

### Validasi Booking
Sistem akan memvalidasi:
- ✅ Waktu mulai harus sebelum waktu selesai
- ✅ Tidak boleh booking di masa lalu
- ✅ Jumlah peserta tidak melebihi kapasitas ruangan
- ✅ Tidak ada konflik dengan booking lain

### Submit Booking
1. Pastikan semua data sudah benar
2. Klik **"Buat Booking"**
3. Booking akan berstatus **"Menunggu Persetujuan"**

## 📋 Mengelola Booking

### Melihat Daftar Booking
- Klik **"Booking Saya"** di menu navigasi
- Lihat semua booking yang pernah dibuat
- Filter berdasarkan status jika diperlukan

### Status Booking
Booking memiliki 5 status:
- 🟡 **Menunggu**: Menunggu persetujuan staff
- 🟢 **Disetujui**: Booking telah disetujui
- 🔴 **Ditolak**: Booking ditolak dengan alasan
- ⚫ **Dibatalkan**: Booking dibatalkan oleh pengguna
- 🔵 **Selesai**: Acara telah selesai

### Detail Booking
Klik booking untuk melihat detail:
- Informasi lengkap booking
- Status dan waktu persetujuan
- Alasan penolakan (jika ada)
- Riwayat perubahan status

### Edit Booking
Untuk booking yang berstatus **"Menunggu"**:
1. Buka detail booking
2. Klik **"Edit Booking"**
3. Ubah informasi yang diperlukan
4. Klik **"Update Booking"**

### Batalkan Booking
Untuk booking yang berstatus **"Menunggu"**:
1. Buka detail booking
2. Klik **"Batalkan"**
3. Konfirmasi pembatalan
4. Status akan berubah menjadi **"Dibatalkan"**

## 🔔 Notifikasi & Status

### Pesan Sistem
Aplikasi akan menampilkan pesan untuk:
- ✅ Booking berhasil dibuat
- ✅ Booking berhasil diupdate
- ⚠️ Error validasi
- ℹ️ Informasi status perubahan

### Status Persetujuan
Setelah submit booking:
1. **Menunggu**: Staff akan review booking Anda
2. **Disetujui**: Anda akan mendapat notifikasi persetujuan
3. **Ditolak**: Anda akan melihat alasan penolakan

## 💡 Tips Penggunaan

### Booking yang Efektif
- 📝 Berikan judul acara yang jelas
- 📅 Periksa ketersediaan ruangan terlebih dahulu
- 👥 Pastikan jumlah peserta sesuai kapasitas
- ⏰ Booking jauh-jauh hari untuk memastikan ketersediaan

### Menghindari Konflik
- 🔍 Cek jadwal ruangan sebelum booking
- ⏱️ Berikan buffer waktu setup/cleanup
- 📞 Koordinasi dengan staff jika ada kebutuhan khusus

### Etika Booking
- 🚫 Jangan booking ruangan yang tidak digunakan
- ⏰ Batalkan booking jika tidak jadi digunakan
- 📝 Berikan deskripsi yang akurat
- 🤝 Hormati pengguna lain

## ❓ FAQ

**Q: Berapa lama booking saya akan diproses?**
A: Biasanya dalam 1-2 hari kerja. Staff akan review dan memberikan persetujuan.

**Q: Apakah saya bisa booking recurring/berulang?**
A: Saat ini sistem belum support booking berulang. Buat booking terpisah untuk setiap tanggal.

**Q: Bagaimana jika ruangan yang saya inginkan tidak tersedia?**
A: Coba waktu lain atau ruangan alternatif. Anda juga bisa menghubungi staff.

**Q: Bisakah saya mengubah booking yang sudah disetujui?**
A: Tidak bisa melalui sistem. Hubungi staff untuk perubahan booking yang sudah disetujui.

**Q: Apakah ada biaya untuk booking ruangan?**
A: Tergantung kebijakan organisasi. Informasi biaya akan diberikan oleh staff.

## 🆘 Bantuan

Jika mengalami kesulitan:
1. 📖 Periksa [FAQ](../faq.md)
2. 🔧 Lihat [Troubleshooting](../troubleshooting.md)
3. 📞 Hubungi admin/staff
4. 📧 Kirim email ke support

---

**Selamat menggunakan Room Booking System!** 🎉
