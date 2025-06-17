# 🚀 Deployment Testing Scenarios

Skenario deployment bertahap dengan testing untuk Room Booking System dari development hingga production.

## 📋 Overview Deployment Stages

```
Local Dev → Local Docker → Staging → Pre-Production → Production
    ↓           ↓            ↓           ↓             ↓
  Unit Test → Integration → E2E Test → Load Test → Monitor
```

## 🎯 Stage 1: Local Development Testing

### Prerequisites Check
```bash
# Check system requirements
docker --version          # Should be 20.10+
docker-compose --version  # Should be 2.0+
python --version          # Should be 3.11+
git --version
```

### 1.1 Environment Setup
```bash
# Clone and setup
git clone https://github.com/YOUR_USERNAME/room-booking-system.git
cd room-booking-system

# Check project structure
ls -la
ls -la docs/

# Verify environment file
cp .env.example .env
cat .env
```

### 1.2 Local Development Testing
```bash
# Test 1: Python dependencies
python -m venv venv
source venv/bin/activate  # Linux/Mac
pip install -r requirements.txt

# Test 2: Django configuration
export DEBUG=True
export DB_HOST=localhost
python manage.py check
python manage.py check --deploy

# Test 3: Database migrations
python manage.py makemigrations --dry-run
python manage.py sqlmigrate rooms 0001 --verbosity=2

# Test 4: Static files
python manage.py collectstatic --dry-run --verbosity=2
```

### 1.3 Unit Testing
```bash
# Run unit tests
python manage.py test --verbosity=2
python manage.py test rooms.tests.test_models --verbosity=2
python manage.py test rooms.tests.test_views --verbosity=2

# Test coverage (optional)
# pip install coverage
# coverage run --source='.' manage.py test
# coverage report
```

### ✅ Stage 1 Success Criteria
- [ ] All dependencies installed successfully
- [ ] Django configuration passes checks
- [ ] Database migrations are valid
- [ ] Static files collection works
- [ ] All unit tests pass

---

## 🐳 Stage 2: Local Docker Testing

### 2.1 Docker Build Testing
```bash
# Test 1: Docker build
docker build -t room-booking-test .

# Test 2: Check image
docker images | grep room-booking
docker inspect room-booking-test

# Test 3: Container run test
docker run --rm room-booking-test python manage.py check
```

### 2.2 Docker Compose Testing
```bash
# Test 1: Environment validation
cat .env
grep -E "^(DEBUG|SECRET_KEY|DB_)" .env

# Test 2: Services startup
docker-compose config
docker-compose up -d

# Test 3: Services health check
docker-compose ps
docker-compose logs web
docker-compose logs db
```

### 2.3 Application Testing
```bash
# Test 4: Database connectivity
docker-compose exec web python manage.py dbshell --version
docker-compose exec db mysql -u root -p -e "SHOW DATABASES;"

# Test 5: Migrations
docker-compose exec web python manage.py showmigrations
docker-compose exec web python manage.py migrate --verbosity=2

# Test 6: Admin user creation
docker-compose exec web python manage.py createsuperuser --noinput --username admin --email admin@test.com

# Test 7: Static files
docker-compose exec web python manage.py collectstatic --noinput
```

### 2.4 Functionality Testing
```bash
# Test 8: HTTP connectivity
curl -I http://localhost:8001/
curl -I http://localhost:8001/admin/
curl -I http://localhost:8001/rooms/

# Test 9: Application endpoints
curl -s http://localhost:8001/ | grep -i "room booking"
curl -s http://localhost:8001/admin/ | grep -i "django"
```

### ✅ Stage 2 Success Criteria
- [ ] Docker image builds successfully
- [ ] All containers start without errors
- [ ] Database connection established
- [ ] Migrations applied successfully
- [ ] Admin user created
- [ ] Static files served correctly
- [ ] All endpoints respond correctly

---

## 🔧 Stage 3: Staging Environment Testing

### 3.1 Staging Environment Setup
```bash
# Create staging environment file
cp .env .env.staging

# Update staging configuration
cat > .env.staging << EOF
DEBUG=False
SECRET_KEY=staging-secret-key-change-in-production
ALLOWED_HOSTS=staging.yourdomain.com,localhost,127.0.0.1

# Database
DB_HOST=db
DB_NAME=room_usage_db_staging
DB_USER=django_user
DB_PASSWORD=staging-password-123
DB_PORT=3306
MYSQL_ROOT_PASSWORD=staging-root-password-456

# Email (staging)
EMAIL_BACKEND=django.core.mail.backends.console.EmailBackend

# Superuser
DJANGO_SUPERUSER_USERNAME=staging_admin
DJANGO_SUPERUSER_EMAIL=admin@staging.test
DJANGO_SUPERUSER_PASSWORD=staging123
EOF
```

### 3.2 Staging Deployment
```bash
# Deploy to staging
docker-compose --env-file .env.staging down -v
docker-compose --env-file .env.staging up -d --build

# Wait for services to be ready
sleep 30

# Check staging deployment
docker-compose --env-file .env.staging ps
docker-compose --env-file .env.staging logs --tail=50
```

### 3.3 Staging Testing
```bash
# Test 1: Application availability
curl -f http://localhost:8001/ || echo "Homepage failed"
curl -f http://localhost:8001/admin/ || echo "Admin failed"

# Test 2: Database integrity
docker-compose --env-file .env.staging exec web python manage.py check --database default
docker-compose --env-file .env.staging exec web python manage.py migrate --check

# Test 3: Admin functionality
# Manual test: Login to admin panel

# Test 4: Basic CRUD operations
# Manual test: Create room, create user, make booking
```

### ✅ Stage 3 Success Criteria
- [ ] Staging environment deploys successfully
- [ ] Application runs with DEBUG=False
- [ ] Database operations work correctly
- [ ] Admin panel accessible and functional
- [ ] Basic CRUD operations work

---

## 🔍 Stage 4: Integration & E2E Testing

### 4.1 API Testing
```bash
# Create API test script
cat > test_api.sh << 'EOF'
#!/bin/bash

BASE_URL="http://localhost:8001"
echo "Testing Room Booking System API..."

# Test 1: Homepage
echo "Testing homepage..."
response=$(curl -s -o /dev/null -w "%{http_code}" $BASE_URL/)
if [ $response -eq 200 ]; then
    echo "✅ Homepage: OK ($response)"
else
    echo "❌ Homepage: FAILED ($response)"
fi

# Test 2: Admin
echo "Testing admin..."
response=$(curl -s -o /dev/null -w "%{http_code}" $BASE_URL/admin/)
if [ $response -eq 200 ]; then
    echo "✅ Admin: OK ($response)"
else
    echo "❌ Admin: FAILED ($response)"
fi

# Test 3: Rooms list
echo "Testing rooms list..."
response=$(curl -s -o /dev/null -w "%{http_code}" $BASE_URL/rooms/)
if [ $response -eq 200 ]; then
    echo "✅ Rooms list: OK ($response)"
else
    echo "❌ Rooms list: FAILED ($response)"
fi

# Test 4: Static files
echo "Testing static files..."
response=$(curl -s -o /dev/null -w "%{http_code}" $BASE_URL/static/admin/css/base.css)
if [ $response -eq 200 ]; then
    echo "✅ Static files: OK ($response)"
else
    echo "❌ Static files: FAILED ($response)"
fi

echo "API testing completed."
EOF

chmod +x test_api.sh
./test_api.sh
```

### 4.2 Database Testing
```bash
# Create database test script
cat > test_database.sh << 'EOF'
#!/bin/bash

echo "Testing database operations..."

# Test 1: Database connection
echo "Testing database connection..."
docker-compose exec -T web python manage.py dbshell < /dev/null
if [ $? -eq 0 ]; then
    echo "✅ Database connection: OK"
else
    echo "❌ Database connection: FAILED"
fi

# Test 2: Migrations status
echo "Testing migrations..."
result=$(docker-compose exec -T web python manage.py showmigrations --plan | grep -c "\[X\]")
if [ $result -gt 0 ]; then
    echo "✅ Migrations applied: OK ($result migrations)"
else
    echo "❌ Migrations: FAILED"
fi

# Test 3: Sample data creation
echo "Testing sample data creation..."
docker-compose exec -T web python manage.py shell << 'PYTHON'
from django.contrib.auth.models import User
from rooms.models import Room, Booking
from django.utils import timezone
from datetime import timedelta

# Create test user
user, created = User.objects.get_or_create(
    username='testuser',
    defaults={'email': 'test@example.com'}
)
print(f"Test user: {'created' if created else 'exists'}")

# Create test room
room, created = Room.objects.get_or_create(
    name='Test Room',
    defaults={
        'location': 'Test Floor',
        'capacity': 10,
        'description': 'Test room for testing'
    }
)
print(f"Test room: {'created' if created else 'exists'}")

# Create test booking
start_time = timezone.now() + timedelta(days=1)
end_time = start_time + timedelta(hours=2)

booking, created = Booking.objects.get_or_create(
    user=user,
    room=room,
    start_time=start_time,
    defaults={
        'end_time': end_time,
        'title': 'Test Meeting',
        'description': 'Test booking'
    }
)
print(f"Test booking: {'created' if created else 'exists'}")
print("Sample data test completed successfully")
PYTHON

echo "Database testing completed."
EOF

chmod +x test_database.sh
./test_database.sh
```

### 4.3 End-to-End Testing
```bash
# Create E2E test script
cat > test_e2e.sh << 'EOF'
#!/bin/bash

echo "Running End-to-End tests..."

BASE_URL="http://localhost:8001"

# Test 1: User Registration Flow
echo "Testing user registration flow..."
# Note: This would require a more sophisticated testing tool like Selenium
# For now, we test the endpoint availability

registration_page=$(curl -s $BASE_URL/accounts/register/)
if echo "$registration_page" | grep -q "Register"; then
    echo "✅ Registration page: OK"
else
    echo "❌ Registration page: FAILED"
fi

# Test 2: Login Flow
echo "Testing login flow..."
login_page=$(curl -s $BASE_URL/accounts/login/)
if echo "$login_page" | grep -q "Login"; then
    echo "✅ Login page: OK"
else
    echo "❌ Login page: FAILED"
fi

# Test 3: Room Listing
echo "Testing room listing..."
rooms_page=$(curl -s $BASE_URL/rooms/)
if echo "$rooms_page" | grep -q "room\|Room"; then
    echo "✅ Room listing: OK"
else
    echo "❌ Room listing: FAILED"
fi

echo "E2E testing completed."
EOF

chmod +x test_e2e.sh
./test_e2e.sh
```

### ✅ Stage 4 Success Criteria
- [ ] All API endpoints respond correctly
- [ ] Database operations work properly
- [ ] Sample data can be created
- [ ] User registration/login pages accessible
- [ ] Room listing functionality works

---

## 📈 Stage 5: Performance & Load Testing

### 5.1 Performance Baseline
```bash
# Create performance test script
cat > test_performance.sh << 'EOF'
#!/bin/bash

echo "Running performance tests..."

BASE_URL="http://localhost:8001"

# Test 1: Response time measurement
echo "Measuring response times..."

for endpoint in "/" "/admin/" "/rooms/" "/accounts/login/"; do
    echo "Testing $endpoint..."
    time_taken=$(curl -o /dev/null -s -w "%{time_total}" $BASE_URL$endpoint)
    echo "Response time for $endpoint: ${time_taken}s"
    
    # Check if response time is acceptable (< 2 seconds)
    if (( $(echo "$time_taken < 2.0" | bc -l) )); then
        echo "✅ Performance OK for $endpoint"
    else
        echo "❌ Performance SLOW for $endpoint"
    fi
done

echo "Performance testing completed."
EOF

chmod +x test_performance.sh
./test_performance.sh
```

### 5.2 Load Testing (Optional)
```bash
# Install Apache Bench for load testing
# sudo apt-get install apache2-utils

# Create load test script
cat > test_load.sh << 'EOF'
#!/bin/bash

echo "Running load tests..."

BASE_URL="http://localhost:8001"

# Test with 10 concurrent users, 100 requests
echo "Load testing homepage..."
ab -n 100 -c 10 $BASE_URL/ > load_test_results.txt

# Check results
grep "Requests per second" load_test_results.txt
grep "Time per request" load_test_results.txt
grep "Failed requests" load_test_results.txt

echo "Load testing completed. Check load_test_results.txt for details."
EOF

chmod +x test_load.sh
# ./test_load.sh  # Uncomment to run if apache2-utils is installed
```

### 5.3 Resource Monitoring
```bash
# Create monitoring script
cat > monitor_resources.sh << 'EOF'
#!/bin/bash

echo "Monitoring resource usage..."

# Check Docker container stats
echo "Docker container resource usage:"
docker stats --no-stream

# Check disk usage
echo "Disk usage:"
df -h | grep -E "(Filesystem|/dev/)"

# Check memory usage
echo "Memory usage:"
free -h

echo "Resource monitoring completed."
EOF

chmod +x monitor_resources.sh
./monitor_resources.sh
```

### ✅ Stage 5 Success Criteria
- [ ] Response times < 2 seconds for all endpoints
- [ ] Load test passes without errors
- [ ] Resource usage within acceptable limits
- [ ] No memory leaks detected

---

## 🌐 Stage 6: Pre-Production Testing

### 6.1 Production-like Environment
```bash
# Create production environment file
cp .env .env.production

# Update production configuration
cat > .env.production << EOF
DEBUG=False
SECRET_KEY=production-secret-key-must-be-changed
ALLOWED_HOSTS=yourdomain.com,www.yourdomain.com

# Database
DB_HOST=db
DB_NAME=room_usage_db
DB_USER=django_user
DB_PASSWORD=super-strong-production-password
DB_PORT=3306
MYSQL_ROOT_PASSWORD=super-strong-root-password

# Email (production)
EMAIL_BACKEND=django.core.mail.backends.smtp.EmailBackend
EMAIL_HOST=smtp.gmail.com
EMAIL_PORT=587
EMAIL_USE_TLS=True
EMAIL_HOST_USER=your-email@gmail.com
EMAIL_HOST_PASSWORD=your-app-password

# Superuser
DJANGO_SUPERUSER_USERNAME=admin
DJANGO_SUPERUSER_EMAIL=admin@yourdomain.com
DJANGO_SUPERUSER_PASSWORD=change-this-password
EOF
```

### 6.2 Security Testing
```bash
# Create security test script
cat > test_security.sh << 'EOF'
#!/bin/bash

echo "Running security tests..."

# Test 1: Debug mode check
echo "Checking DEBUG mode..."
response=$(curl -s http://localhost:8001/ | grep -i "debug\|traceback")
if [ -z "$response" ]; then
    echo "✅ DEBUG mode: OFF (secure)"
else
    echo "❌ DEBUG mode: ON (insecure)"
fi

# Test 2: Admin access without auth
echo "Testing admin access without authentication..."
response=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8001/admin/rooms/)
if [ $response -eq 302 ] || [ $response -eq 403 ]; then
    echo "✅ Admin protection: OK ($response)"
else
    echo "❌ Admin protection: FAILED ($response)"
fi

# Test 3: CSRF protection
echo "Testing CSRF protection..."
response=$(curl -s -X POST http://localhost:8001/accounts/login/ -d "username=test&password=test")
if echo "$response" | grep -q "CSRF\|403"; then
    echo "✅ CSRF protection: OK"
else
    echo "❌ CSRF protection: FAILED"
fi

echo "Security testing completed."
EOF

chmod +x test_security.sh
./test_security.sh
```

### 6.3 Data Integrity Testing
```bash
# Create data integrity test
cat > test_data_integrity.sh << 'EOF'
#!/bin/bash

echo "Testing data integrity..."

# Test database backup and restore
echo "Testing database backup..."
docker-compose exec db mysqldump -u root -p$(grep MYSQL_ROOT_PASSWORD .env | cut -d= -f2) room_usage_db > backup_test.sql

if [ -s backup_test.sql ]; then
    echo "✅ Database backup: OK"
    
    # Test restore (to a test database)
    echo "Testing database restore..."
    docker-compose exec db mysql -u root -p$(grep MYSQL_ROOT_PASSWORD .env | cut -d= -f2) -e "CREATE DATABASE test_restore;"
    docker-compose exec -T db mysql -u root -p$(grep MYSQL_ROOT_PASSWORD .env | cut -d= -f2) test_restore < backup_test.sql
    
    if [ $? -eq 0 ]; then
        echo "✅ Database restore: OK"
        docker-compose exec db mysql -u root -p$(grep MYSQL_ROOT_PASSWORD .env | cut -d= -f2) -e "DROP DATABASE test_restore;"
    else
        echo "❌ Database restore: FAILED"
    fi
    
    rm backup_test.sql
else
    echo "❌ Database backup: FAILED"
fi

echo "Data integrity testing completed."
EOF

chmod +x test_data_integrity.sh
./test_data_integrity.sh
```

### ✅ Stage 6 Success Criteria
- [ ] Production configuration works correctly
- [ ] Security measures are in place
- [ ] Database backup/restore works
- [ ] No debug information leaked
- [ ] Admin areas properly protected

---

## 🚀 Stage 7: Production Deployment

### 7.1 Final Pre-deployment Checks
```bash
# Create pre-deployment checklist
cat > pre_deployment_checklist.sh << 'EOF'
#!/bin/bash

echo "Pre-deployment checklist..."

# Check 1: Environment configuration
echo "Checking environment configuration..."
if grep -q "DEBUG=False" .env; then
    echo "✅ DEBUG mode: Disabled"
else
    echo "❌ DEBUG mode: Not disabled"
fi

# Check 2: Secret key
if ! grep -q "change-me\|secret-key-here\|django-insecure" .env; then
    echo "✅ Secret key: Updated"
else
    echo "❌ Secret key: Default/insecure"
fi

# Check 3: Database passwords
if ! grep -q "password\|123456\|admin" .env; then
    echo "✅ Database passwords: Secure"
else
    echo "❌ Database passwords: Weak"
fi

# Check 4: ALLOWED_HOSTS
if grep -q "yourdomain.com" .env; then
    echo "✅ ALLOWED_HOSTS: Configured"
else
    echo "❌ ALLOWED_HOSTS: Not configured"
fi

echo "Pre-deployment checklist completed."
EOF

chmod +x pre_deployment_checklist.sh
./pre_deployment_checklist.sh
```

### 7.2 Production Deployment
```bash
# Deploy to production
echo "Deploying to production..."

# Stop existing containers
docker-compose down

# Pull latest code (if deploying from git)
# git pull origin main

# Deploy with production settings
docker-compose --env-file .env.production up -d --build

# Wait for startup
sleep 45

# Verify deployment
docker-compose ps
echo "Production deployment completed."
```

### 7.3 Post-deployment Testing
```bash
# Create post-deployment test
cat > test_production.sh << 'EOF'
#!/bin/bash

echo "Running post-deployment tests..."

BASE_URL="http://localhost:8001"  # Replace with your domain

# Test 1: Application availability
echo "Testing application availability..."
response=$(curl -s -o /dev/null -w "%{http_code}" $BASE_URL/)
if [ $response -eq 200 ]; then
    echo "✅ Application: Available ($response)"
else
    echo "❌ Application: Unavailable ($response)"
fi

# Test 2: Admin panel
echo "Testing admin panel..."
response=$(curl -s -o /dev/null -w "%{http_code}" $BASE_URL/admin/)
if [ $response -eq 200 ]; then
    echo "✅ Admin panel: Available ($response)"
else
    echo "❌ Admin panel: Unavailable ($response)"
fi

# Test 3: Database connectivity
echo "Testing database connectivity..."
docker-compose exec -T web python manage.py check --database default > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "✅ Database: Connected"
else
    echo "❌ Database: Connection failed"
fi

# Test 4: Static files
echo "Testing static files..."
response=$(curl -s -o /dev/null -w "%{http_code}" $BASE_URL/static/admin/css/base.css)
if [ $response -eq 200 ]; then
    echo "✅ Static files: Served correctly ($response)"
else
    echo "❌ Static files: Not served ($response)"
fi

echo "Post-deployment testing completed."
EOF

chmod +x test_production.sh
./test_production.sh
```

### ✅ Stage 7 Success Criteria
- [ ] All pre-deployment checks pass
- [ ] Production deployment successful
- [ ] Application accessible on production domain
- [ ] All core functionality working
- [ ] Database connectivity confirmed
- [ ] Static files served correctly

---

## 📊 Complete Testing Suite

### Run All Tests
```bash
# Create master test script
cat > run_all_tests.sh << 'EOF'
#!/bin/bash

echo "🚀 Running complete test suite for Room Booking System..."
echo "=================================================="

# Stage 1: Local Development
echo "📝 Stage 1: Local Development Testing"
# python manage.py test  # Uncomment if running locally

# Stage 2: Docker Testing
echo "🐳 Stage 2: Docker Testing"
./test_api.sh
./test_database.sh

# Stage 3: E2E Testing
echo "🔍 Stage 3: End-to-End Testing"
./test_e2e.sh

# Stage 4: Performance Testing
echo "📈 Stage 4: Performance Testing"
./test_performance.sh

# Stage 5: Security Testing
echo "🔒 Stage 5: Security Testing"
./test_security.sh

# Stage 6: Resource Monitoring
echo "🖥️ Stage 6: Resource Monitoring"
./monitor_resources.sh

echo "=================================================="
echo "✅ Complete test suite finished!"
echo "Check individual test outputs for any failures."
EOF

chmod +x run_all_tests.sh
```

### Continuous Testing
```bash
# Create monitoring script for production
cat > monitor_production.sh << 'EOF'
#!/bin/bash

echo "🔍 Production monitoring script..."

while true; do
    clear
    echo "=== Room Booking System Monitoring ==="
    echo "Time: $(date)"
    echo
    
    # Check application status
    response=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8001/)
    if [ $response -eq 200 ]; then
        echo "✅ Application: Running (HTTP $response)"
    else
        echo "❌ Application: Issue detected (HTTP $response)"
    fi
    
    # Check container status
    echo "🐳 Container Status:"
    docker-compose ps
    
    # Check resource usage
    echo "📊 Resource Usage:"
    docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.MemPerc}}"
    
    echo "Next check in 30 seconds... (Ctrl+C to stop)"
    sleep 30
done
EOF

chmod +x monitor_production.sh
```

### ✅ Complete Success Criteria

**🎯 All Stages Must Pass:**
- [ ] Local development tests pass
- [ ] Docker containers deploy successfully  
- [ ] Staging environment works correctly
- [ ] Integration tests pass
- [ ] Performance metrics acceptable
- [ ] Security tests pass
- [ ] Production deployment successful
- [ ] Post-deployment verification complete

---

## 📋 Quick Deployment Commands

### Fast Deploy & Test
```bash
# Quick deployment and testing
git clone https://github.com/YOUR_USERNAME/room-booking-system.git
cd room-booking-system

# Setup and deploy
chmod +x start.sh
./start.sh

# Run basic tests
chmod +x run_all_tests.sh
./run_all_tests.sh

# Monitor (optional)
# ./monitor_production.sh
```

### Emergency Rollback
```bash
# Emergency rollback procedure
echo "🚨 Emergency rollback..."
docker-compose down
git checkout HEAD~1  # or specific commit
docker-compose up -d --build
./test_production.sh
echo "Rollback completed. Check test results."
```

---

**🚀 Deployment Testing Scenarios - Room Booking System**

*Comprehensive step-by-step deployment with testing at each stage from development to production.*
