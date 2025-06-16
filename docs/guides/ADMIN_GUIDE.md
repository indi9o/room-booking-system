# 👨‍💻 Admin Guide - Room Booking System

Panduan lengkap untuk administrator sistem Room Booking System.

## 🎯 Pendahuluan

Sebagai administrator, Anda memiliki kontrol penuh atas sistem:
- Manajemen pengguna dan permissions
- Konfigurasi sistem dan settings
- Monitoring performa dan keamanan
- Backup dan recovery
- Deployment dan maintenance

## 🔐 Akses Administrator

### Superuser Account
Pastikan Anda memiliki akses superuser:
```bash
# Membuat superuser
python manage.py createsuperuser

# Atau di Docker
docker-compose exec web python manage.py createsuperuser
```

### Admin Panel
Akses admin panel di:
- **URL**: `/admin/`
- **Login**: Gunakan credentials superuser
- **Features**: Full CRUD access untuk semua model

## 👥 User Management

### Jenis User
1. **Regular User**: User biasa yang dapat booking
2. **Staff**: User dengan akses approval booking
3. **Superuser**: Administrator dengan akses penuh

### Mengelola User
**Di Admin Panel:**
1. Buka **"Users"** di admin panel
2. Klik user untuk edit
3. Set permissions:
   - `is_staff`: Akses staff untuk approval
   - `is_superuser`: Akses admin penuh
   - `is_active`: User aktif/non-aktif

### Membuat Staff User
```bash
# Via Django shell
python manage.py shell
```
```python
from django.contrib.auth.models import User
user = User.objects.get(username='username')
user.is_staff = True
user.save()
```

### Batch User Operations
```python
# Script untuk membuat multiple staff users
staff_usernames = ['staff1', 'staff2', 'staff3']
for username in staff_usernames:
    user = User.objects.get(username=username)
    user.is_staff = True
    user.save()
```

## 🏢 Room Management

### Menambah Ruangan
**Via Admin Panel:**
1. Buka **"Rooms"** di admin panel
2. Klik **"Add Room"**
3. Isi informasi ruangan:
   - Nama ruangan
   - Deskripsi
   - Kapasitas
   - Lokasi
   - Fasilitas
   - Upload gambar

**Via Web Interface:**
- Login sebagai staff
- Akses **"Tambah Ruangan"** di menu

### Bulk Room Import
```python
# Script untuk import ruangan dari CSV
import csv
from rooms.models import Room

with open('rooms.csv', 'r') as file:
    reader = csv.DictReader(file)
    for row in reader:
        Room.objects.create(
            name=row['name'],
            description=row['description'],
            capacity=int(row['capacity']),
            location=row['location'],
            facilities=row['facilities'],
            is_active=True
        )
```

## 📊 Booking Management

### Monitoring Bookings
**Dashboard Overview:**
- Total bookings per periode
- Approval rate
- Popular rooms
- Peak usage times

### Bulk Booking Operations
```python
# Approve semua booking pending untuk ruangan tertentu
from rooms.models import Booking
from django.contrib.auth.models import User

admin_user = User.objects.get(username='admin')
pending_bookings = Booking.objects.filter(
    room_id=1, 
    status='pending'
)

for booking in pending_bookings:
    booking.status = 'approved'
    booking.approved_by = admin_user
    booking.save()
```

### Export Booking Data
```python
# Export booking ke CSV
import csv
from rooms.models import Booking

bookings = Booking.objects.all()
with open('bookings_export.csv', 'w', newline='') as file:
    writer = csv.writer(file)
    writer.writerow(['ID', 'Title', 'User', 'Room', 'Start', 'End', 'Status'])
    
    for booking in bookings:
        writer.writerow([
            booking.id,
            booking.title,
            booking.user.username,
            booking.room.name,
            booking.start_datetime,
            booking.end_datetime,
            booking.status
        ])
```

## ⚙️ System Configuration

### Environment Variables
```env
# Production settings
DEBUG=0
SECRET_KEY=your-production-secret-key
ALLOWED_HOSTS=yourdomain.com,www.yourdomain.com

# Database
DB_HOST=your-db-host
DB_NAME=your-db-name
DB_USER=your-db-user
DB_PASSWORD=your-secure-password

# Email (for notifications)
EMAIL_HOST=smtp.gmail.com
EMAIL_PORT=587
EMAIL_USE_TLS=1
EMAIL_HOST_USER=your-email@gmail.com
EMAIL_HOST_PASSWORD=your-app-password
```

### Django Settings
```python
# settings.py key configurations
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.mysql',
        'NAME': os.getenv('DB_NAME'),
        'USER': os.getenv('DB_USER'),
        'PASSWORD': os.getenv('DB_PASSWORD'),
        'HOST': os.getenv('DB_HOST'),
        'PORT': os.getenv('DB_PORT', '3306'),
    }
}

# Security settings
SECURE_SSL_REDIRECT = True
SECURE_HSTS_SECONDS = 31536000
SECURE_HSTS_INCLUDE_SUBDOMAINS = True
SECURE_HSTS_PRELOAD = True
```

## 🔧 Maintenance Tasks

### Database Maintenance
```bash
# Database migrations
python manage.py makemigrations
python manage.py migrate

# Database backup
mysqldump -u user -p database_name > backup.sql

# Database restore
mysql -u user -p database_name < backup.sql
```

### Static Files
```bash
# Collect static files for production
python manage.py collectstatic --noinput

# Clear cache
python manage.py clear_cache
```

### Log Rotation
```bash
# Setup logrotate for Django logs
sudo nano /etc/logrotate.d/django

/path/to/logs/django.log {
    daily
    missingok
    rotate 52
    compress
    delaycompress
    notifempty
    create 0644 www-data www-data
}
```

## 📈 Monitoring & Analytics

### Health Checks
Akses endpoint monitoring:
- `/health/` - Basic health check
- `/health/detailed/` - Detailed system info
- `/metrics/` - System metrics

### Performance Monitoring
```python
# Custom monitoring script
from rooms.models import Room, Booking
from django.db import connection

def system_stats():
    stats = {
        'total_rooms': Room.objects.count(),
        'active_rooms': Room.objects.filter(is_active=True).count(),
        'total_bookings': Booking.objects.count(),
        'pending_bookings': Booking.objects.filter(status='pending').count(),
        'db_queries': len(connection.queries)
    }
    return stats
```

### Log Analysis
```bash
# Analyze access logs
tail -f /var/log/nginx/access.log | grep "POST /bookings"

# Monitor error logs
tail -f /var/log/django/error.log

# Check slow queries
tail -f /var/log/mysql/slow.log
```

## 🛡️ Security Management

### Security Checklist
- [ ] SSL/TLS certificate configured
- [ ] Strong SECRET_KEY in production
- [ ] Database credentials secured
- [ ] CSRF protection enabled
- [ ] XSS protection enabled
- [ ] File upload validation
- [ ] Rate limiting configured
- [ ] Regular security updates

### User Permissions Audit
```python
# Audit user permissions
from django.contrib.auth.models import User

for user in User.objects.all():
    permissions = user.get_all_permissions()
    print(f"User: {user.username}")
    print(f"Staff: {user.is_staff}")
    print(f"Superuser: {user.is_superuser}")
    print(f"Permissions: {permissions}")
    print("---")
```

### Security Updates
```bash
# Update dependencies
pip list --outdated
pip install --upgrade package_name

# Security scan
pip-audit

# Update Docker images
docker-compose pull
docker-compose up -d
```

## 💾 Backup & Recovery

### Automated Backup Script
```bash
#!/bin/bash
# backup.sh

DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/backups"

# Database backup
mysqldump -u $DB_USER -p$DB_PASSWORD $DB_NAME > $BACKUP_DIR/db_$DATE.sql

# Media files backup
tar -czf $BACKUP_DIR/media_$DATE.tar.gz media/

# Code backup (if needed)
tar -czf $BACKUP_DIR/code_$DATE.tar.gz --exclude=venv --exclude=.git .

# Upload to cloud storage (optional)
# aws s3 cp $BACKUP_DIR/ s3://your-bucket/backups/ --recursive
```

### Recovery Procedures
```bash
# Database recovery
mysql -u $DB_USER -p$DB_PASSWORD $DB_NAME < backup.sql

# Media files recovery
tar -xzf media_backup.tar.gz

# Full system recovery
docker-compose down
# Restore files and database
docker-compose up -d
```

## 🚀 Deployment Management

### Production Deployment
```bash
# Production deployment checklist
1. Update code from repository
2. Install/update dependencies
3. Run database migrations
4. Collect static files
5. Restart services
6. Verify deployment
```

### CI/CD Pipeline
The system includes GitHub Actions workflow:
```yaml
# .github/workflows/ci-cd.yml
- Test and build application
- Run security scans
- Deploy to staging/production
- Send notifications
```

### Docker Production
```yaml
# docker-compose.prod.yml
version: '3.8'
services:
  web:
    build: .
    restart: unless-stopped
    environment:
      - DEBUG=0
      - DJANGO_ENV=production
    volumes:
      - static_volume:/code/staticfiles
      - media_volume:/code/media
  
  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - static_volume:/staticfiles
      - ./nginx.conf:/etc/nginx/nginx.conf
```

## 📊 Reporting & Analytics

### Weekly Reports
```python
# Weekly booking report
from datetime import datetime, timedelta
from rooms.models import Booking

def weekly_report():
    week_ago = datetime.now() - timedelta(days=7)
    bookings = Booking.objects.filter(created_at__gte=week_ago)
    
    report = {
        'total_bookings': bookings.count(),
        'approved': bookings.filter(status='approved').count(),
        'rejected': bookings.filter(status='rejected').count(),
        'pending': bookings.filter(status='pending').count(),
    }
    
    return report
```

### Custom Admin Views
```python
# admin.py
from django.contrib import admin
from django.urls import path
from django.shortcuts import render

class CustomAdminSite(admin.AdminSite):
    def get_urls(self):
        urls = super().get_urls()
        custom_urls = [
            path('reports/', self.admin_view(self.reports_view), name='reports'),
        ]
        return custom_urls + urls
    
    def reports_view(self, request):
        context = {
            'title': 'System Reports',
            'stats': get_system_stats(),
        }
        return render(request, 'admin/reports.html', context)
```

## 🆘 Troubleshooting

### Common Admin Issues

**Database Connection Issues:**
```bash
# Check database connectivity
python manage.py dbshell

# Check migrations status
python manage.py showmigrations
```

**Performance Issues:**
```python
# Debug slow queries
from django.db import connection
print(connection.queries)

# Enable query logging
LOGGING = {
    'loggers': {
        'django.db.backends': {
            'level': 'DEBUG',
            'handlers': ['console'],
        }
    }
}
```

**Memory Issues:**
```bash
# Monitor memory usage
docker stats

# Check Django memory usage
import tracemalloc
tracemalloc.start()
# ... run code ...
print(tracemalloc.get_traced_memory())
```

## 📞 Emergency Procedures

### System Down
1. Check Docker containers: `docker-compose ps`
2. Check logs: `docker-compose logs`
3. Restart services: `docker-compose restart`
4. Verify database connectivity
5. Check disk space and memory

### Data Corruption
1. Stop application immediately
2. Backup current state
3. Restore from latest backup
4. Verify data integrity
5. Restart application
6. Monitor for issues

---

**Need Help?** 🆘
- Technical Issues: Check logs and error messages
- Emergency: Follow emergency procedures
- Questions: Consult documentation or reach out to development team

**Remember**: Always test changes in staging environment first! 🧪
