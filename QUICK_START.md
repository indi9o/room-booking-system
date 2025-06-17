# 🚀 Quick Start Guide

## Clone & Setup (5 minutes)

```bash
# 1. Clone repository
git clone https://github.com/YOUR_USERNAME/room-booking-system.git
cd room-booking-system

# 2. Setup environment
cp .env.example .env

# 3. Start application
docker-compose up -d

# 4. Wait for setup (first time takes ~2 minutes)
docker-compose logs -f web

# 5. Access application
open http://localhost:8001
```

## Default Access

- **Web App**: http://localhost:8001
- **Admin Panel**: http://localhost:8001/admin
- **Username**: `admin`
- **Password**: `admin123` ⚠️ Change in production!

## External Access

Edit `.env` to add your server IP:
```env
ALLOWED_HOSTS=localhost,127.0.0.1,YOUR_SERVER_IP
CSRF_TRUSTED_ORIGINS=http://localhost:8001,http://YOUR_SERVER_IP:8001
```

Restart: `docker-compose restart web`

## Health Check

- **Basic**: http://localhost:8001/health/
- **Detailed**: http://localhost:8001/health/detailed/

## Troubleshooting

### Application not accessible
```bash
# Check container status
docker-compose ps

# Check logs
docker-compose logs web

# Restart if needed
docker-compose restart web
```

### CSRF Error (403)
```bash
# Check CSRF settings in .env
grep CSRF .env

# Ensure these are set for HTTP access:
CSRF_COOKIE_SECURE=False
SESSION_COOKIE_SECURE=False
```

### Port already in use
```bash
# Change port in .env
echo "WEB_PORT=8002" >> .env
docker-compose restart
```

## Security Note

🔐 **Before production deployment:**
1. Generate new SECRET_KEY
2. Set strong passwords
3. Configure proper ALLOWED_HOSTS
4. Enable HTTPS settings
5. Change default admin credentials

Read `SECURITY.md` for complete security guidelines.
