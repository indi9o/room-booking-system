#!/bin/bash

# 🚀 GitHub Push Script for Room Booking System
# Run this script after creating your GitHub repository

echo "🚀 GitHub Push Commands for Room Booking System"
echo "==============================================="
echo ""

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if we're in a git repository
if [ ! -d ".git" ]; then
    echo -e "${RED}❌ Error: Not a git repository${NC}"
    echo "Please run this script from the project root directory."
    exit 1
fi

echo -e "${BLUE}📋 Current repository status:${NC}"
git status --short
echo ""

echo -e "${BLUE}📊 Commit history:${NC}"
git log --oneline | head -3
echo ""

echo -e "${YELLOW}⚠️  IMPORTANT: Before running this script:${NC}"
echo "1. Create a new repository on GitHub.com"
echo "2. Repository name: room-booking-system"
echo "3. Description: Complete Room Booking System built with Django 4.2.7, MySQL 8.0, and Docker"
echo "4. DO NOT initialize with README, .gitignore, or license"
echo ""

read -p "Have you created the GitHub repository? (y/N): " confirm
if [[ $confirm != [yY] && $confirm != [yY][eE][sS] ]]; then
    echo -e "${RED}❌ Please create the GitHub repository first${NC}"
    echo "Go to: https://github.com/new"
    exit 1
fi

echo ""
read -p "Enter your GitHub username: " github_username

if [ -z "$github_username" ]; then
    echo -e "${RED}❌ GitHub username cannot be empty${NC}"
    exit 1
fi

REPO_URL="https://github.com/${github_username}/room-booking-system.git"

echo ""
echo -e "${BLUE}🔗 Repository URL: ${REPO_URL}${NC}"
echo ""

# Check if remote already exists
if git remote get-url origin &> /dev/null; then
    echo -e "${YELLOW}⚠️  Remote 'origin' already exists. Removing...${NC}"
    git remote remove origin
fi

echo -e "${BLUE}🔧 Adding remote origin...${NC}"
git remote add origin "$REPO_URL"

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Remote origin added successfully${NC}"
else
    echo -e "${RED}❌ Failed to add remote origin${NC}"
    exit 1
fi

echo ""
echo -e "${BLUE}📤 Pushing main branch...${NC}"
git push -u origin main

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Main branch pushed successfully${NC}"
else
    echo -e "${RED}❌ Failed to push main branch${NC}"
    echo "This might be because the repository is not empty."
    echo "Try: git push -u origin main --force"
    exit 1
fi

echo ""
echo -e "${BLUE}🏷️  Pushing tags...${NC}"
git push origin --tags

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Tags pushed successfully${NC}"
else
    echo -e "${YELLOW}⚠️  Failed to push tags (this is usually okay)${NC}"
fi

echo ""
echo -e "${BLUE}🔍 Verifying remote connection...${NC}"
git remote -v

echo ""
echo -e "${GREEN}🎉 SUCCESS! Your repository has been uploaded to GitHub${NC}"
echo ""
echo -e "${BLUE}📝 Next steps:${NC}"
echo "1. Visit: https://github.com/${github_username}/room-booking-system"
echo "2. Add repository topics: django, python, mysql, docker, bootstrap, booking-system"
echo "3. Enable Issues and Wiki in repository settings"
echo "4. Consider adding a license file"
echo "5. Set up GitHub Pages for documentation (optional)"
echo ""
echo -e "${BLUE}📊 Repository statistics:${NC}"
echo "- Files uploaded: $(git ls-files | wc -l) files"
echo "- Total commits: $(git rev-list --count HEAD) commits"
echo "- Repository size: $(du -sh .git | cut -f1)"
echo ""
echo -e "${GREEN}✅ Your Room Booking System is now on GitHub!${NC}"
