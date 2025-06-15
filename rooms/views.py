from django.shortcuts import render, get_object_or_404, redirect
from django.contrib.auth.decorators import login_required
from django.contrib.auth import login
from django.contrib import messages
from django.db.models import Q
from django.utils import timezone
from django.core.paginator import Paginator
from django.http import JsonResponse
from django.views.generic import ListView, DetailView
from django.contrib.auth.mixins import LoginRequiredMixin
from .models import Room, Booking, BookingHistory
from .forms import CustomUserCreationForm, BookingForm, BookingUpdateForm, BookingStatusForm, RoomForm

def register(request):
    """View untuk registrasi user baru"""
    if request.method == 'POST':
        form = CustomUserCreationForm(request.POST)
        if form.is_valid():
            user = form.save()
            login(request, user)
            messages.success(request, 'Akun berhasil dibuat!')
            return redirect('home')
    else:
        form = CustomUserCreationForm()
    return render(request, 'registration/register.html', {'form': form})

class RoomListView(ListView):
    """View untuk menampilkan daftar ruangan"""
    model = Room
    template_name = 'rooms/room_list.html'
    context_object_name = 'rooms'
    paginate_by = 9

    def get_queryset(self):
        queryset = Room.objects.filter(is_active=True)
        search = self.request.GET.get('search')
        if search:
            queryset = queryset.filter(
                Q(name__icontains=search) |
                Q(location__icontains=search) |
                Q(description__icontains=search)
            )
        return queryset

class RoomDetailView(DetailView):
    """View untuk detail ruangan"""
    model = Room
    template_name = 'rooms/room_detail.html'
    context_object_name = 'room'

    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        # Ambil booking yang akan datang untuk ruangan ini
        upcoming_bookings = Booking.objects.filter(
            room=self.object,
            status='approved',
            start_datetime__gte=timezone.now()
        ).order_by('start_datetime')[:5]
        context['upcoming_bookings'] = upcoming_bookings
        return context

def home(request):
    """View untuk halaman utama"""
    rooms = Room.objects.filter(is_active=True)[:6]
    recent_bookings = None
    
    if request.user.is_authenticated:
        recent_bookings = Booking.objects.filter(user=request.user).order_by('-created_at')[:3]
    
    context = {
        'rooms': rooms,
        'recent_bookings': recent_bookings,
    }
    return render(request, 'rooms/home.html', context)

@login_required
def create_booking(request, room_id=None):
    """View untuk membuat booking baru"""
    room = None
    if room_id:
        room = get_object_or_404(Room, id=room_id, is_active=True)
    
    if request.method == 'POST':
        form = BookingForm(request.POST, user=request.user)
        if form.is_valid():
            booking = form.save(commit=False)
            booking.user = request.user
            try:
                booking.save()
                messages.success(request, 'Booking berhasil dibuat!')
                return redirect('booking_detail', pk=booking.pk)
            except Exception as e:
                messages.error(request, f'Error: {str(e)}')
    else:
        initial_data = {}
        if room:
            initial_data['room'] = room
        form = BookingForm(initial=initial_data, user=request.user)
    
    return render(request, 'rooms/create_booking.html', {
        'form': form,
        'room': room
    })

class BookingListView(LoginRequiredMixin, ListView):
    """View untuk menampilkan daftar booking user"""
    model = Booking
    template_name = 'rooms/booking_list.html'
    context_object_name = 'bookings'
    paginate_by = 10

    def get_queryset(self):
        queryset = Booking.objects.filter(user=self.request.user).order_by('-created_at')
        status = self.request.GET.get('status')
        if status:
            queryset = queryset.filter(status=status)
        return queryset

class BookingDetailView(LoginRequiredMixin, DetailView):
    """View untuk detail booking"""
    model = Booking
    template_name = 'rooms/booking_detail.html'
    context_object_name = 'booking'

    def get_queryset(self):
        return Booking.objects.filter(user=self.request.user)

    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        context['history'] = self.object.history.all()
        return context

@login_required
def update_booking(request, pk):
    """View untuk mengupdate booking"""
    booking = get_object_or_404(Booking, pk=pk, user=request.user)
    
    # Hanya bisa edit jika status pending atau belum lewat
    if booking.status != 'pending' or booking.is_past:
        messages.error(request, 'Booking tidak dapat diubah.')
        return redirect('booking_detail', pk=pk)
    
    if request.method == 'POST':
        form = BookingUpdateForm(request.POST, instance=booking)
        if form.is_valid():
            try:
                form.save()
                messages.success(request, 'Booking berhasil diupdate!')
                return redirect('booking_detail', pk=pk)
            except Exception as e:
                messages.error(request, f'Error: {str(e)}')
    else:
        form = BookingUpdateForm(instance=booking)
    
    return render(request, 'rooms/update_booking.html', {
        'form': form,
        'booking': booking
    })

@login_required
def cancel_booking(request, pk):
    """View untuk membatalkan booking"""
    booking = get_object_or_404(Booking, pk=pk, user=request.user)
    
    if booking.status not in ['pending', 'approved'] or booking.is_past:
        messages.error(request, 'Booking tidak dapat dibatalkan.')
        return redirect('booking_detail', pk=pk)
    
    if request.method == 'POST':
        old_status = booking.status
        booking.status = 'cancelled'
        booking.save()
        
        # Simpan history
        BookingHistory.objects.create(
            booking=booking,
            old_status=old_status,
            new_status='cancelled',
            changed_by=request.user,
            notes='Dibatalkan oleh user'
        )
        
        messages.success(request, 'Booking berhasil dibatalkan.')
        return redirect('booking_detail', pk=pk)
    
    return render(request, 'rooms/cancel_booking.html', {'booking': booking})

@login_required
def create_room(request):
    """View untuk membuat ruangan baru"""
    if not request.user.is_staff:
        messages.error(request, 'Anda tidak memiliki akses untuk menambah ruangan.')
        return redirect('room_list')
    
    if request.method == 'POST':
        form = RoomForm(request.POST, request.FILES)
        if form.is_valid():
            room = form.save()
            messages.success(request, f'Ruangan "{room.name}" berhasil ditambahkan!')
            return redirect('room_detail', pk=room.pk)
    else:
        form = RoomForm()
    
    return render(request, 'rooms/create_room.html', {'form': form})

def check_availability(request):
    """AJAX view untuk mengecek ketersediaan ruangan"""
    room_id = request.GET.get('room_id')
    start_datetime = request.GET.get('start_datetime')
    end_datetime = request.GET.get('end_datetime')
    booking_id = request.GET.get('booking_id')  # untuk exclude saat edit
    
    if not all([room_id, start_datetime, end_datetime]):
        return JsonResponse({'available': False, 'message': 'Parameter tidak lengkap'})
    
    try:
        from datetime import datetime
        start_dt = datetime.fromisoformat(start_datetime.replace('Z', '+00:00'))
        end_dt = datetime.fromisoformat(end_datetime.replace('Z', '+00:00'))
        
        conflicting_bookings = Booking.objects.filter(
            room_id=room_id,
            status__in=['approved', 'pending'],
            start_datetime__lt=end_dt,
            end_datetime__gt=start_dt
        )
        
        if booking_id:
            conflicting_bookings = conflicting_bookings.exclude(id=booking_id)
        
        if conflicting_bookings.exists():
            return JsonResponse({
                'available': False,
                'message': 'Ruangan tidak tersedia pada waktu tersebut'
            })
        else:
            return JsonResponse({'available': True, 'message': 'Ruangan tersedia'})
    
    except Exception as e:
        return JsonResponse({'available': False, 'message': f'Error: {str(e)}'})
