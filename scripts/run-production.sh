#!/bin/bash

# Room Booking System - Production Deployment Script

set -e

echo "🚀 Starting Room Booking System in Production Mode"

# Check if .env.production exists
if [ ! -f ".env.production" ]; then
    echo "❌ Error: .env.production file not found!"
    echo "📋 Please copy .env.production.template to .env.production and configure it"
    echo "   cp .env.production.template .env.production"
    exit 1
fi

# Create logs directory if it doesn't exist
mkdir -p logs

# Set environment for production
export ENV_FILE=.env.production

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

echo "✅ Production deployment completed!"
echo "🌐 Application should be available at: http://localhost"
echo "📊 Monitor logs with: docker-compose logs -f web"
echo "🛑 Stop with: docker-compose down"
