# 📅 Booking System - Room Booking System

Dokumentasi lengkap sistem pemesanan ruangan (Booking System).

## 🎯 Overview

Sistem booking memungkinkan pengguna untuk memesan ruangan dengan validasi otomatis, approval workflow, dan manajemen konflik jadwal.

## ✨ Features

### Core Features
- ✅ **Create Booking** - Membuat pemesanan ruangan baru
- 📋 **View Bookings** - Melihat daftar booking pribadi
- ✏️ **Edit Booking** - Mengubah booking yang belum disetujui
- ❌ **Cancel Booking** - Membatalkan booking
- 🔍 **Availability Check** - Pengecekan ketersediaan real-time
- 📊 **Booking History** - Riwayat semua aktivitas booking

### Advanced Features
- ✅ **Approval Workflow** - Staff dapat approve/reject booking
- 🤖 **Conflict Detection** - Deteksi otomatis konflik jadwal
- 📱 **AJAX Validation** - Validasi real-time tanpa reload
- 📈 **Audit Trail** - Pencatatan lengkap perubahan status
- 🔔 **Status Notifications** - Feedback real-time untuk user

## 🏗️ Architecture

### Models
```python
class Booking(models.Model):
    user = models.ForeignKey(User)           # Pembuat booking
    room = models.ForeignKey(Room)           # Ruangan yang dipesan
    title = models.CharField(max_length=200) # Judul acara
    description = models.TextField()         # Deskripsi acara
    start_datetime = models.DateTimeField()  # Waktu mulai
    end_datetime = models.DateTimeField()    # Waktu selesai
    participants = models.PositiveIntegerField() # Jumlah peserta
    status = models.CharField(max_length=20) # Status booking
    notes = models.TextField()               # Catatan staff
    approved_by = models.ForeignKey(User)    # Staff yang approve
    approved_at = models.DateTimeField()     # Waktu approval
    created_at = models.DateTimeField()      # Waktu dibuat
    updated_at = models.DateTimeField()      # Waktu update
```

### Status Flow
```
[Pending] → [Approved] → [Completed]
    ↓
[Rejected]
    ↓
[Cancelled]
```

## 📝 Booking Process

### 1. Create Booking
**User Flow:**
1. User login dan akses form booking
2. Pilih ruangan dan waktu
3. Isi detail acara
4. Submit form
5. Status awal: **"Pending"**

**Validations:**
- ✅ User harus login
- ✅ Waktu mulai < waktu selesai
- ✅ Tidak boleh booking di masa lalu
- ✅ Peserta ≤ kapasitas ruangan
- ✅ Tidak ada konflik dengan booking lain

### 2. Staff Review
**Staff Flow:**
1. Staff akses dashboard `/manage-bookings/`
2. Review booking dengan status "Pending"
3. Approve atau reject dengan alasan
4. Status berubah sesuai keputusan

### 3. User Notification
**Notification Flow:**
- ✅ **Approved**: User melihat status "Disetujui"
- ❌ **Rejected**: User melihat alasan penolakan
- 📝 **Updated**: History tercatat untuk audit

## 🔍 Technical Implementation

### Views
```python
@login_required
def create_booking(request, room_id=None):
    """Create new booking"""
    # Form handling and validation
    
@login_required
def update_booking(request, pk):
    """Update existing booking (only if pending)"""
    # Check ownership and status
    
@login_required
def cancel_booking(request, pk):
    """Cancel booking (only if pending)"""
    # Update status to cancelled
    
def check_availability(request):
    """AJAX endpoint for availability check"""
    # Real-time conflict detection
```

### Forms
```python
class BookingForm(forms.ModelForm):
    class Meta:
        model = Booking
        fields = ['room', 'title', 'description', 
                 'start_datetime', 'end_datetime', 'participants']
    
    def clean(self):
        """Custom validation logic"""
        # Time validation
        # Capacity validation
        # Conflict detection
```

### URLs
```python
urlpatterns = [
    path('bookings/', BookingListView.as_view(), name='booking_list'),
    path('bookings/<int:pk>/', BookingDetailView.as_view(), name='booking_detail'),
    path('bookings/create/', create_booking, name='create_booking'),
    path('bookings/create/<int:room_id>/', create_booking, name='create_booking_room'),
    path('bookings/<int:pk>/update/', update_booking, name='update_booking'),
    path('bookings/<int:pk>/cancel/', cancel_booking, name='cancel_booking'),
    path('ajax/check-availability/', check_availability, name='check_availability'),
]
```

## 🎨 User Interface

### Booking Form
**Features:**
- 📅 Date/time picker dengan validasi
- 🏢 Dropdown ruangan dengan info kapasitas
- 👥 Input jumlah peserta dengan validasi real-time
- 🔍 AJAX availability check
- 📝 Rich text description

**JavaScript Integration:**
```javascript
// Real-time availability check
$('#id_start_datetime, #id_end_datetime, #id_room').change(function() {
    checkAvailability();
});

function checkAvailability() {
    $.ajax({
        url: '/ajax/check-availability/',
        data: {
            'room': $('#id_room').val(),
            'start': $('#id_start_datetime').val(),
            'end': $('#id_end_datetime').val(),
        },
        success: function(data) {
            if (data.available) {
                showSuccess('Ruangan tersedia!');
            } else {
                showError(data.message);
            }
        }
    });
}
```

### Booking List
**Features:**
- 📊 Card-based layout dengan status colors
- 🔍 Search dan filter functionality
- 📄 Pagination untuk performa optimal
- 🎯 Quick actions (edit, cancel, view)

### Booking Detail
**Features:**
- 📋 Comprehensive booking information
- 👤 User dan staff information
- 📅 Formatted date/time display
- 📊 Status history dengan timeline
- 🎯 Action buttons berdasarkan role dan status

## 🔐 Security & Permissions

### Access Control
```python
# User dapat akses booking sendiri
if booking.user != request.user and not request.user.is_staff:
    return HttpResponseForbidden()

# Hanya staff yang bisa approve/reject
@staff_required
def approve_booking(request, pk):
    # Staff-only actions
```

### Data Validation
```python
def clean(self):
    # Time validation
    if self.start_datetime >= self.end_datetime:
        raise ValidationError("Waktu mulai harus sebelum waktu selesai")
    
    # Past booking prevention
    if self.start_datetime < timezone.now():
        raise ValidationError("Tidak dapat booking di masa lalu")
    
    # Capacity validation
    if self.participants > self.room.capacity:
        raise ValidationError("Peserta melebihi kapasitas ruangan")
    
    # Conflict detection
    conflicts = Booking.objects.filter(
        room=self.room,
        status__in=['approved', 'pending'],
        start_datetime__lt=self.end_datetime,
        end_datetime__gt=self.start_datetime
    ).exclude(pk=self.pk)
    
    if conflicts.exists():
        raise ValidationError("Terdapat konflik jadwal")
```

## 📊 Analytics & Reporting

### Booking Metrics
```python
def booking_stats():
    return {
        'total_bookings': Booking.objects.count(),
        'pending_bookings': Booking.objects.filter(status='pending').count(),
        'approved_rate': Booking.objects.filter(status='approved').count() / Booking.objects.count() * 100,
        'popular_rooms': Room.objects.annotate(booking_count=Count('booking')).order_by('-booking_count')[:5],
        'peak_hours': get_peak_usage_hours(),
    }
```

### Room Utilization
```python
def room_utilization(room, start_date, end_date):
    total_hours = (end_date - start_date).total_seconds() / 3600
    booked_bookings = Booking.objects.filter(
        room=room,
        status='approved',
        start_datetime__gte=start_date,
        end_datetime__lte=end_date
    )
    
    booked_hours = sum([
        (booking.end_datetime - booking.start_datetime).total_seconds() / 3600
        for booking in booked_bookings
    ])
    
    return (booked_hours / total_hours) * 100
```

## 🧪 Testing

### Unit Tests
```python
class BookingModelTest(TestCase):
    def test_booking_validation(self):
        # Test time validation
        # Test capacity validation
        # Test conflict detection
    
    def test_booking_status_flow(self):
        # Test status transitions
        # Test approval workflow
        
class BookingViewTest(TestCase):
    def test_create_booking_authenticated(self):
        # Test booking creation
        
    def test_booking_permissions(self):
        # Test access control
```

### Integration Tests
```python
class BookingIntegrationTest(TestCase):
    def test_booking_workflow(self):
        # Test complete booking flow
        # Create → Review → Approve → Complete
        
    def test_conflict_detection(self):
        # Test overlapping bookings
        # Test edge cases
```

## 🚀 Performance Optimization

### Database Optimization
```python
# Optimized queries
bookings = Booking.objects.select_related('user', 'room', 'approved_by')\
                         .prefetch_related('bookinghistory_set')\
                         .filter(status='pending')

# Database indexes
class Meta:
    indexes = [
        models.Index(fields=['status', 'start_datetime']),
        models.Index(fields=['room', 'start_datetime', 'end_datetime']),
    ]
```

### Caching Strategy
```python
from django.core.cache import cache

def get_room_availability(room_id, date):
    cache_key = f"room_availability_{room_id}_{date}"
    availability = cache.get(cache_key)
    
    if availability is None:
        availability = calculate_availability(room_id, date)
        cache.set(cache_key, availability, timeout=300)  # 5 minutes
    
    return availability
```

## 📱 Mobile Responsiveness

### Responsive Design
- 📱 **Mobile-first** approach
- 🎨 **Bootstrap 5** untuk responsive grid
- 📅 **Mobile-friendly** date/time pickers
- 👆 **Touch-optimized** buttons dan forms

### Progressive Enhancement
```javascript
// Touch-friendly enhancements
if ('ontouchstart' in window) {
    // Add touch-specific interactions
    $('.booking-card').addClass('touch-optimized');
}

// Offline functionality (future enhancement)
if ('serviceWorker' in navigator) {
    navigator.serviceWorker.register('/sw.js');
}
```

## 🔮 Future Enhancements

### Planned Features
- 🔄 **Recurring Bookings** - Weekly/monthly recurring
- 📧 **Email Notifications** - Automated notifications
- 📱 **Mobile App** - Native mobile application
- 🤖 **AI Suggestions** - Smart room recommendations
- 📊 **Advanced Analytics** - Detailed usage reports
- 🔗 **Calendar Integration** - Google/Outlook calendar sync

### Technical Improvements
- ⚡ **Real-time Updates** - WebSocket integration
- 🔍 **Advanced Search** - Full-text search with filters
- 📈 **Performance Monitoring** - APM integration
- 🛡️ **Enhanced Security** - 2FA, rate limiting
- 🌍 **Internationalization** - Multi-language support

---

**Booking System Status**: ✅ Production Ready  
**Last Updated**: June 2025  
**Version**: 1.0.0
