# 🌐 Remote Repository Setup

Panduan untuk menghubungkan repository lokal ke GitHub/GitLab dan setup untuk kolaborasi tim.

## 🎯 Overview

Setelah development lokal, Anda perlu menghubungkan repository ke remote hosting untuk:
- 🔄 **Backup dan sync** code
- 👥 **Collaboration** dengan tim
- 🚀 **Deployment** dari remote repository  
- 📝 **Issue tracking** dan project management

## 🐙 GitHub Setup (Recommended)

### 1. Create Repository
1. **Login to GitHub**: https://github.com
2. **Click "New Repository"** (green button)
3. **Repository Settings**:
   - **Name**: `room-booking-system`
   - **Description**: `Complete Room Booking System with Django, MySQL, Docker`
   - **Visibility**: Public (recommended for open source)
   - **⚠️ Important**: DO NOT initialize with README, .gitignore, or license

### 2. Connect Local Repository
```bash
# Navigate to project directory
cd /home/alan/Documents/03Resource/test-agent

# Add GitHub remote (replace YOUR_USERNAME)
git remote add origin https://github.com/YOUR_USERNAME/room-booking-system.git

# Push main branch
git push -u origin main

# Push all tags
git push origin --tags

# Verify connection
git remote -v
```

### 3. Repository Configuration

#### Add Topics/Tags
```
django, python, mysql, docker, bootstrap, booking-system, 
room-management, web-application, docker-compose, responsive-design
```

#### Enable Features
- ✅ **Issues** - Bug tracking and feature requests
- ✅ **Wiki** - Additional documentation
- ✅ **Discussions** - Community Q&A
- ✅ **Security** - Vulnerability alerts
- ✅ **Projects** - Project management (optional)

## 🦊 GitLab Setup (Alternative)

### 1. Create Project
1. **Login to GitLab**: https://gitlab.com
2. **New Project** → **Create blank project**
3. **Project Settings**:
   - **Name**: `room-booking-system`
   - **Description**: `Complete Room Booking System with Django, MySQL, Docker`
   - **Visibility**: Public or Internal
   - **⚠️ Important**: DO NOT initialize with README

### 2. Connect Repository
```bash
# Add GitLab remote
git remote add origin https://gitlab.com/YOUR_USERNAME/room-booking-system.git

# Push code
git push -u origin main
git push origin --tags
```

## 🔐 SSH Setup (Recommended)

### Benefits of SSH
- 🔒 **More secure** than HTTPS
- 🚀 **No password prompts** for Git operations
- 🔑 **Key-based authentication**

### Generate SSH Key
```bash
# Generate new SSH key
ssh-keygen -t ed25519 -C "your.email@domain.com"

# Start SSH agent
eval "$(ssh-agent -s)"

# Add key to SSH agent
ssh-add ~/.ssh/id_ed25519

# Copy public key to clipboard
cat ~/.ssh/id_ed25519.pub
```

### Add to GitHub/GitLab
1. **GitHub**: Settings → SSH and GPG keys → New SSH key
2. **GitLab**: Settings → SSH Keys → Add key
3. **Paste public key** and save

### Update Remote URL
```bash
# Change to SSH (GitHub)
git remote set-url origin git@github.com:YOUR_USERNAME/room-booking-system.git

# Change to SSH (GitLab)  
git remote set-url origin git@gitlab.com:YOUR_USERNAME/room-booking-system.git

# Test connection
ssh -T git@github.com
# or
ssh -T git@gitlab.com
```

## 👥 Team Collaboration Setup

### Branch Protection Rules
```bash
# Via GitHub web interface:
Settings → Branches → Add rule

Protection Rules:
- ✅ Require pull request reviews
- ✅ Require status checks
- ✅ Require branches to be up to date
- ✅ Include administrators
```

### Collaborator Access
```bash
# Add team members:
Settings → Manage access → Invite a collaborator

Permission Levels:
- Read: View and clone
- Triage: Read + manage issues/PRs
- Write: Read + push to repo
- Maintain: Write + manage settings
- Admin: Full access
```

## 🔄 Daily Workflow

### Starting Work
```bash
# Update local repository
git checkout main
git pull origin main

# Create feature branch
git checkout -b feature/your-feature-name

# Work on your changes...
```

### Pushing Changes
```bash
# Add and commit changes
git add .
git commit -m "Add: your feature description"

# Push feature branch
git push origin feature/your-feature-name

# Create Pull Request via web interface
```

### Staying Updated
```bash
# Fetch latest changes
git fetch origin

# Update main branch
git checkout main
git pull origin main

# Update feature branch with latest main
git checkout feature/your-feature-name
git merge main
```

## 🚀 Automated Deployment Setup

### GitHub Actions (CI/CD)
```yaml
# .github/workflows/deploy.yml
name: Deploy to Production

on:
  push:
    branches: [ main ]
    tags: [ 'v*' ]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Deploy to server
        run: |
          # Your deployment commands
          echo "Deploying to production..."
```

### GitLab CI/CD
```yaml
# .gitlab-ci.yml
stages:
  - test
  - deploy

test:
  stage: test
  script:
    - python manage.py test

deploy:
  stage: deploy
  script:
    - echo "Deploying to production..."
  only:
    - main
    - tags
```

## 📊 Repository Analytics

### GitHub Insights
- **Traffic**: Visitor analytics
- **Commits**: Contribution activity
- **Issues**: Bug and feature tracking
- **Pull Requests**: Code review metrics

### Monitoring Repository Health
```bash
# Regular maintenance tasks:
- Review open issues weekly
- Merge stale PRs or close them
- Update documentation
- Tag releases regularly
- Monitor security alerts
```

## 🔒 Security Best Practices

### Repository Security
- 🔐 **Never commit secrets** (passwords, API keys)
- 🔍 **Enable vulnerability alerts**
- 📝 **Use .gitignore** for sensitive files
- 🔑 **Use environment variables** for config

### Access Control
- 👥 **Limit collaborator access**
- 🔒 **Enable 2FA** for your account
- 🔑 **Rotate SSH keys** periodically
- 📋 **Review permissions** regularly

## 🛠 Troubleshooting

### Common Issues

#### Authentication Failed
```bash
# For HTTPS - check credentials
git config --global user.name "Your Name"
git config --global user.email "your.email@domain.com"

# For SSH - test connection
ssh -T git@github.com
```

#### Push Rejected
```bash
# Update local repository first
git pull origin main

# Resolve conflicts if any
git add .
git commit -m "Resolve merge conflicts"

# Push again
git push origin main
```

#### Large Files
```bash
# Use Git LFS for large files
git lfs install
git lfs track "*.zip"
git lfs track "*.sql"
git add .gitattributes
```

## 📚 Additional Resources

### Learning Git/GitHub
- [Pro Git Book](https://git-scm.com/book)
- [GitHub Docs](https://docs.github.com)
- [GitLab Docs](https://docs.gitlab.com)

### Tools & Clients
- **GitHub Desktop** - GUI for GitHub
- **GitKraken** - Advanced Git client
- **Sourcetree** - Free Git GUI
- **VS Code** - Built-in Git integration

---

## ✅ Remote Repository Ready!

Once you've completed the setup:

1. **✅ Repository is live** on GitHub/GitLab
2. **✅ Team can collaborate** with proper permissions
3. **✅ CI/CD pipeline** ready for automation
4. **✅ Security measures** in place

**Next Steps:**
- Invite team members as collaborators
- Set up branch protection rules
- Configure automated deployment
- Start accepting contributions!

**🚀 Your Room Booking System is now ready for collaborative development!**
