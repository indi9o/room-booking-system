"""
Custom Security Middleware for Room Booking System
"""

import time
import logging
from django.http import HttpResponseForbidden
from django.core.cache import cache
from django.contrib.auth import logout
from django.shortcuts import redirect
from django.urls import reverse
from django.utils.deprecation import MiddlewareMixin

logger = logging.getLogger('django.security')


class SecurityHeadersMiddleware(MiddlewareMixin):
    """
    Add security headers to all responses
    """
    
    def process_response(self, request, response):
        # Add security headers
        response['X-Content-Type-Options'] = 'nosniff'
        response['X-Frame-Options'] = 'DENY'
        response['X-XSS-Protection'] = '1; mode=block'
        response['Referrer-Policy'] = 'strict-origin-when-cross-origin'
        
        # Add CSP header
        csp_policy = (
            "default-src 'self'; "
            "script-src 'self' 'unsafe-inline' https://cdn.jsdelivr.net; "
            "style-src 'self' 'unsafe-inline' https://fonts.googleapis.com https://cdn.jsdelivr.net; "
            "font-src 'self' https://fonts.gstatic.com; "
            "img-src 'self' data: https:; "
            "connect-src 'self';"
        )
        response['Content-Security-Policy'] = csp_policy
        
        return response


class LoginAttemptMiddleware(MiddlewareMixin):
    """
    Track failed login attempts and implement temporary lockouts
    """
    
    def process_request(self, request):
        if request.path == '/accounts/login/' and request.method == 'POST':
            ip_address = self.get_client_ip(request)
            cache_key = f'login_attempts:{ip_address}'
            
            # Check if IP is temporarily locked
            lockout_key = f'lockout:{ip_address}'
            if cache.get(lockout_key):
                logger.warning(f'Login attempt from locked IP: {ip_address}')
                return HttpResponseForbidden('Too many failed login attempts. Please try again later.')
        
        return None
    
    def process_response(self, request, response):
        # Track failed login attempts
        if (request.path == '/accounts/login/' and 
            request.method == 'POST' and 
            response.status_code == 200 and 
            'error' in response.content.decode().lower()):
            
            ip_address = self.get_client_ip(request)
            cache_key = f'login_attempts:{ip_address}'
            
            attempts = cache.get(cache_key, 0) + 1
            cache.set(cache_key, attempts, 300)  # 5 minutes
            
            logger.warning(f'Failed login attempt #{attempts} from IP: {ip_address}')
            
            # Lock account after 5 attempts
            if attempts >= 5:
                cache.set(f'lockout:{ip_address}', True, 900)  # 15 minutes lockout
                logger.critical(f'IP locked due to repeated failed attempts: {ip_address}')
        
        # Clear attempts on successful login
        elif (request.path == '/accounts/login/' and 
              request.method == 'POST' and 
              response.status_code == 302):
            
            ip_address = self.get_client_ip(request)
            cache.delete(f'login_attempts:{ip_address}')
        
        return response
    
    def get_client_ip(self, request):
        """Get client IP address"""
        x_forwarded_for = request.META.get('HTTP_X_FORWARDED_FOR')
        if x_forwarded_for:
            ip = x_forwarded_for.split(',')[0]
        else:
            ip = request.META.get('REMOTE_ADDR')
        return ip


class SessionSecurityMiddleware(MiddlewareMixin):
    """
    Enhanced session security with timeout and IP checking
    """
    
    def process_request(self, request):
        if request.user.is_authenticated:
            # Check session timeout
            last_activity = request.session.get('last_activity')
            if last_activity:
                time_since_last_activity = time.time() - last_activity
                
                # Logout after 1 hour of inactivity
                if time_since_last_activity > 3600:
                    logger.info(f'Session timeout for user: {request.user.username}')
                    logout(request)
                    return redirect(reverse('login'))
            
            # Update last activity
            request.session['last_activity'] = time.time()
            
            # IP binding (optional - comment out if causing issues)
            session_ip = request.session.get('session_ip')
            current_ip = self.get_client_ip(request)
            
            if session_ip and session_ip != current_ip:
                logger.warning(f'IP change detected for user {request.user.username}: {session_ip} -> {current_ip}')
                # Uncomment to enforce IP binding:
                # logout(request)
                # return redirect(reverse('login'))
            else:
                request.session['session_ip'] = current_ip
        
        return None
    
    def get_client_ip(self, request):
        """Get client IP address"""
        x_forwarded_for = request.META.get('HTTP_X_FORWARDED_FOR')
        if x_forwarded_for:
            ip = x_forwarded_for.split(',')[0]
        else:
            ip = request.META.get('REMOTE_ADDR')
        return ip


class RequestLoggingMiddleware(MiddlewareMixin):
    """
    Log security-relevant requests
    """
    
    SENSITIVE_PATHS = [
        '/admin/',
        '/accounts/login/',
        '/accounts/logout/',
        '/rooms/create/',
        '/bookings/create/',
    ]
    
    def process_request(self, request):
        # Log sensitive requests
        if any(request.path.startswith(path) for path in self.SENSITIVE_PATHS):
            ip_address = self.get_client_ip(request)
            user = request.user.username if request.user.is_authenticated else 'anonymous'
            
            logger.info(f'Request: {request.method} {request.path} from {ip_address} by {user}')
        
        return None
    
    def process_response(self, request, response):
        # Log failed requests to sensitive paths
        if (any(request.path.startswith(path) for path in self.SENSITIVE_PATHS) and 
            response.status_code >= 400):
            
            ip_address = self.get_client_ip(request)
            user = request.user.username if request.user.is_authenticated else 'anonymous'
            
            logger.warning(f'Failed request: {request.method} {request.path} '
                         f'from {ip_address} by {user} - Status: {response.status_code}')
        
        return response
    
    def get_client_ip(self, request):
        """Get client IP address"""
        x_forwarded_for = request.META.get('HTTP_X_FORWARDED_FOR')
        if x_forwarded_for:
            ip = x_forwarded_for.split(',')[0]
        else:
            ip = request.META.get('REMOTE_ADDR')
        return ip
