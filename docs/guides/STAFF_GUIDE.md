# 👨‍💼 Staff Guide - Sistem Persetujuan Booking

Panduan lengkap untuk staff dalam mengelola dan menyetujui booking ruangan.

## 🎯 Pendahuluan

Sebagai staff, Anda memiliki akses khusus untuk:
- Mengelola semua booking ruangan
- Menyetujui atau menolak booking
- Melihat dashboard management
- Mengakses laporan dan statistik

## 🔐 Akses Staff

### Login Staff
1. Login menggunakan akun dengan privilege staff
2. Menu khusus staff akan muncul di navigasi:
   - **"Kelola Booking"** - Dashboard management
   - **"Tambah Ruangan"** - Menambah ruangan baru

### Verifikasi Akses
Pastikan akun Anda memiliki status `is_staff = True` di database.

## 📊 Dashboard Management

### Akses Dashboard
- Klik **"Kelola Booking"** di menu navigasi
- Atau akses langsung: `/manage-bookings/`

### Fitur Dashboard
Dashboard staff menyediakan:
- 📋 Daftar semua booking (semua pengguna)
- 🔍 Filter berdasarkan status dan ruangan
- 🎯 Aksi approve/reject langsung
- 📄 Pagination untuk performa optimal

### Filter Booking
**Filter Status:**
- Semua Status
- Menunggu Persetujuan
- Disetujui
- Ditolak
- Dibatalkan
- Selesai

**Filter Ruangan:**
- Semua Ruangan
- Ruangan spesifik

### Informasi yang Ditampilkan
Untuk setiap booking:
- 📝 Judul acara dan deskripsi
- 👤 Nama pemohon dan email
- 🏢 Ruangan yang dipesan
- ⏰ Waktu mulai dan selesai
- 🏷️ Status saat ini
- 📅 Waktu booking dibuat

## ✅ Menyetujui Booking

### Cara Menyetujui
**Dari Dashboard:**
1. Temukan booking dengan status "Menunggu"
2. Klik **"Setujui"** di kolom aksi
3. Konfirmasi persetujuan
4. Status otomatis berubah menjadi "Disetujui"

**Dari Detail Booking:**
1. Klik **"Detail"** pada booking
2. Klik **"Setujui"** di halaman detail
3. Konfirmasi persetujuan

### Apa yang Terjadi Setelah Approve
- ✅ Status booking berubah menjadi "Disetujui"
- 📝 Field `approved_by` diisi dengan nama staff
- ⏰ Field `approved_at` diisi dengan timestamp
- 📊 History record dibuat untuk audit trail
- 💬 User mendapat feedback melalui sistem

## ❌ Menolak Booking

### Cara Menolak
**Dari Dashboard:**
1. Temukan booking dengan status "Menunggu"
2. Klik **"Tolak"** di kolom aksi
3. Isi form alasan penolakan

**Dari Detail Booking:**
1. Klik **"Detail"** pada booking
2. Klik **"Tolak"** di halaman detail
3. Isi form alasan penolakan

### Form Penolakan
- **Alasan Penolakan**: Field wajib diisi
- Berikan alasan yang jelas dan konstruktif
- Alasan akan dilihat oleh user

### Contoh Alasan Penolakan
✅ **Alasan yang Baik:**
- "Ruangan sudah ada booking maintenance pada waktu tersebut"
- "Jumlah peserta melebihi kapasitas aman ruangan (COVID protocol)"
- "Acara tidak sesuai dengan peruntukan ruangan"
- "Waktu booking bertabrakan dengan acara prioritas tinggi"

❌ **Alasan yang Kurang Baik:**
- "Tidak bisa"
- "Tolak saja"
- "Ruangan penuh" (tanpa detail)

### Apa yang Terjadi Setelah Reject
- ❌ Status booking berubah menjadi "Ditolak"
- 📝 Alasan penolakan disimpan di field `notes`
- 📊 History record dibuat
- 💬 User dapat melihat alasan penolakan

## 📋 Detail Booking (Staff View)

### Informasi Tambahan Staff
Saat melihat detail booking, staff dapat melihat:
- 👤 Informasi lengkap user
- 📞 Kontak user (jika ada)
- 📊 History lengkap perubahan status
- 🔍 Audit trail semua perubahan

### Tombol Aksi Staff
Di halaman detail booking:
- ✅ **"Setujui"** - Untuk booking pending
- ❌ **"Tolak"** - Untuk booking pending  
- 🔗 **"Kelola Semua Booking"** - Kembali ke dashboard

## 📊 Audit Trail & History

### BookingHistory
Setiap aksi staff dicatat:
- 🕐 Waktu perubahan status
- 👤 Staff yang melakukan perubahan
- 📝 Status lama → status baru
- 💭 Catatan tambahan

### Cara Melihat History
1. Buka detail booking
2. Scroll ke bagian **"Riwayat Status"**
3. Lihat chronological history

## 🎯 Best Practices

### Pengelolaan Booking Efektif
- 📅 Review booking secara rutin (harian/2 hari sekali)
- ⚡ Berikan respons yang cepat untuk user experience
- 📝 Berikan alasan penolakan yang jelas dan membantu
- 🔍 Periksa konflik jadwal dengan teliti

### Komunikasi dengan User
- 💬 Gunakan bahasa yang sopan dan profesional
- 📋 Berikan alternatif jika menolak booking
- 📞 Hubungi user langsung untuk kasus kompleks
- 📧 Follow up jika diperlukan

### Keamanan & Authorization
- 🔐 Jangan share akses staff dengan non-staff
- 👥 Koordinasi dengan staff lain untuk konsistensi
- 📊 Regular review untuk keputusan yang fair
- 🚫 Hindari bias dalam persetujuan

## 🔧 Troubleshooting

### Masalah Umum

**Q: Tidak bisa mengakses dashboard management**
A: Pastikan akun memiliki `is_staff = True`. Hubungi admin.

**Q: Tombol approve/reject tidak muncul**
A: Hanya muncul untuk booking dengan status "Menunggu".

**Q: Error saat approve booking**
A: Periksa apakah booking masih berstatus "Menunggu" dan tidak ada konflik.

**Q: Form penolakan tidak bisa disubmit**
A: Pastikan field "Alasan Penolakan" sudah diisi.

### Error Handling
Jika terjadi error:
1. 🔄 Refresh halaman
2. 🔍 Periksa status booking terkini
3. 📞 Hubungi admin jika masalah persisten
4. 📧 Report bug melalui sistem ticketing

## 📈 Monitoring & Reports

### Metrik yang Perlu Diperhatikan
- 📊 Jumlah booking per hari/minggu
- ⚡ Response time approval
- 📈 Approval rate vs rejection rate
- 🏢 Utilization rate per ruangan

### Akses Reports
- 📊 Dashboard analytics (jika tersedia)
- 📈 Export data untuk analysis
- 📋 Regular reports ke management

## 🆘 Bantuan & Escalation

### Kapan Escalate ke Admin
- 🚨 Booking dengan requirement khusus
- 🔧 Technical issues yang tidak bisa diselesaikan
- 👥 Konflik antar user
- 📋 Policy clarification

### Kontak
- 📞 Admin: [kontak admin]
- 📧 IT Support: [email support]
- 💬 Internal chat/communication tool

---

**Terima kasih atas dedikasi Anda sebagai staff!** 🙏  
**Kontribusi Anda sangat penting untuk kelancaran sistem booking ruangan.** ⭐
