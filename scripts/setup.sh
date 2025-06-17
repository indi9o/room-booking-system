#!/bin/bash

# Room Booking System - Setup Script

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo "🚀 Room Booking System - Setup Script"
echo "====================================="

# Function to check system requirements
check_requirements() {
    echo "🔍 Checking system requirements..."
    
    local missing_deps=()
    
    # Check Docker
    if ! command -v docker &> /dev/null; then
        missing_deps+=("docker")
    else
        echo "✅ Docker: $(docker --version)"
    fi
    
    # Check Docker Compose
    if ! command -v docker-compose &> /dev/null; then
        missing_deps+=("docker-compose")
    else
        echo "✅ Docker Compose: $(docker-compose --version)"
    fi
    
    # Check Git
    if ! command -v git &> /dev/null; then
        missing_deps+=("git")
    else
        echo "✅ Git: $(git --version)"
    fi
    
    if [ ${#missing_deps[@]} -ne 0 ]; then
        echo ""
        echo "❌ Missing dependencies:"
        for dep in "${missing_deps[@]}"; do
            echo "   - $dep"
        done
        echo ""
        echo "Please install the missing dependencies and run this script again."
        echo ""
        echo "Installation commands:"
        echo "  - Docker: https://docs.docker.com/get-docker/"
        echo "  - Docker Compose: https://docs.docker.com/compose/install/"
        echo "  - Git: sudo apt install git (Ubuntu/Debian)"
        exit 1
    fi
    
    echo "✅ All system requirements met"
}

# Function to setup environment
setup_environment() {
    echo "⚙️  Setting up environment..."
    
    cd "$PROJECT_ROOT"
    
    # Create .env from template if it doesn't exist
    if [ ! -f ".env" ]; then
        if [ -f ".env.template" ]; then
            cp ".env.template" ".env"
            echo "✅ Created .env from template"
        else
            echo "❌ .env.template not found"
            exit 1
        fi
    else
        echo "⚠️  .env already exists, skipping"
    fi
    
    # Create directories
    mkdir -p media logs backups
    echo "✅ Created necessary directories"
    
    # Set proper permissions for scripts
    chmod +x scripts/*.sh 2>/dev/null || true
    chmod +x docker-entrypoint.sh 2>/dev/null || true
    echo "✅ Set script permissions"
}

# Function to build and start application
build_and_start() {
    echo "🔨 Building and starting application..."
    
    cd "$PROJECT_ROOT"
    
    # Build images
    echo "Building Docker images..."
    docker-compose build
    
    # Start services
    echo "Starting services..."
    docker-compose up -d
    
    # Wait for services to be ready
    echo "⏳ Waiting for services to start..."
    sleep 15
    
    # Check if services are running
    if docker-compose ps | grep -q "Up"; then
        echo "✅ Services are running"
    else
        echo "❌ Failed to start services"
        docker-compose logs
        exit 1
    fi
}

# Function to setup database
setup_database() {
    echo "🗄️  Setting up database..."
    
    cd "$PROJECT_ROOT"
    
    # Wait for database to be ready
    echo "⏳ Waiting for database to be ready..."
    local max_attempts=30
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        if docker-compose exec -T web python manage.py check --database default > /dev/null 2>&1; then
            break
        fi
        echo "Waiting for database... (attempt $attempt/$max_attempts)"
        sleep 2
        ((attempt++))
    done
    
    if [ $attempt -gt $max_attempts ]; then
        echo "❌ Database failed to start within timeout"
        exit 1
    fi
    
    # Run migrations
    echo "Running database migrations..."
    docker-compose exec web python manage.py migrate
    
    # Load sample data
    echo "Loading sample data..."
    docker-compose exec web python manage.py load_sample_data
    
    # Collect static files
    echo "Collecting static files..."
    docker-compose exec web python manage.py collectstatic --noinput
    
    echo "✅ Database setup completed"
}

# Function to create admin user
create_admin_user() {
    echo "👤 Creating admin user..."
    
    # Check if admin user should be created automatically
    source "$PROJECT_ROOT/.env" 2>/dev/null || true
    
    if [ -n "$DJANGO_SUPERUSER_USERNAME" ] && [ -n "$DJANGO_SUPERUSER_PASSWORD" ] && [ -n "$DJANGO_SUPERUSER_EMAIL" ]; then
        echo "Creating admin user from environment variables..."
        docker-compose exec -T web python manage.py shell << EOF
from django.contrib.auth.models import User
if not User.objects.filter(username='$DJANGO_SUPERUSER_USERNAME').exists():
    User.objects.create_superuser('$DJANGO_SUPERUSER_USERNAME', '$DJANGO_SUPERUSER_EMAIL', '$DJANGO_SUPERUSER_PASSWORD')
    print('✅ Admin user created successfully')
else:
    print('⚠️  Admin user already exists')
EOF
    else
        echo "⚠️  No admin user credentials in .env, skipping automatic creation"
        echo "💡 You can create an admin user later with: docker-compose exec web python manage.py createsuperuser"
    fi
}

# Function to verify installation
verify_installation() {
    echo "🔍 Verifying installation..."
    
    cd "$PROJECT_ROOT"
    
    # Check if web application is responding
    local max_attempts=10
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        if curl -f -s http://localhost:8001/ > /dev/null 2>&1; then
            echo "✅ Web application is responding"
            break
        fi
        echo "Checking web application... (attempt $attempt/$max_attempts)"
        sleep 3
        ((attempt++))
    done
    
    if [ $attempt -gt $max_attempts ]; then
        echo "⚠️  Web application is not responding, but setup may still be successful"
        echo "💡 Check logs with: docker-compose logs web"
    fi
    
    # Show container status
    echo ""
    echo "📊 Container Status:"
    docker-compose ps
    
    # Show application URLs
    echo ""
    echo "🌐 Application URLs:"
    echo "  - Main Application: http://localhost:8001"
    echo "  - Admin Panel: http://localhost:8001/admin"
    
    # Show admin credentials if available
    source "$PROJECT_ROOT/.env" 2>/dev/null || true
    if [ -n "$DJANGO_SUPERUSER_USERNAME" ] && [ -n "$DJANGO_SUPERUSER_PASSWORD" ]; then
        echo ""
        echo "🔑 Admin Credentials:"
        echo "  - Username: $DJANGO_SUPERUSER_USERNAME"
        echo "  - Password: $DJANGO_SUPERUSER_PASSWORD"
    fi
}

# Function to show next steps
show_next_steps() {
    echo ""
    echo "🎉 Setup completed successfully!"
    echo ""
    echo "🔗 Quick Links:"
    echo "  - Application: http://localhost:8001"
    echo "  - Admin Panel: http://localhost:8001/admin"
    echo ""
    echo "📋 Useful Commands:"
    echo "  - View logs: docker-compose logs -f web"
    echo "  - Stop application: docker-compose down"
    echo "  - Restart application: docker-compose restart"
    echo "  - Development tools: $SCRIPT_DIR/dev-tools.sh"
    echo "  - Monitor application: $SCRIPT_DIR/monitor.sh"
    echo "  - Backup data: $SCRIPT_DIR/backup.sh"
    echo ""
    echo "📚 Documentation:"
    echo "  - User Guide: docs/DOCUMENTATION.md"
    echo "  - Developer Guide: docs/DEVELOPER.md"
    echo "  - Deployment Guide: docs/DEPLOYMENT.md"
    echo ""
    echo "Happy coding! 🚀"
}

# Main setup process
main() {
    echo "Starting setup process..."
    echo ""
    
    check_requirements
    echo ""
    
    setup_environment
    echo ""
    
    build_and_start
    echo ""
    
    setup_database
    echo ""
    
    create_admin_user
    echo ""
    
    verify_installation
    echo ""
    
    show_next_steps
}

# Script options
case "${1:-}" in
    "requirements")
        check_requirements
        ;;
    "environment")
        setup_environment
        ;;
    "build")
        build_and_start
        ;;
    "database")
        setup_database
        ;;
    "admin")
        create_admin_user
        ;;
    "verify")
        verify_installation
        ;;
    *)
        main
        ;;
esac
