#!/bin/bash
# =============================================================================
# Start Application Script - Docker Only
# =============================================================================
# Script untuk menjalankan Room Booking System dengan Docker
# All operations are performed via Docker containers - no local Python execution

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEFAULT_MODE="up"

# Functions
print_banner() {
    echo -e "${BLUE}"
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║              Room Booking System - Docker Only               ║"
    echo "║                     Startup Script                           ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

print_help() {
    echo "Usage: $0 [MODE] [OPTIONS]"
    echo ""
    echo "Docker-Only Modes:"
    echo "  up         - Start application with Docker (default)"
    echo "  build      - Build and start with Docker"
    echo "  down       - Stop Docker services"
    echo "  restart    - Restart Docker services"
    echo "  migrate    - Run database migrations via Docker"
    echo "  test       - Run tests via Docker"
    echo "  shell      - Open Django shell via Docker"
    echo "  logs       - Show container logs"
    echo ""
    echo "Options:"
    echo "  --build    - Force rebuild containers"
    echo "  --fresh    - Fresh start (remove old containers)"
    echo ""
    echo "Examples:"
    echo "  $0                       # Start with Docker (default)"
    echo "  $0 up --build            # Build and start"
    echo "  $0 migrate               # Run migrations only"
    echo "  $0 test                  # Run tests"
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
    if ! command -v docker &> /dev/null; then
        error "Docker is not installed. Please install Docker first."
    fi
    if ! command -v docker-compose &> /dev/null; then
        error "Docker Compose is not installed. Please install Docker Compose first."
    fi
}

check_env_file() {
    if [ ! -f "$PROJECT_DIR/.env" ]; then
        warn "No .env file found. Creating basic .env file for Docker..."
        cat > "$PROJECT_DIR/.env" << EOF
# Docker Configuration
DEBUG=1
SECRET_KEY=dev-secret-key-change-in-production
ALLOWED_HOSTS=localhost,127.0.0.1,0.0.0.0

# Database Configuration
DB_HOST=db
DB_NAME=room_usage_db
DB_USER=django_user
DB_PASSWORD=django_password
DB_PORT=3306

# MySQL Root Password
MYSQL_ROOT_PASSWORD=root_password

# Web Port
WEB_PORT=8001
EOF
        log ".env file created with Docker defaults"
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
    
    cd "$PROJECT_DIR"
    
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
        log "👨‍💼 Admin: http://localhost:$port/admin/"
        echo ""
        log "📊 Container status:"
        docker-compose ps
    else
        error "Failed to start services. Check logs with: docker-compose logs"
    fi
}

run_migrations() {
    cd "$PROJECT_DIR"
    log "Running migrations via Docker..."
    docker-compose exec web python manage.py migrate
    log "✅ Migrations completed"
}

run_tests() {
    cd "$PROJECT_DIR"
    log "Running tests via Docker..."
    docker-compose exec web python manage.py test
}

open_shell() {
    cd "$PROJECT_DIR"
    log "Opening Django shell via Docker..."
    docker-compose exec web python manage.py shell
}

stop_services() {
    cd "$PROJECT_DIR"
    log "Stopping Docker services..."
    docker-compose down
    log "✅ Services stopped"
}

restart_services() {
    cd "$PROJECT_DIR"
    log "Restarting Docker services..."
    docker-compose restart
    log "✅ Services restarted"
}

show_logs() {
    cd "$PROJECT_DIR"
    log "Showing container logs..."
    docker-compose logs -f
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
    
    # Check Docker dependencies
    check_dependencies
    
    # Execute based on mode
    case "$MODE" in
        up|docker)
            run_docker "$@"
            ;;
        build)
            run_docker --build "$@"
            ;;
        down|stop)
            stop_services
            ;;
        restart)
            restart_services
            ;;
        migrate)
            run_migrations
            ;;
        test)
            run_tests
            ;;
        shell)
            open_shell
            ;;
        logs)
            show_logs
            ;;
        *)
            error "Unknown mode: $MODE. Use --help for usage information."
            ;;
    esac
}

# Run main function with all arguments
main "$@"
