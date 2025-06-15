#!/bin/bash

# 🚀 GitHub Repository Setup Script
# Room Booking System - Django Application

echo "🚀 GitHub Repository Setup for Room Booking System"
echo "=================================================="
echo ""

# Repository information
REPO_NAME="room-booking-system"
REPO_DESCRIPTION="Complete Room Booking System built with Django 4.2.7, MySQL 8.0, and Docker"
GITHUB_USERNAME=""

echo "📋 Repository Information:"
echo "- Name: $REPO_NAME"
echo "- Description: $REPO_DESCRIPTION"
echo "- Type: Public (recommended)"
echo ""

echo "🔧 Manual Setup Instructions:"
echo "=============================="
echo ""

echo "1. 🌐 Create GitHub Repository:"
echo "   - Go to: https://github.com/new"
echo "   - Repository name: $REPO_NAME"
echo "   - Description: $REPO_DESCRIPTION"
echo "   - Set as Public or Private"
echo "   - ❌ DO NOT initialize with README (we already have one)"
echo "   - ❌ DO NOT add .gitignore (we already have one)"
echo "   - ❌ DO NOT add license (can be added later)"
echo ""

echo "2. 🔗 After creating repository, GitHub will show quick setup:"
echo "   Copy the repository URL (should look like):"
echo "   https://github.com/YOUR_USERNAME/$REPO_NAME.git"
echo ""

echo "3. 🏷️ Repository Topics (add these for better discoverability):"
echo "   django, python, mysql, docker, bootstrap, booking-system"
echo "   room-management, web-application, docker-compose, responsive-design"
echo ""

echo "4. 📝 Repository Settings (recommended):"
echo "   - Enable Issues"
echo "   - Enable Wiki"
echo "   - Enable Discussions (optional)"
echo "   - Enable Security features"
echo ""

echo "🚀 Ready for Push Commands:"
echo "=========================="
echo ""
echo "After creating the GitHub repository, run these commands:"
echo ""
echo "# Add remote origin (replace YOUR_USERNAME with your GitHub username)"
echo "git remote add origin https://github.com/YOUR_USERNAME/$REPO_NAME.git"
echo ""
echo "# Push main branch"
echo "git push -u origin main"
echo ""
echo "# Push all tags"
echo "git push origin --tags"
echo ""
echo "# Verify push"
echo "git remote -v"
echo ""

echo "📊 What will be uploaded:"
echo "========================"
echo "- 42 files total"
echo "- Complete Django application"
echo "- Docker configuration"
echo "- Documentation"
echo "- Sample data and scripts"
echo ""

echo "🎯 Current Git Status:"
git log --oneline | head -5
echo ""

echo "💡 Pro Tips:"
echo "============"
echo "- Add repository description and topics for better SEO"
echo "- Enable GitHub Pages for documentation (optional)"
echo "- Set up branch protection rules for main branch"
echo "- Consider adding GitHub Actions for CI/CD"
echo ""

echo "✅ Ready to create your GitHub repository!"
echo "Follow the manual steps above, then run the git commands."
