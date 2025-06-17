from django.http import JsonResponse
from django.db import connection
from django.core.exceptions import ImproperlyConfigured
import os

def health_check(request):
    """Simple health check endpoint"""
    return JsonResponse({
        'status': 'healthy',
        'service': 'room-booking-system'
    })

def health_check_detailed(request):
    """Detailed health check with database connectivity"""
    health_data = {
        'status': 'healthy',
        'service': 'room-booking-system',
        'debug': os.getenv('DEBUG', 'False'),
        'environment': os.getenv('ENVIRONMENT', 'development')
    }
    
    # Check database connectivity
    try:
        with connection.cursor() as cursor:
            cursor.execute("SELECT 1")
        health_data['database'] = 'connected'
    except Exception as e:
        health_data['status'] = 'degraded'
        health_data['database'] = f'error: {str(e)}'
    
    return JsonResponse(health_data)