# 🚀 Setup Remote Repository (GitHub/GitLab)

## 📋 Langkah-langkah untuk Push ke Remote Repository

### Option 1: GitHub
1. **Buat repository baru di GitHub**:
   - Login ke GitHub
   - Klik "New Repository"
   - Nama: `room-booking-system`
   - Deskripsi: "Complete Room Booking System with Django, MySQL, Docker"
   - Set sebagai Public atau Private
   - **Jangan** centang "Initialize with README" (karena sudah ada lokal)

2. **Connect local repository ke GitHub**:
   ```bash
   cd /home/alan/Documents/03Resource/test-agent
   git remote add origin https://github.com/YOUR_USERNAME/room-booking-system.git
   git push -u origin main
   git push origin --tags
   ```

### Option 2: GitLab
1. **Buat project baru di GitLab**:
   - Login ke GitLab
   - Klik "New Project" > "Create blank project"
   - Project name: `room-booking-system`
   - Deskripsi: "Complete Room Booking System with Django, MySQL, Docker"
   - Set visibility level
   - **Jangan** centang "Initialize repository with a README"

2. **Connect local repository ke GitLab**:
   ```bash
   cd /home/alan/Documents/03Resource/test-agent
   git remote add origin https://gitlab.com/YOUR_USERNAME/room-booking-system.git
   git push -u origin main
   git push origin --tags
   ```

## 🔗 Setelah Setup Remote

### Verify Remote Connection
```bash
git remote -v
# Output should show:
# origin  https://github.com/YOUR_USERNAME/room-booking-system.git (fetch)
# origin  https://github.com/YOUR_USERNAME/room-booking-system.git (push)
```

### Future Development Workflow
```bash
# Pull latest changes
git pull origin main

# Push new changes
git add .
git commit -m "Feature: description"
git push origin main

# Push tags
git push origin --tags
```

## 📊 Repository Features untuk Enable

### GitHub
- [ ] **Issues**: Untuk bug tracking dan feature requests
- [ ] **Wiki**: Untuk dokumentasi tambahan
- [ ] **Projects**: Untuk project management
- [ ] **Actions**: Untuk CI/CD pipeline
- [ ] **Security**: Untuk security scanning
- [ ] **Insights**: Untuk analytics

### GitLab
- [ ] **Issues**: Bug tracking
- [ ] **Merge Requests**: Code review workflow
- [ ] **CI/CD**: Pipeline automation
- [ ] **Wiki**: Documentation
- [ ] **Snippets**: Code sharing
- [ ] **Container Registry**: Docker images

## 🏷 Recommended Repository Settings

### Repository Description
```
Complete Room Booking System built with Django 4.2.7, MySQL 8.0, and Docker. Features include room management, booking system, user authentication, admin panel, and responsive Bootstrap UI.
```

### Topics/Tags
```
django, python, mysql, docker, bootstrap, booking-system, room-management, web-application, docker-compose, responsive-design
```

### README Badge Examples
```markdown
![Django](https://img.shields.io/badge/Django-4.2.7-green)
![Python](https://img.shields.io/badge/Python-3.11-blue)
![MySQL](https://img.shields.io/badge/MySQL-8.0-orange)
![Docker](https://img.shields.io/badge/Docker-Compose-blue)
![Bootstrap](https://img.shields.io/badge/Bootstrap-5-purple)
```

## 🔐 SSH Setup (Recommended)

### Generate SSH Key
```bash
ssh-keygen -t ed25519 -C "alan@ub.ac.id"
```

### Add SSH Key to GitHub/GitLab
1. Copy public key:
   ```bash
   cat ~/.ssh/id_ed25519.pub
   ```
2. Add to GitHub: Settings > SSH and GPG keys > New SSH key
3. Add to GitLab: Settings > SSH Keys

### Update Remote to Use SSH
```bash
git remote set-url origin git@github.com:YOUR_USERNAME/room-booking-system.git
# or for GitLab:
git remote set-url origin git@gitlab.com:YOUR_USERNAME/room-booking-system.git
```

---

## ✅ Ready for Remote!
Local repository sudah siap untuk di-push ke remote repository pilihan Anda!
