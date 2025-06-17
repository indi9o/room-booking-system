# 🔧 Developer Guide

> **📍 Navigation**: [📋 Documentation Index](README.md) | [🤝 Contributing](CONTRIBUTING.md) | [📡 API Docs](API.md)

Panduan untuk developer yang ingin berkontribusi atau mengembangkan Room Booking System.

## 📋 Development Setup

### Prerequisites
- Python 3.11+
- Docker & Docker Compose
- Git
- Code editor (VS Code recommended)

### Local Development

#### 1. Setup Virtual Environment (Optional)
```bash
python -m venv venv
source venv/bin/activate  # Linux/Mac
# atau
venv\Scripts\activate     # Windows
```

#### 2. Install Dependencies
```bash
pip install -r requirements.txt
```

#### 3. Setup Local Database
```bash
# Menggunakan SQLite untuk development
cp .env .env.local
# Edit DEBUG=True di .env.local

# Run migrations
python manage.py migrate

# Create superuser
python manage.py createsuperuser

# Load sample data (optional)
python manage.py load_sample_data
```

#### 4. Run Development Server
```bash
python manage.py runserver
```

## 🏗️ Project Structure

```
room-booking-system/
├── room_usage_project/          # Django project
│   ├── __init__.py
│   ├── settings.py             # Main settings
│   ├── urls.py                 # URL routing
│   ├── wsgi.py                 # WSGI config
│   └── asgi.py                 # ASGI config
│
├── rooms/                       # Main app
│   ├── __init__.py
│   ├── admin.py                # Admin configuration
│   ├── apps.py                 # App configuration
│   ├── forms.py                # Django forms
│   ├── models.py               # Database models
│   ├── views.py                # View functions
│   ├── urls.py                 # App URL patterns
│   ├── tests.py                # Unit tests
│   ├── migrations/             # Database migrations
│   └── management/             # Custom commands
│       └── commands/
│           └── load_sample_data.py
│
├── templates/                   # HTML templates
│   ├── base.html               # Base template
│   ├── registration/           # Auth templates
│   │   ├── login.html
│   │   └── register.html
│   └── rooms/                  # Room templates
│       ├── home.html
│       ├── room_list.html
│       ├── room_detail.html
│       ├── create_room.html
│       ├── booking_list.html
│       ├── create_booking.html
│       └── booking_detail.html
│
├── staticfiles/                # Static files (collected)
├── media/                      # User uploads
├── requirements.txt            # Python dependencies
├── manage.py                   # Django management
├── docker-compose.yml          # Docker configuration
├── Dockerfile                  # Container definition
├── docker-entrypoint.sh        # Container startup
└── .env                        # Environment variables
```

## 🎨 Frontend Development

### Template System
- Base template: `templates/base.html`
- Bootstrap 5 untuk styling
- jQuery untuk interaktivitas
- Font Awesome untuk icons

### Static Files
```
staticfiles/
├── admin/                      # Django admin static files
├── bootstrap_datepicker_plus/  # Date picker widget
└── custom/                     # Custom CSS/JS (if any)
```

### CSS Framework
```html
<!-- Bootstrap 5 CDN -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">

<!-- Font Awesome -->
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
```

## 🗄️ Database Schema

### Models Overview

#### Room Model
```python
class Room(models.Model):
    name = CharField(max_length=100)           # Nama ruangan
    description = TextField(blank=True)        # Deskripsi
    capacity = PositiveIntegerField()          # Kapasitas
    location = CharField(max_length=200)       # Lokasi
    facilities = TextField(blank=True)         # Fasilitas
    image = ImageField(upload_to='rooms/')     # Gambar
    is_active = BooleanField(default=True)     # Status aktif
    created_at = DateTimeField(auto_now_add=True)
    updated_at = DateTimeField(auto_now=True)
```

#### Booking Model
```python
class Booking(models.Model):
    STATUS_CHOICES = [
        ('pending', 'Menunggu'),
        ('approved', 'Disetujui'),
        ('rejected', 'Ditolak'),
        ('cancelled', 'Dibatalkan'),
        ('completed', 'Selesai'),
    ]
    
    user = ForeignKey(User, on_delete=CASCADE)
    room = ForeignKey(Room, on_delete=CASCADE)
    title = CharField(max_length=200)          # Judul acara
    description = TextField(blank=True)        # Deskripsi acara
    start_datetime = DateTimeField()           # Waktu mulai
    end_datetime = DateTimeField()             # Waktu selesai
    participants = PositiveIntegerField()      # Jumlah peserta
    status = CharField(max_length=20, choices=STATUS_CHOICES)
    notes = TextField(blank=True)              # Catatan
    approved_by = ForeignKey(User, null=True, blank=True)
    approved_at = DateTimeField(null=True, blank=True)
    created_at = DateTimeField(auto_now_add=True)
    updated_at = DateTimeField(auto_now=True)
```

#### BookingHistory Model
```python
class BookingHistory(models.Model):
    booking = ForeignKey(Booking, on_delete=CASCADE)
    old_status = CharField(max_length=20)
    new_status = CharField(max_length=20)
    changed_by = ForeignKey(User, on_delete=CASCADE)
    notes = TextField(blank=True)
    created_at = DateTimeField(auto_now_add=True)
```

### Database Relationships
```
User (Django built-in)
 ├── Booking (many-to-one)
 └── BookingHistory (many-to-one)

Room
 └── Booking (many-to-one)

Booking
 └── BookingHistory (one-to-many)
```

## 🔧 Business Logic

### Booking Validation
```python
def clean(self):
    # 1. Waktu mulai harus sebelum waktu selesai
    if self.start_datetime >= self.end_datetime:
        raise ValidationError("Waktu mulai harus sebelum waktu selesai.")
    
    # 2. Tidak bisa booking di masa lalu
    if self.start_datetime < timezone.now():
        raise ValidationError("Tidak dapat melakukan booking di masa lalu.")
    
    # 3. Jumlah peserta tidak boleh melebihi kapasitas
    if self.participants > self.room.capacity:
        raise ValidationError(f"Jumlah peserta melebihi kapasitas ruangan.")
    
    # 4. Cek konflik jadwal
    conflicting_bookings = Booking.objects.filter(
        room=self.room,
        status__in=['approved', 'pending'],
        start_datetime__lt=self.end_datetime,
        end_datetime__gt=self.start_datetime
    )
    
    if self.pk:
        conflicting_bookings = conflicting_bookings.exclude(pk=self.pk)
    
    if conflicting_bookings.exists():
        raise ValidationError("Terdapat konflik jadwal dengan booking yang sudah ada.")
```

### Status Management
```python
def approve_booking(booking, approved_by):
    old_status = booking.status
    booking.status = 'approved'
    booking.approved_by = approved_by
    booking.approved_at = timezone.now()
    booking.save()
    
    # Create history record
    BookingHistory.objects.create(
        booking=booking,
        old_status=old_status,
        new_status='approved',
        changed_by=approved_by,
        notes='Booking approved'
    )
```

## 🧪 Testing

### Running Tests
```bash
# Run all tests
python manage.py test

# Run specific app tests
python manage.py test rooms

# Run with coverage
pip install coverage
coverage run --source='.' manage.py test
coverage report
coverage html
```

### Test Structure
```python
# rooms/tests.py
class RoomModelTest(TestCase):
    def test_room_creation(self):
        room = Room.objects.create(
            name="Test Room",
            capacity=10,
            location="Test Location"
        )
        self.assertEqual(room.name, "Test Room")
        
class BookingModelTest(TestCase):
    def setUp(self):
        self.user = User.objects.create_user('testuser', 'test@test.com', 'pass123')
        self.room = Room.objects.create(
            name="Test Room",
            capacity=10,
            location="Test Location"
        )
    
    def test_booking_validation(self):
        # Test booking creation and validation
        pass
```

## 🚀 Deployment

### Environment Configuration
```python
# settings.py
DEBUG = config('DEBUG', default=False, cast=bool)
ALLOWED_HOSTS = config('ALLOWED_HOSTS', default='localhost').split(',')

# Database configuration
if config('DB_HOST', default='') == 'db':  # Docker
    DATABASES = {
        'default': {
            'ENGINE': 'django.db.backends.mysql',
            'NAME': config('DB_NAME'),
            'USER': config('DB_USER'),
            'PASSWORD': config('DB_PASSWORD'),
            'HOST': config('DB_HOST'),
            'PORT': config('DB_PORT', default='3306'),
        }
    }
else:  # Local development
    DATABASES = {
        'default': {
            'ENGINE': 'django.db.backends.sqlite3',
            'NAME': BASE_DIR / 'db.sqlite3',
        }
    }
```

### Docker Configuration
```dockerfile
# Dockerfile
FROM python:3.11-slim

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

WORKDIR /code

# Install system dependencies
RUN apt-get update && apt-get install -y \
    default-mysql-client \
    pkg-config \
    default-libmysqlclient-dev \
    build-essential

# Install Python dependencies
COPY requirements.txt /code/
RUN pip install -r requirements.txt

# Copy project
COPY . /code/

EXPOSE 8000
CMD ["./docker-entrypoint.sh"]
```

## 🔍 Debugging

### Django Debug Toolbar (Development)
```python
# settings.py (for development)
if DEBUG:
    INSTALLED_APPS += ['debug_toolbar']
    MIDDLEWARE += ['debug_toolbar.middleware.DebugToolbarMiddleware']
    INTERNAL_IPS = ['127.0.0.1']
```

### Logging Configuration
```python
# settings.py
LOGGING = {
    'version': 1,
    'disable_existing_loggers': False,
    'handlers': {
        'file': {
            'level': 'INFO',
            'class': 'logging.FileHandler',
            'filename': 'django.log',
        },
        'console': {
            'level': 'DEBUG',
            'class': 'logging.StreamHandler',
        },
    },
    'loggers': {
        'django': {
            'handlers': ['file', 'console'],
            'level': 'INFO',
            'propagate': True,
        },
        'rooms': {
            'handlers': ['file', 'console'],
            'level': 'DEBUG',
            'propagate': True,
        },
    },
}
```

## 🛠️ Development Tools

### Useful Django Commands
```bash
# Create new migration
python manage.py makemigrations

# Apply migrations
python manage.py migrate

# Create superuser
python manage.py createsuperuser

# Collect static files
python manage.py collectstatic

# Run development server
python manage.py runserver

# Django shell
python manage.py shell

# Show URLs
python manage.py show_urls

# Check for issues
python manage.py check
```

### Custom Management Commands
```python
# rooms/management/commands/load_sample_data.py
from django.core.management.base import BaseCommand
from rooms.models import Room

class Command(BaseCommand):
    help = 'Load sample data for development'
    
    def handle(self, *args, **options):
        # Create sample rooms
        Room.objects.get_or_create(
            name="Conference Room A",
            defaults={
                'description': 'Main conference room',
                'capacity': 20,
                'location': 'Building 1, Floor 2',
                'facilities': 'Projector, Whiteboard, WiFi'
            }
        )
        
        self.stdout.write(
            self.style.SUCCESS('Successfully loaded sample data')
        )
```

## 📝 Contributing

### Code Style
- Follow PEP 8 for Python code
- Use descriptive variable and function names
- Add docstrings for functions and classes
- Write unit tests for new features

### Git Workflow
```bash
# Create feature branch
git checkout -b feature/new-feature

# Make changes and commit
git add .
git commit -m "Add new feature"

# Push to remote
git push origin feature/new-feature

# Create pull request
```

### Pull Request Guidelines
1. Write clear description of changes
2. Include tests for new features
3. Update documentation if needed
4. Ensure all tests pass
5. Follow code style guidelines

---

**Happy coding! 🚀**
