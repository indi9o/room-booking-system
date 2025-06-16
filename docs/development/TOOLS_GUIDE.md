# 🛠 Tools Development Guide

> Panduan lengkap penggunaan dan pengembangan tools untuk Room Booking System

## 📋 Overview

Room Booking System dilengkapi dengan suite tools komprehensif untuk membantu development, deployment, dan maintenance. Semua tools dapat diakses melalui master script `tools.sh` atau dijalankan secara individual.

## 🚀 Quick Start

### Master Tools Launcher
```bash
# Run interactive tools launcher
./tools.sh

# Example output:
🛠 Room Booking System - Development Tools
==========================================

Available Tools:
1. start_app.sh     - 🚀 One-click application startup
2. make_staff.py    - 👤 Convert user to staff/admin
3. backup.sh        - 💾 Database backup & restore utilities
4. github_setup.sh  - 🌐 GitHub repository setup guide
5. push_to_github.sh - 📤 Safe push to GitHub
6. setup_i18n.sh    - 🌍 Setup internationalization
7. performance_test.sh - ⚡ Performance testing & health checks
8. tools/README.md   - 📖 Complete tools documentation

Enter tool number (1-8) or 'q' to quit: 
```

## 📁 Tools Directory Structure

```
tools/
├── README.md              # Complete tools documentation
├── start_app.sh           # Application startup script
├── make_staff.py          # User management utility
├── backup.sh              # Database backup/restore
├── github_setup.sh        # GitHub repository setup
├── push_to_github.sh      # Safe GitHub push
├── setup_i18n.sh          # Internationalization setup
└── performance_test.sh    # Performance testing suite
```

## 💻 Development Workflow

### First Time Setup
```bash
# 1. Clone repository
git clone <your-repo-url>
cd room-booking-system

# 2. Run master tools launcher
./tools.sh

# 3. Select option 1 (start_app.sh) for complete setup
```

### Daily Development
```bash
# Start development environment
./tools/start_app.sh

# Make users staff when needed
python tools/make_staff.py

# Push changes safely
./tools/push_to_github.sh
```

### Database Management
```bash
# Create backup before major changes
./tools/backup.sh backup

# Restore if needed
./tools/backup.sh restore
```

### Performance Monitoring
```bash
# Run comprehensive performance tests
./tools/performance_test.sh

# Quick performance check
./tools/performance_test.sh quick
```

## 🔧 Tool Integration

### Adding New Tools
1. Create script in `tools/` directory
2. Make executable: `chmod +x tools/new_tool.sh`
3. Add to `tools.sh` launcher
4. Document in `tools/README.md`

### Tool Standards
- ✅ Include help/usage information
- ✅ Use consistent error handling
- ✅ Provide colored output for better UX
- ✅ Include logging and confirmation prompts
- ✅ Follow defensive programming practices

## 📖 Complete Documentation

- **[tools/README.md](../tools/README.md)** - Detailed documentation for each tool
- **[docs/guides/](../guides/)** - User guides and tutorials
- **[docs/INDEX.md](../INDEX.md)** - Master documentation index

## 🎯 Best Practices

### Tool Usage
1. **Always use tools.sh** for discovery and navigation
2. **Read tool documentation** before first use
3. **Test in development** before production use
4. **Keep tools updated** with project changes

### Development Guidelines
1. **Modular design** - Each tool has single responsibility
2. **Consistent interface** - Similar command patterns
3. **Error handling** - Graceful failure with helpful messages
4. **Documentation** - Keep docs updated with changes

## 🚨 Troubleshooting

### Common Issues

**Tool not executable**
```bash
chmod +x tools/script_name.sh
```

**Tool not found**
```bash
# Ensure you're in project root
ls tools/
./tools.sh
```

**Permission errors**
```bash
# Fix all tool permissions
chmod +x tools/*.sh tools/*.py
```

### Getting Help

1. **Check tool help**: Most tools support `--help` or interactive mode
2. **Read documentation**: `tools/README.md` has detailed guides
3. **Use tools.sh**: Master launcher shows all available options
4. **Check logs**: Most tools provide detailed logging

---

*For more help, see [docs/guides/](../guides/) or check the main [documentation index](../INDEX.md).*
