#!/bin/bash

# Room Booking System - Backup Script

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
BACKUP_DIR="$PROJECT_ROOT/backups"
DATE=$(date +%Y%m%d_%H%M%S)

echo "🗄️  Room Booking System - Backup Script"
echo "======================================="

# Create backup directory
mkdir -p "$BACKUP_DIR"

# Function to backup database
backup_database() {
    echo "📊 Backing up database..."
    
    if docker-compose ps | grep -q "room_booking.*db.*Up"; then
        # Get database credentials from .env
        source "$PROJECT_ROOT/.env" 2>/dev/null || true
        
        DB_NAME=${DB_NAME:-room_usage_db}
        DB_USER=${DB_USER:-django_user}
        DB_PASSWORD=${DB_PASSWORD:-django_password}
        
        # Create database backup
        docker-compose exec -T db mysqldump \
            -u"$DB_USER" -p"$DB_PASSWORD" \
            "$DB_NAME" > "$BACKUP_DIR/database_$DATE.sql"
        
        # Compress backup
        gzip "$BACKUP_DIR/database_$DATE.sql"
        
        echo "✅ Database backup created: database_$DATE.sql.gz"
    else
        echo "⚠️  Database container not running, skipping database backup"
    fi
}

# Function to backup media files
backup_media() {
    echo "📁 Backing up media files..."
    
    if [ -d "$PROJECT_ROOT/media" ] && [ "$(ls -A $PROJECT_ROOT/media)" ]; then
        tar -czf "$BACKUP_DIR/media_$DATE.tar.gz" -C "$PROJECT_ROOT" media/
        echo "✅ Media backup created: media_$DATE.tar.gz"
    else
        echo "⚠️  No media files to backup"
    fi
}

# Function to backup configuration
backup_config() {
    echo "⚙️  Backing up configuration..."
    
    # Create config backup directory
    CONFIG_BACKUP="$BACKUP_DIR/config_$DATE"
    mkdir -p "$CONFIG_BACKUP"
    
    # Copy important config files (excluding sensitive .env files)
    cp "$PROJECT_ROOT/docker-compose.yml" "$CONFIG_BACKUP/" 2>/dev/null || true
    cp "$PROJECT_ROOT/Dockerfile" "$CONFIG_BACKUP/" 2>/dev/null || true
    cp "$PROJECT_ROOT/requirements.txt" "$CONFIG_BACKUP/" 2>/dev/null || true
    cp "$PROJECT_ROOT/.env.template" "$CONFIG_BACKUP/" 2>/dev/null || true
    cp "$PROJECT_ROOT/.env.production.template" "$CONFIG_BACKUP/" 2>/dev/null || true
    
    # Compress config backup
    tar -czf "$BACKUP_DIR/config_$DATE.tar.gz" -C "$BACKUP_DIR" "config_$DATE"
    rm -rf "$CONFIG_BACKUP"
    
    echo "✅ Configuration backup created: config_$DATE.tar.gz"
}

# Function to cleanup old backups
cleanup_old_backups() {
    echo "🧹 Cleaning up old backups..."
    
    # Keep only last 7 days of backups
    find "$BACKUP_DIR" -name "*.gz" -type f -mtime +7 -delete 2>/dev/null || true
    find "$BACKUP_DIR" -name "*.sql" -type f -mtime +7 -delete 2>/dev/null || true
    
    echo "✅ Old backups cleaned up"
}

# Main backup process
main() {
    echo "📅 Backup started at: $(date)"
    echo "📁 Backup directory: $BACKUP_DIR"
    echo ""
    
    backup_database
    backup_media
    backup_config
    cleanup_old_backups
    
    echo ""
    echo "✅ Backup completed successfully!"
    echo "📁 Backups stored in: $BACKUP_DIR"
    
    # Show backup summary
    echo ""
    echo "📋 Backup Summary:"
    ls -lh "$BACKUP_DIR"/*_$DATE* 2>/dev/null || echo "No backups created"
}

# Script options
case "${1:-}" in
    "database")
        backup_database
        ;;
    "media")
        backup_media
        ;;
    "config")
        backup_config
        ;;
    "cleanup")
        cleanup_old_backups
        ;;
    *)
        main
        ;;
esac
