# 🔒 Security Guide

Panduan keamanan untuk Room Booking System dalam environment production.

## 🛡️ Security Checklist

### Django Security Settings

#### 1. DEBUG Mode
```python
# settings.py
DEBUG = False  # NEVER True in production
```

#### 2. Secret Key
```python
# Generate strong secret key
SECRET_KEY = 'your-256-bit-secret-here'
```

#### 3. Allowed Hosts
```python
ALLOWED_HOSTS = ['yourdomain.com', 'www.yourdomain.com']
```

#### 4. HTTPS Settings
```python
# Force HTTPS
SECURE_SSL_REDIRECT = True
SECURE_PROXY_SSL_HEADER = ('HTTP_X_FORWARDED_PROTO', 'https')
SESSION_COOKIE_SECURE = True
CSRF_COOKIE_SECURE = True
```

### Database Security

#### 1. Strong Passwords
```env
DB_PASSWORD=Complex_Password_123!@#
MYSQL_ROOT_PASSWORD=Another_Strong_Password_456$%^
```

#### 2. User Permissions
```sql
-- Create dedicated user with limited permissions
CREATE USER 'django_user'@'%' IDENTIFIED BY 'strong_password';
GRANT SELECT, INSERT, UPDATE, DELETE ON room_usage_db.* TO 'django_user'@'%';
FLUSH PRIVILEGES;
```

#### 3. Database Access
```yaml
# docker-compose.yml - Don't expose MySQL port in production
services:
  db:
    ports: []  # Remove "3306:3306" mapping
```

### Application Security

#### 1. Input Validation
```python
# forms.py - Always validate user input
class BookingForm(forms.ModelForm):
    def clean_end_time(self):
        end_time = self.cleaned_data['end_time']
        start_time = self.cleaned_data.get('start_time')
        
        if start_time and end_time <= start_time:
            raise forms.ValidationError("End time must be after start time")
        
        return end_time
```

#### 2. SQL Injection Protection
```python
# Use Django ORM instead of raw SQL
Booking.objects.filter(room=room, start_time__lt=end_time, end_time__gt=start_time)

# If raw SQL needed, use parameterized queries
cursor.execute("SELECT * FROM rooms WHERE id = %s", [room_id])
```

#### 3. XSS Prevention
```html
<!-- Always escape user content -->
{{ user_content|escape }}

<!-- Use Django's built-in template filters -->
{{ booking.description|safe }}  <!-- Only for trusted content -->
```

#### 4. CSRF Protection
```html
<!-- Include CSRF token in all forms -->
<form method="post">
    {% csrf_token %}
    <!-- form fields -->
</form>
```

### File Upload Security

#### 1. File Type Validation
```python
# models.py
def validate_image_extension(value):
    allowed_extensions = ['.jpg', '.jpeg', '.png', '.gif']
    ext = os.path.splitext(value.name)[1]
    if ext.lower() not in allowed_extensions:
        raise ValidationError('Only image files are allowed.')

class Room(models.Model):
    image = models.ImageField(
        upload_to='rooms/',
        validators=[validate_image_extension],
        blank=True
    )
```

#### 2. File Size Limits
```python
# settings.py
FILE_UPLOAD_MAX_MEMORY_SIZE = 5242880  # 5MB
DATA_UPLOAD_MAX_MEMORY_SIZE = 5242880  # 5MB
```

### Docker Security

#### 1. Use Non-root User
```dockerfile
# Dockerfile
RUN adduser --disabled-password --gecos '' appuser
USER appuser
```

#### 2. Minimize Attack Surface
```dockerfile
# Use minimal base image
FROM python:3.11-slim

# Remove unnecessary packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*
```

#### 3. Security Scanning
```bash
# Scan Docker image for vulnerabilities
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
  projectdiscovery/nuclei -target docker://room-booking-system_web
```

### Network Security

#### 1. Firewall Configuration
```bash
# UFW firewall rules
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw enable
```

#### 2. Docker Network
```yaml
# docker-compose.yml
networks:
  internal:
    driver: bridge
    internal: true
  external:
    driver: bridge

services:
  web:
    networks:
      - internal
      - external
  db:
    networks:
      - internal  # Database only on internal network
```

### Environment Security

#### 1. Environment File Protection
```bash
# Set proper permissions
chmod 600 .env
chown root:root .env
```

#### 2. Secrets Management
```yaml
# docker-compose.yml - Use Docker secrets
version: '3.8'
services:
  web:
    secrets:
      - db_password
      - secret_key

secrets:
  db_password:
    file: ./secrets/db_password.txt
  secret_key:
    file: ./secrets/secret_key.txt
```

### Monitoring & Logging

#### 1. Enable Logging
```python
# settings.py
LOGGING = {
    'version': 1,
    'disable_existing_loggers': False,
    'handlers': {
        'file': {
            'level': 'WARNING',
            'class': 'logging.FileHandler',
            'filename': '/var/log/django/security.log',
        },
    },
    'loggers': {
        'django.security': {
            'handlers': ['file'],
            'level': 'WARNING',
            'propagate': True,
        },
    },
}
```

#### 2. Failed Login Monitoring
```python
# views.py
import logging
from django.contrib.auth.signals import user_login_failed

logger = logging.getLogger('django.security')

def log_failed_login(sender, credentials, **kwargs):
    logger.warning(f"Failed login attempt for username: {credentials.get('username')}")

user_login_failed.connect(log_failed_login)
```

### Regular Security Tasks

#### 1. Update Dependencies
```bash
# Check for security updates
pip list --outdated
pip install --upgrade package_name

# Security audit
pip install safety
safety check
```

#### 2. Database Backup Security
```bash
# Encrypt backups
gpg --symmetric --cipher-algo AES256 backup.sql
```

#### 3. SSL Certificate Renewal
```bash
# Setup auto-renewal for Let's Encrypt
echo "0 12 * * * /usr/bin/certbot renew --quiet" | sudo crontab -
```

## 🚨 Incident Response

### 1. Security Breach Detection
- Monitor unusual login patterns
- Check for unexpected admin users
- Review application logs regularly
- Monitor database access patterns

### 2. Response Steps
1. **Isolate**: Disconnect affected systems
2. **Assess**: Determine scope of breach
3. **Contain**: Prevent further damage
4. **Recover**: Restore from clean backups
5. **Learn**: Update security measures

### 3. Emergency Contacts
- System Administrator: admin@yourdomain.com
- Security Team: security@yourdomain.com
- Hosting Provider: support@hostingprovider.com

## 📋 Security Audit Checklist

- [ ] DEBUG = False in production
- [ ] Strong SECRET_KEY generated
- [ ] ALLOWED_HOSTS properly configured
- [ ] HTTPS enforced
- [ ] Strong database passwords
- [ ] Database port not exposed
- [ ] File upload validation enabled
- [ ] CSRF protection active
- [ ] XSS prevention measures
- [ ] Input validation implemented
- [ ] Logging configured
- [ ] Backups encrypted
- [ ] SSL certificates valid
- [ ] Dependencies updated
- [ ] Firewall configured
- [ ] Docker security measures

---

**⚠️ Security is an ongoing process. Review and update these measures regularly.**
