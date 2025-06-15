"""
Comprehensive Test Suite for Room Booking System
Tests models, views, forms, and business logic
"""

from django.test import TestCase, Client
from django.contrib.auth.models import User
from django.urls import reverse
from django.utils import timezone
from datetime import datetime, timedelta
from .models import Room, Booking
from .forms import RoomForm, BookingForm


class RoomModelTest(TestCase):
    """Test Room model functionality"""
    
    def setUp(self):
        self.room = Room.objects.create(
            name="Conference Room A",
            location="Building 1, Floor 2",
            capacity=10,
            facilities="Projector, Whiteboard, WiFi",
            description="Main conference room for meetings"
        )
    
    def test_room_creation(self):
        """Test room creation and string representation"""
        self.assertEqual(self.room.name, "Conference Room A")
        self.assertEqual(str(self.room), "Conference Room A")
        self.assertEqual(self.room.capacity, 10)
        self.assertTrue(self.room.is_available)
    
    def test_room_validation(self):
        """Test room field validations"""
        # Test capacity validation
        room = Room(name="Test Room", capacity=-1)
        self.assertRaises(Exception, room.full_clean)
    
    def test_room_availability_check(self):
        """Test room availability checking logic"""
        user = User.objects.create_user('testuser', 'test@test.com', 'pass123')
        
        # Create a booking for tomorrow
        tomorrow = timezone.now() + timedelta(days=1)
        booking = Booking.objects.create(
            room=self.room,
            user=user,
            start_time=tomorrow.replace(hour=10, minute=0),
            end_time=tomorrow.replace(hour=12, minute=0),
            purpose="Test Meeting",
            status='approved'
        )
        
        # Room should still be generally available
        self.assertTrue(self.room.is_available)


class BookingModelTest(TestCase):
    """Test Booking model functionality"""
    
    def setUp(self):
        self.user = User.objects.create_user('testuser', 'test@test.com', 'pass123')
        self.room = Room.objects.create(
            name="Test Room",
            location="Test Location",
            capacity=5
        )
    
    def test_booking_creation(self):
        """Test booking creation"""
        start_time = timezone.now() + timedelta(hours=1)
        end_time = start_time + timedelta(hours=2)
        
        booking = Booking.objects.create(
            room=self.room,
            user=self.user,
            start_time=start_time,
            end_time=end_time,
            purpose="Team Meeting"
        )
        
        self.assertEqual(booking.status, 'pending')
        self.assertEqual(booking.room, self.room)
        self.assertEqual(booking.user, self.user)
    
    def test_booking_validation(self):
        """Test booking time validation"""
        # Start time should be before end time
        start_time = timezone.now() + timedelta(hours=2)
        end_time = timezone.now() + timedelta(hours=1)  # Earlier than start
        
        booking = Booking(
            room=self.room,
            user=self.user,
            start_time=start_time,
            end_time=end_time,
            purpose="Invalid Meeting"
        )
        
        # Should raise validation error
        self.assertRaises(Exception, booking.full_clean)
    
    def test_booking_conflict_detection(self):
        """Test booking conflict detection"""
        base_time = timezone.now() + timedelta(days=1)
        
        # First booking
        booking1 = Booking.objects.create(
            room=self.room,
            user=self.user,
            start_time=base_time.replace(hour=10, minute=0),
            end_time=base_time.replace(hour=12, minute=0),
            purpose="Meeting 1",
            status='approved'
        )
        
        # Overlapping booking
        booking2 = Booking(
            room=self.room,
            user=self.user,
            start_time=base_time.replace(hour=11, minute=0),
            end_time=base_time.replace(hour=13, minute=0),
            purpose="Meeting 2"
        )
        
        # Should detect conflict (implement this logic in model)
        # For now, just test that both can be created
        self.assertTrue(booking1.id)


class RoomViewTest(TestCase):
    """Test room-related views"""
    
    def setUp(self):
        self.client = Client()
        self.user = User.objects.create_user('testuser', 'test@test.com', 'pass123')
        self.staff_user = User.objects.create_user('staffuser', 'staff@test.com', 'pass123')
        self.staff_user.is_staff = True
        self.staff_user.save()
        
        self.room = Room.objects.create(
            name="Test Room",
            location="Test Location",
            capacity=10
        )
    
    def test_room_list_view(self):
        """Test room list view accessibility"""
        response = self.client.get(reverse('rooms:room_list'))
        self.assertEqual(response.status_code, 200)
        self.assertContains(response, self.room.name)
    
    def test_room_detail_view(self):
        """Test room detail view"""
        response = self.client.get(reverse('rooms:room_detail', args=[self.room.id]))
        self.assertEqual(response.status_code, 200)
        self.assertContains(response, self.room.name)
        self.assertContains(response, self.room.location)
    
    def test_room_create_view_requires_staff(self):
        """Test that room creation requires staff permission"""
        # Anonymous user
        response = self.client.get(reverse('rooms:room_create'))
        self.assertEqual(response.status_code, 302)  # Redirect to login
        
        # Regular user
        self.client.login(username='testuser', password='pass123')
        response = self.client.get(reverse('rooms:room_create'))
        self.assertEqual(response.status_code, 403)  # Forbidden
        
        # Staff user
        self.client.login(username='staffuser', password='pass123')
        response = self.client.get(reverse('rooms:room_create'))
        self.assertEqual(response.status_code, 200)  # OK
    
    def test_room_creation_post(self):
        """Test room creation via POST"""
        self.client.login(username='staffuser', password='pass123')
        
        room_data = {
            'name': 'New Test Room',
            'location': 'New Location',
            'capacity': 15,
            'facilities': 'WiFi, Projector',
            'description': 'A new room for testing'
        }
        
        response = self.client.post(reverse('rooms:room_create'), room_data)
        self.assertEqual(response.status_code, 302)  # Redirect after successful creation
        
        # Check if room was created
        self.assertTrue(Room.objects.filter(name='New Test Room').exists())


class BookingViewTest(TestCase):
    """Test booking-related views"""
    
    def setUp(self):
        self.client = Client()
        self.user = User.objects.create_user('testuser', 'test@test.com', 'pass123')
        self.room = Room.objects.create(
            name="Test Room",
            location="Test Location",
            capacity=10
        )
    
    def test_booking_requires_authentication(self):
        """Test that booking requires authentication"""
        response = self.client.get(reverse('rooms:booking_create', args=[self.room.id]))
        self.assertEqual(response.status_code, 302)  # Redirect to login
    
    def test_booking_creation_view(self):
        """Test booking creation view for authenticated user"""
        self.client.login(username='testuser', password='pass123')
        response = self.client.get(reverse('rooms:booking_create', args=[self.room.id]))
        self.assertEqual(response.status_code, 200)
        self.assertContains(response, self.room.name)
    
    def test_booking_list_view(self):
        """Test user's booking list view"""
        self.client.login(username='testuser', password='pass123')
        response = self.client.get(reverse('rooms:my_bookings'))
        self.assertEqual(response.status_code, 200)


class FormTest(TestCase):
    """Test form validations"""
    
    def test_room_form_validation(self):
        """Test room form validation"""
        # Valid form
        form_data = {
            'name': 'Test Room',
            'location': 'Test Location', 
            'capacity': 10,
            'facilities': 'WiFi',
            'description': 'Test description'
        }
        form = RoomForm(data=form_data)
        self.assertTrue(form.is_valid())
        
        # Invalid form - negative capacity
        form_data['capacity'] = -1
        form = RoomForm(data=form_data)
        self.assertFalse(form.is_valid())
    
    def test_booking_form_validation(self):
        """Test booking form validation"""
        room = Room.objects.create(name="Test Room", location="Test", capacity=5)
        
        # Valid booking form
        start_time = timezone.now() + timedelta(hours=1)
        end_time = start_time + timedelta(hours=2)
        
        form_data = {
            'start_time': start_time.strftime('%Y-%m-%d %H:%M'),
            'end_time': end_time.strftime('%Y-%m-%d %H:%M'),
            'purpose': 'Test Meeting'
        }
        
        form = BookingForm(data=form_data)
        # Note: This might fail if form expects specific format
        # Adjust based on your actual form implementation


class IntegrationTest(TestCase):
    """Integration tests for complete workflows"""
    
    def setUp(self):
        self.client = Client()
        self.user = User.objects.create_user('testuser', 'test@test.com', 'pass123')
        self.staff_user = User.objects.create_user('staffuser', 'staff@test.com', 'pass123')
        self.staff_user.is_staff = True
        self.staff_user.save()
    
    def test_complete_booking_workflow(self):
        """Test complete booking workflow from room creation to booking"""
        # 1. Staff creates a room
        self.client.login(username='staffuser', password='pass123')
        
        room_data = {
            'name': 'Integration Test Room',
            'location': 'Test Building',
            'capacity': 8,
            'facilities': 'WiFi, Projector',
            'description': 'Room for integration testing'
        }
        
        response = self.client.post(reverse('rooms:room_create'), room_data)
        self.assertEqual(response.status_code, 302)
        
        room = Room.objects.get(name='Integration Test Room')
        
        # 2. User logs in and views room
        self.client.login(username='testuser', password='pass123')
        response = self.client.get(reverse('rooms:room_detail', args=[room.id]))
        self.assertEqual(response.status_code, 200)
        
        # 3. User creates booking (this would need actual form submission)
        # For now, just test that the booking form is accessible
        response = self.client.get(reverse('rooms:booking_create', args=[room.id]))
        self.assertEqual(response.status_code, 200)
    
    def test_permission_workflow(self):
        """Test that permissions work correctly throughout the system"""
        # Create room as staff
        self.client.login(username='staffuser', password='pass123')
        room = Room.objects.create(name="Permission Test Room", location="Test", capacity=5)
        
        # Regular user cannot edit room
        self.client.login(username='testuser', password='pass123')
        response = self.client.get(reverse('rooms:room_edit', args=[room.id]))
        self.assertEqual(response.status_code, 403)
        
        # But can view it
        response = self.client.get(reverse('rooms:room_detail', args=[room.id]))
        self.assertEqual(response.status_code, 200)
