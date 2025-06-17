#!/bin/bash

# Enhanced startup script for Room Booking System

echo "=== Starting Room Booking System ==="
echo "Environment: $([ "$DEBUG" = "True" ] || [ "$DEBUG" = "true" ] && echo "Development" || echo "Production")"

# Wait for database to be ready
echo "Waiting for database..."
until python -c "
import os, django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', '${DJANGO_SETTINGS_MODULE:-room_usage_project.settings}')
django.setup()
from django.db import connection
connection.ensure_connection()
print('Database ready!')
" 2>/dev/null; do
    echo "Database not ready, waiting..."
    sleep 2
done

# Run database migrations
echo "Running migrations..."
python manage.py migrate --noinput

# Collect static files
echo "Collecting static files..."
python manage.py collectstatic --noinput

# Create superuser if specified
if [ "$DJANGO_SUPERUSER_USERNAME" ] && [ "$DJANGO_SUPERUSER_PASSWORD" ] && [ "$DJANGO_SUPERUSER_EMAIL" ]; then
    echo "Creating superuser..."
    python manage.py shell << EOF
from django.contrib.auth.models import User
if not User.objects.filter(username='$DJANGO_SUPERUSER_USERNAME').exists():
    User.objects.create_superuser('$DJANGO_SUPERUSER_USERNAME', '$DJANGO_SUPERUSER_EMAIL', '$DJANGO_SUPERUSER_PASSWORD')
    print('Superuser created successfully')
else:
    print('Superuser already exists')
EOF
fi

echo "=== Setup completed! ==="

# Start application based on environment
if [ "$DEBUG" = "True" ] || [ "$DEBUG" = "true" ]; then
    echo "Starting Django development server..."
    exec python manage.py runserver 0.0.0.0:8000
else
    echo "Starting Gunicorn production server..."
    # Production-grade gunicorn configuration
    exec gunicorn \
        --bind 0.0.0.0:8000 \
        --workers ${GUNICORN_WORKERS:-4} \
        --worker-class ${GUNICORN_WORKER_CLASS:-sync} \
        --timeout ${GUNICORN_TIMEOUT:-120} \
        --keep-alive ${GUNICORN_KEEPALIVE:-5} \
        --max-requests ${GUNICORN_MAX_REQUESTS:-1000} \
        --max-requests-jitter ${GUNICORN_MAX_REQUESTS_JITTER:-100} \
        --access-logfile - \
        --error-logfile - \
        --log-level ${GUNICORN_LOG_LEVEL:-info} \
        room_usage_project.wsgi:application
fi
