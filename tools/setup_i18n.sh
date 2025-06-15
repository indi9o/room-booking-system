#!/bin/bash

# 🌍 Internationalization Setup Script
# Room Booking System - Multi-language Support

echo "🌍 Setting up Internationalization for Room Booking System"
echo "========================================================="
echo ""

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if Django is available
echo -e "${BLUE}📋 Checking requirements...${NC}"
python -c "import django" 2>/dev/null
if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Django not found. Please activate your virtual environment.${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Django found${NC}"

# Create locale directories
echo -e "${BLUE}📁 Creating locale directories...${NC}"
mkdir -p locale/en/LC_MESSAGES
mkdir -p locale/id/LC_MESSAGES
mkdir -p locale/zh/LC_MESSAGES
mkdir -p locale/ja/LC_MESSAGES
mkdir -p locale/ko/LC_MESSAGES

echo -e "${GREEN}✅ Locale directories created${NC}"

# Generate translation files for each language
languages=("id" "zh" "ja" "ko")

for lang in "${languages[@]}"; do
    echo -e "${BLUE}🔄 Generating translation files for ${lang}...${NC}"
    python manage.py makemessages -l $lang --ignore=venv --ignore=staticfiles
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Translation files generated for ${lang}${NC}"
    else
        echo -e "${YELLOW}⚠️  Warning: Could not generate files for ${lang}${NC}"
    fi
done

# Generate JavaScript translation files
echo -e "${BLUE}🔄 Generating JavaScript translation files...${NC}"
python manage.py makemessages -d djangojs -l id --ignore=venv --ignore=staticfiles

# Compile existing translations
echo -e "${BLUE}⚙️  Compiling existing translations...${NC}"
python manage.py compilemessages

echo ""
echo -e "${GREEN}🎉 Internationalization setup complete!${NC}"
echo ""
echo -e "${YELLOW}📝 Next steps:${NC}"
echo "1. Edit translation files in locale/[language]/LC_MESSAGES/django.po"
echo "2. Run 'python manage.py compilemessages' after editing"
echo "3. Add {% load i18n %} to your templates"
echo "4. Use {% trans 'text' %} for translatable strings"
echo "5. Access translation interface at /rosetta/ (admin required)"
echo ""
echo -e "${BLUE}🔗 Useful commands:${NC}"
echo "  python manage.py makemessages -l [language]  # Generate new translations"
echo "  python manage.py compilemessages             # Compile translations"  
echo "  python manage.py runserver                   # Test with different languages"
echo ""
