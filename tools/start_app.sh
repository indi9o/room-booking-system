#!/bin/bash
# =============================================================================
# Start Application Script
# =============================================================================
# Script untuk menjalankan Room Booking System dengan berbagai mode
# Supports: development, production, docker modes

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VENV_DIR="$PROJECT_DIR/venv"
DEFAULT_MODE="docker"

# Functions
print_banner() {
    echo -e "${BLUE}"
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║                    Room Booking System                       ║"
    echo "║                     Startup Script                           ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

print_help() {
    echo "Usage: $0 [MODE] [OPTIONS]"
    echo ""
    echo "Modes:"
    echo "  docker     - Run with Docker (default)"
    echo "  dev        - Run development server"
    echo "  prod       - Run production server"
    echo "  migrate    - Run database migrations only"
    echo "  test       - Run tests"
    echo "  shell      - Open Django shell"
    echo ""
    echo "Options:"
    echo "  --build    - Force rebuild Docker images"
    echo "  --fresh    - Fresh start (clean database)"
    echo "  --port N   - Specify port (default: 8001 for docker, 8000 for dev)"
    echo "  --help     - Show this help"
    echo ""
    echo "Examples:"
    echo "  $0 docker --build        # Build and run with Docker"
    echo "  $0 dev --port 8080       # Run dev server on port 8080"
    echo "  $0 migrate               # Run migrations only"
}

log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

warn() {
    echo -e "${YELLOW}[WARNING] $1${NC}"
}

error() {
    echo -e "${RED}[ERROR] $1${NC}"
    exit 1
}

check_dependencies() {
    case $1 in
        docker)
            if ! command -v docker &> /dev/null; then
                error "Docker is not installed. Please install Docker first."
            fi
            if ! command -v docker-compose &> /dev/null; then
                error "Docker Compose is not installed. Please install Docker Compose first."
            fi
            ;;
        dev|prod)
            if ! command -v python3 &> /dev/null; then
                error "Python 3 is not installed. Please install Python 3 first."
            fi
            ;;
    esac
}

setup_virtualenv() {
    log "Setting up virtual environment..."
    if [ ! -d "$VENV_DIR" ]; then
        python3 -m venv "$VENV_DIR"
        log "Virtual environment created"
    fi
    
    source "$VENV_DIR/bin/activate"
    pip install --upgrade pip
    pip install -r requirements.txt
    log "Dependencies installed"
}

check_env_file() {
    if [ ! -f "$PROJECT_DIR/.env" ]; then
        if [ -f "$PROJECT_DIR/.env.example" ]; then
            log "Copying .env.example to .env"
            cp "$PROJECT_DIR/.env.example" "$PROJECT_DIR/.env"
        else
            warn "No .env file found. Creating basic .env file..."
            cat > "$PROJECT_DIR/.env" << EOF
DEBUG=1
SECRET_KEY=dev-secret-key-change-in-production
DB_HOST=localhost
DB_NAME=room_usage_db
DB_USER=django_user
DB_PASSWORD=django_password
DB_PORT=3306
EOF
        fi
    fi
}

run_docker() {
    local build_flag=""
    local port="8001"
    
    # Parse options
    while [[ $# -gt 0 ]]; do
        case $1 in
            --build)
                build_flag="--build"
                shift
                ;;
            --port)
                port="$2"
                shift 2
                ;;
            --fresh)
                log "Cleaning up existing containers..."
                docker-compose down -v
                shift
                ;;
            *)
                shift
                ;;
        esac
    done
    
    log "Starting application with Docker..."
    log "Port: $port"
    
    # Update port in docker-compose if different
    if [ "$port" != "8001" ]; then
        sed -i "s/8001:8000/$port:8000/g" docker-compose.yml
    fi
    
    docker-compose up -d $build_flag
    
    log "Waiting for services to start..."
    sleep 10
    
    # Check if services are running
    if docker-compose ps | grep -q "Up"; then
        log "✅ Application started successfully!"
        log "🌐 Access: http://localhost:$port"
        log "🏥 Health: http://localhost:$port/health/"
        log "👨‍💼 Admin: http://localhost:$port/admin/"
        echo ""
        log "📊 Container status:"
        docker-compose ps
    else
        error "Failed to start services. Check logs with: docker-compose logs"
    fi
}

run_development() {
    local port="8000"
    
    # Parse options
    while [[ $# -gt 0 ]]; do
        case $1 in
            --port)
                port="$2"
                shift 2
                ;;
            --fresh)
                log "Fresh start - cleaning database..."
                rm -f db.sqlite3
                shift
                ;;
            *)
                shift
                ;;
        esac
    done
    
    cd "$PROJECT_DIR"
    setup_virtualenv
    source "$VENV_DIR/bin/activate"
    
    log "Running database migrations..."
    python manage.py migrate
    
    log "Collecting static files..."
    python manage.py collectstatic --noinput
    
    log "Starting development server on port $port..."
    python manage.py runserver "0.0.0.0:$port"
}

run_production() {
    cd "$PROJECT_DIR"
    setup_virtualenv
    source "$VENV_DIR/bin/activate"
    
    log "Running production checks..."
    python manage.py check --deploy
    
    log "Running database migrations..."
    python manage.py migrate
    
    log "Collecting static files..."
    python manage.py collectstatic --noinput
    
    log "Starting production server..."
    gunicorn room_usage_project.wsgi:application --bind 0.0.0.0:8000
}

run_migrations() {
    cd "$PROJECT_DIR"
    
    if [ -f "$VENV_DIR/bin/activate" ]; then
        source "$VENV_DIR/bin/activate"
        python manage.py migrate
    else
        log "Running migrations in Docker..."
        docker-compose exec web python manage.py migrate
    fi
}

run_tests() {
    cd "$PROJECT_DIR"
    
    if [ -f "$VENV_DIR/bin/activate" ]; then
        source "$VENV_DIR/bin/activate"
        python manage.py test
    else
        log "Running tests in Docker..."
        docker-compose exec web python manage.py test
    fi
}

open_shell() {
    cd "$PROJECT_DIR"
    
    if [ -f "$VENV_DIR/bin/activate" ]; then
        source "$VENV_DIR/bin/activate"
        python manage.py shell
    else
        log "Opening Django shell in Docker..."
        docker-compose exec web python manage.py shell
    fi
}

# Main script
main() {
    print_banner
    
    # Change to project directory
    cd "$PROJECT_DIR"
    
    # Parse mode
    MODE="${1:-$DEFAULT_MODE}"
    shift || true
    
    # Handle help
    if [[ "$MODE" == "--help" || "$MODE" == "-h" ]]; then
        print_help
        exit 0
    fi
    
    # Check environment file
    check_env_file
    
    # Check dependencies
    check_dependencies "$MODE"
    
    # Execute based on mode
    case "$MODE" in
        docker)
            run_docker "$@"
            ;;
        dev|development)
            run_development "$@"
            ;;
        prod|production)
            run_production "$@"
            ;;
        migrate)
            run_migrations "$@"
            ;;
        test)
            run_tests "$@"
            ;;
        shell)
            open_shell "$@"
            ;;
        *)
            error "Unknown mode: $MODE. Use --help for usage information."
            ;;
    esac
}

# Run main function with all arguments
main "$@"
