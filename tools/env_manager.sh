#!/bin/bash
# =============================================================================
# Environment Manager Script
# =============================================================================
# Script untuk mengelola multiple environment files untuk Room Booking System

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Configuration
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_FILES=(".env.development" ".env.production" ".env.test" ".env.example")

# Functions
print_banner() {
    echo -e "${BLUE}"
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║              Environment Manager - Room Booking              ║"
    echo "║                    Multiple Environment Files                 ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

print_help() {
    echo "Usage: $0 [COMMAND] [OPTIONS]"
    echo ""
    echo "Commands:"
    echo "  list           - List all available environment files"
    echo "  use <env>      - Switch to specific environment"
    echo "  show <env>     - Show environment file content"
    echo "  validate <env> - Validate environment configuration"
    echo "  diff <env1> <env2> - Compare two environment files"
    echo "  backup         - Backup current .env file"
    echo "  restore        - Restore .env from backup"
    echo "  create <env>   - Create new environment from template"
    echo ""
    echo "Environments:"
    echo "  development    - Development configuration (default)"
    echo "  production     - Production configuration"
    echo "  test           - Testing configuration"
    echo ""
    echo "Examples:"
    echo "  $0 list                    # List all environments"
    echo "  $0 use development         # Switch to development"
    echo "  $0 use production          # Switch to production"
    echo "  $0 validate production     # Validate production config"
    echo "  $0 diff development production  # Compare configs"
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

list_environments() {
    echo -e "${BLUE}📋 Available Environment Files:${NC}"
    echo ""
    
    for env_file in "${ENV_FILES[@]}"; do
        if [[ -f "$PROJECT_DIR/$env_file" ]]; then
            echo -e "${GREEN}✅ $env_file${NC}"
            
            # Show basic info
            if grep -q "DEBUG=1" "$PROJECT_DIR/$env_file"; then
                echo -e "   ${YELLOW}Mode: Development/Debug${NC}"
            elif grep -q "DEBUG=0" "$PROJECT_DIR/$env_file"; then
                echo -e "   ${PURPLE}Mode: Production${NC}"
            fi
            
            if grep -q "DB_HOST=db" "$PROJECT_DIR/$env_file"; then
                echo -e "   ${BLUE}Database: Docker MySQL${NC}"
            elif grep -q "DB_HOST=127.0.0.1" "$PROJECT_DIR/$env_file"; then
                echo -e "   ${BLUE}Database: Local MySQL${NC}"
            fi
            echo ""
        else
            echo -e "${RED}❌ $env_file (missing)${NC}"
        fi
    done
    
    # Show current active
    if [[ -f "$PROJECT_DIR/.env" ]]; then
        echo -e "${GREEN}🎯 Current active: .env${NC}"
        if grep -q "SENTRY_ENVIRONMENT=" "$PROJECT_DIR/.env"; then
            env_type=$(grep "SENTRY_ENVIRONMENT=" "$PROJECT_DIR/.env" | cut -d'=' -f2)
            echo -e "   ${YELLOW}Environment: $env_type${NC}"
        fi
    else
        echo -e "${YELLOW}⚠️  No active .env file${NC}"
    fi
}

switch_environment() {
    local env_name="$1"
    local source_file="$PROJECT_DIR/.env.$env_name"
    local target_file="$PROJECT_DIR/.env"
    
    if [[ -z "$env_name" ]]; then
        error "Environment name required. Use: development, production, or test"
    fi
    
    if [[ ! -f "$source_file" ]]; then
        error "Environment file $source_file not found"
    fi
    
    # Backup current .env if exists
    if [[ -f "$target_file" ]]; then
        cp "$target_file" "$PROJECT_DIR/.env.backup"
        log "Current .env backed up to .env.backup"
    fi
    
    # Copy environment file
    cp "$source_file" "$target_file"
    log "Switched to $env_name environment"
    
    # Show confirmation
    echo ""
    echo -e "${BLUE}Active Environment: $env_name${NC}"
    if grep -q "DEBUG=" "$target_file"; then
        debug_mode=$(grep "DEBUG=" "$target_file" | cut -d'=' -f2)
        echo -e "Debug Mode: $debug_mode"
    fi
    if grep -q "DB_HOST=" "$target_file"; then
        db_host=$(grep "DB_HOST=" "$target_file" | cut -d'=' -f2)
        echo -e "Database Host: $db_host"
    fi
    
    echo ""
    echo -e "${YELLOW}💡 Next steps:${NC}"
    echo "1. Review configuration: ./tools/env_manager.sh show current"
    echo "2. Restart Docker: ./tools/docker_django.sh restart"
    echo "3. Run migrations: ./tools/docker_django.sh migrate"
}

show_environment() {
    local env_name="$1"
    local env_file
    
    if [[ "$env_name" == "current" || "$env_name" == "active" ]]; then
        env_file="$PROJECT_DIR/.env"
        env_name="current"
    else
        env_file="$PROJECT_DIR/.env.$env_name"
    fi
    
    if [[ ! -f "$env_file" ]]; then
        error "Environment file $env_file not found"
    fi
    
    echo -e "${BLUE}📄 Environment Configuration: $env_name${NC}"
    echo "========================================"
    echo ""
    
    # Show with syntax highlighting-like formatting
    while IFS= read -r line; do
        if [[ "$line" =~ ^#.*$ ]]; then
            echo -e "${YELLOW}$line${NC}"
        elif [[ "$line" =~ ^[A-Z_]+=.*$ ]]; then
            key=$(echo "$line" | cut -d'=' -f1)
            value=$(echo "$line" | cut -d'=' -f2-)
            echo -e "${GREEN}$key${NC}=${BLUE}$value${NC}"
        else
            echo "$line"
        fi
    done < "$env_file"
}

validate_environment() {
    local env_name="$1"
    local env_file="$PROJECT_DIR/.env.$env_name"
    
    if [[ "$env_name" == "current" ]]; then
        env_file="$PROJECT_DIR/.env"
    fi
    
    if [[ ! -f "$env_file" ]]; then
        error "Environment file $env_file not found"
    fi
    
    echo -e "${BLUE}🔍 Validating environment: $env_name${NC}"
    echo ""
    
    # Required variables
    required_vars=("DEBUG" "SECRET_KEY" "DB_NAME" "DB_USER" "DB_PASSWORD" "DB_HOST")
    missing_vars=()
    
    for var in "${required_vars[@]}"; do
        if ! grep -q "^$var=" "$env_file"; then
            missing_vars+=("$var")
        fi
    done
    
    if [[ ${#missing_vars[@]} -gt 0 ]]; then
        echo -e "${RED}❌ Missing required variables:${NC}"
        for var in "${missing_vars[@]}"; do
            echo "  - $var"
        done
        echo ""
    else
        echo -e "${GREEN}✅ All required variables present${NC}"
    fi
    
    # Security checks
    echo -e "${BLUE}🔒 Security checks:${NC}"
    
    if grep -q "SECRET_KEY=your-secret-key" "$env_file" || grep -q "SECRET_KEY=dev-secret-key" "$env_file"; then
        echo -e "${YELLOW}⚠️  Using default SECRET_KEY (change for production)${NC}"
    else
        echo -e "${GREEN}✅ SECRET_KEY appears to be customized${NC}"
    fi
    
    if grep -q "DEBUG=1" "$env_file" && [[ "$env_name" == "production" ]]; then
        echo -e "${RED}❌ DEBUG=1 in production environment${NC}"
    elif grep -q "DEBUG=0" "$env_file" && [[ "$env_name" == "development" ]]; then
        echo -e "${YELLOW}⚠️  DEBUG=0 in development environment${NC}"
    else
        echo -e "${GREEN}✅ DEBUG setting appropriate for environment${NC}"
    fi
    
    # Database checks
    echo ""
    echo -e "${BLUE}🗄️  Database configuration:${NC}"
    if grep -q "DB_HOST=db" "$env_file"; then
        echo -e "${GREEN}✅ Using Docker database (DB_HOST=db)${NC}"
    elif grep -q "DB_HOST=127.0.0.1" "$env_file"; then
        echo -e "${YELLOW}⚠️  Using local database (DB_HOST=127.0.0.1)${NC}"
    fi
}

compare_environments() {
    local env1="$1"
    local env2="$2"
    local file1="$PROJECT_DIR/.env.$env1"
    local file2="$PROJECT_DIR/.env.$env2"
    
    if [[ ! -f "$file1" ]] || [[ ! -f "$file2" ]]; then
        error "One or both environment files not found"
    fi
    
    echo -e "${BLUE}🔄 Comparing $env1 vs $env2:${NC}"
    echo ""
    
    # Use diff with color if available
    if command -v colordiff &> /dev/null; then
        colordiff -u "$file1" "$file2" || true
    else
        diff -u "$file1" "$file2" || true
    fi
}

backup_current() {
    if [[ ! -f "$PROJECT_DIR/.env" ]]; then
        error "No active .env file to backup"
    fi
    
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local backup_file="$PROJECT_DIR/.env.backup.$timestamp"
    
    cp "$PROJECT_DIR/.env" "$backup_file"
    log "Current .env backed up to .env.backup.$timestamp"
}

restore_backup() {
    if [[ ! -f "$PROJECT_DIR/.env.backup" ]]; then
        error "No backup file found (.env.backup)"
    fi
    
    cp "$PROJECT_DIR/.env.backup" "$PROJECT_DIR/.env"
    log "Restored .env from backup"
}

create_environment() {
    local env_name="$1"
    local new_file="$PROJECT_DIR/.env.$env_name"
    local template_file="$PROJECT_DIR/.env.example"
    
    if [[ -z "$env_name" ]]; then
        error "Environment name required"
    fi
    
    if [[ -f "$new_file" ]]; then
        error "Environment file $new_file already exists"
    fi
    
    if [[ ! -f "$template_file" ]]; then
        error "Template file $template_file not found"
    fi
    
    cp "$template_file" "$new_file"
    log "Created new environment: $env_name"
    log "Edit $new_file to customize configuration"
}

# Main script
main() {
    print_banner
    
    cd "$PROJECT_DIR"
    
    case "${1:-list}" in
        "list"|"ls")
            list_environments
            ;;
        "use"|"switch")
            switch_environment "$2"
            ;;
        "show"|"cat"|"view")
            show_environment "$2"
            ;;
        "validate"|"check")
            validate_environment "$2"
            ;;
        "diff"|"compare")
            compare_environments "$2" "$3"
            ;;
        "backup")
            backup_current
            ;;
        "restore")
            restore_backup
            ;;
        "create"|"new")
            create_environment "$2"
            ;;
        "help"|"-h"|"--help")
            print_help
            ;;
        *)
            error "Unknown command: $1. Use --help for usage information."
            ;;
    esac
}

# Run main function with all arguments
main "$@"
