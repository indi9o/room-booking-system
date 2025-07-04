# 🛠 Tools & Utilities

Direktori ini berisi berbagai script dan utility untuk membantu development, deployment, dan maintenance Room Booking System.

## 📁 Available Tools

### 🚀 Development & Setup
- **[start_app.sh](#start_appsh)** - Script startup aplikasi dengan setup otomatis
- **[docker_django.sh](#docker_djangosh)** - Docker Django management commands
- **[make_staff.py](#make_staffpy)** - Script untuk menjadikan user sebagai staff/admin
- **[backup.sh](#backupsh)** - Database backup dan restore utilities
- **[env_docker_integration.sh](#env_docker_integrationsh)** - .env dan Docker Compose integration tools
- **[setup_i18n.sh](#setup_i18nsh)** - Setup internationalization dan multi-language support
- **[performance_test.sh](#performance_testsh)** - Comprehensive performance testing dan health checks

### 🌐 Git & Repository Management  
- **[github_setup.sh](#github_setupsh)** - Panduan setup repository GitHub
- **[push_to_github.sh](#push_to_githubsh)** - Script untuk push ke GitHub dengan validasi

---

## 📖 Tool Documentation

### start_app.sh
**Purpose**: One-click application startup dengan setup environment otomatis

**Features**:
- ✅ Aktivasi virtual environment otomatis
- ✅ Install dependencies dari requirements.txt
- ✅ Run database migrations
- ✅ Collect static files
- ✅ Create superuser jika belum ada
- ✅ Load sample data untuk development
- ✅ Start development server

**Usage**:
```bash
# Make executable
chmod +x tools/start_app.sh

# Run the script
./tools/start_app.sh
```

**Perfect for**: First-time setup, development environment

---

### docker_django.sh
**Purpose**: Comprehensive Docker Django management untuk development dan deployment

**Features**:
- ✅ Container management (up, down, build, restart)
- ✅ Django commands (migrate, createsuperuser, shell, test)
- ✅ Database operations (backup, restore, shell)
- ✅ Development utilities (logs, exec, bash)
- ✅ Auto container checking dan startup
- ✅ Colored output dan user-friendly interface

**Usage**:
```bash
# Container management
./tools/docker_django.sh up               # Start all services
./tools/docker_django.sh down             # Stop all services
./tools/docker_django.sh build            # Build containers
./tools/docker_django.sh restart          # Restart services
./tools/docker_django.sh status           # Show container status

# Django commands
./tools/docker_django.sh migrate          # Run migrations
./tools/docker_django.sh createsuperuser  # Create superuser
./tools/docker_django.sh shell            # Django shell
./tools/docker_django.sh test             # Run tests

# Database operations
./tools/docker_django.sh dbshell          # Database shell
./tools/docker_django.sh dbbackup         # Create backup
./tools/docker_django.sh dbrestore file   # Restore backup

# Development
./tools/docker_django.sh bash             # Container bash shell
./tools/docker_django.sh exec 'command'   # Execute custom command
./tools/docker_django.sh logs             # Show container logs
```

**Perfect for**: Docker-based development, container management, Django operations

---

### make_staff.py
**Purpose**: Convert regular user menjadi staff untuk access admin panel

**Features**:
- ✅ Interactive mode untuk pilih user
- ✅ Batch processing multiple users
- ✅ Safety checks dan validasi
- ✅ Logging dan confirmation

**Usage**:
```bash
# Interactive mode
python tools/make_staff.py

# Direct user conversion
python tools/make_staff.py --username user1

# Via Django shell
python manage.py shell
>>> exec(open('tools/make_staff.py').read())
```

**Perfect for**: User management, admin access control

---

### backup.sh
**Purpose**: Comprehensive database backup dan restore utilities

**Features**:
- ✅ Database backup dengan timestamp
- ✅ Automated backup scheduling
- ✅ Backup restoration dengan validasi
- ✅ Backup integrity checks
- ✅ Multiple backup retention policies
- ✅ Configuration file support

**Usage**:
```bash
# Create database backup
./tools/backup.sh backup

# Restore from backup
./tools/backup.sh restore

# Interactive mode
./tools/backup.sh

# View backup history
./tools/backup.sh list
```

**Perfect for**: Data safety, migration, disaster recovery

---

### env_docker_integration.sh
**Purpose**: Analyze dan optimize integrasi antara .env dan Docker Compose

**Features**:
- ✅ Analyze current configuration integration
- ✅ Fix docker-compose.yml untuk menggunakan .env variables
- ✅ Validate consistency antara .env dan docker-compose
- ✅ Create comprehensive .env dari template
- ✅ Backup configuration files
- ✅ Best practices enforcement

**Usage**:
```bash
# Interactive mode (show help)
./tools/env_docker_integration.sh

# Analyze current integration
./tools/env_docker_integration.sh analyze

# Fix docker-compose to use .env
./tools/env_docker_integration.sh fix

# Validate configuration consistency
./tools/env_docker_integration.sh validate

# Create comprehensive .env
./tools/env_docker_integration.sh create-env

# Backup current configuration
./tools/env_docker_integration.sh backup
```

**Perfect for**: Configuration management, Docker optimization, environment consistency

---

### github_setup.sh
**Purpose**: Comprehensive guide untuk setup GitHub repository

**Features**:
- ✅ Step-by-step GitHub repository creation
- ✅ Remote repository connection commands
- ✅ Best practices untuk repository setup
- ✅ Branch management guidelines
- ✅ Repository configuration recommendations

**Usage**:
```bash
# Read the guide
./tools/github_setup.sh

# Or view as documentation
cat tools/github_setup.sh
```

**Perfect for**: First-time GitHub setup, team onboarding

---

### push_to_github.sh
**Purpose**: Safe dan validated push to GitHub dengan pre-checks

**Features**:
- ✅ Repository status validation
- ✅ Commit history verification  
- ✅ Branch safety checks
- ✅ Remote connection testing
- ✅ Colored output untuk readability
- ✅ Error handling dan rollback

**Usage**:
```bash
# Make executable
chmod +x tools/push_to_github.sh

# Run push script
./tools/push_to_github.sh
```

**Perfect for**: Safe repository updates, team collaboration

---

### setup_i18n.sh
**Purpose**: Setup internationalization untuk multi-language support

**Features**:
- ✅ Create locale directories untuk semua supported languages
- ✅ Generate translation files (.po files)
- ✅ Setup Django Rosetta untuk translation management
- ✅ Compile existing translations
- ✅ JavaScript translation support

**Usage**:
```bash
# Make executable and run
chmod +x tools/setup_i18n.sh
./tools/setup_i18n.sh
```

**What it does**:
- Creates locale directories (en, id, zh, ja, ko)
- Generates django.po files for each language
- Compiles message files
- Sets up translation management interface

**Perfect for**: Adding multi-language support, translation management

---

### performance_test.sh
**Purpose**: Comprehensive performance testing dan health checking untuk sistem

**Features**:
- ✅ Service availability checking
- ✅ Response time measurement untuk setiap endpoint
- ✅ API endpoint performance testing
- ✅ Basic load testing dengan Apache Bench
- ✅ Database connectivity testing
- ✅ Security headers validation
- ✅ Comprehensive performance reporting
- ✅ Color-coded output dan thresholds
- ✅ Multiple test modes (quick, load, security)

**Usage**:
```bash
# Make executable
chmod +x tools/performance_test.sh

# Full performance test suite
./tools/performance_test.sh

# Quick performance test only
./tools/performance_test.sh quick

# Load testing only
./tools/performance_test.sh load

# Security headers test only
./tools/performance_test.sh security
```

**Requirements**:
- curl (untuk HTTP testing)
- bc (untuk calculations) 
- ab (Apache Bench, optional untuk load testing)

**Performance Thresholds**:
- **Excellent**: < 500ms
- **Acceptable**: < 2000ms
- **Slow**: < 5000ms
- **Unacceptable**: > 5000ms

**Perfect for**: Production readiness testing, performance monitoring, CI/CD validation

---

## 🎯 Quick Commands

### First-Time Setup
```bash
# 1. Start application for first time
./tools/start_app.sh

# 2. Make your user staff (interactive)
python tools/make_staff.py

# 3. Setup GitHub repository (follow guide)
./tools/github_setup.sh
```

### Daily Development
```bash
# Start development server
./tools/start_app.sh

# Push changes safely
./tools/push_to_github.sh
```

### User Management
```bash
# Make user staff
python tools/make_staff.py --username newuser

# Or interactive mode
python tools/make_staff.py
```

## 🔧 Tool Maintenance

### Adding New Tools
1. Create script in `tools/` directory
2. Make executable: `chmod +x tools/script.sh`
3. Add documentation to this README
4. Update [main documentation](../docs/development/tools.md)

### Best Practices
- ✅ **Executable permissions** for shell scripts
- ✅ **Error handling** and user feedback
- ✅ **Documentation** with usage examples
- ✅ **Validation** before destructive operations
- ✅ **Logging** for debugging and auditing

---

## 📚 Related Documentation

- **[Development Guide](../docs/development/git-workflow.md)** - Git workflow dan contribution
- **[Quick Start](../docs/setup/quick-start.md)** - Application setup
- **[Remote Repository Setup](../docs/setup/remote-repository.md)** - GitHub/GitLab setup
- **[FAQ](../docs/faq.md)** - Common questions about tools

---

**💡 Need help?** Check the [troubleshooting guide](../docs/troubleshooting.md) or open an issue!
