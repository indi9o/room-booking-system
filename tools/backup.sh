#!/bin/bash
# =============================================================================
# Backup and Restore Script
# =============================================================================
# Script untuk backup dan restore Room Booking System

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BACKUP_DIR="${BACKUP_DIR:-$PROJECT_DIR/backups}"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Database configuration from .env
if [ -f "$PROJECT_DIR/.env" ]; then
    source "$PROJECT_DIR/.env"
fi

DB_HOST="${DB_HOST:-localhost}"
DB_NAME="${DB_NAME:-room_usage_db}"
DB_USER="${DB_USER:-django_user}"
DB_PASSWORD="${DB_PASSWORD:-django_password}"
DB_PORT="${DB_PORT:-3306}"

# Functions
print_banner() {
    echo -e "${BLUE}"
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║                    Room Booking System                       ║"
    echo "║                   Backup & Restore Tool                      ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

print_help() {
    echo "Usage: $0 [COMMAND] [OPTIONS]"
    echo ""
    echo "Commands:"
    echo "  backup     - Create backup (default)"
    echo "  restore    - Restore from backup"
    echo "  list       - List available backups"
    echo "  clean      - Clean old backups"
    echo "  schedule   - Setup automated backup schedule"
    echo ""
    echo "Options:"
    echo "  --type TYPE        - Backup type: full, db, media, code (default: full)"
    echo "  --file FILE        - Specific backup file to restore"
    echo "  --days N          - Keep backups for N days (default: 30)"
    echo "  --compress        - Compress backup files"
    echo "  --upload          - Upload to cloud storage"
    echo "  --help            - Show this help"
    echo ""
    echo "Examples:"
    echo "  $0 backup --type db                    # Database only"
    echo "  $0 backup --type full --compress       # Full compressed backup"
    echo "  $0 restore --file backup_20231215.sql  # Restore specific backup"
    echo "  $0 list                                # List all backups"
    echo "  $0 clean --days 7                     # Keep only 7 days"
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

info() {
    echo -e "${BLUE}[INFO] $1${NC}"
}

check_dependencies() {
    local backup_type="$1"
    
    case "$backup_type" in
        db|full)
            if ! command -v mysqldump &> /dev/null; then
                error "mysqldump is not installed. Please install MySQL client."
            fi
            if ! command -v mysql &> /dev/null; then
                error "mysql client is not installed."
            fi
            ;;
    esac
    
    if ! command -v tar &> /dev/null; then
        error "tar is not installed."
    fi
}

ensure_backup_dir() {
    if [ ! -d "$BACKUP_DIR" ]; then
        log "Creating backup directory: $BACKUP_DIR"
        mkdir -p "$BACKUP_DIR"
    fi
}

backup_database() {
    local backup_file="$1"
    local compress="$2"
    
    log "Backing up database..."
    
    local dump_file="${backup_file}_db.sql"
    
    # Check if running in Docker
    if docker-compose ps | grep -q "room_usage_db.*Up"; then
        log "Using Docker database..."
        docker-compose exec -T db mysqldump -u "$DB_USER" -p"$DB_PASSWORD" "$DB_NAME" > "$dump_file"
    else
        # Direct MySQL connection
        mysqldump -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" -p"$DB_PASSWORD" "$DB_NAME" > "$dump_file"
    fi
    
    if [ $? -eq 0 ]; then
        log "✅ Database backup completed: $dump_file"
        
        if [ "$compress" = "true" ]; then
            log "Compressing database backup..."
            gzip "$dump_file"
            log "✅ Database backup compressed: ${dump_file}.gz"
        fi
    else
        error "Database backup failed"
    fi
}

backup_media() {
    local backup_file="$1"
    local compress="$2"
    
    log "Backing up media files..."
    
    local media_dir="$PROJECT_DIR/media"
    local media_backup="${backup_file}_media.tar"
    
    if [ -d "$media_dir" ] && [ "$(ls -A $media_dir)" ]; then
        if [ "$compress" = "true" ]; then
            tar -czf "${media_backup}.gz" -C "$PROJECT_DIR" media/
            log "✅ Media backup completed: ${media_backup}.gz"
        else
            tar -cf "$media_backup" -C "$PROJECT_DIR" media/
            log "✅ Media backup completed: $media_backup"
        fi
    else
        info "No media files to backup"
    fi
}

backup_code() {
    local backup_file="$1"
    local compress="$2"
    
    log "Backing up source code..."
    
    local code_backup="${backup_file}_code.tar"
    local exclude_opts="--exclude=venv --exclude=.git --exclude=__pycache__ --exclude=*.pyc --exclude=.env --exclude=backups --exclude=staticfiles --exclude=media --exclude=db.sqlite3"
    
    if [ "$compress" = "true" ]; then
        tar -czf "${code_backup}.gz" $exclude_opts -C "$PROJECT_DIR/.." "$(basename "$PROJECT_DIR")"
        log "✅ Code backup completed: ${code_backup}.gz"
    else
        tar -cf "$code_backup" $exclude_opts -C "$PROJECT_DIR/.." "$(basename "$PROJECT_DIR")"
        log "✅ Code backup completed: $code_backup"
    fi
}

create_backup() {
    local backup_type="$1"
    local compress="$2"
    local upload="$3"
    
    ensure_backup_dir
    check_dependencies "$backup_type"
    
    local backup_file="$BACKUP_DIR/backup_$TIMESTAMP"
    
    log "Starting $backup_type backup..."
    log "Backup location: $backup_file"
    
    case "$backup_type" in
        full)
            backup_database "$backup_file" "$compress"
            backup_media "$backup_file" "$compress"
            backup_code "$backup_file" "$compress"
            ;;
        db)
            backup_database "$backup_file" "$compress"
            ;;
        media)
            backup_media "$backup_file" "$compress"
            ;;
        code)
            backup_code "$backup_file" "$compress"
            ;;
        *)
            error "Unknown backup type: $backup_type"
            ;;
    esac
    
    # Create backup manifest
    local manifest_file="${backup_file}_manifest.txt"
    cat > "$manifest_file" << EOF
Room Booking System Backup
==========================
Timestamp: $(date)
Type: $backup_type
Compressed: $compress
Host: $(hostname)
User: $(whoami)
Project Dir: $PROJECT_DIR

Files:
EOF
    
    ls -la "$BACKUP_DIR"/backup_$TIMESTAMP* >> "$manifest_file"
    
    log "✅ Backup completed successfully!"
    log "📋 Manifest: $manifest_file"
    
    # Upload to cloud if requested
    if [ "$upload" = "true" ]; then
        upload_backup "$backup_file"
    fi
    
    # Show backup size
    local total_size=$(du -sh "$BACKUP_DIR"/backup_$TIMESTAMP* | awk '{sum+=$1} END {print sum}')
    info "💾 Total backup size: $(du -sh "$BACKUP_DIR"/backup_$TIMESTAMP* | tail -1 | awk '{print $1}')"
}

restore_database() {
    local backup_file="$1"
    
    log "Restoring database from: $backup_file"
    
    # Check if file exists and determine if compressed
    if [ -f "${backup_file}.gz" ]; then
        backup_file="${backup_file}.gz"
        log "Using compressed backup file"
    elif [ ! -f "$backup_file" ]; then
        error "Backup file not found: $backup_file"
    fi
    
    # Confirm restoration
    warn "This will REPLACE the current database. Are you sure? (y/N)"
    read -r confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        info "Database restore cancelled"
        return 0
    fi
    
    # Restore database
    if [[ "$backup_file" == *.gz ]]; then
        if docker-compose ps | grep -q "room_usage_db.*Up"; then
            gunzip -c "$backup_file" | docker-compose exec -T db mysql -u "$DB_USER" -p"$DB_PASSWORD" "$DB_NAME"
        else
            gunzip -c "$backup_file" | mysql -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" -p"$DB_PASSWORD" "$DB_NAME"
        fi
    else
        if docker-compose ps | grep -q "room_usage_db.*Up"; then
            docker-compose exec -T db mysql -u "$DB_USER" -p"$DB_PASSWORD" "$DB_NAME" < "$backup_file"
        else
            mysql -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" -p"$DB_PASSWORD" "$DB_NAME" < "$backup_file"
        fi
    fi
    
    if [ $? -eq 0 ]; then
        log "✅ Database restored successfully"
    else
        error "Database restore failed"
    fi
}

restore_backup() {
    local backup_file="$1"
    
    if [ -z "$backup_file" ]; then
        # List available backups and let user choose
        list_backups
        echo ""
        echo "Enter backup timestamp (e.g., 20231215_143022):"
        read -r timestamp
        backup_file="$BACKUP_DIR/backup_${timestamp}_db.sql"
    fi
    
    if [[ "$backup_file" != /* ]]; then
        backup_file="$BACKUP_DIR/$backup_file"
    fi
    
    # Determine backup type from filename
    if [[ "$backup_file" =~ _db\.sql ]]; then
        restore_database "$backup_file"
    else
        error "Only database restore is currently supported"
    fi
}

list_backups() {
    log "Available backups in $BACKUP_DIR:"
    echo ""
    
    if [ ! -d "$BACKUP_DIR" ] || [ -z "$(ls -A "$BACKUP_DIR" 2>/dev/null)" ]; then
        info "No backups found"
        return
    fi
    
    echo "📅 Timestamp        📁 Type    💾 Size       📄 Files"
    echo "────────────────────────────────────────────────────────"
    
    for manifest in "$BACKUP_DIR"/backup_*_manifest.txt; do
        if [ -f "$manifest" ]; then
            local timestamp=$(basename "$manifest" | sed 's/backup_\(.*\)_manifest.txt/\1/')
            local type=$(grep "Type:" "$manifest" | cut -d' ' -f2)
            local files=$(ls "$BACKUP_DIR"/backup_${timestamp}* 2>/dev/null | wc -l)
            local size=$(du -sh "$BACKUP_DIR"/backup_${timestamp}* 2>/dev/null | tail -1 | awk '{print $1}')
            
            printf "%-19s %-7s %-10s %s files\n" "$timestamp" "$type" "$size" "$files"
        fi
    done
}

clean_old_backups() {
    local days="$1"
    
    if [ -z "$days" ]; then
        days=30
    fi
    
    log "Cleaning backups older than $days days..."
    
    if [ ! -d "$BACKUP_DIR" ]; then
        info "No backup directory found"
        return
    fi
    
    local deleted=0
    find "$BACKUP_DIR" -name "backup_*" -type f -mtime +$days -print0 | while IFS= read -r -d '' file; do
        log "Removing old backup: $(basename "$file")"
        rm "$file"
        ((deleted++))
    done
    
    if [ $deleted -eq 0 ]; then
        info "No old backups to clean"
    else
        log "✅ Cleaned $deleted old backup files"
    fi
}

upload_backup() {
    local backup_file="$1"
    
    # This is a placeholder for cloud upload functionality
    # Implement based on your cloud provider (AWS S3, Google Cloud, etc.)
    
    info "Cloud upload functionality not implemented yet"
    info "Add your cloud storage integration here"
    
    # Example for AWS S3:
    # aws s3 cp "$backup_file"* s3://your-backup-bucket/room-booking-system/
    
    # Example for rsync to remote server:
    # rsync -av "$backup_file"* user@backup-server:/path/to/backups/
}

setup_cron_schedule() {
    log "Setting up automated backup schedule..."
    
    local cron_file="/tmp/room_booking_backup_cron"
    local script_path="$PROJECT_DIR/tools/backup.sh"
    
    # Create cron job for daily backup at 2 AM
    cat > "$cron_file" << EOF
# Room Booking System - Daily Backup
0 2 * * * $script_path backup --type full --compress >/dev/null 2>&1

# Room Booking System - Weekly Cleanup (keep 30 days)
0 3 * * 0 $script_path clean --days 30 >/dev/null 2>&1
EOF
    
    # Install cron job
    crontab "$cron_file"
    rm "$cron_file"
    
    log "✅ Automated backup schedule configured:"
    log "   - Daily full backup at 2:00 AM"
    log "   - Weekly cleanup (keep 30 days) at 3:00 AM on Sunday"
    log ""
    log "Current crontab:"
    crontab -l | grep -E "(Room Booking|backup\.sh)"
}

# Main script
main() {
    print_banner
    
    # Change to project directory
    cd "$PROJECT_DIR"
    
    # Parse command
    COMMAND="${1:-backup}"
    shift || true
    
    # Parse options
    BACKUP_TYPE="full"
    BACKUP_FILE=""
    DAYS=""
    COMPRESS=false
    UPLOAD=false
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --type)
                BACKUP_TYPE="$2"
                shift 2
                ;;
            --file)
                BACKUP_FILE="$2"
                shift 2
                ;;
            --days)
                DAYS="$2"
                shift 2
                ;;
            --compress)
                COMPRESS=true
                shift
                ;;
            --upload)
                UPLOAD=true
                shift
                ;;
            --help|-h)
                print_help
                exit 0
                ;;
            *)
                warn "Unknown option: $1"
                shift
                ;;
        esac
    done
    
    # Execute command
    case "$COMMAND" in
        backup)
            create_backup "$BACKUP_TYPE" "$COMPRESS" "$UPLOAD"
            ;;
        restore)
            restore_backup "$BACKUP_FILE"
            ;;
        list)
            list_backups
            ;;
        clean)
            clean_old_backups "$DAYS"
            ;;
        schedule)
            setup_cron_schedule
            ;;
        *)
            error "Unknown command: $COMMAND. Use --help for usage information."
            ;;
    esac
}

# Run main function with all arguments
main "$@"
