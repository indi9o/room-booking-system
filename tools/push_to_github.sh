#!/bin/bash
# =============================================================================
# Push to GitHub Script
# =============================================================================
# Simple script untuk push changes ke GitHub dengan berbagai opsi

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Functions
print_banner() {
    echo -e "${BLUE}"
    echo "╔═════════════════════════════════════════════════════════════╗"
    echo "║                  Push to GitHub                             ║"
    echo "║              Room Booking System                            ║"
    echo "╚═════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

print_help() {
    echo "Usage: $0 [OPTIONS] [MESSAGE]"
    echo ""
    echo "Options:"
    echo "  -m, --message MSG    - Commit message"
    echo "  -f, --force         - Force push"
    echo "  -a, --add-all       - Add all files (default)"
    echo "  -s, --status        - Show status only"
    echo "  -d, --dry-run       - Show what would be done"
    echo "  --amend             - Amend last commit"
    echo "  --help              - Show this help"
    echo ""
    echo "Examples:"
    echo "  $0 \"Fix bug in booking system\""
    echo "  $0 -m \"Add new feature\" --force"
    echo "  $0 --status"
    echo "  $0 --dry-run"
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

check_git() {
    if ! command -v git &> /dev/null; then
        error "Git is not installed."
    fi
    
    if [ ! -d ".git" ]; then
        error "Not a Git repository. Run 'git init' first."
    fi
}

check_remote() {
    if ! git remote get-url origin &> /dev/null; then
        error "No remote 'origin' configured. Set up GitHub repository first."
    fi
}

show_status() {
    log "Repository Status"
    echo ""
    
    # Current branch
    current_branch=$(git branch --show-current)
    echo "📍 Current branch: $current_branch"
    
    # Remote URL
    remote_url=$(git remote get-url origin)
    echo "🔗 Remote: $remote_url"
    
    echo ""
    
    # Git status
    git status --porcelain | head -20
    
    if [ $(git status --porcelain | wc -l) -gt 20 ]; then
        echo "... and $(( $(git status --porcelain | wc -l) - 20 )) more files"
    fi
    
    echo ""
    
    # Unpushed commits
    unpushed=$(git log origin/$(git branch --show-current)..HEAD --oneline 2>/dev/null | wc -l)
    if [ $unpushed -gt 0 ]; then
        echo "📤 Unpushed commits: $unpushed"
        git log origin/$(git branch --show-current)..HEAD --oneline | head -5
    else
        echo "✅ All commits are pushed"
    fi
    
    echo ""
    
    # Recent commits
    echo "📝 Recent commits:"
    git log --oneline -5
}

generate_commit_message() {
    local default_msg="Update Room Booking System"
    
    # Try to generate a smart commit message based on changes
    local changes=$(git diff --cached --name-only)
    
    if echo "$changes" | grep -q "docs/"; then
        echo "docs: Update documentation"
    elif echo "$changes" | grep -q "tools/"; then
        echo "tools: Update development tools"
    elif echo "$changes" | grep -q "rooms/"; then
        echo "feat: Update booking system functionality"
    elif echo "$changes" | grep -q "templates/"; then
        echo "ui: Update user interface"
    elif echo "$changes" | grep -q "requirements.txt"; then
        echo "deps: Update dependencies"
    elif echo "$changes" | grep -q "docker"; then
        echo "docker: Update Docker configuration"
    else
        echo "$default_msg - $(date +'%Y-%m-%d %H:%M:%S')"
    fi
}

perform_commit() {
    local message="$1"
    local amend="$2"
    local add_all="$3"
    
    # Add files if requested
    if [ "$add_all" = "true" ]; then
        log "Adding all changes..."
        git add .
    fi
    
    # Check if there are changes to commit
    if git diff-index --quiet HEAD -- 2>/dev/null && [ "$amend" != "true" ]; then
        info "No changes to commit"
        return 0
    fi
    
    # Generate commit message if not provided
    if [ -z "$message" ] && [ "$amend" != "true" ]; then
        message=$(generate_commit_message)
        info "Generated commit message: $message"
    fi
    
    # Commit
    if [ "$amend" = "true" ]; then
        log "Amending last commit..."
        if [ -n "$message" ]; then
            git commit --amend -m "$message"
        else
            git commit --amend --no-edit
        fi
    else
        log "Committing changes..."
        git commit -m "$message"
    fi
}

perform_push() {
    local force="$1"
    local current_branch=$(git branch --show-current)
    
    log "Pushing to GitHub..."
    
    if [ "$force" = "true" ]; then
        warn "Force pushing to $current_branch..."
        echo "This will overwrite remote history. Are you sure? (y/N)"
        read -r confirm
        if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
            info "Push cancelled"
            return 0
        fi
        git push --force origin "$current_branch"
    else
        git push origin "$current_branch"
    fi
    
    if [ $? -eq 0 ]; then
        log "✅ Successfully pushed to GitHub"
        
        # Show repository URL
        local repo_url=$(git remote get-url origin)
        if [[ "$repo_url" =~ github\.com ]]; then
            # Convert SSH to HTTPS for display
            repo_url=$(echo "$repo_url" | sed 's/git@github.com:/https:\/\/github.com\//' | sed 's/\.git$//')
            info "🌐 Repository: $repo_url"
        fi
    else
        error "Failed to push to GitHub"
    fi
}

dry_run() {
    local message="$1"
    local add_all="$2"
    
    log "Dry run - showing what would be done:"
    echo ""
    
    if [ "$add_all" = "true" ]; then
        echo "📁 Files that would be added:"
        git status --porcelain | grep -E '^\?\?' | head -10
        echo ""
    fi
    
    echo "📝 Files that would be committed:"
    git diff --cached --name-only 2>/dev/null || git diff --name-only
    echo ""
    
    if [ -z "$message" ]; then
        message=$(generate_commit_message)
    fi
    echo "💬 Commit message: $message"
    echo ""
    
    echo "📤 Would push to: $(git remote get-url origin)"
    echo "🌿 Branch: $(git branch --show-current)"
}

# Main script
main() {
    print_banner
    
    # Change to project directory
    cd "$PROJECT_DIR"
    
    # Check dependencies
    check_git
    check_remote
    
    # Parse options
    MESSAGE=""
    FORCE=false
    ADD_ALL=true
    STATUS_ONLY=false
    DRY_RUN=false
    AMEND=false
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            -m|--message)
                MESSAGE="$2"
                shift 2
                ;;
            -f|--force)
                FORCE=true
                shift
                ;;
            -a|--add-all)
                ADD_ALL=true
                shift
                ;;
            -s|--status)
                STATUS_ONLY=true
                shift
                ;;
            -d|--dry-run)
                DRY_RUN=true
                shift
                ;;
            --amend)
                AMEND=true
                shift
                ;;
            --help|-h)
                print_help
                exit 0
                ;;
            *)
                # Treat remaining args as commit message
                if [ -z "$MESSAGE" ]; then
                    MESSAGE="$*"
                    break
                fi
                shift
                ;;
        esac
    done
    
    # Status only mode
    if [ "$STATUS_ONLY" = "true" ]; then
        show_status
        exit 0
    fi
    
    # Dry run mode
    if [ "$DRY_RUN" = "true" ]; then
        dry_run "$MESSAGE" "$ADD_ALL"
        exit 0
    fi
    
    # Main workflow
    perform_commit "$MESSAGE" "$AMEND" "$ADD_ALL"
    perform_push "$FORCE"
    
    log "🎉 Push completed successfully!"
}

# Run main function with all arguments
main "$@"
