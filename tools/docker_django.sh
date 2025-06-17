#!/bin/bash

# 🐳 Docker Django Management Tool
# Room Booking System - Docker Development Helper

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

echo "🐳 Docker Django Management Tool"
echo "================================"
echo ""

# Function to show help
show_help() {
    echo -e "${BLUE}Available Commands:${NC}"
    echo ""
    echo -e "${GREEN}Container Management:${NC}"
    echo "  up          - Start all services"
    echo "  down        - Stop all services"
    echo "  build       - Build/rebuild containers"
    echo "  restart     - Restart all services"
    echo "  logs        - Show container logs"
    echo "  status      - Show container status"
    echo ""
    echo -e "${GREEN}Django Commands:${NC}"
    echo "  migrate     - Run database migrations"
    echo "  makemigrations - Create new migrations"
    echo "  createsuperuser - Create Django superuser"
    echo "  collectstatic - Collect static files"
    echo "  shell       - Open Django shell"
    echo "  test        - Run Django tests"
    echo ""
    echo -e "${GREEN}Database:${NC}"
    echo "  dbshell     - Open database shell"
    echo "  dbbackup    - Create database backup"
    echo "  dbrestore   - Restore database from backup"
    echo ""
    echo -e "${GREEN}Development:${NC}"
    echo "  exec [cmd]  - Execute command in web container"
    echo "  bash        - Open bash shell in web container"
    echo ""
    echo -e "${YELLOW}Usage Examples:${NC}"
    echo "  ./tools/docker_django.sh up"
    echo "  ./tools/docker_django.sh migrate"
    echo "  ./tools/docker_django.sh exec 'pip list'"
    echo ""
}

# Function to check if containers are running
check_containers() {
    if ! docker-compose ps | grep -q "Up"; then
        echo -e "${YELLOW}⚠️  Containers not running. Starting them...${NC}"
        docker-compose up -d
        sleep 5
    fi
}

# Main command handling
case "${1:-help}" in
    "up")
        echo -e "${BLUE}🚀 Starting all services...${NC}"
        docker-compose up -d
        echo -e "${GREEN}✅ Services started. Access app at http://localhost:8001${NC}"
        ;;
    "down")
        echo -e "${BLUE}🛑 Stopping all services...${NC}"
        docker-compose down
        echo -e "${GREEN}✅ All services stopped${NC}"
        ;;
    "build")
        echo -e "${BLUE}🔨 Building containers...${NC}"
        docker-compose build
        echo -e "${GREEN}✅ Build complete${NC}"
        ;;
    "restart")
        echo -e "${BLUE}🔄 Restarting services...${NC}"
        docker-compose restart
        echo -e "${GREEN}✅ Services restarted${NC}"
        ;;
    "logs")
        echo -e "${BLUE}📋 Showing container logs...${NC}"
        docker-compose logs -f
        ;;
    "status")
        echo -e "${BLUE}📊 Container status:${NC}"
        docker-compose ps
        ;;
    "migrate")
        echo -e "${BLUE}📊 Running database migrations...${NC}"
        check_containers
        docker-compose exec web python manage.py migrate
        echo -e "${GREEN}✅ Migrations complete${NC}"
        ;;
    "makemigrations")
        echo -e "${BLUE}📝 Creating new migrations...${NC}"
        check_containers
        docker-compose exec web python manage.py makemigrations
        echo -e "${GREEN}✅ Migrations created${NC}"
        ;;
    "createsuperuser")
        echo -e "${BLUE}👤 Creating Django superuser...${NC}"
        check_containers
        docker-compose exec web python manage.py createsuperuser
        echo -e "${GREEN}✅ Superuser created${NC}"
        ;;
    "collectstatic")
        echo -e "${BLUE}📁 Collecting static files...${NC}"
        check_containers
        docker-compose exec web python manage.py collectstatic --noinput
        echo -e "${GREEN}✅ Static files collected${NC}"
        ;;
    "shell")
        echo -e "${BLUE}🐍 Opening Django shell...${NC}"
        check_containers
        docker-compose exec web python manage.py shell
        ;;
    "test")
        echo -e "${BLUE}🧪 Running Django tests...${NC}"
        check_containers
        docker-compose exec web python manage.py test
        ;;
    "dbshell")
        echo -e "${BLUE}🗄️  Opening database shell...${NC}"
        check_containers
        docker-compose exec db mysql -u root -p
        ;;
    "dbbackup")
        echo -e "${BLUE}💾 Creating database backup...${NC}"
        check_containers
        timestamp=$(date +%Y%m%d_%H%M%S)
        docker-compose exec db mysqldump -u root -p room_usage_db > "backup_${timestamp}.sql"
        echo -e "${GREEN}✅ Backup created: backup_${timestamp}.sql${NC}"
        ;;
    "dbrestore")
        if [[ -z "$2" ]]; then
            echo -e "${RED}❌ Please specify backup file: ./tools/docker_django.sh dbrestore backup_file.sql${NC}"
            exit 1
        fi
        echo -e "${BLUE}🔄 Restoring database from $2...${NC}"
        check_containers
        docker-compose exec -T db mysql -u root -p room_usage_db < "$2"
        echo -e "${GREEN}✅ Database restored${NC}"
        ;;
    "exec")
        if [[ -z "$2" ]]; then
            echo -e "${RED}❌ Please specify command: ./tools/docker_django.sh exec 'command'${NC}"
            exit 1
        fi
        echo -e "${BLUE}⚡ Executing: $2${NC}"
        check_containers
        docker-compose exec web bash -c "$2"
        ;;
    "bash")
        echo -e "${BLUE}💻 Opening bash shell in web container...${NC}"
        check_containers
        docker-compose exec web bash
        ;;
    "help"|*)
        show_help
        ;;
esac
