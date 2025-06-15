# 🔧 Troubleshooting Guide

Panduan pemecahan masalah untuk Room Booking System. Temukan solusi cepat untuk masalah umum.

## 🚨 Emergency Quick Fixes

### Application Won't Start
```bash
# Quick restart
docker-compose down
docker-compose up -d

# If still fails, rebuild
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```

### Can't Access Web Application
1. **Check URL**: http://localhost:8001 (not 8000)
2. **Check containers**: `docker-compose ps`
3. **Check logs**: `docker-compose logs web`

### Database Connection Failed
```bash
# Restart database
docker-compose restart db

# Check database status
docker-compose logs db
```

## 🐳 Docker Issues

### Container Won't Start

#### Symptoms
- Container exits immediately
- "Port already in use" error
- "Permission denied" errors

#### Solutions
```bash
# Check what's using the port
sudo lsof -i :8001
sudo lsof -i :3306

# Kill processes using ports
sudo kill -9 <PID>

# Or change ports in docker-compose.yml
ports:
  - "8002:8000"  # Change from 8001 to 8002
```

### Out of Disk Space
```bash
# Clean Docker system
docker system prune -a

# Remove unused volumes
docker volume prune

# Check disk usage
df -h
du -sh /var/lib/docker
```

### Permission Issues
```bash
# Fix file ownership
sudo chown -R $USER:$USER .

# Fix Docker permissions (Linux)
sudo usermod -aG docker $USER
newgrp docker

# Restart Docker service
sudo systemctl restart docker
```

### Memory Issues
```bash
# Check Docker memory usage
docker stats

# Increase Docker memory limit (Docker Desktop)
# Settings > Resources > Advanced > Memory

# For Linux, edit daemon.json
sudo nano /etc/docker/daemon.json
{
  "default-ulimits": {
    "memlock": {
      "Hard": -1,
      "Name": "memlock",
      "Soft": -1
    }
  }
}
```

## 🗄️ Database Issues

### MySQL Container Won't Start

#### Check Logs
```bash
docker-compose logs db
```

#### Common Issues & Solutions
```bash
# Issue: "mysqld: Can't create/write to file"
# Solution: Fix permissions
docker-compose down
sudo chown -R 999:999 mysql_data/
docker-compose up -d

# Issue: "Access denied for user"
# Solution: Reset password
docker-compose down
docker volume rm room_usage_mysql_data
docker-compose up -d
```

### Database Connection Timeout
```bash
# Check database connectivity
docker-compose exec web python manage.py check --database default

# Test MySQL connection directly
docker-compose exec db mysql -u root -proot_password -e "SHOW DATABASES;"

# Restart both services
docker-compose restart db web
```

### Missing Tables/Data
```bash
# Check if migrations are applied
docker-compose exec web python manage.py showmigrations

# Apply migrations
docker-compose exec web python manage.py migrate

# Load sample data
docker-compose exec web python manage.py load_sample_data

# Create superuser if missing
docker-compose exec web python manage.py createsuperuser
```

### Database Corruption
```bash
# Backup first (if possible)
docker-compose exec db mysqldump -u root -proot_password room_usage_db > backup.sql

# Reset database
docker-compose down
docker volume rm room_usage_mysql_data
docker-compose up -d

# Wait for database to initialize, then restore
docker-compose exec -i db mysql -u root -proot_password room_usage_db < backup.sql
```

## 🌐 Web Application Issues

### 500 Internal Server Error

#### Check Logs
```bash
docker-compose logs web
```

#### Common Causes
1. **Missing environment variables**
2. **Database connection issues**
3. **Missing static files**
4. **Python import errors**

#### Solutions
```bash
# Check environment variables
docker-compose exec web env | grep DB_

# Collect static files
docker-compose exec web python manage.py collectstatic --noinput

# Check Django configuration
docker-compose exec web python manage.py check

# Debug mode (temporary)
# Edit docker-compose.yml: DEBUG=1
```

### Static Files Not Loading (CSS/JS)

#### Quick Fix
```bash
# Collect static files
docker-compose exec web python manage.py collectstatic --noinput

# Restart web container
docker-compose restart web

# Clear browser cache (Ctrl+F5)
```

#### Persistent Issues
```bash
# Check static files settings
docker-compose exec web python manage.py shell
>>> from django.conf import settings
>>> print(settings.STATIC_URL)
>>> print(settings.STATIC_ROOT)

# Verify static files exist
docker-compose exec web ls -la /code/staticfiles/

# Check nginx config (if using)
# Ensure static files are served correctly
```

### Forms Not Submitting

#### CSRF Token Issues
```bash
# Check if CSRF middleware is enabled
# In Django settings.py
MIDDLEWARE = [
    'django.middleware.csrf.CsrfViewMiddleware',
    # ... other middleware
]

# Clear browser cookies
# Refresh page and try again
```

#### Form Validation Errors
1. **Check browser console** for JavaScript errors
2. **Check network tab** for failed requests
3. **Verify form fields** are properly filled
4. **Check server logs** for validation errors

### File Upload Issues

#### Large File Upload Fails
```bash
# Check file size limits
# In Django settings.py
FILE_UPLOAD_MAX_MEMORY_SIZE = 5242880  # 5MB
DATA_UPLOAD_MAX_MEMORY_SIZE = 5242880  # 5MB

# Check nginx/web server limits
client_max_body_size 10M;
```

#### Permission Issues
```bash
# Check media directory permissions
docker-compose exec web ls -la /code/media/

# Fix permissions
docker-compose exec web chown -R www-data:www-data /code/media/
```

## 👤 Authentication Issues

### Can't Login

#### Forgot Credentials
```bash
# Create new superuser
docker-compose exec web python manage.py createsuperuser

# Reset user password
docker-compose exec web python manage.py shell
>>> from django.contrib.auth.models import User
>>> user = User.objects.get(username='admin')
>>> user.set_password('newpassword')
>>> user.save()
```

#### Session Issues
```bash
# Clear browser cookies and cache
# Or try incognito/private mode

# Check session settings
docker-compose exec web python manage.py shell
>>> from django.conf import settings
>>> print(settings.SESSION_ENGINE)
>>> print(settings.SESSION_COOKIE_AGE)
```

### User Not Staff/Admin

#### Make User Staff
```bash
# Using custom script
docker-compose exec web python make_staff.py

# Manual method
docker-compose exec web python manage.py shell
>>> from django.contrib.auth.models import User
>>> user = User.objects.get(username='username')
>>> user.is_staff = True
>>> user.save()
```

## 📱 Browser/UI Issues

### Page Layout Broken

#### CSS Not Loading
1. **Check static files** are collected
2. **Clear browser cache** (Ctrl+F5)
3. **Check browser console** for errors
4. **Try different browser** to isolate issue

#### Mobile Layout Issues
```css
/* Check responsive breakpoints */
/* In browser dev tools, test different screen sizes */

/* Common fixes in custom CSS */
@media (max-width: 768px) {
    .container {
        padding: 0 15px;
    }
}
```

### JavaScript Errors

#### Check Browser Console
1. **Open Developer Tools** (F12)
2. **Check Console tab** for errors
3. **Look for failed network requests**
4. **Check if JavaScript files loaded**

#### Common Fixes
```javascript
// If jQuery not loading
// Check if CDN is accessible
// Use local jQuery file if needed

// If Bootstrap JS not working
// Ensure proper order: jQuery first, then Bootstrap
```

## 📧 Email/Notification Issues

### Email Not Sending
*Note: Email features not yet implemented in v1.0.0*

Future troubleshooting for email features:
```python
# Email settings to check
EMAIL_BACKEND = 'django.core.mail.backends.smtp.EmailBackend'
EMAIL_HOST = 'smtp.gmail.com'
EMAIL_PORT = 587
EMAIL_USE_TLS = True
EMAIL_HOST_USER = 'your-email@gmail.com'
EMAIL_HOST_PASSWORD = 'your-app-password'
```

## 🔧 Performance Issues

### Application Running Slow

#### Check Resource Usage
```bash
# Monitor containers
docker stats

# Check system resources
htop
free -h
df -h
```

#### Database Performance
```bash
# Check database connections
docker-compose exec db mysql -u root -proot_password -e "SHOW PROCESSLIST;"

# Check table sizes
docker-compose exec db mysql -u root -proot_password room_usage_db -e "
SELECT 
    table_name AS 'Table',
    round(((data_length + index_length) / 1024 / 1024), 2) 'DB Size in MB'
FROM information_schema.tables 
WHERE table_schema='room_usage_db';"
```

#### Optimization Tips
```python
# Add database indexes (if needed)
class Meta:
    indexes = [
        models.Index(fields=['start_datetime']),
        models.Index(fields=['room', 'start_datetime']),
    ]

# Use select_related for foreign keys
bookings = Booking.objects.select_related('room', 'user').all()

# Add caching (future enhancement)
from django.core.cache import cache
```

## 🔄 Backup & Recovery

### Database Backup Failed
```bash
# Manual backup
docker-compose exec db mysqldump -u root -proot_password room_usage_db > backup_$(date +%Y%m%d_%H%M%S).sql

# Backup with compression
docker-compose exec db mysqldump -u root -proot_password room_usage_db | gzip > backup_$(date +%Y%m%d_%H%M%S).sql.gz

# Verify backup
gunzip -c backup_*.sql.gz | head -20
```

### Recovery from Backup
```bash
# Stop application
docker-compose down

# Start only database
docker-compose up -d db

# Wait for database to start
sleep 30

# Restore backup
gunzip -c backup_*.sql.gz | docker-compose exec -T db mysql -u root -proot_password room_usage_db

# Start application
docker-compose up -d
```

## 🚨 Emergency Recovery

### Complete System Reset
```bash
# ⚠️ WARNING: This will delete all data!

# Stop all containers
docker-compose down

# Remove all volumes (deletes data)
docker-compose down -v

# Remove all images
docker system prune -a

# Rebuild from scratch
docker-compose build --no-cache
docker-compose up -d

# Wait for initialization and load sample data
sleep 60
docker-compose exec web python manage.py load_sample_data
```

### Rollback to Previous Version
```bash
# If using Git tags
git checkout v1.0.0
docker-compose down
docker-compose build --no-cache
docker-compose up -d

# If using Docker image tags
# Edit docker-compose.yml to use previous image
image: room-booking:v1.0.0
```

## 📞 Getting Help

### Before Asking for Help

#### Gather Information
1. **What were you trying to do?**
2. **What actually happened?**
3. **Error messages** (exact text)
4. **Environment details** (OS, Docker version)
5. **Steps to reproduce**

#### Collect Logs
```bash
# All logs
docker-compose logs > system_logs.txt

# Web application logs
docker-compose logs web > web_logs.txt

# Database logs
docker-compose logs db > db_logs.txt

# System information
docker version > docker_info.txt
docker-compose version >> docker_info.txt
```

### Create GitHub Issue

#### Bug Report Template
```markdown
**Bug Description**
Brief description of the bug

**To Reproduce**
1. Step 1
2. Step 2
3. See error

**Expected Behavior**
What should have happened

**Environment**
- OS: [e.g. Ubuntu 20.04]
- Docker Version: [e.g. 20.10.12]
- Browser: [e.g. Chrome 96]

**Logs**
```
[Paste relevant logs here]
```

**Additional Context**
Any other information that might help
```

### Community Resources
- **GitHub Issues**: Bug reports and questions
- **Documentation**: Complete guides and references
- **Discord/Slack**: Real-time community help (if available)

---

## ✅ Prevention Tips

### Regular Maintenance
- **Weekly**: Check logs for errors
- **Monthly**: Update dependencies
- **Quarterly**: Review and test backups
- **Yearly**: Security audit and updates

### Monitoring Setup
```bash
# Set up log rotation
# Monitor disk space
# Set up health checks
# Monitor response times
```

### Best Practices
- **Always backup** before major changes
- **Test in staging** before production
- **Monitor logs** regularly
- **Keep documentation** updated
- **Version control** all changes

---

## 🆘 Still Need Help?

If this troubleshooting guide doesn't solve your issue:

1. **Search existing issues** on GitHub
2. **Check FAQ** for common questions
3. **Create detailed bug report** with logs
4. **Join community discussions** for help

**Remember**: The more details you provide, the better we can help you!
