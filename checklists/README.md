# 📋 Checklists Directory

Direktori ini berisi berbagai checklist untuk membantu development, deployment, dan maintenance aplikasi Room Booking System.

## 📁 Available Checklists

### 🔐 [Security Checklist](SECURITY_CHECKLIST.md)
Checklist keamanan sebelum deploy ke production atau upload ke GitHub:
- Environment & secrets management
- Docker security
- Django security settings
- Pre-production security requirements

### 🚀 [Deployment Checklist](DEPLOYMENT_CHECKLIST.md)
Checklist untuk deployment aplikasi ke production:
- Pre-deployment preparation
- Deployment process
- Post-deployment verification
- Troubleshooting guide

### 🔄 [Development Checklist](DEVELOPMENT_CHECKLIST.md)
Checklist untuk development dan contribution:
- Development setup
- Coding standards
- Testing procedures
- Git workflow

### 📋 [Code Review Checklist](CODE_REVIEW_CHECKLIST.md)
Checklist untuk code review dan quality assurance:
- Code quality standards
- Security review
- Performance considerations
- Django best practices

## 🎯 How to Use

1. **Before Starting Development**: Baca `DEVELOPMENT_CHECKLIST.md`
2. **Before Submitting Code**: Gunakan `CODE_REVIEW_CHECKLIST.md`
3. **Before Deployment**: Ikuti `DEPLOYMENT_CHECKLIST.md`
4. **Security Audit**: Gunakan `SECURITY_CHECKLIST.md`

## ✅ Quick Reference

### Daily Development
```bash
# Setup development
./run-development.sh

# Run tests
python manage.py test

# Check code quality
flake8 .
```

### Before Commit
```bash
# Run security checks
git check-ignore .env  # Should output .env

# Run tests
python manage.py test

# Check for secrets
grep -r "password" --include="*.py" . | grep -v test
```

### Before Deployment
```bash
# Security check
cp .env.production.template .env.production
# Edit .env.production

# Test build
docker build -t room-booking-test .

# Deploy
./run-production.sh
```

## 📚 Related Documentation

- [Security Documentation](../docs/SECURITY.md)
- [Deployment Guide](../docs/DEPLOYMENT.md)
- [Developer Guide](../docs/DEVELOPER.md)
- [Contributing Guidelines](../docs/CONTRIBUTING.md)

## 🔄 Maintenance

Checklist ini harus diupdate ketika:
- Ada perubahan di security requirements
- Framework atau dependencies diupdate
- Deployment process berubah
- Best practices terbaru diadopsi

## 📝 Contributing

Jika menemukan item yang missing atau outdated:
1. Create issue di GitHub
2. Submit pull request dengan update
3. Diskusi dengan team untuk approval
