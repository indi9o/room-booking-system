#!/bin/bash

# 🚀 Performance Testing Script for Room Booking System
# This script performs comprehensive performance testing and health checks

set -e

echo "🚀 Room Booking System - Performance Testing"
echo "============================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
APP_URL="http://localhost:8001"
ADMIN_URL="$APP_URL/admin/"
HEALTH_URL="$APP_URL/health/"
METRICS_URL="$APP_URL/metrics/"

# Performance thresholds (in milliseconds)
THRESHOLD_FAST=500
THRESHOLD_ACCEPTABLE=2000
THRESHOLD_SLOW=5000

# Test counters
TESTS_TOTAL=0
TESTS_PASSED=0
TESTS_FAILED=0

# Function to print colored output
print_status() {
    local status=$1
    local message=$2
    
    case $status in
        "PASS")
            echo -e "${GREEN}✅ PASS${NC}: $message"
            ((TESTS_PASSED++))
            ;;
        "FAIL")
            echo -e "${RED}❌ FAIL${NC}: $message"
            ((TESTS_FAILED++))
            ;;
        "WARN")
            echo -e "${YELLOW}⚠️  WARN${NC}: $message"
            ;;
        "INFO")
            echo -e "${BLUE}ℹ️  INFO${NC}: $message"
            ;;
    esac
    ((TESTS_TOTAL++))
}

# Function to measure response time
measure_response_time() {
    local url=$1
    local description=$2
    local max_time=${3:-$THRESHOLD_ACCEPTABLE}
    
    echo -n "Testing $description... "
    
    # Measure response time using curl
    local response_time=$(curl -o /dev/null -s -w "%{time_total}\n" --max-time 10 "$url" 2>/dev/null || echo "ERROR")
    
    if [ "$response_time" = "ERROR" ]; then
        print_status "FAIL" "$description - Connection failed or timeout"
        return 1
    fi
    
    # Convert to milliseconds
    local response_ms=$(echo "$response_time * 1000" | bc -l | cut -d. -f1)
    
    echo "${response_ms}ms"
    
    if [ "$response_ms" -lt "$THRESHOLD_FAST" ]; then
        print_status "PASS" "$description - Excellent performance (${response_ms}ms)"
    elif [ "$response_ms" -lt "$max_time" ]; then
        print_status "PASS" "$description - Acceptable performance (${response_ms}ms)"
    elif [ "$response_ms" -lt "$THRESHOLD_SLOW" ]; then
        print_status "WARN" "$description - Slow performance (${response_ms}ms)"
    else
        print_status "FAIL" "$description - Unacceptable performance (${response_ms}ms)"
        return 1
    fi
    
    return 0
}

# Function to check service availability
check_service_availability() {
    echo ""
    echo "🔍 Checking Service Availability"
    echo "--------------------------------"
    
    # Check if application is running
    if curl -s "$APP_URL" > /dev/null; then
        print_status "PASS" "Application is accessible at $APP_URL"
    else
        print_status "FAIL" "Application is not accessible at $APP_URL"
        echo ""
        echo "💡 Make sure the application is running:"
        echo "   docker-compose up -d"
        echo "   OR"
        echo "   python manage.py runserver 8001"
        exit 1
    fi
    
    # Check health endpoint
    if curl -s "$HEALTH_URL" > /dev/null; then
        print_status "PASS" "Health endpoint is accessible"
        
        # Check health status
        local health_status=$(curl -s "$HEALTH_URL" | grep -o '"status":"[^"]*"' | cut -d'"' -f4)
        if [ "$health_status" = "healthy" ]; then
            print_status "PASS" "Application health status: $health_status"
        else
            print_status "FAIL" "Application health status: $health_status"
        fi
    else
        print_status "WARN" "Health endpoint not accessible - may not be implemented yet"
    fi
}

# Function to test page performance
test_page_performance() {
    echo ""
    echo "⚡ Testing Page Performance"
    echo "---------------------------"
    
    # Test homepage
    measure_response_time "$APP_URL" "Homepage" $THRESHOLD_ACCEPTABLE
    
    # Test rooms list page
    measure_response_time "$APP_URL/rooms/" "Rooms list page" $THRESHOLD_ACCEPTABLE
    
    # Test admin page (will redirect to login, but still tests performance)
    measure_response_time "$ADMIN_URL" "Admin login page" $THRESHOLD_ACCEPTABLE
    
    # Test static file (CSS)
    measure_response_time "$APP_URL/static/css/style.css" "Static CSS file" $THRESHOLD_FAST
}

# Function to test API endpoints
test_api_endpoints() {
    echo ""
    echo "🔌 Testing API Endpoints"
    echo "------------------------"
    
    # Test health endpoint performance
    if curl -s "$HEALTH_URL" > /dev/null; then
        measure_response_time "$HEALTH_URL" "Health check endpoint" $THRESHOLD_FAST
        
        # Test detailed health endpoint
        measure_response_time "$APP_URL/health/detailed/" "Detailed health endpoint" $THRESHOLD_ACCEPTABLE
    else
        print_status "WARN" "Health endpoints not available - skipping API tests"
    fi
    
    # Test metrics endpoint if available
    if curl -s "$METRICS_URL" > /dev/null; then
        measure_response_time "$METRICS_URL" "Metrics endpoint" $THRESHOLD_FAST
    else
        print_status "WARN" "Metrics endpoint not available"
    fi
}

# Function to test under load
test_load_performance() {
    echo ""
    echo "🏋️  Basic Load Testing"
    echo "----------------------"
    
    if ! command -v ab &> /dev/null; then
        print_status "WARN" "Apache Bench (ab) not installed - skipping load tests"
        echo "       Install with: sudo apt-get install apache2-utils"
        return
    fi
    
    print_status "INFO" "Running concurrent request test (10 requests, 2 concurrent)"
    
    # Test with 10 requests, 2 concurrent users
    local ab_result=$(ab -n 10 -c 2 -q "$APP_URL" 2>/dev/null | grep "Time per request" | head -1 | awk '{print $4}')
    
    if [ ! -z "$ab_result" ]; then
        local avg_time_ms=$(echo "$ab_result" | cut -d. -f1)
        
        if [ "$avg_time_ms" -lt "$THRESHOLD_ACCEPTABLE" ]; then
            print_status "PASS" "Average response time under load: ${avg_time_ms}ms"
        else
            print_status "WARN" "Average response time under load: ${avg_time_ms}ms (consider optimization)"
        fi
    else
        print_status "WARN" "Could not measure load performance"
    fi
}

# Function to check database performance
test_database_performance() {
    echo ""
    echo "🗄️  Database Performance Check"
    echo "------------------------------"
    
    if [ -f "manage.py" ]; then
        print_status "INFO" "Checking database connectivity"
        
        # Test database connection
        if python manage.py check --database default 2>/dev/null; then
            print_status "PASS" "Database connection successful"
        else
            print_status "FAIL" "Database connection failed"
        fi
        
        # Test migrations
        if python manage.py showmigrations --verbosity=0 2>/dev/null | grep -q "\[X\]"; then
            print_status "PASS" "Database migrations are applied"
        else
            print_status "WARN" "Some migrations may not be applied"
        fi
    else
        print_status "WARN" "Not in Django project directory - skipping database tests"
    fi
}

# Function to check security headers
test_security_headers() {
    echo ""
    echo "🔒 Security Headers Check"
    echo "-------------------------"
    
    local headers=$(curl -I -s "$APP_URL" 2>/dev/null)
    
    # Check for security headers
    if echo "$headers" | grep -i "X-Content-Type-Options" > /dev/null; then
        print_status "PASS" "X-Content-Type-Options header present"
    else
        print_status "WARN" "X-Content-Type-Options header missing"
    fi
    
    if echo "$headers" | grep -i "X-Frame-Options" > /dev/null; then
        print_status "PASS" "X-Frame-Options header present"
    else
        print_status "WARN" "X-Frame-Options header missing"
    fi
    
    if echo "$headers" | grep -i "X-XSS-Protection" > /dev/null; then
        print_status "PASS" "X-XSS-Protection header present"
    else
        print_status "WARN" "X-XSS-Protection header missing"
    fi
}

# Function to generate performance report
generate_report() {
    echo ""
    echo "📊 Performance Test Summary"
    echo "==========================="
    echo ""
    echo "Total Tests: $TESTS_TOTAL"
    echo -e "Passed: ${GREEN}$TESTS_PASSED${NC}"
    echo -e "Failed: ${RED}$TESTS_FAILED${NC}"
    echo ""
    
    local success_rate=$((TESTS_PASSED * 100 / TESTS_TOTAL))
    
    if [ "$success_rate" -ge 90 ]; then
        echo -e "Overall Performance: ${GREEN}Excellent ($success_rate%)${NC}"
        echo "✅ System is performing well and ready for production"
    elif [ "$success_rate" -ge 75 ]; then
        echo -e "Overall Performance: ${YELLOW}Good ($success_rate%)${NC}"
        echo "⚠️  System is performing adequately with minor issues"
    elif [ "$success_rate" -ge 50 ]; then
        echo -e "Overall Performance: ${YELLOW}Fair ($success_rate%)${NC}"
        echo "⚠️  System has performance issues that should be addressed"
    else
        echo -e "Overall Performance: ${RED}Poor ($success_rate%)${NC}"
        echo "❌ System has significant performance issues requiring immediate attention"
    fi
    
    echo ""
    echo "📚 For more information:"
    echo "   - Documentation: docs/"
    echo "   - Troubleshooting: docs/troubleshooting.md"
    echo "   - Performance tuning: docs/deployment/production.md"
}

# Main execution
main() {
    # Check dependencies
    if ! command -v curl &> /dev/null; then
        echo "❌ curl is required but not installed. Please install curl first."
        exit 1
    fi
    
    if ! command -v bc &> /dev/null; then
        echo "❌ bc is required but not installed. Please install bc first."
        exit 1
    fi
    
    # Run all tests
    check_service_availability
    test_page_performance
    test_api_endpoints
    test_load_performance
    test_database_performance
    test_security_headers
    
    # Generate final report
    generate_report
}

# Check if running with specific test
case "$1" in
    "quick")
        echo "🚀 Running Quick Performance Test"
        check_service_availability
        test_page_performance
        generate_report
        ;;
    "load")
        echo "🚀 Running Load Test Only"
        test_load_performance
        ;;
    "security")
        echo "🚀 Running Security Test Only"
        test_security_headers
        ;;
    "help"|"-h"|"--help")
        echo "Usage: $0 [option]"
        echo ""
        echo "Options:"
        echo "  (no option) - Run all tests"
        echo "  quick       - Run basic performance tests only"
        echo "  load        - Run load tests only"
        echo "  security    - Run security header tests only"
        echo "  help        - Show this help message"
        echo ""
        echo "Examples:"
        echo "  ./tools/performance_test.sh        # Full test suite"
        echo "  ./tools/performance_test.sh quick  # Quick test"
        ;;
    *)
        main
        ;;
esac
