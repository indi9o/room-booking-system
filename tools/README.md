# 🛠 Tools & Utilities

Direktori ini berisi berbagai script dan utility untuk membantu development, deployment, dan maintenance Room Booking System.

## 📁 Available Tools

### 🚀 Development & Setup
- **[start_app.sh](#start_appsh)** - Script startup aplikasi dengan setup otomatis
- **[make_staff.py](#make_staffpy)** - Script untuk menjadikan user sebagai staff/admin

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
