# 🏢 Room Booking System

![Django](https://img.shields.io/badge/Django-4.2.7-green) ![Python](https://img.shields.io/badge/Python-3.11-blue) ![MySQL](https://img.shields.io/badge/MySQL-8.0-orange) ![Docker](https://img.shields.io/badge/Docker-Compose-blue) ![Bootstrap](https://img.shields.io/badge/Bootstrap-5-purple)

A complete **Room Booking System** built with Django 4.2.7, MySQL 8.0, and Docker. This application provides a modern, responsive interface for managing room reservations with user authentication, admin panel, and comprehensive booking management.

## 🚀 Features

### 🏢 Core Functionality
- ✅ **Room Management**: Complete CRUD operations for rooms with capacity and facilities
- ✅ **Smart Booking System**: Conflict detection and validation
- ✅ **User Authentication**: Registration, login, and user management
- ✅ **Admin Panel**: Full administrative interface
- ✅ **Booking History**: Complete audit trail of all booking changes
- ✅ **Status Management**: Approval workflow (pending/approved/cancelled)
- ✅ **Staff Permissions**: Role-based access control for room management

### 🎨 User Interface
- ✅ **Responsive Design**: Bootstrap 5 based mobile-friendly UI
- ✅ **Modern Dashboard**: Intuitive homepage with room and booking overview
- ✅ **Form Validation**: Real-time validation with user-friendly feedback
- ✅ **File Upload**: Room image upload with validation
- ✅ **Search & Filter**: Advanced room and booking search capabilities

### 🛠 Technical Features
- ✅ **Environment Flexibility**: SQLite (development) and MySQL (production)
- ✅ **Docker Ready**: Complete containerization with docker-compose
- ✅ **Sample Data**: Pre-loaded demo data for testing
- ✅ **Static Files**: Optimized handling for CSS, JS, and media
- ✅ **Security**: CSRF protection, SQL injection prevention, secure authentication

## 📸 Screenshots

*Coming soon - Add screenshots of your application here*

## 🚀 Quick Start

### Prerequisites
- Docker & Docker Compose
- Git
- 8GB RAM (recommended)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/YOUR_USERNAME/room-booking-system.git
   cd room-booking-system
   ```

2. **Run with Docker (Recommended)**
   ```bash
   docker-compose up -d
   ```

3. **Access the application**
   - **Web Application**: http://localhost:8001
   - **Admin Panel**: http://localhost:8001/admin

### Default Login Credentials

#### Admin Access
```
Username: admin
Password: admin123
```

#### Sample Users
```
Username: user1, user2, user3
Password: password123
```

## 📋 Development Setup

### Local Development (SQLite)
```bash
# Create virtual environment
python -m venv venv
source venv/bin/activate  # Linux/Mac
# or
venv\Scripts\activate  # Windows

# Install dependencies
pip install -r requirements.txt

# Run migrations
python manage.py migrate

# Load sample data
python manage.py load_sample_data

# Create superuser
python manage.py createsuperuser

# Run development server
python manage.py runserver
```

### Production with Docker
```bash
# Build and run containers
docker-compose up -d

# Check logs
docker-compose logs web

# Stop containers
docker-compose down
```

## 🗂 Project Structure

```
room-booking-system/
├── 📁 room_usage_project/      # Django project settings
├── 📁 rooms/                   # Main application
│   ├── 📁 management/commands/ # Custom management commands
│   ├── 📁 migrations/          # Database migrations
│   ├── 📄 models.py           # Database models
│   ├── 📄 views.py            # Business logic
│   ├── 📄 forms.py            # Form definitions
│   ├── 📄 admin.py            # Admin configurations
│   └── 📄 urls.py             # URL routing
├── 📁 templates/              # HTML templates
├── 📄 requirements.txt        # Python dependencies
├── 📄 Dockerfile             # Docker image definition
├── 📄 docker-compose.yml     # Multi-container setup
├── 📄 docker-entrypoint.sh   # Container startup script
└── 📄 README.md              # This file
```

## 🎯 Usage Guide

### For Regular Users
1. **Register/Login** to access the system
2. **Browse Rooms** to see available spaces
3. **Create Booking** by selecting room, date, and time
4. **Manage Bookings** view, edit, or cancel your reservations

### For Staff/Admin
1. **Add New Rooms** with details and photos
2. **Manage Bookings** approve or reject booking requests
3. **User Management** via Django admin panel
4. **System Configuration** and maintenance

## 🔧 Configuration

### Environment Variables
Create a `.env` file in the root directory:

```env
DEBUG=1
SECRET_KEY=your-secret-key-here
DB_HOST=db
DB_NAME=room_usage_db
DB_USER=django_user
DB_PASSWORD=django_password
DB_PORT=3306
```

### Database Configuration
- **Development**: SQLite (automatic)
- **Production**: MySQL via Docker
- **Migrations**: Automatic via management commands

## 🛡 Security Features

- **CSRF Protection**: Django built-in CSRF protection
- **SQL Injection Protection**: Django ORM safeguards
- **Authentication**: Session-based user authentication
- **Password Security**: Django's built-in password hashing
- **File Upload Security**: Type and size validation
- **Access Control**: Role-based permissions

## 🚀 Deployment

### Docker Production
```bash
# Clone repository
git clone https://github.com/YOUR_USERNAME/room-booking-system.git
cd room-booking-system

# Start services
docker-compose up -d

# Check status
docker-compose ps
```

### Manual Deployment
See [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md) for detailed instructions.

## 🧪 Testing

```bash
# Run tests
python manage.py test

# Check code coverage
coverage run manage.py test
coverage report
```

## 📚 Documentation

- [Project Status](PROJECT_STATUS.md) - Current project status
- [Deployment Guide](DEPLOYMENT_GUIDE.md) - Deployment instructions
- [Add Room Feature](TAMBAH_RUANGAN_GUIDE.md) - Room management guide
- [Git Workflow](GIT_INFO.md) - Development workflow

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🏷 Version History

- **v1.0.0** - Initial release with complete booking system
  - Room management with CRUD operations
  - Booking system with conflict validation
  - User authentication and admin panel
  - Docker containerization
  - Bootstrap responsive UI

## 🙏 Acknowledgments

- Django framework for robust backend
- Bootstrap for responsive UI components
- MySQL for reliable data storage
- Docker for containerization
- FontAwesome for beautiful icons

## 📞 Support

If you have any questions or issues:

1. Check the [documentation](README.md)
2. Search [existing issues](https://github.com/YOUR_USERNAME/room-booking-system/issues)
3. Create a [new issue](https://github.com/YOUR_USERNAME/room-booking-system/issues/new)

---

**⭐ If you find this project helpful, please give it a star!**

Made with ❤️ using Django, MySQL, and Docker
