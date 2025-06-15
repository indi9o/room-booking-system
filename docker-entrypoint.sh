#!/bin/bash

# Docker startup script for Room Booking System

echo "=== Starting Room Booking System with Docker ==="
echo "Waiting for database to be ready..."

# Simple wait for database
sleep 10

echo "Installing dependencies..."
pip install mysqlclient

echo "Running migrations..."
python manage.py makemigrations
python manage.py migrate

echo "Collecting static files..."
python manage.py collectstatic --noinput

echo "Creating superuser if not exists..."
python manage.py shell << EOF
from django.contrib.auth.models import User
if not User.objects.filter(username='admin').exists():
    User.objects.create_superuser('admin', 'admin@example.com', 'admin123')
    print('Superuser created: admin/admin123')
else:
    print('Superuser already exists')
EOF

echo "Loading sample data..."
python manage.py load_sample_data

echo "=== Setup completed! ==="
echo "Starting Django server..."

# Start Django development server
exec python manage.py runserver 0.0.0.0:8000
