# 🔄 Git Workflow Guide

Panduan lengkap untuk menggunakan Git dalam pengembangan Room Booking System, dari setup awal hingga kolaborasi tim.

## 🎯 Overview

Git workflow untuk Room Booking System dirancang untuk:
- 🔒 **Maintaining code quality** melalui structured branching
- 👥 **Team collaboration** dengan clear process
- 🚀 **Smooth deployment** dari development ke production
- 📦 **Version management** dengan semantic versioning

## 🌳 Branching Strategy

### Branch Structure
```
main (production-ready)
├── develop (integration branch)
│   ├── feature/add-room-management
│   ├── feature/booking-validation
│   └── feature/user-notifications
├── hotfix/urgent-bug-fix
└── release/v1.1.0
```

### Branch Types

#### 1. Main Branch
- **Purpose**: Production-ready code
- **Protection**: Protected, requires PR
- **Deploy**: Auto-deploy to production
- **Naming**: `main`

#### 2. Develop Branch
- **Purpose**: Integration and testing
- **Merge from**: Feature branches
- **Merge to**: Release branches
- **Naming**: `develop`

#### 3. Feature Branches
- **Purpose**: New features development
- **Branch from**: `develop`
- **Merge to**: `develop`
- **Naming**: `feature/feature-name`

#### 4. Release Branches
- **Purpose**: Prepare new releases
- **Branch from**: `develop`
- **Merge to**: `main` and `develop`
- **Naming**: `release/v1.x.x`

#### 5. Hotfix Branches
- **Purpose**: Critical production fixes
- **Branch from**: `main`
- **Merge to**: `main` and `develop`
- **Naming**: `hotfix/issue-description`

## 🚀 Getting Started

### 1. Initial Repository Setup

#### Clone Repository
```bash
git clone https://github.com/YOUR_USERNAME/room-booking-system.git
cd room-booking-system
```

#### Setup Git Configuration
```bash
git config user.name "Your Name"
git config user.email "your.email@domain.com"
git config pull.rebase false  # Prefer merge over rebase
```

#### Verify Setup
```bash
git remote -v
git branch -a
git status
```

### 2. Development Environment
```bash
# Create and switch to develop branch (if not exists)
git checkout -b develop origin/develop

# Or switch to existing develop
git checkout develop
git pull origin develop
```

## 🎯 Feature Development Workflow

### 1. Starting New Feature

#### Create Feature Branch
```bash
# Switch to develop and update
git checkout develop
git pull origin develop

# Create new feature branch
git checkout -b feature/room-search-filter

# Push branch to remote
git push -u origin feature/room-search-filter
```

#### Feature Branch Naming
```bash
✅ Good Examples:
feature/add-room-management
feature/booking-conflict-validation
feature/user-notification-system
feature/mobile-responsive-ui

❌ Avoid:
feature/fix           # Too generic
feature/update        # No context
feature/new-stuff     # Unclear
```

### 2. Development Process

#### Daily Development
```bash
# Start of day: Update your branch
git checkout feature/your-feature
git fetch origin
git merge origin/develop  # Or rebase if preferred

# Work on your feature...
# Make changes, test locally

# Commit changes
git add .
git commit -m "Add: room search filter functionality"

# Push to remote
git push origin feature/your-feature
```

#### Commit Message Convention
```bash
# Format: Type: Description (max 50 chars)
# Body: Detailed explanation (if needed)

✅ Good Examples:
Add: room search and filter functionality
Fix: booking conflict validation error
Update: room capacity validation logic
Remove: deprecated booking status field
Docs: update room management guide
Test: add unit tests for booking model

❌ Avoid:
"fixed bug"          # No context
"updates"            # Too vague
"asdf"              # Meaningless
"WIP"               # Work in progress
```

### 3. Feature Completion

#### Pre-Merge Checklist
- [ ] Feature fully implemented
- [ ] All tests passing
- [ ] Code reviewed and clean
- [ ] Documentation updated
- [ ] No merge conflicts
- [ ] Tested in development environment

#### Merge Process
```bash
# Update feature branch with latest develop
git checkout feature/your-feature
git fetch origin
git merge origin/develop

# Resolve any conflicts if they exist
# Test everything still works

# Create Pull Request via GitHub/GitLab
# Or merge directly if you have permissions:
git checkout develop
git pull origin develop
git merge feature/your-feature
git push origin develop

# Delete feature branch after merge
git branch -d feature/your-feature
git push origin --delete feature/your-feature
```

## 🔄 Release Workflow

### 1. Preparing Release

#### Create Release Branch
```bash
# From develop branch
git checkout develop
git pull origin develop

# Create release branch
git checkout -b release/v1.1.0
git push -u origin release/v1.1.0
```

#### Release Preparation Tasks
- [ ] Update version numbers
- [ ] Update CHANGELOG.md
- [ ] Run full test suite
- [ ] Update documentation
- [ ] Build and test Docker images
- [ ] Security audit

#### Version File Updates
```python
# room_usage_project/settings.py
VERSION = '1.1.0'

# setup.py (if exists)
version='1.1.0'
```

### 2. Release Finalization

#### Merge to Main
```bash
# Switch to main and update
git checkout main
git pull origin main

# Merge release branch
git merge release/v1.1.0

# Tag the release
git tag -a v1.1.0 -m "Version 1.1.0: Room search and filtering

Features:
- Advanced room search functionality
- Filter by capacity, location, facilities
- Improved mobile responsive design
- Enhanced booking conflict detection

Fixes:
- Fixed booking validation edge cases
- Improved error handling
- Updated documentation"

# Push main and tags
git push origin main
git push origin --tags
```

#### Merge Back to Develop
```bash
# Update develop with release changes
git checkout develop
git merge release/v1.1.0
git push origin develop

# Delete release branch
git branch -d release/v1.1.0
git push origin --delete release/v1.1.0
```

## 🚨 Hotfix Workflow

### Emergency Production Fix

#### Create Hotfix Branch
```bash
# From main branch
git checkout main
git pull origin main

# Create hotfix branch
git checkout -b hotfix/booking-validation-error
git push -u origin hotfix/booking-validation-error
```

#### Implement Fix
```bash
# Make minimal changes to fix the issue
# Focus only on the critical fix
# Test thoroughly

git add .
git commit -m "Fix: critical booking validation error

- Fixed null pointer exception in booking validation
- Added defensive null checks
- Updated error handling for edge cases"

git push origin hotfix/booking-validation-error
```

#### Deploy Hotfix
```bash
# Merge to main
git checkout main
git merge hotfix/booking-validation-error

# Tag hotfix version
git tag -a v1.0.1 -m "Hotfix 1.0.1: Critical booking validation fix"

# Push to production
git push origin main
git push origin --tags

# Merge back to develop
git checkout develop
git merge hotfix/booking-validation-error
git push origin develop

# Clean up
git branch -d hotfix/booking-validation-error
git push origin --delete hotfix/booking-validation-error
```

## 👥 Collaboration Guidelines

### 1. Pull Request Process

#### Creating PR
```markdown
# PR Title Format
[Type] Brief description

# PR Description Template
## What does this PR do?
Brief description of changes

## Type of Change
- [ ] Bug fix (non-breaking change)
- [ ] New feature (non-breaking change)
- [ ] Breaking change (fix/feature causing existing functionality to change)
- [ ] Documentation update

## How to Test
1. Step by step testing instructions
2. Expected behavior
3. Edge cases to verify

## Checklist
- [ ] Code follows project style guidelines
- [ ] Self-review completed
- [ ] Documentation updated
- [ ] Tests added/updated
- [ ] No breaking changes (or clearly documented)
```

#### Code Review Guidelines
```bash
✅ Review Focus Areas:
- Functionality correctness
- Code quality and style
- Security considerations
- Performance implications
- Documentation accuracy

✅ Review Checklist:
- [ ] Code is readable and well-commented
- [ ] No hardcoded values or credentials
- [ ] Error handling is appropriate
- [ ] Tests cover new functionality
- [ ] No debug code or console.logs
```

### 2. Conflict Resolution

#### Merge Conflicts
```bash
# When conflicts occur during merge
git status  # Shows conflicted files

# Edit conflicted files, resolve conflicts
# Look for conflict markers: <<<<<<<, =======, >>>>>>>

# After resolving conflicts
git add .
git commit -m "Resolve merge conflicts"
git push origin your-branch
```

#### Preventing Conflicts
```bash
# Regularly sync with develop
git checkout feature/your-feature
git fetch origin
git merge origin/develop

# Keep feature branches small and focused
# Communicate with team about overlapping work
# Merge frequently to avoid large conflicts
```

## 📦 Version Management

### Semantic Versioning
```
Format: MAJOR.MINOR.PATCH

MAJOR: Breaking changes (2.0.0)
MINOR: New features, backward compatible (1.1.0)
PATCH: Bug fixes, backward compatible (1.0.1)

Examples:
v1.0.0 - Initial release
v1.1.0 - Added room management features
v1.1.1 - Fixed booking validation bug
v2.0.0 - Major UI overhaul (breaking changes)
```

### Release Notes Template
```markdown
# Version 1.1.0 - June 15, 2025

## 🎉 New Features
- Advanced room search and filtering
- Mobile-responsive design improvements
- Bulk room management in admin panel

## 🔧 Improvements
- Enhanced booking conflict detection
- Improved error messages and validation
- Better performance for large room lists

## 🐛 Bug Fixes
- Fixed booking cancellation edge case
- Resolved timezone handling issues
- Fixed mobile layout on small screens

## 📚 Documentation
- Updated room management guide
- Added troubleshooting section
- Improved API documentation

## ⚠️ Breaking Changes
None in this release

## 🔄 Migration Notes
No database migrations required
```

## 🛠️ Git Tools & Tips

### Useful Git Commands

#### Status and Information
```bash
# Check repository status
git status
git log --oneline --graph --all
git branch -v
git remote -v

# View changes
git diff
git diff --staged
git show HEAD

# Search commit history
git log --grep="booking"
git log --author="username"
```

#### Cleaning Up
```bash
# Remove merged branches
git branch --merged | grep -v main | xargs -n 1 git branch -d

# Clean up remote tracking branches
git remote prune origin

# Reset to clean state (careful!)
git reset --hard HEAD
git clean -fd
```

#### Stashing Work
```bash
# Save work in progress
git stash push -m "Work in progress on search feature"

# List stashes
git stash list

# Apply stash
git stash pop
git stash apply stash@{0}

# Drop stash
git stash drop stash@{0}
```

### Git Aliases (Optional)
```bash
# Add to ~/.gitconfig
[alias]
    st = status
    co = checkout
    br = branch
    ci = commit
    df = diff
    lg = log --oneline --graph --all
    up = pull --rebase
    cm = commit -m
    ac = !git add -A && git commit -m
```

## 📋 Best Practices Checklist

### Daily Development
- [ ] Start day by pulling latest develop
- [ ] Work on focused, small features
- [ ] Commit early and often with clear messages
- [ ] Push work at end of day
- [ ] Keep feature branches up to date

### Before Merging
- [ ] Code is tested and working
- [ ] All tests pass
- [ ] Documentation updated
- [ ] No merge conflicts
- [ ] Code reviewed (if team process)

### Repository Maintenance
- [ ] Regular cleanup of merged branches
- [ ] Keep main and develop up to date
- [ ] Tag releases properly
- [ ] Update changelog with releases
- [ ] Monitor repository size and performance

## 🚨 Emergency Procedures

### Rollback Production
```bash
# Quick rollback to previous version
git checkout main
git reset --hard v1.0.0  # Previous stable version
git push --force-with-lease origin main

# Or revert specific commits
git revert HEAD~1
git push origin main
```

### Repository Corruption
```bash
# Backup current work
cp -r .git .git.backup

# Re-clone repository
git clone https://github.com/YOUR_USERNAME/room-booking-system.git new-repo
cd new-repo

# Restore your work from backup
# Apply changes manually and commit
```

---

## 📚 Additional Resources

### Learning Git
- [Pro Git Book](https://git-scm.com/book) - Comprehensive Git guide
- [Atlassian Git Tutorials](https://www.atlassian.com/git/tutorials)
- [Git Branching Model](https://nvie.com/posts/a-successful-git-branching-model/)

### Tools
- **GitKraken**: Visual Git client
- **Sourcetree**: Free Git GUI
- **VS Code**: Built-in Git integration
- **GitHub Desktop**: Simple GitHub integration

### Team Communication
- Use PR descriptions for context
- Comment on code reviews constructively
- Communicate breaking changes early
- Document decisions in commit messages

---

## ✅ Git Workflow Mastery

You're now equipped with a comprehensive Git workflow for Room Booking System development!

**Next Steps:**
- Practice with a test feature branch
- Set up your preferred Git client
- Establish team review process
- Learn advanced Git techniques

**Need help? Check [Development Guide](../development/) or create a GitHub issue!**
