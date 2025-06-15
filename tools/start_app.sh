#!/bin/bash

# Script untuk menjalankan aplikasi Room Booking System

echo "=== Room Booking System Startup ==="

# Activate virtual environment if exists
if [ -d "venv" ]; then
    echo "Activating virtual environment..."
    source venv/bin/activate
fi

# Install dependencies if requirements.txt exists
if [ -f "requirements.txt" ]; then
    echo "Installing dependencies..."
    pip install -r requirements.txt
fi

# Run migrations
echo "Running migrations..."
python manage.py makemigrations
python manage.py migrate

# Collect static files
echo "Collecting static files..."
python manage.py collectstatic --noinput

# Create superuser if not exists
echo "Creating superuser (if not exists)..."
python manage.py shell -c "
from django.contrib.auth.models import User
if not User.objects.filter(username='admin').exists():
    User.objects.create_superuser('admin', 'alan@ub.ac.id', 'admin123')
    print('Superuser created: admin / admin123')
else:
    print('Superuser already exists')
"

echo "=== Starting Django Development Server ==="
echo "Access the application at: http://localhost:8000"
echo "Admin panel at: http://localhost:8000/admin"
echo "Login: admin / admin123"
echo ""

# Start development server
python manage.py runserver 0.0.0.0:8000
