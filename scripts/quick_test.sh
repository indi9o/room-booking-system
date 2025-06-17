#!/bin/bash

# 🧪 Quick Deployment Test Script
# Simplified version for quick testing

echo "🧪 Quick Deployment Test - Room Booking System"
echo "=============================================="

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Test counter
PASS=0
FAIL=0

test_step() {
    echo -n "Testing $1... "
    if eval "$2" >/dev/null 2>&1; then
        echo -e "${GREEN}PASS${NC}"
        ((PASS++))
    else
        echo -e "${RED}FAIL${NC}"
        ((FAIL++))
    fi
}

echo
echo "📋 Step 1: Prerequisites"
test_step "Docker installed" "docker --version"
test_step "Docker Compose installed" "docker-compose --version"
test_step "Project files exist" "[ -f docker-compose.yml -a -f .env ]"

echo
echo "🏗️ Step 2: Building"
echo "Building application... (this may take a few minutes)"
docker-compose build >/dev/null 2>&1
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Build successful${NC}"
    ((PASS++))
else
    echo -e "${RED}❌ Build failed${NC}"
    ((FAIL++))
fi

echo
echo "🚀 Step 3: Deployment"
echo "Starting services..."
docker-compose up -d >/dev/null 2>&1
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Services started${NC}"
    ((PASS++))
else
    echo -e "${RED}❌ Service startup failed${NC}"
    ((FAIL++))
fi

echo "Waiting for services to be ready..."
sleep 30

echo
echo "🔍 Step 4: Health Checks"
test_step "Web container running" "docker-compose ps | grep -q 'Up'"
test_step "Database accessible" "docker-compose exec -T web python manage.py check --database default"

echo
echo "📡 Step 5: HTTP Tests"
test_step "Homepage accessible" "curl -f -s http://localhost:8001/"
test_step "Admin panel accessible" "curl -f -s http://localhost:8001/admin/"
test_step "API endpoints working" "curl -f -s http://localhost:8001/rooms/"

echo
echo "💾 Step 6: Database Tests"
echo "Running migrations..."
docker-compose exec -T web python manage.py migrate >/dev/null 2>&1
test_step "Migrations applied" "docker-compose exec -T web python manage.py showmigrations | grep -q '\[X\]'"

echo "Collecting static files..."
docker-compose exec -T web python manage.py collectstatic --noinput >/dev/null 2>&1
test_step "Static files collected" "docker-compose exec -T web ls staticfiles/admin/css/base.css"

echo
echo "📊 Final Results"
echo "================"
echo -e "Tests Passed: ${GREEN}$PASS${NC}"
echo -e "Tests Failed: ${RED}$FAIL${NC}"

if [ $FAIL -eq 0 ]; then
    echo
    echo -e "${GREEN}🎉 All tests passed! Deployment successful!${NC}"
    echo
    echo "🌐 Your application is running at:"
    echo "   Homepage: http://localhost:8001"
    echo "   Admin: http://localhost:8001/admin"
    echo
    echo "👤 Default admin login: admin / admin123"
    echo
    echo "📚 Next steps:"
    echo "   • Read user manual: docs/DOCUMENTATION.md"
    echo "   • Check FAQ: docs/FAQ.md"
    echo "   • See all docs: docs/README.md"
else
    echo
    echo -e "${RED}❌ Some tests failed. Check the logs above.${NC}"
    echo "🆘 Troubleshooting:"
    echo "   • Check docs/FAQ.md"
    echo "   • Run: docker-compose logs"
    echo "   • Restart: docker-compose restart"
fi
