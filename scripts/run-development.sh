#!/bin/bash

# Room Booking System - Development Setup Script

set -e

echo "🔧 Starting Room Booking System in Development Mode"

# Check if .env exists, if not create from template
if [ ! -f ".env" ]; then
    echo "📋 Creating .env from template..."
    cp .env.template .env
    echo "✅ .env file created. You can edit it if needed."
fi

# Create logs directory if it doesn't exist
mkdir -p logs

echo "🔧 Building and starting containers..."
docker-compose up -d --build

echo "⏳ Waiting for services to be ready..."
sleep 10

# Check if services are running
echo "🔍 Checking service status..."
docker-compose ps

# Show logs for a few seconds
echo "📋 Recent logs:"
docker-compose logs --tail=20 web

echo "✅ Development environment ready!"
echo "🌐 Application available at: http://localhost:8001"
echo "📊 Monitor logs with: docker-compose logs -f web"
echo "🛑 Stop with: docker-compose down"
echo "🔄 Restart with: docker-compose restart web"
