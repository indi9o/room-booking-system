from django.urls import path
from . import views
from .health import health_check, health_check_detailed

urlpatterns = [
    path('', views.home, name='home'),
    path('register/', views.register, name='register'),
    
    # Room URLs
    path('rooms/', views.RoomListView.as_view(), name='room_list'),
    path('rooms/create/', views.create_room, name='create_room'),
    path('rooms/<int:pk>/', views.RoomDetailView.as_view(), name='room_detail'),
    
    # Booking URLs
    path('bookings/', views.BookingListView.as_view(), name='booking_list'),
    path('bookings/<int:pk>/', views.BookingDetailView.as_view(), name='booking_detail'),
    path('bookings/create/', views.create_booking, name='create_booking'),
    path('bookings/create/<int:room_id>/', views.create_booking, name='create_booking_room'),
    path('bookings/<int:pk>/update/', views.update_booking, name='update_booking'),
    path('bookings/<int:pk>/cancel/', views.cancel_booking, name='cancel_booking'),
    
    # Approval URLs (untuk staff)
    path('bookings/<int:pk>/approve/', views.approve_booking, name='approve_booking'),
    path('bookings/<int:pk>/reject/', views.reject_booking, name='reject_booking'),
    path('manage-bookings/', views.manage_bookings, name='manage_bookings'),
    
    # AJAX URLs
    path('ajax/check-availability/', views.check_availability, name='check_availability'),
    
    # Monitoring & Health Check URLs
    path('health/', health_check, name='health_check'),
    path('health/detailed/', health_check_detailed, name='health_check_detailed'),
    path('metrics/', views.metrics, name='metrics'),
]
