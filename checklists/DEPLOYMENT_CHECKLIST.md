# 🚀 Deployment Checklist

Checklist untuk deployment aplikasi Room Booking System.

## ✅ Pre-Deployment

### Environment Setup
- [ ] Copy `.env.production.template` ke `.env.production`
- [ ] Generate SECRET_KEY yang unik
- [ ] Set database credentials yang kuat
- [ ] Configure email settings
- [ ] Set proper ALLOWED_HOSTS
- [ ] Set DEBUG=False
- [ ] Configure logging paths

### Infrastructure
- [ ] Server/VPS ready dengan Docker installed
- [ ] Domain name configured (jika diperlukan)
- [ ] SSL certificate ready (jika menggunakan HTTPS)
- [ ] Firewall configured (port 80/443)
- [ ] Backup strategy in place

### Database
- [ ] Database server ready
- [ ] Database backup scheduled
- [ ] Database monitoring configured
- [ ] Connection testing successful

## ✅ Deployment Process

### Build & Test
- [ ] Docker build successful locally
- [ ] All tests passing
- [ ] Security scan passed
- [ ] Performance test completed

### Deploy Commands
```bash
# 1. Clone repository
git clone https://github.com/YOUR_USERNAME/room-booking-system.git
cd room-booking-system

# 2. Setup production environment
cp .env.production.template .env.production
# Edit .env.production with actual values

# 3. Deploy
./run-production.sh
```

### Verification
- [ ] Application accessible via web browser
- [ ] Admin panel working
- [ ] Database connections working
- [ ] Static files served correctly
- [ ] Email notifications working (if configured)
- [ ] Health checks passing

## ✅ Post-Deployment

### Security
- [ ] Change default admin credentials
- [ ] Remove development users
- [ ] Verify security headers
- [ ] Check SSL configuration
- [ ] Review access logs

### Monitoring
- [ ] Set up application monitoring
- [ ] Configure error alerting
- [ ] Set up log aggregation
- [ ] Monitor resource usage
- [ ] Test backup restoration

### Documentation
- [ ] Update deployment documentation
- [ ] Document admin procedures
- [ ] Create runbook for common issues
- [ ] Share access credentials with team

## 🔧 Troubleshooting

### Common Issues
1. **Container won't start**: Check environment variables and logs
2. **Database connection failed**: Verify DB credentials and network
3. **Static files not loading**: Check collectstatic and volume mounts
4. **Permission denied**: Verify user permissions and file ownership

### Debug Commands
```bash
# Check container status
docker-compose ps

# View logs
docker-compose logs -f web

# Access container shell
docker-compose exec web bash

# Check database connectivity
docker-compose exec web python manage.py dbshell
```

## 📋 Rollback Plan

If deployment fails:
```bash
# 1. Stop new deployment
docker-compose down

# 2. Restore from backup
# (restore database and files)

# 3. Deploy previous version
git checkout PREVIOUS_STABLE_TAG
./run-production.sh
```
