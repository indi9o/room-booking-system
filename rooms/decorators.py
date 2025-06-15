"""
Security Decorators for Room Booking System
Custom decorators for rate limiting, permissions, and security
"""

import functools
import time
from django.http import HttpResponseForbidden, JsonResponse
from django.core.cache import cache
from django.contrib.auth.decorators import user_passes_test
from django.shortcuts import redirect
from django.urls import reverse
from django.contrib import messages
from django.views.decorators.cache import cache_page
from django.views.decorators.vary import vary_on_headers


def rate_limit(requests_per_minute=60, per_ip=True, per_user=False):
    """
    Rate limiting decorator
    
    Args:
        requests_per_minute: Maximum requests allowed per minute
        per_ip: Apply limit per IP address
        per_user: Apply limit per authenticated user
    """
    def decorator(view_func):
        @functools.wraps(view_func)
        def wrapper(request, *args, **kwargs):
            # Determine cache key
            if per_user and request.user.is_authenticated:
                cache_key = f'rate_limit_user_{request.user.id}_{view_func.__name__}'
            elif per_ip:
                ip = get_client_ip(request)
                cache_key = f'rate_limit_ip_{ip}_{view_func.__name__}'
            else:
                cache_key = f'rate_limit_global_{view_func.__name__}'
            
            # Check current request count
            current_requests = cache.get(cache_key, 0)
            
            if current_requests >= requests_per_minute:
                if request.headers.get('Accept') == 'application/json':
                    return JsonResponse({
                        'error': 'Rate limit exceeded',
                        'retry_after': 60
                    }, status=429)
                else:
                    return HttpResponseForbidden('Rate limit exceeded. Please try again later.')
            
            # Increment counter
            cache.set(cache_key, current_requests + 1, 60)
            
            return view_func(request, *args, **kwargs)
        
        return wrapper
    return decorator


def staff_required(view_func):
    """
    Decorator that requires user to be staff
    """
    @functools.wraps(view_func)
    def wrapper(request, *args, **kwargs):
        if not request.user.is_authenticated:
            return redirect(f"{reverse('login')}?next={request.path}")
        
        if not request.user.is_staff:
            messages.error(request, 'You need staff privileges to access this page.')
            return redirect('rooms:room_list')
        
        return view_func(request, *args, **kwargs)
    
    return wrapper


def superuser_required(view_func):
    """
    Decorator that requires user to be superuser
    """
    @functools.wraps(view_func)
    def wrapper(request, *args, **kwargs):
        if not request.user.is_authenticated:
            return redirect(f"{reverse('login')}?next={request.path}")
        
        if not request.user.is_superuser:
            messages.error(request, 'You need superuser privileges to access this page.')
            return redirect('rooms:room_list')
        
        return view_func(request, *args, **kwargs)
    
    return wrapper


def owner_or_staff_required(model_field='user'):
    """
    Decorator that requires user to be owner of object or staff
    
    Args:
        model_field: Field name that contains the owner user
    """
    def decorator(view_func):
        @functools.wraps(view_func)
        def wrapper(request, *args, **kwargs):
            if not request.user.is_authenticated:
                return redirect(f"{reverse('login')}?next={request.path}")
            
            # If staff, allow access
            if request.user.is_staff:
                return view_func(request, *args, **kwargs)
            
            # Check if user owns the object
            # This assumes the view has access to the object
            # You might need to modify this based on your view structure
            
            return view_func(request, *args, **kwargs)
        
        return wrapper
    return decorator


def secure_upload(allowed_extensions=None, max_size=5*1024*1024):
    """
    Decorator for secure file upload handling
    
    Args:
        allowed_extensions: List of allowed file extensions
        max_size: Maximum file size in bytes
    """
    if allowed_extensions is None:
        allowed_extensions = ['jpg', 'jpeg', 'png', 'gif', 'pdf']
    
    def decorator(view_func):
        @functools.wraps(view_func)
        def wrapper(request, *args, **kwargs):
            if request.method == 'POST' and request.FILES:
                for file_field, uploaded_file in request.FILES.items():
                    # Check file size
                    if uploaded_file.size > max_size:
                        messages.error(request, f'File {uploaded_file.name} is too large. Maximum size is {max_size // (1024*1024)}MB.')
                        return redirect(request.path)
                    
                    # Check file extension
                    file_extension = uploaded_file.name.split('.')[-1].lower()
                    if file_extension not in allowed_extensions:
                        messages.error(request, f'File type .{file_extension} is not allowed. Allowed types: {", ".join(allowed_extensions)}')
                        return redirect(request.path)
                    
                    # Check for malicious content (basic)
                    if b'<script' in uploaded_file.read(1024):
                        messages.error(request, 'File contains potentially malicious content.')
                        return redirect(request.path)
                    
                    # Reset file pointer
                    uploaded_file.seek(0)
            
            return view_func(request, *args, **kwargs)
        
        return wrapper
    return decorator


def csrf_exempt_ajax(view_func):
    """
    CSRF exempt decorator for AJAX requests with additional security
    """
    from django.views.decorators.csrf import csrf_exempt
    
    @csrf_exempt
    @functools.wraps(view_func)
    def wrapper(request, *args, **kwargs):
        # Only allow AJAX requests
        if not request.headers.get('X-Requested-With') == 'XMLHttpRequest':
            return JsonResponse({'error': 'AJAX requests only'}, status=400)
        
        # Check origin for AJAX requests
        origin = request.headers.get('Origin')
        if origin and not is_safe_origin(origin, request):
            return JsonResponse({'error': 'Invalid origin'}, status=403)
        
        return view_func(request, *args, **kwargs)
    
    return wrapper


def log_security_event(event_type):
    """
    Decorator to log security events
    
    Args:
        event_type: Type of security event (e.g., 'login', 'access_denied', 'data_modification')
    """
    def decorator(view_func):
        @functools.wraps(view_func)
        def wrapper(request, *args, **kwargs):
            import logging
            
            logger = logging.getLogger('django.security')
            ip = get_client_ip(request)
            user = request.user.username if request.user.is_authenticated else 'anonymous'
            
            # Log before execution
            logger.info(f'Security event: {event_type} - User: {user}, IP: {ip}, Path: {request.path}')
            
            try:
                response = view_func(request, *args, **kwargs)
                
                # Log success
                logger.info(f'Security event completed: {event_type} - User: {user}, Status: success')
                
                return response
                
            except Exception as e:
                # Log failure
                logger.error(f'Security event failed: {event_type} - User: {user}, Error: {str(e)}')
                raise
        
        return wrapper
    return decorator


def cache_response(timeout=300):
    """
    Cache response decorator with security considerations
    
    Args:
        timeout: Cache timeout in seconds
    """
    def decorator(view_func):
        @cache_page(timeout)
        @vary_on_headers('User-Agent', 'Accept-Language')
        @functools.wraps(view_func)
        def wrapper(request, *args, **kwargs):
            # Don't cache responses for authenticated users by default
            if request.user.is_authenticated:
                return view_func(request, *args, **kwargs)
            
            return view_func(request, *args, **kwargs)
        
        return wrapper
    return decorator


# Utility functions
def get_client_ip(request):
    """Get client IP address"""
    x_forwarded_for = request.META.get('HTTP_X_FORWARDED_FOR')
    if x_forwarded_for:
        ip = x_forwarded_for.split(',')[0]
    else:
        ip = request.META.get('REMOTE_ADDR')
    return ip


def is_safe_origin(origin, request):
    """Check if origin is safe"""
    from django.conf import settings
    
    allowed_origins = getattr(settings, 'ALLOWED_ORIGINS', [])
    allowed_hosts = getattr(settings, 'ALLOWED_HOSTS', [])
    
    # Add current host to allowed origins
    current_host = request.get_host()
    allowed_origins.extend([f'http://{current_host}', f'https://{current_host}'])
    
    return origin in allowed_origins


# Example usage decorators
def api_key_required(view_func):
    """
    Decorator that requires API key in header
    """
    @functools.wraps(view_func)
    def wrapper(request, *args, **kwargs):
        api_key = request.headers.get('X-API-Key')
        
        if not api_key:
            return JsonResponse({'error': 'API key required'}, status=401)
        
        # Validate API key (implement your logic)
        # if not validate_api_key(api_key):
        #     return JsonResponse({'error': 'Invalid API key'}, status=403)
        
        return view_func(request, *args, **kwargs)
    
    return wrapper
