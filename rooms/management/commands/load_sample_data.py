from django.core.management.base import BaseCommand
from django.contrib.auth.models import User
from rooms.models import Room, Booking
from datetime import datetime, timedelta
from django.utils import timezone

class Command(BaseCommand):
    help = 'Load sample data for Room Booking System'

    def handle(self, *args, **options):
        # Create superuser if not exists
        if not User.objects.filter(username='admin').exists():
            User.objects.create_superuser('admin', 'alan@ub.ac.id', 'admin123')
            self.stdout.write(self.style.SUCCESS('Superuser created: admin/admin123'))

        # Create sample users
        users_data = [
            {'username': 'user1', 'email': 'user1@example.com', 'first_name': 'John', 'last_name': 'Doe'},
            {'username': 'user2', 'email': 'user2@example.com', 'first_name': 'Jane', 'last_name': 'Smith'},
            {'username': 'user3', 'email': 'user3@example.com', 'first_name': 'Bob', 'last_name': 'Johnson'},
        ]

        for user_data in users_data:
            if not User.objects.filter(username=user_data['username']).exists():
                user = User.objects.create_user(
                    username=user_data['username'],
                    email=user_data['email'],
                    password='password123',
                    first_name=user_data['first_name'],
                    last_name=user_data['last_name']
                )
                self.stdout.write(f'User created: {user.username}')

        # Create sample rooms
        rooms_data = [
            {
                'name': 'Ruang Rapat A',
                'description': 'Ruang rapat dengan kapasitas sedang, dilengkapi dengan proyektor dan AC.',
                'capacity': 20,
                'location': 'Lantai 2, Gedung A',
                'facilities': 'Proyektor, AC, Whiteboard, WiFi, Sound System'
            },
            {
                'name': 'Ruang Seminar B',
                'description': 'Ruang seminar besar untuk acara formal dan presentasi.',
                'capacity': 50,
                'location': 'Lantai 3, Gedung B',
                'facilities': 'Proyektor, AC, Mikrofon, Sound System, Podium'
            },
            {
                'name': 'Ruang Meeting C',
                'description': 'Ruang meeting kecil untuk diskusi tim.',
                'capacity': 10,
                'location': 'Lantai 1, Gedung A',
                'facilities': 'TV, AC, Whiteboard, WiFi'
            },
            {
                'name': 'Auditorium',
                'description': 'Auditorium besar untuk acara besar dan konferensi.',
                'capacity': 100,
                'location': 'Lantai Dasar, Gedung Utama',
                'facilities': 'Proyektor Besar, Sound System, Panggung, AC, Lighting'
            },
            {
                'name': 'Ruang Pelatihan',
                'description': 'Ruang pelatihan dengan meja dan kursi yang bisa diatur.',
                'capacity': 30,
                'location': 'Lantai 2, Gedung C',
                'facilities': 'Proyektor, AC, Meja Lipat, Kursi, WiFi'
            }
        ]

        for room_data in rooms_data:
            if not Room.objects.filter(name=room_data['name']).exists():
                room = Room.objects.create(**room_data)
                self.stdout.write(f'Room created: {room.name}')

        # Create sample bookings
        users = User.objects.filter(username__in=['user1', 'user2', 'user3'])
        
        if users.exists():
            room_rapat_a = Room.objects.get(name='Ruang Rapat A')
            room_seminar_b = Room.objects.get(name='Ruang Seminar B') 
            room_meeting_c = Room.objects.get(name='Ruang Meeting C')
            auditorium = Room.objects.get(name='Auditorium')

            bookings_data = [
                {
                    'user': users[0],
                    'room': room_rapat_a,  # Ruang Rapat A (20 capacity)
                    'title': 'Rapat Mingguan Tim',
                    'description': 'Rapat rutin mingguan untuk membahas progress project.',
                    'start_datetime': timezone.now() + timedelta(days=1, hours=9),
                    'end_datetime': timezone.now() + timedelta(days=1, hours=11),
                    'participants': 15,
                    'status': 'approved'
                },
                {
                    'user': users[1],
                    'room': room_seminar_b,  # Ruang Seminar B (50 capacity)
                    'title': 'Seminar Teknologi Terbaru',
                    'description': 'Seminar tentang perkembangan teknologi terkini.',
                    'start_datetime': timezone.now() + timedelta(days=3, hours=14),
                    'end_datetime': timezone.now() + timedelta(days=3, hours=17),
                    'participants': 45,
                    'status': 'pending'
                },
                {
                    'user': users[2],
                    'room': room_meeting_c,  # Ruang Meeting C (10 capacity)
                    'title': 'Diskusi Project Alpha',
                    'description': 'Diskusi progress dan planning project Alpha.',
                    'start_datetime': timezone.now() + timedelta(days=2, hours=10),
                    'end_datetime': timezone.now() + timedelta(days=2, hours=12),
                    'participants': 8,
                    'status': 'approved'
                },
                {
                    'user': users[0],
                    'room': auditorium,  # Auditorium (100 capacity)
                    'title': 'Konferensi Tahunan',
                    'description': 'Konferensi tahunan perusahaan dengan seluruh karyawan.',
                    'start_datetime': timezone.now() + timedelta(days=7, hours=8),
                    'end_datetime': timezone.now() + timedelta(days=7, hours=17),
                    'participants': 90,
                    'status': 'pending'
                }
            ]

            for booking_data in bookings_data:
                if not Booking.objects.filter(
                    user=booking_data['user'],
                    room=booking_data['room'],
                    title=booking_data['title']
                ).exists():
                    booking = Booking.objects.create(**booking_data)
                    self.stdout.write(f'Booking created: {booking.title}')

        self.stdout.write(self.style.SUCCESS('Sample data loaded successfully!'))
        self.stdout.write('Login credentials:')
        self.stdout.write('Admin: admin / admin123')
        self.stdout.write('Users: user1, user2, user3 / password123')
