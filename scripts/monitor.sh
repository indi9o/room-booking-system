#!/bin/bash

# Room Booking System - Log Monitor Script

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo "📊 Room Booking System - Log Monitor"
echo "==================================="

# Function to show container logs
show_container_logs() {
    local container=${1:-web}
    local lines=${2:-50}
    
    echo "📋 Showing last $lines lines from $container container:"
    echo "─────────────────────────────────────────────────────"
    
    if docker-compose ps | grep -q "$container.*Up"; then
        docker-compose logs --tail="$lines" -t "$container"
    else
        echo "⚠️  Container '$container' is not running"
    fi
}

# Function to follow logs in real-time
follow_logs() {
    local container=${1:-web}
    
    echo "📡 Following logs from $container container (Ctrl+C to stop):"
    echo "─────────────────────────────────────────────────────────────"
    
    if docker-compose ps | grep -q "$container.*Up"; then
        docker-compose logs -f -t "$container"
    else
        echo "⚠️  Container '$container' is not running"
    fi
}

# Function to show container stats
show_container_stats() {
    echo "📊 Container Statistics:"
    echo "──────────────────────"
    
    if command -v docker &> /dev/null; then
        # Get container IDs
        WEB_CONTAINER=$(docker-compose ps -q web 2>/dev/null)
        DB_CONTAINER=$(docker-compose ps -q db 2>/dev/null)
        
        if [ -n "$WEB_CONTAINER" ] || [ -n "$DB_CONTAINER" ]; then
            docker stats --no-stream "$WEB_CONTAINER" "$DB_CONTAINER" 2>/dev/null || echo "No running containers found"
        else
            echo "No containers are currently running"
        fi
    else
        echo "Docker not available"
    fi
}

# Function to check application health
check_health() {
    echo "🏥 Application Health Check:"
    echo "───────────────────────────"
    
    # Check if containers are running
    if docker-compose ps | grep -q "Up"; then
        echo "✅ Containers are running"
        
        # Check web application
        if curl -f -s http://localhost:8001/ > /dev/null 2>&1; then
            echo "✅ Web application is responding"
        else
            echo "❌ Web application is not responding"
        fi
        
        # Check database connectivity
        if docker-compose exec -T web python manage.py check --database default > /dev/null 2>&1; then
            echo "✅ Database connection is working"
        else
            echo "❌ Database connection failed"
        fi
    else
        echo "❌ Containers are not running"
    fi
}

# Function to show disk usage
show_disk_usage() {
    echo "💾 Disk Usage:"
    echo "─────────────"
    
    # Show Docker disk usage
    if command -v docker &> /dev/null; then
        echo "🐳 Docker disk usage:"
        docker system df 2>/dev/null || echo "Cannot get Docker disk usage"
        echo ""
    fi
    
    # Show project directory size
    echo "📁 Project directory size:"
    du -sh "$PROJECT_ROOT" 2>/dev/null || echo "Cannot calculate directory size"
    
    # Show logs directory size if exists
    if [ -d "$PROJECT_ROOT/logs" ]; then
        echo "📋 Logs directory size:"
        du -sh "$PROJECT_ROOT/logs" 2>/dev/null || echo "Cannot calculate logs size"
    fi
}

# Function to export logs
export_logs() {
    local output_dir="$PROJECT_ROOT/exported_logs"
    local timestamp=$(date +%Y%m%d_%H%M%S)
    
    echo "📤 Exporting logs to: $output_dir"
    mkdir -p "$output_dir"
    
    # Export container logs
    for container in web db; do
        if docker-compose ps | grep -q "$container.*Up"; then
            echo "Exporting $container logs..."
            docker-compose logs "$container" > "$output_dir/${container}_logs_$timestamp.txt" 2>&1
        fi
    done
    
    # Export system logs if available
    if [ -d "$PROJECT_ROOT/logs" ]; then
        echo "Copying application logs..."
        cp -r "$PROJECT_ROOT/logs" "$output_dir/app_logs_$timestamp"
    fi
    
    echo "✅ Logs exported to: $output_dir"
}

# Function to clean up logs
cleanup_logs() {
    echo "🧹 Cleaning up logs..."
    
    # Clean Docker logs (careful with this)
    read -p "⚠️  This will clean ALL Docker logs. Continue? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        docker system prune -f --volumes
        echo "✅ Docker logs cleaned"
    else
        echo "Cleanup cancelled"
    fi
    
    # Clean application logs older than 7 days
    if [ -d "$PROJECT_ROOT/logs" ]; then
        find "$PROJECT_ROOT/logs" -name "*.log" -type f -mtime +7 -delete 2>/dev/null || true
        echo "✅ Old application logs cleaned"
    fi
}

# Main menu
show_menu() {
    echo ""
    echo "Available commands:"
    echo "  logs [container] [lines]  - Show recent logs (default: web, 50 lines)"
    echo "  follow [container]        - Follow logs in real-time (default: web)"
    echo "  stats                     - Show container statistics"
    echo "  health                    - Check application health"
    echo "  disk                      - Show disk usage"
    echo "  export                    - Export all logs"
    echo "  cleanup                   - Clean up old logs"
    echo "  menu                      - Show this menu"
    echo ""
    echo "Examples:"
    echo "  $0 logs web 100          - Show last 100 lines from web container"
    echo "  $0 follow db             - Follow database logs"
    echo "  $0 health                - Check if everything is working"
}

# Main script logic
case "${1:-menu}" in
    "logs")
        show_container_logs "${2:-web}" "${3:-50}"
        ;;
    "follow")
        follow_logs "${2:-web}"
        ;;
    "stats")
        show_container_stats
        ;;
    "health")
        check_health
        ;;
    "disk")
        show_disk_usage
        ;;
    "export")
        export_logs
        ;;
    "cleanup")
        cleanup_logs
        ;;
    "menu"|*)
        show_menu
        ;;
esac
