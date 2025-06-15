# 🚀 Quick Start Guide

Panduan instalasi cepat untuk menjalankan Room Booking System dalam waktu kurang dari 5 menit!

## 📋 Prerequisites

### Minimum Requirements
- **Docker**: Version 20.10+
- **Docker Compose**: Version 2.0+
- **RAM**: 4GB (8GB recommended)
- **Disk Space**: 2GB free space

### Optional (for local development)
- **Python**: 3.11+
- **MySQL**: 8.0+ (optional, Docker included)

## ⚡ 30-Second Setup (Docker)

### 1. Clone Repository
```bash
git clone https://github.com/YOUR_USERNAME/room-booking-system.git
cd room-booking-system
```

### 2. Start Application
```bash
docker-compose up -d
```

### 3. Access Application
- **Web App**: http://localhost:8001
- **Admin Panel**: http://localhost:8001/admin

**That's it! 🎉**

## 🔑 Default Login Credentials

### Administrator
```
Username: admin
Password: admin123
```

### Sample Users
```
Username: user1, user2, user3
Password: password123
```

## 🎯 First Steps After Installation

### For End Users
1. **📝 Register Account**: Create your user account
2. **🏢 Browse Rooms**: Explore available rooms
3. **📅 Make Booking**: Reserve your first room
4. **✅ Manage Bookings**: View and manage your reservations

### For Administrators
1. **🔐 Login as Admin**: Use admin credentials above
2. **➕ Add Rooms**: Create new rooms with photos
3. **👥 Manage Users**: Approve/manage user accounts
4. **📊 Monitor System**: Check bookings and usage

## 🛠 Quick Commands Reference

### Docker Management
```bash
# Start services
docker-compose up -d

# Stop services
docker-compose down

# View logs
docker-compose logs web

# Restart specific service
docker-compose restart web

# Check status
docker-compose ps
```

### Application Management
```bash
# Access Django shell
docker-compose exec web python manage.py shell

# Create superuser
docker-compose exec web python manage.py createsuperuser

# Load sample data
docker-compose exec web python manage.py load_sample_data

# Make user staff
docker-compose exec web python make_staff.py
```

## 🔧 Configuration

### Environment Variables
Create `.env` file for custom configuration:
```env
DEBUG=1
SECRET_KEY=your-secret-key-here
DB_HOST=db
DB_NAME=room_usage_db
DB_USER=django_user
DB_PASSWORD=django_password
```

### Port Configuration
Default ports used:
- **Web Application**: 8001 → 8000 (container)
- **MySQL Database**: 3306 → 3306 (container)

To change web port, edit `docker-compose.yml`:
```yaml
ports:
  - "YOUR_PORT:8000"  # Change YOUR_PORT
```

## 🏥 Health Check

### Verify Installation
1. **Services Running**:
   ```bash
   docker-compose ps
   ```
   Should show both `web` and `db` as "Up"

2. **Web Access**: Visit http://localhost:8001
   - Should show homepage with room listings

3. **Database**: Check database connection
   ```bash
   docker-compose exec web python manage.py check --database default
   ```

4. **Admin Panel**: Visit http://localhost:8001/admin
   - Should show Django admin login

### Common Success Indicators
- ✅ Homepage loads with room listings
- ✅ Admin panel accessible
- ✅ Login/registration working
- ✅ Sample data loaded (5 rooms visible)
- ✅ No error messages in logs

## 🚨 Quick Troubleshooting

### Port Already in Use
```bash
# Check what's using port 8001
sudo lsof -i :8001

# Or change port in docker-compose.yml
```

### Container Won't Start
```bash
# Check logs for errors
docker-compose logs

# Rebuild containers
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```

### Database Connection Issues
```bash
# Restart database container
docker-compose restart db

# Check database logs
docker-compose logs db
```

### Permission Issues
```bash
# Fix file permissions
sudo chown -R $USER:$USER .
```

## 📱 Testing the Application

### Basic Functionality Test
1. **Home Page**: Navigate to homepage → Should show room grid
2. **User Registration**: Register new account → Should redirect to dashboard
3. **Room Booking**: Select room → Create booking → Should confirm reservation
4. **Admin Access**: Login as admin → Should access admin panel

### Advanced Testing
1. **Room Management**: Add new room with photo
2. **Booking Conflicts**: Try booking same room/time → Should prevent conflict
3. **User Management**: Manage users via admin panel
4. **Responsive Design**: Test on mobile device

## 🆘 Getting Help

### Documentation
- [Full Documentation](../DOCUMENTATION.md)
- [Troubleshooting Guide](../troubleshooting.md)
- [FAQ](../faq.md)

### Community Support
- **GitHub Issues**: Report bugs or request features
- **Discussions**: Ask questions and share experiences

### Development Support
- [Local Development Setup](local-development.md)
- [Project Structure](../development/project-structure.md)
- [Contributing Guide](../development/contributing.md)

---

## 🎉 Congratulations!

You've successfully set up Room Booking System! 

**Next Steps:**
- Explore [Features Documentation](../features/)
- Learn about [Room Management](../features/room-management.md)
- Discover [Advanced Configuration](../deployment/)

**🚀 Ready to book your first room? Let's go!**
