#!/bin/bash

# 🔧 Docker Environment Integration Tool
# Room Booking System - Environment Configuration Optimizer

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

echo "🔧 Docker Environment Integration Tool"
echo "====================================="
echo ""

# Function to show help
show_help() {
    echo -e "${BLUE}Available Options:${NC}"
    echo ""
    echo -e "${GREEN}1.${NC} ${PURPLE}analyze${NC}     - Analyze current .env and docker-compose integration"
    echo -e "${GREEN}2.${NC} ${PURPLE}fix${NC}         - Fix docker-compose.yml to use .env variables"
    echo -e "${GREEN}3.${NC} ${PURPLE}validate${NC}    - Validate .env and docker-compose consistency"
    echo -e "${GREEN}4.${NC} ${PURPLE}create-env${NC}  - Create comprehensive .env from template"
    echo -e "${GREEN}5.${NC} ${PURPLE}backup${NC}      - Backup current configuration files"
    echo -e "${GREEN}6.${NC} ${PURPLE}help${NC}        - Show this help message"
    echo ""
    echo -e "${YELLOW}Usage Examples:${NC}"
    echo "  ./tools/env_docker_integration.sh analyze"
    echo "  ./tools/env_docker_integration.sh fix"
    echo "  ./tools/env_docker_integration.sh validate"
    echo ""
}

# Function to analyze current state
analyze_integration() {
    echo -e "${BLUE}🔍 Analyzing current .env and docker-compose integration...${NC}"
    echo ""
    
    # Check if files exist
    if [[ ! -f "docker-compose.yml" ]]; then
        echo -e "${RED}❌ docker-compose.yml not found${NC}"
        return 1
    fi
    
    if [[ ! -f ".env" ]] && [[ ! -f ".env.example" ]]; then
        echo -e "${RED}❌ No .env or .env.example file found${NC}"
        return 1
    fi
    
    echo -e "${GREEN}✅ Configuration files found${NC}"
    echo ""
    
    # Analyze docker-compose.yml for hardcoded values
    echo -e "${BLUE}📊 Docker Compose Analysis:${NC}"
    
    hardcoded_count=$(grep -E "(MYSQL_|DB_|DEBUG)" docker-compose.yml | grep -v "\${" | wc -l)
    env_vars_count=$(grep -E "\\\${" docker-compose.yml | wc -l)
    
    echo "  - Hardcoded values: $hardcoded_count"
    echo "  - Environment variables: $env_vars_count"
    
    if [[ $hardcoded_count -gt 0 ]]; then
        echo -e "${YELLOW}  ⚠️  Found hardcoded values that should use .env${NC}"
        echo "  Hardcoded entries:"
        grep -E "(MYSQL_|DB_|DEBUG)" docker-compose.yml | grep -v "\${" | sed 's/^/    /'
    fi
    echo ""
    
    # Check for env_file directive
    if grep -q "env_file:" docker-compose.yml; then
        echo -e "${GREEN}✅ env_file directive found${NC}"
    else
        echo -e "${YELLOW}⚠️  env_file directive missing${NC}"
    fi
    
    # Analyze .env file
    if [[ -f ".env" ]]; then
        echo -e "${BLUE}📊 .env File Analysis:${NC}"
        var_count=$(grep -v "^#" .env | grep -v "^$" | wc -l)
        echo "  - Variables defined: $var_count"
        
        # Check for required variables
        required_vars=("DB_NAME" "DB_USER" "DB_PASSWORD" "SECRET_KEY")
        missing_vars=()
        
        for var in "${required_vars[@]}"; do
            if ! grep -q "^$var=" .env; then
                missing_vars+=("$var")
            fi
        done
        
        if [[ ${#missing_vars[@]} -gt 0 ]]; then
            echo -e "${YELLOW}  ⚠️  Missing required variables: ${missing_vars[*]}${NC}"
        else
            echo -e "${GREEN}  ✅ All required variables present${NC}"
        fi
    fi
    
    echo ""
    echo -e "${BLUE}💡 Recommendations:${NC}"
    
    if [[ $hardcoded_count -gt 0 ]]; then
        echo "  1. Run 'fix' command to update docker-compose.yml"
    fi
    
    if [[ ! -f ".env" ]] && [[ -f ".env.example" ]]; then
        echo "  2. Run 'create-env' command to create .env from template"
    fi
    
    if ! grep -q "env_file:" docker-compose.yml; then
        echo "  3. Add env_file directive to docker-compose services"
    fi
}

# Function to fix docker-compose.yml
fix_docker_compose() {
    echo -e "${BLUE}🔧 Fixing docker-compose.yml to use .env variables...${NC}"
    echo ""
    
    # Backup original
    if [[ ! -f "docker-compose.yml.backup" ]]; then
        cp docker-compose.yml docker-compose.yml.backup
        echo -e "${GREEN}✅ Backup created: docker-compose.yml.backup${NC}"
    fi
    
    # Create improved docker-compose.yml
    cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
  db:
    image: mysql:8.0
    container_name: room_usage_db
    restart: always
    environment:
      MYSQL_DATABASE: ${DB_NAME}
      MYSQL_USER: ${DB_USER}
      MYSQL_PASSWORD: ${DB_PASSWORD}
      MYSQL_ROOT_PASSWORD: ${MYSQL_ROOT_PASSWORD}
    ports:
      - "${DB_PORT:-3306}:3306"
    volumes:
      - mysql_data:/var/lib/mysql
    command: --default-authentication-plugin=mysql_native_password
    env_file:
      - .env

  web:
    build: .
    container_name: room_usage_web
    command: ./docker-entrypoint.sh
    volumes:
      - .:/code
    ports:
      - "${WEB_PORT:-8001}:8000"
    depends_on:
      - db
    env_file:
      - .env
    environment:
      - DB_HOST=db

volumes:
  mysql_data:
EOF
    
    echo -e "${GREEN}✅ docker-compose.yml updated with .env variables${NC}"
    echo ""
    echo -e "${YELLOW}Changes made:${NC}"
    echo "  - Replaced hardcoded values with \${VARIABLE} syntax"
    echo "  - Added env_file directive to both services"
    echo "  - Added default values for optional ports"
    echo "  - Original backed up as docker-compose.yml.backup"
}

# Function to create comprehensive .env
create_env_file() {
    echo -e "${BLUE}📝 Creating comprehensive .env file...${NC}"
    echo ""
    
    if [[ -f ".env" ]]; then
        echo -e "${YELLOW}⚠️  .env file already exists${NC}"
        read -p "Do you want to backup and replace it? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            cp .env .env.backup
            echo -e "${GREEN}✅ Existing .env backed up as .env.backup${NC}"
        else
            echo "Operation cancelled."
            return 0
        fi
    fi
    
    # Create comprehensive .env
    cat > .env << 'EOF'
# ===========================================
# CORE APPLICATION SETTINGS
# ===========================================
DEBUG=1
SECRET_KEY=django-insecure-change-in-production
ALLOWED_HOSTS=localhost,127.0.0.1,0.0.0.0

# ===========================================
# DATABASE CONFIGURATION
# ===========================================
DB_ENGINE=django.db.backends.mysql
DB_NAME=room_usage_db
DB_USER=django_user
DB_PASSWORD=django_password
DB_HOST=localhost
DB_PORT=3306

# ===========================================
# MYSQL DOCKER CONFIGURATION
# ===========================================
MYSQL_ROOT_PASSWORD=root_password

# ===========================================
# DOCKER PORTS
# ===========================================
WEB_PORT=8001

# ===========================================
# EMAIL CONFIGURATION
# ===========================================
EMAIL_BACKEND=django.core.mail.backends.console.EmailBackend
EMAIL_HOST=smtp.gmail.com
EMAIL_PORT=587
EMAIL_USE_TLS=True
EMAIL_HOST_USER=
EMAIL_HOST_PASSWORD=

# ===========================================
# STATIC & MEDIA FILES
# ===========================================
STATIC_URL=/static/
MEDIA_URL=/media/
STATIC_ROOT=staticfiles
MEDIA_ROOT=media

# ===========================================
# SECURITY SETTINGS
# ===========================================
SECURE_SSL_REDIRECT=False
SECURE_HSTS_SECONDS=0
SESSION_COOKIE_SECURE=False
CSRF_COOKIE_SECURE=False

# ===========================================
# LOGGING & MONITORING
# ===========================================
LOG_LEVEL=DEBUG
SENTRY_DSN=

# ===========================================
# EXTERNAL SERVICES
# ===========================================
REDIS_URL=redis://localhost:6379/0
EOF
    
    echo -e "${GREEN}✅ Comprehensive .env file created${NC}"
    echo ""
    echo -e "${YELLOW}💡 Next steps:${NC}"
    echo "  1. Review and customize values in .env"
    echo "  2. Run 'validate' command to check consistency"
    echo "  3. Test with: docker-compose up --build"
}

# Function to validate configuration
validate_config() {
    echo -e "${BLUE}✅ Validating .env and docker-compose consistency...${NC}"
    echo ""
    
    if [[ ! -f ".env" ]]; then
        echo -e "${RED}❌ .env file not found${NC}"
        return 1
    fi
    
    if [[ ! -f "docker-compose.yml" ]]; then
        echo -e "${RED}❌ docker-compose.yml not found${NC}"
        return 1
    fi
    
    # Load .env variables
    source .env
    
    # Check required variables
    required_vars=("DB_NAME" "DB_USER" "DB_PASSWORD" "MYSQL_ROOT_PASSWORD")
    missing_vars=()
    
    for var in "${required_vars[@]}"; do
        if [[ -z "${!var}" ]]; then
            missing_vars+=("$var")
        fi
    done
    
    if [[ ${#missing_vars[@]} -gt 0 ]]; then
        echo -e "${RED}❌ Missing required variables in .env: ${missing_vars[*]}${NC}"
        return 1
    fi
    
    # Check if docker-compose uses env variables
    env_usage=$(grep -c "\${" docker-compose.yml)
    
    if [[ $env_usage -eq 0 ]]; then
        echo -e "${YELLOW}⚠️  docker-compose.yml doesn't use environment variables${NC}"
        echo "  Consider running 'fix' command"
    else
        echo -e "${GREEN}✅ docker-compose.yml uses $env_usage environment variables${NC}"
    fi
    
    # Test environment variable substitution
    echo -e "${BLUE}🧪 Testing variable substitution...${NC}"
    
    if command -v docker-compose &> /dev/null; then
        if docker-compose config &> /dev/null; then
            echo -e "${GREEN}✅ docker-compose configuration is valid${NC}"
        else
            echo -e "${RED}❌ docker-compose configuration has errors${NC}"
            echo "  Run: docker-compose config"
        fi
    else
        echo -e "${YELLOW}⚠️  docker-compose not installed, skipping validation${NC}"
    fi
    
    echo ""
    echo -e "${GREEN}✅ Validation complete${NC}"
}

# Function to backup configuration
backup_config() {
    echo -e "${BLUE}💾 Backing up configuration files...${NC}"
    echo ""
    
    timestamp=$(date +%Y%m%d_%H%M%S)
    backup_dir="config_backup_$timestamp"
    
    mkdir -p "$backup_dir"
    
    files_to_backup=("docker-compose.yml" ".env" ".env.example" "room_usage_project/settings.py")
    
    for file in "${files_to_backup[@]}"; do
        if [[ -f "$file" ]]; then
            cp "$file" "$backup_dir/"
            echo -e "${GREEN}✅ Backed up: $file${NC}"
        fi
    done
    
    echo ""
    echo -e "${GREEN}✅ Backup created in: $backup_dir${NC}"
}

# Main script logic
case "${1:-help}" in
    "analyze")
        analyze_integration
        ;;
    "fix")
        fix_docker_compose
        ;;
    "validate")
        validate_config
        ;;
    "create-env")
        create_env_file
        ;;
    "backup")
        backup_config
        ;;
    "help"|*)
        show_help
        ;;
esac
