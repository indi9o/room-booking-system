# Docker Deployment Guide

## Unified Docker Configuration

Proyek ini menggunakan **satu Dockerfile dan satu docker-compose.yml** yang dapat digunakan untuk development dan production dengan konfigurasi yang berbeda melalui environment variables.

## Development

```bash
# Setup development environment
cp .env.template .env
# Edit .env jika diperlukan

# Menjalankan dalam mode development
docker-compose up -d
```

Environment akan otomatis menggunakan:
- `DEBUG=True`
- Django development server
- Container berjalan sebagai root user
- Port 8001
- Resource limits yang ringan

## Production

```bash
# Setup production environment
cp .env.production.template .env.production
# Edit .env.production dengan nilai yang sesuai

# Menjalankan dalam mode production
ENV_FILE=.env.production docker-compose up -d
```

Atau buat script untuk production:
```bash
# create scripts/run-production.sh
#!/bin/bash
export ENV_FILE=.env.production
docker-compose up -d
```

Production akan menggunakan:
- `DEBUG=False`
- Gunicorn production server
- Container berjalan sebagai django user (non-root)
- Port 80
- Resource limits yang optimal
- Health checks yang ketat

## Fitur Unified Docker Setup

### Keunggulan:
1. **Single Docker Compose** - Hanya satu file docker-compose.yml
2. **Environment Adaptive** - Konfigurasi berubah berdasarkan environment variables
3. **Flexible Configuration** - Semua aspek dapat dikonfigurasi via .env
4. **Resource Management** - Memory limits berbeda untuk dev/prod
5. **Security Ready** - Non-root user untuk production
6. **Health Monitoring** - Built-in health checks

### Configuration Variables

| Variable | Development | Production | Description |
|----------|-------------|------------|-------------|
| `DEBUG` | `True` | `False` | Django debug mode |
| `CONTAINER_USER` | `root` | `django` | Container user |
| `WEB_PORT` | `8001` | `80` | External port mapping |
| `CONTAINER_PREFIX` | `room_booking_dev` | `room_booking_prod` | Container name prefix |
| `ENV_FILE` | `.env` | `.env.production` | Environment file to use |
| `WEB_MEMORY_LIMIT` | `1G` | `2G` | Memory limit for web container |
| `HEALTH_INTERVAL` | `60s` | `30s` | Health check frequency |

### Commands

```bash
# Development
./scripts/run-development.sh

# Production (method 1)
ENV_FILE=.env.production docker-compose up -d

# Production (method 2)
./scripts/run-production.sh

# View logs
docker-compose logs -f web

# Scale workers (if needed)
docker-compose up -d --scale web=2
```

## Migration from Old Setup

Perubahan dari setup sebelumnya:
1. ✅ **Removed**: `docker-compose.production.yml` (tidak diperlukan)
2. ✅ **Unified**: Satu docker-compose.yml untuk semua environment
3. ✅ **Simplified**: Konfigurasi melalui environment variables saja
4. ✅ **Flexible**: Mudah switch antara development dan production

## Benefits

- **Simpler**: Hanya satu docker-compose file untuk maintain
- **Flexible**: Environment dapat dikonfigurasi tanpa mengubah docker-compose
- **Consistent**: Structure yang sama antara development dan production
- **Maintainable**: Tidak ada duplikasi konfigurasi
- **Scalable**: Mudah untuk menambah environment baru (staging, testing, dll)
