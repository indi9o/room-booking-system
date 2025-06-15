"""
Internationalization Settings for Room Booking System
Multi-language support configuration
"""

from .settings import *

# Internationalization
USE_I18N = True
USE_L10N = True
USE_TZ = True

# Language code
LANGUAGE_CODE = 'en-us'

# Time zone
TIME_ZONE = 'Asia/Jakarta'  # Adjust to your timezone

# Available languages
LANGUAGES = [
    ('en', 'English'),
    ('id', 'Bahasa Indonesia'),
    ('zh', '中文'),
    ('ja', '日本語'),
    ('ko', '한국어'),
]

# Locale paths
LOCALE_PATHS = [
    BASE_DIR / 'locale',
]

# Middleware for language detection
MIDDLEWARE.insert(0, 'django.middleware.locale.LocaleMiddleware')

# Language detection order
# 1. URL prefix (/en/, /id/, etc.)
# 2. Session
# 3. Cookie
# 4. Accept-Language header
# 5. Default language

# Language cookie settings
LANGUAGE_COOKIE_NAME = 'django_language'
LANGUAGE_COOKIE_AGE = 31536000  # 1 year
LANGUAGE_COOKIE_DOMAIN = None
LANGUAGE_COOKIE_PATH = '/'
LANGUAGE_COOKIE_SECURE = False  # Set to True in production with HTTPS
LANGUAGE_COOKIE_HTTPONLY = False
LANGUAGE_COOKIE_SAMESITE = 'Lax'

# Date and time formatting
DATE_FORMAT = 'Y-m-d'
TIME_FORMAT = 'H:i'
DATETIME_FORMAT = 'Y-m-d H:i'
SHORT_DATE_FORMAT = 'm/d/Y'
SHORT_DATETIME_FORMAT = 'm/d/Y P'

# Number formatting
USE_THOUSAND_SEPARATOR = True
THOUSAND_SEPARATOR = ','
DECIMAL_SEPARATOR = '.'

# Currency formatting (if needed for future features)
DEFAULT_CURRENCY = 'USD'
CURRENCY_CHOICES = [
    ('USD', 'US Dollar'),
    ('IDR', 'Indonesian Rupiah'),
    ('EUR', 'Euro'),
    ('GBP', 'British Pound'),
    ('JPY', 'Japanese Yen'),
]

# Translation management (django-rosetta)
ROSETTA_MESSAGES_PER_PAGE = 25
ROSETTA_ENABLE_TRANSLATION_SUGGESTIONS = True
ROSETTA_MESSAGES_SOURCE_LANGUAGE_CODE = 'en'
ROSETTA_MESSAGES_SOURCE_LANGUAGE_NAME = 'English'

# Additional i18n apps
INSTALLED_APPS += [
    'rosetta',  # Translation management interface
]

# Template context processors for i18n
TEMPLATES[0]['OPTIONS']['context_processors'].extend([
    'django.template.context_processors.i18n',
])

# Custom format strings for different locales
FORMAT_MODULE_PATH = [
    'room_usage_project.formats',
]
