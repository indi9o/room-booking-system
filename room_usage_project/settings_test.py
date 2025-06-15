"""
Test Settings for Room Booking System
Optimized for CI/CD and automated testing
"""

from .settings import *
import os

# Test Database Configuration
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.mysql',
        'NAME': os.getenv('DB_NAME', 'test_room_booking'),
        'USER': os.getenv('DB_USER', 'root'),
        'PASSWORD': os.getenv('DB_PASSWORD', 'test_password'),
        'HOST': os.getenv('DB_HOST', '127.0.0.1'),
        'PORT': os.getenv('DB_PORT', '3306'),
        'OPTIONS': {
            'charset': 'utf8mb4',
            'init_command': "SET sql_mode='STRICT_TRANS_TABLES'",
        },
        'TEST': {
            'CHARSET': 'utf8mb4',
            'COLLATION': 'utf8mb4_unicode_ci',
        }
    }
}

# Test-specific settings
DEBUG = False
SECRET_KEY = 'test-secret-key-for-automated-testing'
ALLOWED_HOSTS = ['localhost', '127.0.0.1', 'testserver']

# Disable migrations for faster testing
class DisableMigrations:
    def __contains__(self, item):
        return True
    
    def __getitem__(self, item):
        return None

# MIGRATION_MODULES = DisableMigrations()

# Fast password hashing for tests
PASSWORD_HASHERS = [
    'django.contrib.auth.hashers.MD5PasswordHasher',
]

# Console email backend for testing
EMAIL_BACKEND = 'django.core.mail.backends.console.EmailBackend'

# Static files (for testing)
STATIC_ROOT = '/tmp/static/'
MEDIA_ROOT = '/tmp/media/'

# Disable logging during tests
LOGGING = {
    'version': 1,
    'disable_existing_loggers': False,
    'handlers': {
        'console': {
            'class': 'logging.StreamHandler',
        },
    },
    'root': {
        'handlers': ['console'],
        'level': 'WARNING',
    },
}

# Test cache (in-memory)
CACHES = {
    'default': {
        'BACKEND': 'django.core.cache.backends.locmem.LocMemCache',
    }
}

# Security settings for testing
SECURE_SSL_REDIRECT = False
SESSION_COOKIE_SECURE = False
CSRF_COOKIE_SECURE = False

# Test-specific apps
INSTALLED_APPS += [
    'django_extensions',  # For testing utilities
]

# Test runner
TEST_RUNNER = 'django.test.runner.DiscoverRunner'

# Celery settings for testing (if using async tasks)
CELERY_TASK_ALWAYS_EAGER = True
CELERY_TASK_EAGER_PROPAGATES = True
