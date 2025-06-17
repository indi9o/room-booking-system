# 📋 Code Review Checklist

Checklist untuk code review dan quality assurance.

## ✅ General Code Quality

### Code Style & Structure
- [ ] Code follows Django conventions
- [ ] Consistent indentation (4 spaces)
- [ ] Meaningful variable dan function names
- [ ] No unused imports atau variables
- [ ] Proper use of whitespace
- [ ] Line length reasonable (<120 characters)

### Documentation
- [ ] Functions have docstrings
- [ ] Complex logic has comments
- [ ] Class documentation present
- [ ] API endpoints documented
- [ ] README updated jika diperlukan

## ✅ Django Specific

### Models
- [ ] Model fields have appropriate types
- [ ] Proper use of model relationships
- [ ] Model methods documented
- [ ] `__str__` methods defined
- [ ] Meta classes configured properly
- [ ] Database indexes considered

### Views
- [ ] Proper HTTP methods used
- [ ] Authentication/authorization implemented
- [ ] Input validation present
- [ ] Error handling implemented
- [ ] Proper status codes returned
- [ ] No business logic di templates

### Templates
- [ ] Template inheritance used properly
- [ ] No hardcoded URLs
- [ ] Proper use of template tags
- [ ] XSS protection considered
- [ ] Responsive design maintained
- [ ] Accessibility considerations

### Forms
- [ ] Form validation implemented
- [ ] Proper field types used
- [ ] Error messages user-friendly
- [ ] CSRF protection present
- [ ] Form rendering consistent

## ✅ Security Review

### Input Validation
- [ ] All user inputs validated
- [ ] SQL injection prevention
- [ ] XSS prevention
- [ ] File upload security
- [ ] Parameter tampering protection

### Authentication & Authorization
- [ ] Proper login/logout flow
- [ ] Permission checks implemented
- [ ] Session management secure
- [ ] Password policies enforced
- [ ] User roles properly checked

### Data Protection
- [ ] Sensitive data encrypted
- [ ] No passwords di logs
- [ ] Environment variables used
- [ ] No hardcoded secrets
- [ ] Database queries optimized

## ✅ Performance

### Database
- [ ] No N+1 query problems
- [ ] Proper use of select_related/prefetch_related
- [ ] Database indexes present
- [ ] Query optimization considered
- [ ] Bulk operations untuk large datasets

### Frontend
- [ ] Static files optimized
- [ ] Minimal JavaScript/CSS
- [ ] Image optimization
- [ ] Lazy loading considered
- [ ] Caching strategies implemented

## ✅ Testing

### Test Coverage
- [ ] Unit tests untuk new code
- [ ] Integration tests present
- [ ] Edge cases covered
- [ ] Error conditions tested
- [ ] Mock objects used appropriately

### Test Quality
- [ ] Tests are readable
- [ ] Tests are deterministic
- [ ] No test data leakage
- [ ] Proper setup/teardown
- [ ] Tests run independently

## ✅ Git & Deployment

### Commit Quality
- [ ] Atomic commits
- [ ] Clear commit messages
- [ ] No merge commits di feature branch
- [ ] No sensitive files committed
- [ ] Proper branch naming

### Migration Safety
- [ ] Migrations are reversible
- [ ] No data loss migrations
- [ ] Migration dependencies correct
- [ ] Migration tested locally
- [ ] Backward compatibility considered

## ✅ Pull Request Review

### PR Description
- [ ] Clear description of changes
- [ ] Linked to relevant issues
- [ ] Screenshots untuk UI changes
- [ ] Breaking changes documented
- [ ] Testing instructions provided

### Code Changes
- [ ] Changes are focused
- [ ] No unnecessary changes
- [ ] Proper file organization
- [ ] Dependencies updated jika needed
- [ ] Configuration changes documented

## 🔍 Review Tools & Commands

### Static Analysis
```bash
# Check for Python issues
flake8 .

# Security check
bandit -r .

# Import sorting
isort --check-only .

# Code formatting
black --check .
```

### Testing
```bash
# Run all tests
python manage.py test

# Test coverage
coverage run --source='.' manage.py test
coverage report
coverage html

# Performance testing
python manage.py test --debug-mode
```

### Database Review
```bash
# Check migrations
python manage.py showmigrations

# Explain queries
python manage.py shell
>>> from django.db import connection
>>> print(connection.queries)

# Check for migration issues
python manage.py makemigrations --check
```

## ❌ Common Issues to Watch For

### Security Red Flags
- Hardcoded passwords atau API keys
- Raw SQL queries tanpa sanitization
- File uploads tanpa validation
- User input di eval() atau exec()
- Missing authentication checks

### Performance Issues
- N+1 queries di loops
- Large database queries tanpa pagination
- Missing database indexes
- Synchronous calls ke external APIs
- Large file processing tanpa streaming

### Django Anti-patterns
- Logic di templates
- Fat controllers
- Direct database access di templates
- Circular imports
- Settings di code instead of environment

## ✅ Approval Criteria

### Must Have
- [ ] All tests passing
- [ ] Security review passed
- [ ] Performance acceptable
- [ ] Documentation complete
- [ ] No obvious bugs

### Nice to Have
- [ ] Code coverage improved
- [ ] Performance optimizations
- [ ] Additional test scenarios
- [ ] Improved error messages
- [ ] Better user experience
