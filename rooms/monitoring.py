"""
Health Check and Monitoring Views
Provides endpoints for application health monitoring
"""

from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from django.views.decorators.http import require_http_methods
from django.db import connection
from django.core.cache import cache
from django.conf import settings
import time
import os
import psutil
from datetime import datetime


@csrf_exempt
@require_http_methods(["GET"])
def health_check(request):
    """
    Basic health check endpoint
    Returns 200 if application is healthy
    """
    try:
        # Test database connection
        with connection.cursor() as cursor:
            cursor.execute("SELECT 1")
        
        return JsonResponse({
            'status': 'healthy',
            'timestamp': datetime.now().isoformat(),
            'version': getattr(settings, 'VERSION', '1.0.0'),
            'environment': getattr(settings, 'ENVIRONMENT', 'development')
        })
    
    except Exception as e:
        return JsonResponse({
            'status': 'unhealthy',
            'error': str(e),
            'timestamp': datetime.now().isoformat()
        }, status=503)


@csrf_exempt
@require_http_methods(["GET"])
def health_detailed(request):
    """
    Detailed health check with system metrics
    Includes database, cache, disk space, memory usage
    """
    health_data = {
        'status': 'healthy',
        'timestamp': datetime.now().isoformat(),
        'checks': {}
    }
    
    overall_status = True
    
    # Database Check
    try:
        start_time = time.time()
        with connection.cursor() as cursor:
            cursor.execute("SELECT COUNT(*) FROM django_session")
            result = cursor.fetchone()
        
        db_response_time = (time.time() - start_time) * 1000
        
        health_data['checks']['database'] = {
            'status': 'pass',
            'response_time_ms': round(db_response_time, 2),
            'sessions_count': result[0] if result else 0
        }
    except Exception as e:
        health_data['checks']['database'] = {
            'status': 'fail',
            'error': str(e)
        }
        overall_status = False
    
    # Cache Check
    try:
        start_time = time.time()
        cache.set('health_check', 'test', 10)
        cache_value = cache.get('health_check')
        cache_response_time = (time.time() - start_time) * 1000
        
        if cache_value == 'test':
            health_data['checks']['cache'] = {
                'status': 'pass',
                'response_time_ms': round(cache_response_time, 2)
            }
        else:
            health_data['checks']['cache'] = {
                'status': 'fail',
                'error': 'Cache value mismatch'
            }
            overall_status = False
            
    except Exception as e:
        health_data['checks']['cache'] = {
            'status': 'fail',
            'error': str(e)
        }
        overall_status = False
    
    # System Resources Check
    try:
        # Memory usage
        memory = psutil.virtual_memory()
        health_data['checks']['memory'] = {
            'status': 'pass' if memory.percent < 90 else 'warn',
            'usage_percent': memory.percent,
            'available_gb': round(memory.available / (1024**3), 2),
            'total_gb': round(memory.total / (1024**3), 2)
        }
        
        # Disk usage
        disk = psutil.disk_usage('/')
        health_data['checks']['disk'] = {
            'status': 'pass' if disk.percent < 85 else 'warn',
            'usage_percent': disk.percent,
            'free_gb': round(disk.free / (1024**3), 2),
            'total_gb': round(disk.total / (1024**3), 2)
        }
        
        # CPU usage
        cpu_percent = psutil.cpu_percent(interval=1)
        health_data['checks']['cpu'] = {
            'status': 'pass' if cpu_percent < 80 else 'warn',
            'usage_percent': cpu_percent,
            'core_count': psutil.cpu_count()
        }
        
    except Exception as e:
        health_data['checks']['system'] = {
            'status': 'fail',
            'error': str(e)
        }
    
    # Application-specific checks
    try:
        from .models import Room, Booking
        
        room_count = Room.objects.count()
        booking_count = Booking.objects.count()
        active_bookings = Booking.objects.filter(status='approved').count()
        
        health_data['checks']['application'] = {
            'status': 'pass',
            'rooms_total': room_count,
            'bookings_total': booking_count,
            'active_bookings': active_bookings
        }
        
    except Exception as e:
        health_data['checks']['application'] = {
            'status': 'fail',
            'error': str(e)
        }
        overall_status = False
    
    # Set overall status
    health_data['status'] = 'healthy' if overall_status else 'unhealthy'
    
    status_code = 200 if overall_status else 503
    return JsonResponse(health_data, status=status_code)


@csrf_exempt
@require_http_methods(["GET"])
def metrics(request):
    """
    Prometheus-style metrics endpoint
    Returns application metrics in text format
    """
    try:
        from .models import Room, Booking
        
        # Application metrics
        room_total = Room.objects.count()
        room_available = Room.objects.filter(is_available=True).count()
        
        booking_total = Booking.objects.count()
        booking_pending = Booking.objects.filter(status='pending').count()
        booking_approved = Booking.objects.filter(status='approved').count()
        booking_rejected = Booking.objects.filter(status='rejected').count()
        
        # System metrics
        memory = psutil.virtual_memory()
        disk = psutil.disk_usage('/')
        cpu_percent = psutil.cpu_percent()
        
        metrics_text = f"""# HELP room_booking_rooms_total Total number of rooms
# TYPE room_booking_rooms_total gauge
room_booking_rooms_total {room_total}

# HELP room_booking_rooms_available Number of available rooms  
# TYPE room_booking_rooms_available gauge
room_booking_rooms_available {room_available}

# HELP room_booking_bookings_total Total number of bookings
# TYPE room_booking_bookings_total counter
room_booking_bookings_total {booking_total}

# HELP room_booking_bookings_by_status Number of bookings by status
# TYPE room_booking_bookings_by_status gauge
room_booking_bookings_by_status{{status="pending"}} {booking_pending}
room_booking_bookings_by_status{{status="approved"}} {booking_approved}
room_booking_bookings_by_status{{status="rejected"}} {booking_rejected}

# HELP system_memory_usage_percent Memory usage percentage
# TYPE system_memory_usage_percent gauge
system_memory_usage_percent {memory.percent}

# HELP system_disk_usage_percent Disk usage percentage
# TYPE system_disk_usage_percent gauge
system_disk_usage_percent {disk.percent}

# HELP system_cpu_usage_percent CPU usage percentage
# TYPE system_cpu_usage_percent gauge
system_cpu_usage_percent {cpu_percent}
"""
        
        return JsonResponse({
            'metrics': metrics_text,
            'timestamp': datetime.now().isoformat()
        })
        
    except Exception as e:
        return JsonResponse({
            'error': str(e),
            'timestamp': datetime.now().isoformat()
        }, status=500)
