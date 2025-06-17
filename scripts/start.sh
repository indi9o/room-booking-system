#!/bin/bash

# Room Booking System - Legacy Start Script
# This script is maintained for backward compatibility

echo "🔄 Redirecting to enhanced setup script..."
echo ""

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Redirect to setup.sh with all arguments
exec "$SCRIPT_DIR/setup.sh" "$@"