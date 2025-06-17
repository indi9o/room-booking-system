# 🤝 Contributing to Room Booking System

Thank you for your interest in contributing to Room Booking System! This guide will help you get started with contributing to the project.

## 📋 Table of Contents

1. [Code of Conduct](#code-of-conduct)
2. [Getting Started](#getting-started)
3. [How to Contribute](#how-to-contribute)
4. [Development Workflow](#development-workflow)
5. [Coding Standards](#coding-standards)
6. [Testing Guidelines](#testing-guidelines)
7. [Documentation](#documentation)
8. [Pull Request Process](#pull-request-process)
9. [Issue Reporting](#issue-reporting)
10. [Community](#community)

## 📜 Code of Conduct

By participating in this project, you agree to abide by our Code of Conduct:

### Our Pledge
We pledge to make participation in our project a harassment-free experience for everyone, regardless of age, body size, disability, ethnicity, gender identity and expression, level of experience, education, socio-economic status, nationality, personal appearance, race, religion, or sexual identity and orientation.

### Our Standards
Examples of behavior that contributes to creating a positive environment include:
- Using welcoming and inclusive language
- Being respectful of differing viewpoints and experiences
- Gracefully accepting constructive criticism
- Focusing on what is best for the community
- Showing empathy towards other community members

### Unacceptable Behavior
Examples of unacceptable behavior include:
- The use of sexualized language or imagery
- Trolling, insulting/derogatory comments, and personal or political attacks
- Public or private harassment
- Publishing others' private information without explicit permission
- Other conduct which could reasonably be considered inappropriate in a professional setting

## 🚀 Getting Started

### Prerequisites
- Python 3.11+
- Docker & Docker Compose
- Git
- Code editor (VS Code recommended)

### Development Setup

1. **Fork the Repository**
   ```bash
   # Click "Fork" button on GitHub, then clone your fork
   git clone https://github.com/YOUR_USERNAME/room-booking-system.git
   cd room-booking-system
   ```

2. **Set Up Remote**
   ```bash
   git remote add upstream https://github.com/ORIGINAL_OWNER/room-booking-system.git
   ```

3. **Development Environment**
   ```bash
   # Option 1: Docker (Recommended)
   ./start.sh
   
   # Option 2: Local Development
   python -m venv venv
   source venv/bin/activate  # Linux/Mac
   pip install -r requirements.txt
   
   # Setup local database
   export DEBUG=True
   python manage.py migrate
   python manage.py createsuperuser
   python manage.py runserver
   ```

## 🛠️ How to Contribute

### Types of Contributions

1. **🐛 Bug Reports**: Help us identify and fix bugs
2. **✨ Feature Requests**: Suggest new features or enhancements
3. **💻 Code Contributions**: Submit bug fixes or new features
4. **📚 Documentation**: Improve or add documentation
5. **🧪 Testing**: Write tests or test the application
6. **🎨 UI/UX**: Improve user interface and experience
7. **🔧 DevOps**: Improve deployment, CI/CD, or infrastructure

### Areas Where Help is Needed

- 📱 Mobile responsiveness improvements
- 🔄 Recurring booking functionality
- 📊 Analytics and reporting features
- 🌐 Internationalization (i18n)
- 🔔 Notification system enhancements
- 📧 Email template improvements
- 🎨 UI/UX enhancements
- 🧪 Test coverage improvements
- 📖 Documentation updates

## 🔄 Development Workflow

### Branching Strategy

We use **Git Flow** branching model:

- `main`: Production-ready code
- `develop`: Integration branch for features
- `feature/*`: New features
- `bugfix/*`: Bug fixes
- `hotfix/*`: Critical production fixes

### Workflow Steps

1. **Create Feature Branch**
   ```bash
   git checkout develop
   git pull upstream develop
   git checkout -b feature/your-feature-name
   ```

2. **Make Changes**
   - Write code following our coding standards
   - Add tests for your changes
   - Update documentation if needed

3. **Test Your Changes**
   ```bash
   # Run tests
   python manage.py test
   
   # Check code style
   black .
   isort .
   flake8 .
   ```

4. **Commit Changes**
   ```bash
   git add .
   git commit -m "feat: add new booking feature"
   ```

5. **Push and Create PR**
   ```bash
   git push origin feature/your-feature-name
   # Create Pull Request on GitHub
   ```

## 📝 Coding Standards

### Python Code Style

We follow **PEP 8** with some modifications:

#### Formatting
- **Line Length**: 88 characters (Black default)
- **Indentation**: 4 spaces
- **String Quotes**: Prefer double quotes

#### Tools
```bash
# Auto-formatting
black .

# Import sorting
isort .

# Linting
flake8 .

# Type checking (optional)
mypy .
```

#### Example Code Style
```python
# Good
def create_booking(
    user: User,
    room: Room,
    start_time: datetime,
    end_time: datetime,
    title: str,
) -> Booking:
    """Create a new booking with validation."""
    if start_time >= end_time:
        raise ValueError("End time must be after start time")
    
    # Check for conflicts
    conflicts = Booking.objects.filter(
        room=room,
        start_time__lt=end_time,
        end_time__gt=start_time,
        status__in=["approved", "pending"]
    ).exists()
    
    if conflicts:
        raise ValidationError("Room is already booked for this time")
    
    return Booking.objects.create(
        user=user,
        room=room,
        start_time=start_time,
        end_time=end_time,
        title=title,
        status="pending"
    )
```

### Django Best Practices

#### Models
```python
class Room(models.Model):
    """Room model with proper field definitions."""
    
    name = models.CharField(max_length=100, help_text="Room name")
    capacity = models.PositiveIntegerField(help_text="Maximum capacity")
    is_active = models.BooleanField(default=True, help_text="Room is available for booking")
    
    class Meta:
        ordering = ["name"]
        verbose_name = "Room"
        verbose_name_plural = "Rooms"
    
    def __str__(self):
        return f"{self.name} (Capacity: {self.capacity})"
    
    def clean(self):
        """Custom validation."""
        if self.capacity <= 0:
            raise ValidationError("Capacity must be positive")
```

#### Views
```python
class BookingCreateView(LoginRequiredMixin, CreateView):
    """Create new booking view."""
    
    model = Booking
    form_class = BookingForm
    template_name = "rooms/create_booking.html"
    
    def form_valid(self, form):
        """Set user and validate booking."""
        form.instance.user = self.request.user
        try:
            return super().form_valid(form)
        except ValidationError as e:
            form.add_error(None, e.message)
            return self.form_invalid(form)
```

### Frontend Standards

#### HTML/Templates
```html
<!-- Use semantic HTML -->
<main class="container">
    <header class="page-header">
        <h1>{{ page_title }}</h1>
    </header>
    
    <section class="content">
        <!-- Content here -->
    </section>
</main>

<!-- Use proper form structure -->
<form method="post" novalidate>
    {% csrf_token %}
    
    <div class="form-group">
        <label for="{{ form.title.id_for_label }}" class="form-label">
            {{ form.title.label }}
        </label>
        {{ form.title }}
        {% if form.title.errors %}
            <div class="invalid-feedback">
                {{ form.title.errors.0 }}
            </div>
        {% endif %}
    </div>
</form>
```

#### CSS/Styling
```css
/* Use BEM methodology */
.room-card {
    border: 1px solid #ddd;
    border-radius: 8px;
}

.room-card__header {
    padding: 1rem;
    background-color: #f8f9fa;
}

.room-card__title {
    margin: 0;
    font-size: 1.25rem;
}

.room-card--featured {
    border-color: #007bff;
}

/* Use CSS custom properties */
:root {
    --primary-color: #007bff;
    --secondary-color: #6c757d;
    --success-color: #28a745;
    --danger-color: #dc3545;
}
```

## 🧪 Testing Guidelines

### Test Structure
```
rooms/
├── tests/
│   ├── __init__.py
│   ├── test_models.py
│   ├── test_views.py
│   ├── test_forms.py
│   └── test_utils.py
```

### Writing Tests
```python
# test_models.py
from django.test import TestCase
from django.contrib.auth.models import User
from django.core.exceptions import ValidationError
from rooms.models import Room, Booking

class BookingModelTest(TestCase):
    def setUp(self):
        self.user = User.objects.create_user(
            username='testuser',
            password='testpass'
        )
        self.room = Room.objects.create(
            name='Test Room',
            capacity=10
        )
    
    def test_booking_creation(self):
        """Test booking creation with valid data."""
        booking = Booking.objects.create(
            user=self.user,
            room=self.room,
            title='Test Meeting',
            start_time=timezone.now(),
            end_time=timezone.now() + timedelta(hours=1)
        )
        self.assertEqual(booking.status, 'pending')
    
    def test_booking_conflict_validation(self):
        """Test booking conflict detection."""
        # Create first booking
        start_time = timezone.now()
        end_time = start_time + timedelta(hours=1)
        
        Booking.objects.create(
            user=self.user,
            room=self.room,
            title='First Meeting',
            start_time=start_time,
            end_time=end_time
        )
        
        # Try to create conflicting booking
        with self.assertRaises(ValidationError):
            Booking.objects.create(
                user=self.user,
                room=self.room,
                title='Conflicting Meeting',
                start_time=start_time + timedelta(minutes=30),
                end_time=end_time + timedelta(minutes=30)
            )
```

### Test Commands
```bash
# Run all tests
python manage.py test

# Run specific test
python manage.py test rooms.tests.test_models.BookingModelTest

# Run with coverage
coverage run --source='.' manage.py test
coverage report
coverage html  # Generate HTML report
```

## 📚 Documentation

### Documentation Standards

1. **Code Comments**
   ```python
   def complex_function(param1: str, param2: int) -> dict:
       """
       Brief description of what the function does.
       
       Args:
           param1: Description of first parameter
           param2: Description of second parameter
       
       Returns:
           dict: Description of return value
       
       Raises:
           ValueError: When param2 is negative
           
       Example:
           >>> result = complex_function("test", 5)
           >>> print(result["status"])
           "success"
       """
   ```

2. **README Updates**
   - Update README.md if you add new features
   - Include setup instructions for new dependencies
   - Add examples for new functionality

3. **API Documentation**
   - Document new API endpoints in API.md
   - Include request/response examples
   - Document error codes and responses

### Documentation Files to Update

- `README.md`: Main project documentation
- `DOCUMENTATION.md`: Comprehensive user guide
- `DEVELOPER.md`: Developer-specific documentation
- `API.md`: API reference
- `DEPLOYMENT.md`: Deployment instructions
- `FAQ.md`: Frequently asked questions
- `CHANGELOG.md`: Version history

## 🔄 Pull Request Process

### PR Checklist

Before submitting a PR, ensure:

- [ ] Code follows project coding standards
- [ ] Tests are written and passing
- [ ] Documentation is updated
- [ ] Commit messages follow conventional format
- [ ] PR description is clear and detailed
- [ ] No merge conflicts exist
- [ ] Branch is up to date with target branch

### PR Template

```markdown
## Description
Brief description of changes made.

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing
- [ ] Tests pass locally
- [ ] New tests added for new functionality
- [ ] Manual testing completed

## Screenshots (if applicable)
Add screenshots here

## Checklist
- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] Documentation updated
- [ ] Tests added/updated
```

### Review Process

1. **Automated Checks**: CI/CD pipeline runs tests and checks
2. **Code Review**: Maintainers review code for quality and standards
3. **Testing**: Manual testing of new features
4. **Approval**: At least one maintainer approval required
5. **Merge**: Squash and merge into target branch

## 🐛 Issue Reporting

### Bug Reports

Use this template for bug reports:

```markdown
**Bug Description**
A clear description of the bug.

**Steps to Reproduce**
1. Go to '...'
2. Click on '...'
3. Scroll down to '...'
4. See error

**Expected Behavior**
What you expected to happen.

**Actual Behavior**
What actually happened.

**Screenshots**
If applicable, add screenshots.

**Environment**
- OS: [e.g. Ubuntu 22.04]
- Browser: [e.g. Chrome 119]
- Version: [e.g. 1.0.0]

**Additional Context**
Any other context about the problem.
```

### Feature Requests

Use this template for feature requests:

```markdown
**Feature Description**
A clear description of the feature you'd like to see.

**Problem Statement**
What problem does this feature solve?

**Proposed Solution**
How do you envision this feature working?

**Alternatives Considered**
Alternative solutions you've considered.

**Additional Context**
Any other context or screenshots.
```

## 🌟 Recognition

### Contributors

Contributors will be recognized in:
- README.md contributors section
- CHANGELOG.md for significant contributions
- Special mentions in release notes

### Types of Recognition

- **Code Contributors**: Added to contributors list
- **Documentation**: Recognized in documentation credits
- **Bug Reports**: Mentioned in bug fix credits
- **Feature Suggestions**: Credited in feature implementation

## 💬 Community

### Communication Channels

- **GitHub Issues**: Bug reports and feature requests
- **GitHub Discussions**: General discussions and questions
- **Pull Requests**: Code review and collaboration

### Getting Help

1. Check existing issues and documentation
2. Search closed issues for similar problems
3. Create new issue with detailed information
4. Join community discussions

### Mentorship

New contributors can:
- Look for "good first issue" labels
- Ask questions in issues or discussions
- Request code review and feedback
- Pair program with experienced contributors

---

## 📋 Quick Reference

### Commit Message Format
```
type(scope): description

Types: feat, fix, docs, style, refactor, test, chore
Examples:
- feat(booking): add recurring booking functionality
- fix(auth): resolve login redirect issue
- docs(api): update endpoint documentation
```

### Branch Naming
```
feature/description-of-feature
bugfix/description-of-bug
hotfix/critical-fix-description
docs/documentation-update
```

### Common Commands
```bash
# Setup
git clone https://github.com/YOUR_USERNAME/room-booking-system.git
cd room-booking-system
./start.sh

# Development
git checkout -b feature/my-feature
# ... make changes ...
python manage.py test
black .
isort .
git commit -m "feat: add my feature"
git push origin feature/my-feature

# Sync with upstream
git fetch upstream
git checkout develop
git merge upstream/develop
```

---

**🤝 Thank you for contributing to Room Booking System!**

Your contributions help make this project better for everyone. Whether you're fixing bugs, adding features, improving documentation, or helping other users, every contribution is valuable and appreciated.

*Happy coding! 🚀*
