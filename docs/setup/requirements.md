# 💻 System Requirements

Persyaratan sistem untuk menjalankan Room Booking System dalam berbagai environment.

## 🐳 Docker Deployment (Recommended)

### Minimum Requirements
| Component | Minimum | Recommended |
|-----------|---------|-------------|
| **CPU** | 2 cores | 4 cores |
| **RAM** | 4GB | 8GB |
| **Storage** | 10GB | 20GB SSD |
| **Docker** | 20.10+ | Latest |
| **Docker Compose** | 2.0+ | Latest |

### Operating System Support
- ✅ **Linux**: Ubuntu 20.04+, CentOS 8+, Debian 11+
- ✅ **macOS**: 10.15+ with Docker Desktop
- ✅ **Windows**: Windows 10+ with Docker Desktop or WSL2

### Network Requirements
- **Port 8001**: Web application (configurable)
- **Port 3306**: MySQL database (internal, can be exposed)
- **Internet**: For Docker image downloads (~2GB initial)

## 🖥️ Local Development

### Python Environment
| Component | Version | Notes |
|-----------|---------|-------|
| **Python** | 3.11+ | 3.11.6 recommended |
| **pip** | 21.0+ | Latest version |
| **virtualenv** | Latest | For environment isolation |

### Database Options
#### SQLite (Development)
- ✅ **Built-in**: No additional setup required
- ✅ **Lightweight**: Perfect for development
- ⚠️ **Limited**: Not suitable for production

#### MySQL (Production-like)
| Component | Version | Notes |
|-----------|---------|-------|
| **MySQL Server** | 8.0+ | 8.0.35+ recommended |
| **MySQL Client** | 8.0+ | For mysqlclient Python package |

### Development Tools
| Tool | Purpose | Required |
|------|---------|----------|
| **Git** | Version control | ✅ Yes |
| **Node.js** | Frontend tools (optional) | ❌ No |
| **VS Code** | IDE (recommended) | ❌ No |

## 🌐 Production Environment

### Server Specifications
#### Small Deployment (< 100 users)
- **CPU**: 4 cores (2.5GHz+)
- **RAM**: 8GB
- **Storage**: 50GB SSD
- **Bandwidth**: 100Mbps

#### Medium Deployment (100-500 users)
- **CPU**: 8 cores (3.0GHz+)
- **RAM**: 16GB
- **Storage**: 100GB SSD
- **Bandwidth**: 500Mbps

#### Large Deployment (500+ users)
- **CPU**: 16+ cores (3.5GHz+)
- **RAM**: 32GB+
- **Storage**: 200GB+ SSD
- **Bandwidth**: 1Gbps+

### Operating System (Production)
#### Recommended Linux Distributions
- ✅ **Ubuntu Server**: 20.04 LTS or 22.04 LTS
- ✅ **CentOS**: 8+ or Rocky Linux 8+
- ✅ **Debian**: 11+ (Bullseye)
- ✅ **RHEL**: 8+

#### Container Orchestration (Optional)
- **Docker Swarm**: Built-in clustering
- **Kubernetes**: Advanced orchestration
- **Docker Compose**: Simple multi-container

### Web Server (Production)
#### Reverse Proxy Options
| Option | Complexity | Performance | Recommended |
|--------|------------|-------------|-------------|
| **Nginx** | Medium | High | ✅ Yes |
| **Apache** | Medium | Medium | ✅ Yes |
| **Traefik** | Low | High | ✅ Yes (Docker) |
| **Caddy** | Low | Medium | ⚠️ Optional |

### Database (Production)
#### MySQL Configuration
- **Version**: MySQL 8.0.35+
- **Storage Engine**: InnoDB
- **Character Set**: utf8mb4
- **Collation**: utf8mb4_unicode_ci

#### Database Sizing
| Users | Database Size | Connections |
|-------|---------------|-------------|
| < 100 | < 1GB | 20 |
| 100-500 | 1-5GB | 50 |
| 500+ | 5GB+ | 100+ |

## 🔒 Security Requirements

### SSL/TLS
- **Certificate**: Valid SSL certificate (Let's Encrypt recommended)
- **Protocol**: TLS 1.2+ only
- **Ciphers**: Strong cipher suites only

### Firewall
| Port | Purpose | Access |
|------|---------|--------|
| **80** | HTTP (redirect to HTTPS) | Public |
| **443** | HTTPS | Public |
| **22** | SSH | Admin only |
| **3306** | MySQL | Internal only |

### Backup Requirements
- **Database**: Daily automated backups
- **Files**: Media files backup
- **Storage**: 30 days retention minimum
- **Testing**: Regular restore testing

## 🌍 Browser Support

### Supported Browsers
| Browser | Minimum Version | Recommended |
|---------|----------------|-------------|
| **Chrome** | 90+ | Latest |
| **Firefox** | 88+ | Latest |
| **Safari** | 14+ | Latest |
| **Edge** | 90+ | Latest |

### Mobile Support
- ✅ **iOS Safari**: 14+
- ✅ **Android Chrome**: 90+
- ✅ **Samsung Internet**: 14+

### Features Required
- ✅ **JavaScript**: ES6+ support
- ✅ **CSS Grid**: Layout support
- ✅ **Fetch API**: HTTP requests
- ✅ **File API**: File uploads

## 📊 Performance Expectations

### Response Times (Target)
| Action | Target Time | Max Acceptable |
|--------|-------------|----------------|
| **Page Load** | < 2s | < 5s |
| **Form Submit** | < 1s | < 3s |
| **Search** | < 500ms | < 2s |
| **File Upload** | Variable | 30s max |

### Concurrent Users
| Environment | Users | Notes |
|-------------|-------|-------|
| **Development** | 1-5 | Local testing |
| **Staging** | 10-20 | Team testing |
| **Production** | Variable | Based on server specs |

## 🔧 Development Environment

### IDE Recommendations
#### VS Code Extensions
- **Python**: Official Python extension
- **Django**: Django template support
- **Docker**: Container management
- **GitLens**: Git integration
- **Prettier**: Code formatting

#### PyCharm
- **Professional**: Full Django support
- **Community**: Basic Python support

### Terminal/Shell
- **Linux/macOS**: bash, zsh, fish
- **Windows**: WSL2, PowerShell, Git Bash

## 📦 Installation Dependencies

### Python Packages (requirements.txt)
```
Django==4.2.7
mysqlclient==2.2.0
python-decouple==3.8
Pillow==10.0.1
django-crispy-forms==2.0
crispy-bootstrap5==0.7
django-bootstrap-datepicker-plus==5.0.4
```

### System Packages (Ubuntu/Debian)
```bash
sudo apt update
sudo apt install -y python3-dev python3-pip python3-venv
sudo apt install -y default-libmysqlclient-dev build-essential
sudo apt install -y docker.io docker-compose
```

### System Packages (CentOS/RHEL)
```bash
sudo yum update
sudo yum install -y python3-devel python3-pip
sudo yum install -y mysql-devel gcc gcc-c++
sudo yum install -y docker docker-compose
```

## ✅ Pre-Installation Checklist

### Before Starting
- [ ] Server meets minimum requirements
- [ ] Operating system is up to date
- [ ] Required ports are available
- [ ] Internet connection is stable
- [ ] Backup strategy is planned (production)

### Security Checklist
- [ ] Firewall configured
- [ ] SSH key authentication setup
- [ ] SSL certificate ready (production)
- [ ] Database credentials secured
- [ ] Environment variables configured

### Networking Checklist
- [ ] Domain name configured (production)
- [ ] DNS records set up
- [ ] Load balancer configured (if needed)
- [ ] CDN set up (optional)

---

## 🚀 Ready to Install?

Once your system meets these requirements, proceed to:
- [Quick Start Guide](quick-start.md) - For immediate setup
- [Docker Setup](docker-setup.md) - Detailed Docker installation
- [Local Development](local-development.md) - Development environment

**Need help choosing? Start with [Quick Start Guide](quick-start.md) for the fastest setup!**
