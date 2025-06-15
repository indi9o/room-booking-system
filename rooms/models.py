from django.db import models
from django.contrib.auth.models import User
from django.urls import reverse
from django.core.exceptions import ValidationError
from django.utils import timezone

class Room(models.Model):
    """Model untuk ruangan"""
    name = models.CharField(max_length=100, verbose_name="Nama Ruangan")
    description = models.TextField(blank=True, verbose_name="Deskripsi")
    capacity = models.PositiveIntegerField(verbose_name="Kapasitas")
    location = models.CharField(max_length=200, verbose_name="Lokasi")
    facilities = models.TextField(blank=True, verbose_name="Fasilitas")
    image = models.ImageField(upload_to='rooms/', blank=True, null=True, verbose_name="Gambar")
    is_active = models.BooleanField(default=True, verbose_name="Aktif")
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        verbose_name = "Ruangan"
        verbose_name_plural = "Ruangan"
        ordering = ['name']

    def __str__(self):
        return self.name

    def get_absolute_url(self):
        return reverse('room_detail', kwargs={'pk': self.pk})


class Booking(models.Model):
    """Model untuk pemesanan ruangan"""
    STATUS_CHOICES = [
        ('pending', 'Menunggu'),
        ('approved', 'Disetujui'),
        ('rejected', 'Ditolak'),
        ('cancelled', 'Dibatalkan'),
        ('completed', 'Selesai'),
    ]

    user = models.ForeignKey(User, on_delete=models.CASCADE, verbose_name="Pengguna")
    room = models.ForeignKey(Room, on_delete=models.CASCADE, verbose_name="Ruangan")
    title = models.CharField(max_length=200, verbose_name="Judul Acara")
    description = models.TextField(blank=True, verbose_name="Deskripsi Acara")
    start_datetime = models.DateTimeField(verbose_name="Waktu Mulai")
    end_datetime = models.DateTimeField(verbose_name="Waktu Selesai")
    participants = models.PositiveIntegerField(verbose_name="Jumlah Peserta")
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='pending', verbose_name="Status")
    notes = models.TextField(blank=True, verbose_name="Catatan")
    approved_by = models.ForeignKey(
        User, 
        on_delete=models.SET_NULL, 
        null=True, 
        blank=True, 
        related_name='approved_bookings',
        verbose_name="Disetujui Oleh"
    )
    approved_at = models.DateTimeField(null=True, blank=True, verbose_name="Waktu Persetujuan")
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        verbose_name = "Pemesanan"
        verbose_name_plural = "Pemesanan"
        ordering = ['-created_at']

    def __str__(self):
        return f"{self.title} - {self.room.name} ({self.start_datetime.strftime('%d/%m/%Y %H:%M')})"

    def clean(self):
        """Validasi data booking"""
        if self.start_datetime and self.end_datetime:
            # Pastikan waktu mulai sebelum waktu selesai
            if self.start_datetime >= self.end_datetime:
                raise ValidationError("Waktu mulai harus sebelum waktu selesai.")
            
            # Pastikan tidak booking di masa lalu
            if self.start_datetime < timezone.now():
                raise ValidationError("Tidak dapat melakukan booking di masa lalu.")
            
            # Pastikan jumlah peserta tidak melebihi kapasitas ruangan
            if self.participants > self.room.capacity:
                raise ValidationError(f"Jumlah peserta ({self.participants}) melebihi kapasitas ruangan ({self.room.capacity}).")
            
            # Cek konflik jadwal
            conflicting_bookings = Booking.objects.filter(
                room=self.room,
                status__in=['approved', 'pending'],
                start_datetime__lt=self.end_datetime,
                end_datetime__gt=self.start_datetime
            )
            
            # Exclude booking yang sedang diedit
            if self.pk:
                conflicting_bookings = conflicting_bookings.exclude(pk=self.pk)
            
            if conflicting_bookings.exists():
                raise ValidationError("Terdapat konflik jadwal dengan booking yang sudah ada.")

    def save(self, *args, **kwargs):
        self.full_clean()
        super().save(*args, **kwargs)

    @property
    def duration(self):
        """Menghitung durasi booking dalam jam"""
        if self.start_datetime and self.end_datetime:
            duration = self.end_datetime - self.start_datetime
            return duration.total_seconds() / 3600
        return 0

    @property
    def is_past(self):
        """Mengecek apakah booking sudah lewat"""
        return self.end_datetime < timezone.now()

    @property
    def is_ongoing(self):
        """Mengecek apakah booking sedang berlangsung"""
        now = timezone.now()
        return self.start_datetime <= now <= self.end_datetime

    def get_absolute_url(self):
        return reverse('booking_detail', kwargs={'pk': self.pk})


class BookingHistory(models.Model):
    """Model untuk menyimpan riwayat perubahan status booking"""
    booking = models.ForeignKey(Booking, on_delete=models.CASCADE, related_name='history')
    old_status = models.CharField(max_length=20, verbose_name="Status Lama")
    new_status = models.CharField(max_length=20, verbose_name="Status Baru")
    changed_by = models.ForeignKey(User, on_delete=models.CASCADE, verbose_name="Diubah Oleh")
    notes = models.TextField(blank=True, verbose_name="Catatan")
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        verbose_name = "Riwayat Booking"
        verbose_name_plural = "Riwayat Booking"
        ordering = ['-created_at']

    def __str__(self):
        return f"{self.booking.title} - {self.old_status} → {self.new_status}"
