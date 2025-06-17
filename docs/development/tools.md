# 🛠 Tools & Development Utilities

Panduan lengkap untuk menggunakan tools dan utilities yang tersedia dalam Room Booking System untuk mempermudah development, deployment, dan maintenance.

## 📁 Tools Directory Structure

```
tools/
├── README.md              # Tools documentation (you are here)
├── start_app.sh          # Application startup script  
├── make_staff.py         # User management utility
├── github_setup.sh       # GitHub repository setup guide
└── push_to_github.sh     # Safe GitHub push script
```

## 🚀 Essential Development Tools

### 1. Application Startup - `start_app.sh`

**One-click development environment setup**

```bash
# Make executable and run
chmod +x tools/start_app.sh
./tools/start_app.sh
```

**What it does**:
- ✅ Starts Docker containers automatically
- ✅ Runs database migrations (makemigrations + migrate)
- ✅ Collects static files for proper CSS/JS loading
- ✅ Creates superuser if none exists (admin/admin123)
- ✅ Loads sample room data for testing
- ✅ Starts development server on http://localhost:8001

**Perfect for**:
- 🆕 **First-time setup** - Get running in under 2 minutes
- 🔄 **Daily development** - Quick start after git pull
- 🧪 **Fresh environment** - Reset to clean state
- 👥 **Team onboarding** - Consistent setup for all developers

---

### 2. User Management - `make_staff.py`

**Convert regular users to staff/admin for management access**

```bash
# Interactive mode - choose from existing users
python tools/make_staff.py

# Direct mode - specify username
python tools/make_staff.py --username john_doe

# Within Django shell
python manage.py shell
>>> exec(open('tools/make_staff.py').read())
```

**Features**:
- 🔍 **List all users** with current staff status
- 👤 **Interactive selection** for easy user management
- 🔐 **Batch processing** for multiple users
- ✅ **Safety validations** prevent accidental changes
- 📝 **Detailed logging** for audit trail

**Use Cases**:
- 👨‍💼 **New staff member** needs admin panel access
- 🔄 **Role changes** - promote user to management
- 🧪 **Testing purposes** - need admin access quickly
- 👥 **Team setup** - batch promote multiple users

---

### 3. Repository Setup - `github_setup.sh`

**Comprehensive GitHub repository setup guide**

```bash
# View setup instructions
./tools/github_setup.sh

# Or read as reference
cat tools/github_setup.sh
```

**Covers**:
- 🆕 **Repository creation** on GitHub with proper settings
- 🔗 **Remote connection** commands and troubleshooting
- 🌿 **Branch management** best practices
- ⚙️ **Repository configuration** recommendations
- 🏷️ **Tagging strategy** for releases
- 👥 **Team collaboration** setup

**Perfect for**:
- 🆕 **First-time GitHub users** 
- 📚 **Team onboarding** reference
- ✅ **Setup verification** checklist
- 🔧 **Troubleshooting** connection issues

---

### 4. Safe Push - `push_to_github.sh`

**Validated and safe push to GitHub with comprehensive checks**

```bash
# Make executable and run
chmod +x tools/push_to_github.sh
./tools/push_to_github.sh
```

**Safety Features**:
- 🔍 **Repository status** validation before push
- 📊 **Commit history** verification and preview
- 🌿 **Branch safety** checks for protected branches
- 🔗 **Remote connection** testing
- 🎨 **Colored output** for clear status indication
- ⚠️ **Error handling** with rollback capabilities
- 📝 **Change summary** before confirmation

**Prevents**:
- 💥 **Accidental pushes** to wrong repository
- 🔒 **Force push disasters** on shared branches
- 📊 **Large file uploads** that slow down repo
- 🚫 **Broken commits** that fail CI/CD

---

## 🎯 Common Workflows

### New Developer Onboarding

```bash
# 1. Clone repository
git clone https://github.com/username/room-booking-system.git
cd room-booking-system

# 2. One-click setup
./tools/start_app.sh

# 3. Make yourself staff for testing
python tools/make_staff.py --username your_username

# 4. Access admin panel
# http://localhost:8000/admin (admin/admin123)
```

### Daily Development Workflow

```bash
# 1. Start development environment
./tools/start_app.sh

# 2. Make changes, test, commit
git add .
git commit -m "Your changes"

# 3. Safe push to repository
./tools/push_to_github.sh
```

### Production Deployment Preparation (DOCKER-ONLY)

```bash
# 1. Ensure all tests pass
./tools/docker_django.sh test

# 2. Verify static files
./tools/docker_django.sh exec "python manage.py collectstatic --dry-run"

# 3. Check migrations
./tools/docker_django.sh exec "python manage.py makemigrations --dry-run"

# 4. Safe push for deployment
./tools/push_to_github.sh
```

## 🔧 Tool Customization

### Environment Variables

Create `.env` file for tool customization:

```bash
# Development settings
DEBUG=1
SECRET_KEY=your-secret-key

# Database settings  
DB_HOST=localhost
DB_NAME=room_usage_db
DB_USER=django_user
DB_PASSWORD=your-password

# Email settings (optional)
EMAIL_HOST=smtp.gmail.com
EMAIL_PORT=587
```

### Custom Scripts

Add your own tools to `tools/` directory:

```bash
# 1. Create script
touch tools/your_script.sh

# 2. Make executable
chmod +x tools/your_script.sh

# 3. Add to tools/README.md
# 4. Document in this file
```

## 🐛 Troubleshooting Tools

### Permission Issues
```bash
# Fix script permissions
chmod +x tools/*.sh

# Fix Python script permissions
chmod +x tools/*.py
```

### Environment Issues (DOCKER-ONLY)
```bash
# Reset containers
docker-compose down -v
docker-compose build --no-cache
docker-compose up -d
```

### Database Issues (DOCKER-ONLY)
```bash
# Reset database
docker-compose down -v
./tools/docker_django.sh migrate
./tools/docker_django.sh createsuperuser
```

## 📚 Related Documentation

- **[Git Workflow](git-workflow.md)** - Team collaboration guidelines
- **[Quick Start Guide](../setup/quick-start.md)** - Application setup
- **[Remote Repository](../setup/remote-repository.md)** - GitHub/GitLab setup
- **[Troubleshooting](../troubleshooting.md)** - Common issue solutions

---

**💡 Pro Tip**: Bookmark this page and the tools/ directory for quick access to development utilities!
