FROM python:3.11-slim

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Set work directory
WORKDIR /code

# Install system dependencies (with conditional production tools)
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        default-mysql-client \
        pkg-config \
        default-libmysqlclient-dev \
        build-essential \
        curl \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user for security
RUN groupadd -r django && useradd --no-log-init -r -g django django

# Install Python dependencies
COPY requirements.txt /code/
RUN pip install --no-cache-dir -r requirements.txt

# Copy project
COPY . /code/

# Create necessary directories and set permissions
RUN mkdir -p /code/staticfiles /code/media /code/logs \
    && chown -R django:django /code \
    && chmod +x docker-entrypoint.sh

# Switch to non-root user (in production)
# USER directive will be handled by docker-compose or runtime

# Expose port
EXPOSE 8000

# Health check for production readiness
HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8000/ || exit 1

# Run the application
CMD ["./docker-entrypoint.sh"]
