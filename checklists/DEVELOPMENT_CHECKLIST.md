# 🔄 Development Checklist

Checklist untuk development dan contribution guidelines.

## ✅ Development Setup

### Initial Setup
- [ ] Fork repository dari GitHub
- [ ] Clone repository ke local machine
- [ ] Copy `.env.template` ke `.env`
- [ ] Install Docker dan Docker Compose
- [ ] Run `./run-development.sh`
- [ ] Verify application running di http://localhost:8001

### Development Tools
- [ ] Code editor dengan Python extension (VSCode/PyCharm)
- [ ] Git configured dengan user name dan email
- [ ] Docker Desktop running
- [ ] Browser developer tools familiar

## ✅ Before Coding

### Branch Management
- [ ] Create feature branch dari `main`
- [ ] Branch name descriptive (e.g., `feature/booking-validation`)
- [ ] Pull latest changes dari upstream

### Code Style
- [ ] Familiar dengan Django conventions
- [ ] Understand project structure
- [ ] Read existing code untuk consistency
- [ ] Setup linting (jika ada)

## ✅ During Development

### Code Quality
- [ ] Follow Django best practices
- [ ] Write docstrings untuk functions/classes
- [ ] Add comments untuk complex logic
- [ ] Use meaningful variable names
- [ ] Follow existing code patterns

### Testing
- [ ] Write tests untuk new features
- [ ] Run existing tests: `python manage.py test`
- [ ] Test pada development server
- [ ] Test pada Docker environment
- [ ] Manual testing di browser

### Database Changes
- [ ] Create migrations: `python manage.py makemigrations`
- [ ] Review migration files
- [ ] Test migrations up dan down
- [ ] Document database changes

## ✅ Before Commit

### Code Review
- [ ] Remove debug prints dan commented code
- [ ] Check untuk hardcoded values
- [ ] Verify no sensitive data di code
- [ ] Remove unused imports
- [ ] Format code consistently

### Testing
- [ ] All tests passing
- [ ] No console errors di browser
- [ ] Application starts without errors
- [ ] New features working as expected
- [ ] No broken existing functionality

### Git Practices
- [ ] Meaningful commit message
- [ ] Atomic commits (one feature per commit)
- [ ] No large files di commit
- [ ] No `.env` files di commit

## ✅ Pull Request

### PR Preparation
- [ ] Branch up-to-date dengan main
- [ ] All tests passing
- [ ] Clear PR description
- [ ] Screenshots jika UI changes
- [ ] Link to related issues

### PR Content
- [ ] Title descriptive dan clear
- [ ] Description explains what dan why
- [ ] List of changes included
- [ ] Testing instructions provided
- [ ] Breaking changes documented

## 🧪 Testing Checklist

### Unit Tests
- [ ] Models tests
- [ ] Views tests
- [ ] Forms tests
- [ ] Utility functions tests

### Integration Tests
- [ ] API endpoints
- [ ] User workflows
- [ ] Admin functionality
- [ ] Authentication flows

### Manual Testing
- [ ] User registration dan login
- [ ] Room booking flow
- [ ] Admin panel functionality
- [ ] Responsive design
- [ ] Error handling

## 📝 Documentation

### Code Documentation
- [ ] Update docstrings
- [ ] Comment complex algorithms
- [ ] Update inline documentation
- [ ] API documentation (jika ada)

### User Documentation
- [ ] Update README jika diperlukan
- [ ] Update installation instructions
- [ ] Document new features
- [ ] Update FAQ jika applicable

## 🔍 Common Development Tasks

### Running Tests
```bash
# All tests
python manage.py test

# Specific app
python manage.py test rooms

# Specific test
python manage.py test rooms.tests.TestBookingModel

# With coverage
coverage run --source='.' manage.py test
coverage report
```

### Database Operations
```bash
# Make migrations
python manage.py makemigrations

# Apply migrations
python manage.py migrate

# Create superuser
python manage.py createsuperuser

# Load sample data
python manage.py load_sample_data
```

### Docker Development
```bash
# Start development environment
./run-development.sh

# View logs
docker-compose logs -f web

# Access container shell
docker-compose exec web bash

# Restart services
docker-compose restart web
```
