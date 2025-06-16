#!/bin/bash
# =============================================================================
# GitHub Setup and Push Script
# =============================================================================
# Script untuk setup GitHub repository dan push code

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEFAULT_BRANCH="main"

# Functions
print_banner() {
    echo -e "${BLUE}"
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║                    Room Booking System                       ║"
    echo "║                   GitHub Setup Script                        ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

print_help() {
    echo "Usage: $0 [COMMAND] [OPTIONS]"
    echo ""
    echo "Commands:"
    echo "  setup      - Setup GitHub repository (default)"
    echo "  push       - Push changes to GitHub"
    echo "  status     - Show Git status"
    echo "  init       - Initialize new repository"
    echo ""
    echo "Options:"
    echo "  --repo URL         - GitHub repository URL"
    echo "  --branch NAME      - Branch name (default: main)"
    echo "  --message MSG      - Commit message"
    echo "  --force            - Force push (use with caution)"
    echo "  --help             - Show this help"
    echo ""
    echo "Examples:"
    echo "  $0 setup --repo https://github.com/user/repo.git"
    echo "  $0 push --message \"Initial commit\""
    echo "  $0 status"
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

check_git() {
    if ! command -v git &> /dev/null; then
        error "Git is not installed. Please install Git first."
    fi
}

check_github_cli() {
    if command -v gh &> /dev/null; then
        log "GitHub CLI detected"
        return 0
    else
        warn "GitHub CLI not found. Some features may be limited."
        return 1
    fi
}

init_git_repo() {
    cd "$PROJECT_DIR"
    
    if [ ! -d ".git" ]; then
        log "Initializing Git repository..."
        git init
        git branch -M "$DEFAULT_BRANCH"
    else
        log "Git repository already exists"
    fi
    
    # Create .gitignore if it doesn't exist
    if [ ! -f ".gitignore" ]; then
        log "Creating .gitignore file..."
        cat > .gitignore << 'EOF'
# Django
*.pyc
*.pyo
*.pyd
__pycache__/
*.so
.Python
env/
venv/
.venv/
pip-log.txt
pip-delete-this-directory.txt
.tox/
.coverage
.coverage.*
.cache
nosetests.xml
coverage.xml
*.cover
*.log
.git
.mypy_cache
.pytest_cache
.hypothesis

# Local settings
.env
local_settings.py
db.sqlite3
db.sqlite3-journal

# Media files
media/

# Static files (collected)
staticfiles/
static/

# IDE
.vscode/
.idea/
*.swp
*.swo
*~

# OS
.DS_Store
.DS_Store?
._*
.Spotlight-V100
.Trashes
ehthumbs.db
Thumbs.db

# Docker
docker-compose.override.yml

# Backup files
*.bak
*.backup
*.tmp

# Logs
*.log
logs/

# Node modules (if using Node.js tools)
node_modules/
npm-debug.log*
yarn-debug.log*
yarn-error.log*
EOF
        log "✅ .gitignore created"
    fi
}

setup_remote() {
    local repo_url="$1"
    cd "$PROJECT_DIR"
    
    if [ -z "$repo_url" ]; then
        echo "Enter GitHub repository URL:"
        read -r repo_url
    fi
    
    if [ -z "$repo_url" ]; then
        error "Repository URL is required"
    fi
    
    # Remove existing origin if it exists
    if git remote get-url origin &> /dev/null; then
        log "Removing existing remote origin..."
        git remote remove origin
    fi
    
    log "Adding remote origin: $repo_url"
    git remote add origin "$repo_url"
    
    # Verify remote
    if git remote -v | grep -q origin; then
        log "✅ Remote origin added successfully"
    else
        error "Failed to add remote origin"
    fi
}

create_github_repo() {
    local repo_name="$1"
    
    if check_github_cli; then
        echo "Do you want to create a new GitHub repository? (y/N):"
        read -r create_repo
        
        if [[ "$create_repo" =~ ^[Yy]$ ]]; then
            if [ -z "$repo_name" ]; then
                echo "Enter repository name:"
                read -r repo_name
            fi
            
            log "Creating GitHub repository: $repo_name"
            gh repo create "$repo_name" --public --description "Room Booking System - Django application for room management and booking"
            
            if [ $? -eq 0 ]; then
                log "✅ GitHub repository created"
                return 0
            else
                error "Failed to create GitHub repository"
            fi
        fi
    fi
    return 1
}

commit_and_push() {
    local message="$1"
    local force="$2"
    cd "$PROJECT_DIR"
    
    if [ -z "$message" ]; then
        message="Update Room Booking System - $(date +'%Y-%m-%d %H:%M:%S')"
    fi
    
    log "Checking Git status..."
    git status
    
    # Check if there are changes to commit
    if git diff-index --quiet HEAD -- 2>/dev/null; then
        log "No changes to commit"
    else
        log "Adding all changes..."
        git add .
        
        log "Committing changes..."
        git commit -m "$message"
    fi
    
    # Check if we have a remote
    if ! git remote get-url origin &> /dev/null; then
        warn "No remote origin configured. Use 'setup' command first."
        return 1
    fi
    
    # Push to remote
    log "Pushing to GitHub..."
    
    local push_args="origin $DEFAULT_BRANCH"
    if [ "$force" = "true" ]; then
        warn "Force pushing - this may overwrite remote changes!"
        push_args="--force $push_args"
    fi
    
    if git push $push_args; then
        log "✅ Successfully pushed to GitHub"
        
        # Show repository URL if available
        local repo_url=$(git remote get-url origin)
        if [[ "$repo_url" =~ github\.com ]]; then
            # Convert SSH to HTTPS URL for display
            repo_url=$(echo "$repo_url" | sed 's/git@github.com:/https:\/\/github.com\//' | sed 's/\.git$//')
            log "🌐 Repository: $repo_url"
        fi
    else
        error "Failed to push to GitHub"
    fi
}

show_status() {
    cd "$PROJECT_DIR"
    
    log "Git Repository Status"
    echo ""
    
    # Current branch
    current_branch=$(git branch --show-current 2>/dev/null || echo "Not in a Git repository")
    echo "Current branch: $current_branch"
    
    # Remote information
    if git remote get-url origin &> /dev/null; then
        remote_url=$(git remote get-url origin)
        echo "Remote origin: $remote_url"
    else
        echo "Remote origin: Not configured"
    fi
    
    echo ""
    
    # Git status
    if [ -d ".git" ]; then
        git status
        echo ""
        
        # Show recent commits
        echo "Recent commits:"
        git log --oneline -5 2>/dev/null || echo "No commits yet"
    else
        echo "Not a Git repository"
    fi
}

setup_github() {
    local repo_url="$1"
    
    log "Setting up GitHub repository..."
    
    # Initialize Git if needed
    init_git_repo
    
    # Setup remote
    if [ -n "$repo_url" ]; then
        setup_remote "$repo_url"
    else
        # Try to create new repo or setup existing
        if ! create_github_repo; then
            setup_remote
        fi
    fi
    
    log "✅ GitHub setup completed"
}

# Main script
main() {
    print_banner
    
    # Change to project directory
    cd "$PROJECT_DIR"
    
    # Check dependencies
    check_git
    
    # Parse command
    COMMAND="${1:-setup}"
    shift || true
    
    # Parse options
    REPO_URL=""
    BRANCH="$DEFAULT_BRANCH"
    MESSAGE=""
    FORCE=false
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --repo)
                REPO_URL="$2"
                shift 2
                ;;
            --branch)
                BRANCH="$2"
                shift 2
                ;;
            --message)
                MESSAGE="$2"
                shift 2
                ;;
            --force)
                FORCE=true
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
        setup)
            setup_github "$REPO_URL"
            ;;
        push)
            commit_and_push "$MESSAGE" "$FORCE"
            ;;
        status)
            show_status
            ;;
        init)
            init_git_repo
            ;;
        *)
            error "Unknown command: $COMMAND. Use --help for usage information."
            ;;
    esac
}

# Run main function with all arguments
main "$@"
