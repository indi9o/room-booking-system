# 📈 Performance Guide

Panduan optimasi performa untuk Room Booking System.

## 🎯 Performance Targets

### Target Metrics
- **Page Load Time**: < 2 seconds
- **Database Query Time**: < 100ms
- **API Response Time**: < 500ms
- **Concurrent Users**: 100+ simultaneous users
- **Memory Usage**: < 512MB per container
- **CPU Usage**: < 70% under normal load

## 🔍 Performance Monitoring

### 1. Application Monitoring

#### Django Debug Toolbar (Development)
```python
# settings.py
if DEBUG:
    INSTALLED_APPS += ['debug_toolbar']
    MIDDLEWARE.insert(0, 'debug_toolbar.middleware.DebugToolbarMiddleware')
    
    INTERNAL_IPS = ['127.0.0.1', '::1']
    
    DEBUG_TOOLBAR_CONFIG = {
        'SHOW_TOOLBAR_CALLBACK': lambda request: DEBUG,
    }
```

#### Performance Logging
```python
# settings.py
LOGGING = {
    'version': 1,
    'disable_existing_loggers': False,
    'formatters': {
        'performance': {
            'format': '[{asctime}] {levelname} {name} {message}',
            'style': '{',
        },
    },
    'handlers': {
        'performance_file': {
            'level': 'INFO',
            'class': 'logging.handlers.RotatingFileHandler',
            'filename': '/var/log/django/performance.log',
            'maxBytes': 1024*1024*15,
            'backupCount': 10,
            'formatter': 'performance',
        },
    },
    'loggers': {
        'performance': {
            'handlers': ['performance_file'],
            'level': 'INFO',
            'propagate': False,
        },
    },
}
```

#### Custom Performance Middleware
```python
# rooms/middleware.py
import time
import logging
from django.utils.deprecation import MiddlewareMixin

logger = logging.getLogger('performance')

class PerformanceMiddleware(MiddlewareMixin):
    def process_request(self, request):
        request.start_time = time.time()
        
    def process_response(self, request, response):
        if hasattr(request, 'start_time'):
            duration = time.time() - request.start_time
            logger.info(f"Request to {request.path} took {duration:.3f}s")
            
            # Add performance header
            response['X-Response-Time'] = f"{duration:.3f}s"
            
            # Log slow requests
            if duration > 1.0:
                logger.warning(f"Slow request: {request.path} took {duration:.3f}s")
                
        return response
```

### 2. Database Monitoring

#### Slow Query Logging
```python
# settings.py
if not DEBUG:
    LOGGING['loggers']['django.db.backends'] = {
        'handlers': ['performance_file'],
        'level': 'DEBUG',
        'propagate': False,
    }
```

#### Query Analysis
```python
# Custom management command: monitor_queries.py
from django.core.management.base import BaseCommand
from django.db import connection
from django.conf import settings

class Command(BaseCommand):
    help = 'Monitor database queries'
    
    def handle(self, *args, **options):
        # Enable query logging
        settings.LOGGING['loggers']['django.db.backends']['level'] = 'DEBUG'
        
        # Print query statistics
        print(f"Total queries: {len(connection.queries)}")
        for query in connection.queries:
            print(f"Time: {query['time']}s - SQL: {query['sql'][:100]}...")
```

## 🚀 Performance Optimizations

### 1. Database Optimization

#### Query Optimization
```python
# models.py - Use select_related and prefetch_related
class BookingManager(models.Manager):
    def get_with_room_and_user(self):
        return self.select_related('room', 'user')
    
    def get_recent_with_details(self):
        return (self.select_related('room', 'user')
                   .prefetch_related('room__features')
                   .order_by('-created_at'))

class Booking(models.Model):
    # ... existing fields ...
    objects = BookingManager()
```

```python
# views.py - Optimized queries
def booking_list(request):
    # Bad: N+1 queries
    # bookings = Booking.objects.all()
    
    # Good: Optimized queries
    bookings = Booking.objects.get_with_room_and_user().filter(
        user=request.user
    )[:50]  # Limit results
    
    return render(request, 'rooms/booking_list.html', {
        'bookings': bookings
    })
```

#### Database Indexes
```python
# models.py
class Booking(models.Model):
    room = models.ForeignKey(Room, on_delete=models.CASCADE, db_index=True)
    user = models.ForeignKey(User, on_delete=models.CASCADE, db_index=True)
    start_time = models.DateTimeField(db_index=True)
    end_time = models.DateTimeField(db_index=True)
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, db_index=True)
    created_at = models.DateTimeField(auto_now_add=True, db_index=True)
    
    class Meta:
        indexes = [
            models.Index(fields=['room', 'start_time']),
            models.Index(fields=['user', 'status']),
            models.Index(fields=['status', 'created_at']),
            models.Index(fields=['start_time', 'end_time']),
        ]
```

#### Raw SQL for Complex Queries
```python
# views.py
def room_utilization_report(request):
    with connection.cursor() as cursor:
        cursor.execute("""
            SELECT 
                r.id,
                r.name,
                COUNT(b.id) as booking_count,
                AVG(TIMESTAMPDIFF(HOUR, b.start_time, b.end_time)) as avg_duration
            FROM rooms_room r
            LEFT JOIN rooms_booking b ON r.id = b.room_id 
                AND b.status = 'approved'
                AND b.start_time >= %s
            GROUP BY r.id, r.name
            ORDER BY booking_count DESC
        """, [timezone.now() - timedelta(days=30)])
        
        results = cursor.fetchall()
    
    return JsonResponse({'data': results})
```

### 2. Caching Strategy

#### Redis Setup
```python
# settings.py
CACHES = {
    'default': {
        'BACKEND': 'django_redis.cache.RedisCache',
        'LOCATION': 'redis://redis:6379/1',
        'OPTIONS': {
            'CLIENT_CLASS': 'django_redis.client.DefaultClient',
            'SERIALIZER': 'django_redis.serializers.json.JSONSerializer',
            'COMPRESSOR': 'django_redis.compressors.zlib.ZlibCompressor',
        },
        'KEY_PREFIX': 'room_booking',
        'TIMEOUT': 300,  # 5 minutes default
    }
}

# Session cache
SESSION_ENGINE = 'django.contrib.sessions.backends.cache'
SESSION_CACHE_ALIAS = 'default'
```

#### View Caching
```python
# views.py
from django.views.decorators.cache import cache_page
from django.utils.decorators import method_decorator

@cache_page(60 * 15)  # 15 minutes
def room_list(request):
    rooms = Room.objects.filter(is_active=True).select_related()
    return render(request, 'rooms/room_list.html', {'rooms': rooms})

@method_decorator(cache_page(60 * 5), name='dispatch')  # 5 minutes
class RoomDetailView(DetailView):
    model = Room
    template_name = 'rooms/room_detail.html'
    
    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        # Add cached data
        context['recent_bookings'] = self.get_cached_recent_bookings()
        return context
    
    def get_cached_recent_bookings(self):
        cache_key = f"room_recent_bookings_{self.object.id}"
        bookings = cache.get(cache_key)
        
        if bookings is None:
            bookings = list(self.object.booking_set.filter(
                status='approved',
                start_time__gte=timezone.now()
            ).order_by('start_time')[:5].values(
                'title', 'start_time', 'end_time'
            ))
            cache.set(cache_key, bookings, 60 * 10)  # 10 minutes
        
        return bookings
```

#### Template Fragment Caching
```html
<!-- templates/rooms/room_list.html -->
{% load cache %}

{% cache 900 room_list_header %}
<div class="header">
    <h1>Available Rooms</h1>
    <p>Choose from our {{ room_count }} available rooms</p>
</div>
{% endcache %}

{% for room in rooms %}
    {% cache 600 room_card room.id room.updated_at %}
    <div class="room-card">
        <h3>{{ room.name }}</h3>
        <p>{{ room.description }}</p>
        <small>Capacity: {{ room.capacity }}</small>
    </div>
    {% endcache %}
{% endfor %}
```

#### Model-level Caching
```python
# models.py
from django.core.cache import cache

class Room(models.Model):
    # ... existing fields ...
    
    def get_availability_cache_key(self, date):
        return f"room_availability_{self.id}_{date.isoformat()}"
    
    def is_available(self, start_time, end_time):
        cache_key = f"room_check_{self.id}_{start_time}_{end_time}"
        result = cache.get(cache_key)
        
        if result is None:
            conflicts = self.booking_set.filter(
                status__in=['approved', 'pending'],
                start_time__lt=end_time,
                end_time__gt=start_time
            ).exists()
            
            result = not conflicts
            cache.set(cache_key, result, 60 * 5)  # 5 minutes
        
        return result
    
    def invalidate_availability_cache(self):
        # Clear related cache when booking changes
        today = timezone.now().date()
        for i in range(30):  # Next 30 days
            date = today + timedelta(days=i)
            cache_key = self.get_availability_cache_key(date)
            cache.delete(cache_key)
```

### 3. Static Files Optimization

#### Compression & Minification
```python
# settings.py
INSTALLED_APPS += [
    'compressor',
]

STATICFILES_FINDERS += [
    'compressor.finders.CompressorFinder',
]

COMPRESS_ENABLED = not DEBUG
COMPRESS_CSS_FILTERS = [
    'compressor.filters.css_default.CssAbsoluteFilter',
    'compressor.filters.cssmin.rCSSMinFilter',
]
COMPRESS_JS_FILTERS = [
    'compressor.filters.jsmin.rJSMinFilter',
]
```

#### CDN Configuration
```python
# settings.py
if not DEBUG:
    AWS_ACCESS_KEY_ID = 'your-access-key'
    AWS_SECRET_ACCESS_KEY = 'your-secret-key'
    AWS_STORAGE_BUCKET_NAME = 'your-bucket'
    AWS_S3_REGION_NAME = 'us-east-1'
    AWS_S3_CUSTOM_DOMAIN = f'{AWS_STORAGE_BUCKET_NAME}.s3.amazonaws.com'
    
    # Static files
    STATICFILES_STORAGE = 'storages.backends.s3boto3.S3Boto3Storage'
    STATIC_URL = f'https://{AWS_S3_CUSTOM_DOMAIN}/static/'
    
    # Media files
    DEFAULT_FILE_STORAGE = 'storages.backends.s3boto3.S3Boto3Storage'
    MEDIA_URL = f'https://{AWS_S3_CUSTOM_DOMAIN}/media/'
```

### 4. Frontend Optimization

#### Asset Optimization
```html
<!-- templates/base.html -->
{% load compress %}

{% compress css %}
<link rel="stylesheet" type="text/css" href="{% static 'css/bootstrap.min.css' %}">
<link rel="stylesheet" type="text/css" href="{% static 'css/custom.css' %}">
{% endcompress %}

{% compress js %}
<script src="{% static 'js/jquery.min.js' %}"></script>
<script src="{% static 'js/bootstrap.min.js' %}"></script>
<script src="{% static 'js/custom.js' %}"></script>
{% endcompress %}
```

#### Image Optimization
```python
# models.py
from PIL import Image
import os

class Room(models.Model):
    image = models.ImageField(upload_to='rooms/', blank=True)
    
    def save(self, *args, **kwargs):
        super().save(*args, **kwargs)
        
        if self.image:
            img = Image.open(self.image.path)
            
            # Resize if too large
            if img.height > 600 or img.width > 800:
                output_size = (800, 600)
                img.thumbnail(output_size, Image.Resampling.LANCZOS)
                img.save(self.image.path, quality=85, optimize=True)
```

### 5. Application Server Optimization

#### Gunicorn Configuration
```python
# gunicorn.conf.py
import multiprocessing

# Server socket
bind = "0.0.0.0:8000"
backlog = 2048

# Worker processes
workers = multiprocessing.cpu_count() * 2 + 1
worker_class = 'gevent'
worker_connections = 1000
max_requests = 1000
max_requests_jitter = 100

# Performance
preload_app = True
timeout = 30
keepalive = 5
graceful_timeout = 30

# Logging
accesslog = '/var/log/gunicorn/access.log'
errorlog = '/var/log/gunicorn/error.log'
loglevel = 'info'
access_log_format = '%(h)s %(l)s %(u)s %(t)s "%(r)s" %(s)s %(b)s "%(f)s" "%(a)s" %(D)s'

# Security
limit_request_line = 4094
limit_request_fields = 100
limit_request_field_size = 8190
```

#### Nginx Configuration
```nginx
# nginx.conf
upstream app_server {
    server web:8000;
    keepalive 32;
}

server {
    listen 80;
    server_name yourdomain.com;
    
    # Gzip compression
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_types text/plain text/css text/xml text/javascript 
               application/x-javascript application/xml+rss 
               application/javascript application/json;
    
    # Static files caching
    location /static/ {
        alias /app/staticfiles/;
        expires 1y;
        add_header Cache-Control "public, immutable";
        add_header Vary Accept-Encoding;
    }
    
    location /media/ {
        alias /app/media/;
        expires 1M;
        add_header Cache-Control "public";
    }
    
    # Application
    location / {
        proxy_pass http://app_server;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # Connection pooling
        proxy_http_version 1.1;
        proxy_set_header Connection "";
        
        # Timeouts
        proxy_connect_timeout 30s;
        proxy_send_timeout 30s;
        proxy_read_timeout 30s;
        
        # Buffering
        proxy_buffering on;
        proxy_buffer_size 128k;
        proxy_buffers 4 256k;
        proxy_busy_buffers_size 256k;
    }
}
```

## 📊 Performance Testing

### Load Testing with Artillery
```yaml
# artillery-config.yml
config:
  target: 'http://localhost:8001'
  phases:
    - duration: 60
      arrivalRate: 10
      name: "Warm up"
    - duration: 120
      arrivalRate: 50
      name: "Normal load"
    - duration: 60
      arrivalRate: 100
      name: "High load"

scenarios:
  - name: "Browse and book"
    weight: 70
    flow:
      - get:
          url: "/"
      - get:
          url: "/rooms/"
      - get:
          url: "/rooms/1/"
      - think: 5
      
  - name: "User login"
    weight: 30
    flow:
      - get:
          url: "/accounts/login/"
      - post:
          url: "/accounts/login/"
          form:
            username: "testuser"
            password: "testpass"
```

```bash
# Run load test
npm install -g artillery
artillery run artillery-config.yml
```

### Database Performance Testing
```python
# management/commands/performance_test.py
from django.core.management.base import BaseCommand
from django.test.utils import override_settings
from django.db import connection
import time

class Command(BaseCommand):
    help = 'Run database performance tests'
    
    def handle(self, *args, **options):
        # Test query performance
        self.test_room_queries()
        self.test_booking_queries()
        self.test_complex_queries()
    
    def test_room_queries(self):
        start_time = time.time()
        
        # Test room listing
        rooms = list(Room.objects.all())
        self.stdout.write(f"Room list query: {time.time() - start_time:.3f}s")
        
        # Test room with bookings
        start_time = time.time()
        room_with_bookings = Room.objects.prefetch_related('booking_set').first()
        bookings = list(room_with_bookings.booking_set.all())
        self.stdout.write(f"Room with bookings: {time.time() - start_time:.3f}s")
    
    def test_booking_queries(self):
        # Test booking creation
        start_time = time.time()
        booking = Booking.objects.create(
            title="Test Booking",
            room_id=1,
            user_id=1,
            start_time=timezone.now(),
            end_time=timezone.now() + timedelta(hours=1)
        )
        self.stdout.write(f"Booking creation: {time.time() - start_time:.3f}s")
        
        # Clean up
        booking.delete()
```

## 🎛️ Monitoring & Alerting

### Prometheus Metrics
```python
# monitoring.py
from prometheus_client import Counter, Histogram, generate_latest
from django.http import HttpResponse

REQUEST_COUNT = Counter(
    'django_requests_total',
    'Total Django requests',
    ['method', 'endpoint', 'status']
)

REQUEST_LATENCY = Histogram(
    'django_request_duration_seconds',
    'Django request latency'
)

class PrometheusMiddleware:
    def __init__(self, get_response):
        self.get_response = get_response
    
    def __call__(self, request):
        start_time = time.time()
        
        response = self.get_response(request)
        
        REQUEST_COUNT.labels(
            method=request.method,
            endpoint=request.path,
            status=response.status_code
        ).inc()
        
        REQUEST_LATENCY.observe(time.time() - start_time)
        
        return response

def metrics_view(request):
    return HttpResponse(generate_latest(), content_type='text/plain')
```

### Health Check Endpoint
```python
# views.py
from django.http import JsonResponse
from django.db import connection
from django.core.cache import cache

def health_check(request):
    health_status = {
        'status': 'healthy',
        'timestamp': timezone.now().isoformat(),
        'checks': {}
    }
    
    # Database check
    try:
        with connection.cursor() as cursor:
            cursor.execute("SELECT 1")
        health_status['checks']['database'] = 'ok'
    except Exception as e:
        health_status['checks']['database'] = f'error: {str(e)}'
        health_status['status'] = 'unhealthy'
    
    # Cache check
    try:
        cache.set('health_check', 'ok', 10)
        result = cache.get('health_check')
        health_status['checks']['cache'] = 'ok' if result == 'ok' else 'error'
    except Exception as e:
        health_status['checks']['cache'] = f'error: {str(e)}'
        health_status['status'] = 'unhealthy'
    
    status_code = 200 if health_status['status'] == 'healthy' else 503
    return JsonResponse(health_status, status=status_code)
```

## 📈 Performance Optimization Checklist

### Database
- [ ] Indexes on frequently queried fields
- [ ] Query optimization with select_related/prefetch_related
- [ ] Connection pooling configured
- [ ] Slow query logging enabled
- [ ] Database-level caching enabled

### Caching
- [ ] Redis/Memcached configured
- [ ] View-level caching implemented
- [ ] Template fragment caching used
- [ ] Model-level caching for expensive operations
- [ ] Cache invalidation strategy in place

### Static Files
- [ ] Static files served by web server (Nginx)
- [ ] Compression enabled (gzip)
- [ ] CSS/JS minification
- [ ] Image optimization
- [ ] CDN configured for production

### Application
- [ ] Debug mode disabled in production
- [ ] Gunicorn/uWSGI properly configured
- [ ] Appropriate number of workers
- [ ] Connection pooling enabled
- [ ] Performance monitoring in place

### Frontend
- [ ] Minimize HTTP requests
- [ ] Optimize images
- [ ] Use CSS sprites where appropriate
- [ ] Lazy loading for images
- [ ] Progressive web app features

### Infrastructure
- [ ] Load balancer configured
- [ ] Auto-scaling enabled
- [ ] Monitoring and alerting set up
- [ ] Regular performance testing
- [ ] Resource usage optimized

---

**📈 Performance Guide - Optimize your Room Booking System for production load**
