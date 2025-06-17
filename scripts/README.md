# 🛠️ Scripts Directory

Direktori ini berisi berbagai script utility untuk membantu development, deployment, dan maintenance aplikasi Room Booking System.

## 📁 Available Scripts

### 🚀 [setup.sh](setup.sh)
**Complete setup script for new installations**
```bash
./scripts/setup.sh
```
- Checks system requirements
- Sets up environment files
- Builds and starts Docker containers
- Sets up database with sample data
- Creates admin user
- Verifies installation

### 🔄 [run-development.sh](run-development.sh)
**Start development environment**
```bash
./scripts/run-development.sh
```
- Creates .env from template if needed
- Starts development containers
- Shows application status and URLs

### 🚀 [run-production.sh](run-production.sh)
**Deploy to production**
```bash
./scripts/run-production.sh
```
- Validates production configuration
- Starts production containers with optimized settings
- Performs health checks

### 🧪 [quick_test.sh](quick_test.sh)
**Quick testing and validation**
```bash
./scripts/quick_test.sh
```
- Runs basic application tests
- Validates configuration
- Checks container health

### 🧪 [test_deployment.sh](test_deployment.sh)
**Comprehensive deployment testing**
```bash
./scripts/test_deployment.sh
```
- Tests complete deployment process
- Validates all application components
- Generates deployment report

### 🔧 [dev-tools.sh](dev-tools.sh)
**Development utilities**
```bash
./scripts/dev-tools.sh [command]
```
Available commands:
- `reset-db` - Reset database with sample data
- `test [type]` - Run tests (unit, integration, coverage)
- `lint` - Code linting with flake8
- `format` - Code formatting with black
- `secret-key` - Generate Django secret key
- `superuser` - Create Django superuser
- `shell` - Open Django shell
- `dbshell` - Open database shell

### 📊 [monitor.sh](monitor.sh)
**Application monitoring and logs**
```bash
./scripts/monitor.sh [command]
```
Available commands:
- `logs [container] [lines]` - Show recent logs
- `follow [container]` - Follow logs in real-time
- `stats` - Show container statistics
- `health` - Check application health
- `disk` - Show disk usage
- `export` - Export all logs
- `cleanup` - Clean up old logs

### 🗄️ [backup.sh](backup.sh)
**Backup and restore utilities**
```bash
./scripts/backup.sh [type]
```
Available commands:
- (no args) - Full backup (database + media + config)
- `database` - Backup database only
- `media` - Backup media files only
- `config` - Backup configuration only
- `cleanup` - Remove old backups

### 🚀 [start.sh](start.sh)
**Original one-command starter (legacy)**
```bash
./scripts/start.sh
```
- Simple startup script
- Now redirects to setup.sh for better experience

## 🎯 Quick Start Workflows

### First Time Setup
```bash
# 1. Complete setup (recommended for new installations)
./scripts/setup.sh

# Alternative: Manual step-by-step
./scripts/setup.sh requirements  # Check requirements
./scripts/setup.sh environment   # Setup environment
./scripts/setup.sh build        # Build containers
./scripts/setup.sh database     # Setup database
./scripts/setup.sh verify       # Verify installation
```

### Daily Development
```bash
# Start development environment
./scripts/run-development.sh

# Development tools
./scripts/dev-tools.sh test      # Run tests
./scripts/dev-tools.sh lint      # Check code style
./scripts/dev-tools.sh shell     # Django shell

# Monitor application
./scripts/monitor.sh health      # Health check
./scripts/monitor.sh logs web 50 # Show recent logs
```

### Production Deployment
```bash
# Deploy to production
./scripts/run-production.sh

# Test deployment
./scripts/test_deployment.sh

# Monitor production
./scripts/monitor.sh stats       # Container stats
./scripts/monitor.sh health      # Health check
```

### Maintenance
```bash
# Backup data
./scripts/backup.sh             # Full backup
./scripts/backup.sh database    # Database only

# Monitor and troubleshoot
./scripts/monitor.sh disk       # Disk usage
./scripts/monitor.sh export     # Export logs
./scripts/monitor.sh cleanup    # Clean old logs
```

## 🔧 Script Permissions

All scripts should be executable. If you encounter permission issues:
```bash
chmod +x scripts/*.sh
```

## 📝 Environment Variables

Most scripts read configuration from `.env` file. Key variables:
- `DEBUG` - Development/production mode
- `DB_*` - Database configuration
- `DJANGO_SUPERUSER_*` - Admin user creation
- `CONTAINER_PREFIX` - Container naming

## 🔍 Troubleshooting

### Common Issues

1. **Permission denied**
   ```bash
   chmod +x scripts/[script-name].sh
   ```

2. **Docker not found**
   ```bash
   ./scripts/setup.sh requirements
   ```

3. **Containers not starting**
   ```bash
   ./scripts/monitor.sh logs web
   docker-compose down && docker-compose up -d
   ```

4. **Database connection failed**
   ```bash
   ./scripts/dev-tools.sh reset-db
   ```

### Getting Help

```bash
# Show available commands for each script
./scripts/dev-tools.sh menu
./scripts/monitor.sh menu
./scripts/backup.sh
```

## 📚 Related Documentation

- [Development Checklist](../checklists/DEVELOPMENT_CHECKLIST.md)
- [Deployment Checklist](../checklists/DEPLOYMENT_CHECKLIST.md)
- [Security Checklist](../checklists/SECURITY_CHECKLIST.md)
- [Developer Guide](../docs/DEVELOPER.md)
- [Deployment Guide](../docs/DEPLOYMENT.md)

## 🔄 Contributing

When adding new scripts:
1. Follow the existing naming convention
2. Include help/menu functionality
3. Add error handling with `set -e`
4. Update this README
5. Add to appropriate checklists
6. Test on clean environment

## 💡 Tips

- Use `./scripts/setup.sh` for first-time setup
- Use `./scripts/dev-tools.sh` for daily development
- Use `./scripts/monitor.sh` for troubleshooting
- Use `./scripts/backup.sh` before major changes
- All scripts can be run from project root or scripts directory
