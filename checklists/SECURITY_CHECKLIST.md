# 🔐 Security Checklist

Checklist keamanan sebelum deploy ke production atau upload ke GitHub.

## ✅ Pre-Upload Checklist

### Environment & Secrets
- [x] File `.env` ada di `.gitignore`
- [x] File `.env` tidak pernah di-commit ke git
- [x] Template `.env.template` dan `.env.production.template` tersedia
- [x] No hardcoded passwords di source code
- [x] SECRET_KEY menggunakan environment variable dengan default yang safe

### Docker Security
- [x] Container berjalan sebagai non-root user di production
- [x] `.dockerignore` mencegah file sensitive ter-copy
- [x] No environment secrets di Dockerfile
- [x] Health checks implemented

### Django Security
- [x] DEBUG=False di production template
- [x] ALLOWED_HOSTS dikonfigurasi dengan benar
- [x] Strong password validators
- [x] CSRF protection enabled
- [x] SQL injection protection (Django ORM)

## 🚨 Before Production Deployment

### Required Changes
- [ ] Generate unique SECRET_KEY: `python -c "from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())"`
- [ ] Set strong database passwords
- [ ] Configure proper ALLOWED_HOSTS
- [ ] Set up email configuration
- [ ] Change default admin credentials
- [ ] Enable HTTPS/SSL
- [ ] Set up proper logging
- [ ] Configure backup strategy

### Recommended Security Headers
```python
# Add to production settings
SECURE_SSL_REDIRECT = True
SECURE_HSTS_SECONDS = 31536000
SECURE_HSTS_INCLUDE_SUBDOMAINS = True
SECURE_HSTS_PRELOAD = True
SECURE_CONTENT_TYPE_NOSNIFF = True
SECURE_BROWSER_XSS_FILTER = True
X_FRAME_OPTIONS = 'DENY'
```

## 📋 File Security Status

| File | Status | Notes |
|------|--------|-------|
| `.env` | ✅ Safe | Ignored by git |
| `.env.template` | ✅ Safe | Template only, no real secrets |
| `.env.production.template` | ✅ Safe | Template only, no real secrets |
| `settings.py` | ✅ Safe | Uses environment variables |
| `docker-compose.yml` | ✅ Safe | Uses environment variables |
| Tests files | ✅ Safe | Only test credentials |

## 🔍 Security Commands

```bash
# Check for potential secrets in git history
git log --all --full-history -- .env

# Scan for potential passwords in code
grep -r -i "password.*=" --include="*.py" . | grep -v test

# Check file permissions
ls -la .env* 

# Verify .env is ignored
git check-ignore .env
```
