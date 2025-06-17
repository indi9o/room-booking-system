#!/bin/bash

# Room Booking System - Development Tools

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo "🔧 Room Booking System - Development Tools"
echo "=========================================="

# Function to reset database
reset_database() {
    echo "🗄️  Resetting database..."
    
    # Stop containers
    docker-compose down
    
    # Remove database volume
    docker volume rm room-booking-system_mysql_data 2>/dev/null || true
    
    # Start containers
    docker-compose up -d
    
    # Wait for database
    echo "⏳ Waiting for database to be ready..."
    sleep 15
    
    # Run migrations
    docker-compose exec web python manage.py migrate
    
    # Load sample data
    docker-compose exec web python manage.py load_sample_data
    
    echo "✅ Database reset completed"
}

# Function to run tests
run_tests() {
    local test_type=${1:-all}
    
    echo "🧪 Running tests..."
    
    case $test_type in
        "unit")
            docker-compose exec web python manage.py test rooms.tests
            ;;
        "integration")
            echo "Running integration tests..."
            docker-compose exec web python manage.py test --pattern="*integration*"
            ;;
        "coverage")
            echo "Running tests with coverage..."
            docker-compose exec web coverage run --source='.' manage.py test
            docker-compose exec web coverage report
            docker-compose exec web coverage html
            echo "📊 Coverage report generated in htmlcov/"
            ;;
        *)
            docker-compose exec web python manage.py test
            ;;
    esac
}

# Function to lint code
lint_code() {
    echo "🔍 Linting code..."
    
    # Python linting
    if command -v flake8 &> /dev/null; then
        echo "Running flake8..."
        flake8 "$PROJECT_ROOT" --exclude=migrations,venv,staticfiles
    else
        echo "⚠️  flake8 not installed, skipping Python linting"
    fi
    
    # Check imports
    if command -v isort &> /dev/null; then
        echo "Checking import sorting..."
        isort --check-only "$PROJECT_ROOT" --skip=migrations --skip=venv
    else
        echo "⚠️  isort not installed, skipping import check"
    fi
    
    echo "✅ Linting completed"
}

# Function to format code
format_code() {
    echo "✨ Formatting code..."
    
    # Format Python code
    if command -v black &> /dev/null; then
        echo "Formatting Python code with black..."
        black "$PROJECT_ROOT" --exclude="/(migrations|venv|staticfiles)/"
    else
        echo "⚠️  black not installed, skipping Python formatting"
    fi
    
    # Sort imports
    if command -v isort &> /dev/null; then
        echo "Sorting imports..."
        isort "$PROJECT_ROOT" --skip=migrations --skip=venv
    else
        echo "⚠️  isort not installed, skipping import sorting"
    fi
    
    echo "✅ Code formatting completed"
}

# Function to generate secret key
generate_secret_key() {
    echo "🔐 Generating Django secret key..."
    
    if docker-compose ps | grep -q "web.*Up"; then
        SECRET_KEY=$(docker-compose exec -T web python -c "from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())")
        echo ""
        echo "🔑 Generated SECRET_KEY:"
        echo "$SECRET_KEY"
        echo ""
        echo "💡 Add this to your .env file:"
        echo "SECRET_KEY=$SECRET_KEY"
    else
        echo "❌ Web container is not running. Start the application first."
    fi
}

# Function to create superuser
create_superuser() {
    echo "👤 Creating Django superuser..."
    
    if docker-compose ps | grep -q "web.*Up"; then
        docker-compose exec web python manage.py createsuperuser
    else
        echo "❌ Web container is not running. Start the application first."
    fi
}

# Function to collect static files
collect_static() {
    echo "📁 Collecting static files..."
    
    if docker-compose ps | grep -q "web.*Up"; then
        docker-compose exec web python manage.py collectstatic --noinput
        echo "✅ Static files collected"
    else
        echo "❌ Web container is not running. Start the application first."
    fi
}

# Function to show Django shell
django_shell() {
    echo "🐍 Opening Django shell..."
    
    if docker-compose ps | grep -q "web.*Up"; then
        docker-compose exec web python manage.py shell
    else
        echo "❌ Web container is not running. Start the application first."
    fi
}

# Function to show database shell
database_shell() {
    echo "🗄️  Opening database shell..."
    
    if docker-compose ps | grep -q "db.*Up"; then
        docker-compose exec db mysql -u root -p
    else
        echo "❌ Database container is not running. Start the application first."
    fi
}

# Function to check dependencies
check_dependencies() {
    echo "📦 Checking dependencies..."
    
    # Check Docker
    if command -v docker &> /dev/null; then
        echo "✅ Docker: $(docker --version)"
    else
        echo "❌ Docker not installed"
    fi
    
    # Check Docker Compose
    if command -v docker-compose &> /dev/null; then
        echo "✅ Docker Compose: $(docker-compose --version)"
    else
        echo "❌ Docker Compose not installed"
    fi
    
    # Check if containers are running
    if docker-compose ps | grep -q "Up"; then
        echo "✅ Application containers are running"
    else
        echo "⚠️  Application containers are not running"
    fi
    
    # Check Python version in container
    if docker-compose ps | grep -q "web.*Up"; then
        PYTHON_VERSION=$(docker-compose exec -T web python --version)
        echo "✅ Python: $PYTHON_VERSION"
    fi
}

# Function to install dev tools
install_dev_tools() {
    echo "🔧 Installing development tools..."
    
    echo "Installing Python development tools..."
    pip install --user flake8 black isort coverage bandit
    
    echo "✅ Development tools installed"
    echo "💡 You may need to add ~/.local/bin to your PATH"
}

# Main menu
show_menu() {
    echo ""
    echo "Available commands:"
    echo "  reset-db              - Reset database with sample data"
    echo "  test [type]           - Run tests (unit, integration, coverage, all)"
    echo "  lint                  - Lint code with flake8 and isort"
    echo "  format                - Format code with black and isort"
    echo "  secret-key            - Generate Django secret key"
    echo "  superuser             - Create Django superuser"
    echo "  collectstatic         - Collect static files"
    echo "  shell                 - Open Django shell"
    echo "  dbshell               - Open database shell"
    echo "  check-deps            - Check development dependencies"
    echo "  install-tools         - Install development tools"
    echo "  menu                  - Show this menu"
    echo ""
    echo "Examples:"
    echo "  $0 test coverage      - Run tests with coverage report"
    echo "  $0 reset-db           - Reset database"
    echo "  $0 lint               - Check code style"
}

# Main script logic
case "${1:-menu}" in
    "reset-db")
        reset_database
        ;;
    "test")
        run_tests "${2:-all}"
        ;;
    "lint")
        lint_code
        ;;
    "format")
        format_code
        ;;
    "secret-key")
        generate_secret_key
        ;;
    "superuser")
        create_superuser
        ;;
    "collectstatic")
        collect_static
        ;;
    "shell")
        django_shell
        ;;
    "dbshell")
        database_shell
        ;;
    "check-deps")
        check_dependencies
        ;;
    "install-tools")
        install_dev_tools
        ;;
    "menu"|*)
        show_menu
        ;;
esac
