#!/bin/bash

# 🛠 Quick Tools Access Script
# Room Booking System - Development Tools

echo "🛠 Room Booking System - Development Tools"
echo "=========================================="
echo ""

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

echo -e "${BLUE}Available Tools:${NC}"
echo ""

echo -e "${GREEN}1.${NC} ${PURPLE}start_app.sh${NC}     - 🚀 One-click application startup"
echo -e "${GREEN}2.${NC} ${PURPLE}make_staff.py${NC}    - 👤 Convert user to staff/admin"
echo -e "${GREEN}3.${NC} ${PURPLE}backup.sh${NC}        - 💾 Database backup & restore utilities"
echo -e "${GREEN}4.${NC} ${PURPLE}github_setup.sh${NC}  - 🌐 GitHub repository setup guide"
echo -e "${GREEN}5.${NC} ${PURPLE}push_to_github.sh${NC} - 📤 Safe push to GitHub"
echo -e "${GREEN}6.${NC} ${PURPLE}setup_i18n.sh${NC}    - 🌍 Setup internationalization"
echo -e "${GREEN}7.${NC} ${PURPLE}performance_test.sh${NC} - ⚡ Performance testing & health checks"
echo -e "${GREEN}8.${NC} ${PURPLE}tools/README.md${NC}   - 📖 Complete tools documentation"
echo ""

echo -e "${YELLOW}Quick Commands:${NC}"
echo ""

echo -e "${GREEN}Development:${NC}"
echo "  ./tools/start_app.sh              # Start development environment"
echo "  python tools/make_staff.py        # Make user staff (interactive)"
echo ""

echo -e "${GREEN}Database:${NC}"
echo "  ./tools/backup.sh backup          # Create database backup"
echo "  ./tools/backup.sh restore         # Restore from backup"
echo ""

echo -e "${GREEN}Repository:${NC}"
echo "  ./tools/github_setup.sh           # GitHub setup instructions"
echo "  ./tools/push_to_github.sh         # Safe push to repository"
echo ""

echo -e "${GREEN}Advanced Features:${NC}"
echo "  ./tools/setup_i18n.sh             # Setup internationalization"
echo "  ./tools/performance_test.sh       # Performance testing suite"
echo "  ./tools/performance_test.sh quick # Quick performance test"
echo ""

echo -e "${GREEN}Documentation:${NC}"
echo "  cat tools/README.md               # Tools documentation"
echo "  cat docs/development/tools.md     # Development guide"
echo ""

echo -e "${BLUE}💡 Pro Tips:${NC}"
echo "  • Run './tools/start_app.sh' for first-time setup"
echo "  • Use 'python tools/make_staff.py' to get admin access"
echo "  • Check 'tools/README.md' for detailed tool documentation"
echo ""

echo -e "${YELLOW}Need help? Check:${NC}"
echo "  📖 docs/INDEX.md - Complete documentation index"
echo "  ❓ docs/guides/ - User guides and tutorials"
echo "  🔧 docs/troubleshooting.md - Problem solving guide"
echo ""

# Interactive launcher
echo -e "${BLUE}🚀 Quick Launcher:${NC}"
echo ""
read -p "Enter tool number (1-8) or 'q' to quit: " choice

case $choice in
    1)
        echo -e "\n${GREEN}Starting application...${NC}"
        ./tools/start_app.sh
        ;;
    2)
        echo -e "\n${GREEN}Running make staff utility...${NC}"
        python tools/make_staff.py
        ;;
    3)
        echo -e "\n${GREEN}Opening backup utility...${NC}"
        ./tools/backup.sh
        ;;
    4)
        echo -e "\n${GREEN}Opening GitHub setup guide...${NC}"
        ./tools/github_setup.sh
        ;;
    5)
        echo -e "\n${GREEN}Running GitHub push...${NC}"
        ./tools/push_to_github.sh
        ;;
    6)
        echo -e "\n${GREEN}Setting up internationalization...${NC}"
        ./tools/setup_i18n.sh
        ;;
    7)
        echo -e "\n${GREEN}Running performance tests...${NC}"
        ./tools/performance_test.sh
        ;;
    8)
        echo -e "\n${GREEN}Opening tools documentation...${NC}"
        less tools/README.md
        ;;
    q|Q)
        echo -e "\n${YELLOW}Goodbye! 👋${NC}"
        exit 0
        ;;
    *)
        echo -e "\n${YELLOW}Invalid choice. Please run './tools.sh' again.${NC}"
        exit 1
        ;;
esac
