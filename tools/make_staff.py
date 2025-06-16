#!/usr/bin/env python3
"""
Make Staff User Script
======================
Script untuk membuat user staff dalam Room Booking System.
Supports both interactive and batch mode.
"""

import os
import sys
import django
from pathlib import Path

# Add the project directory to Python path
project_dir = Path(__file__).parent.parent
sys.path.insert(0, str(project_dir))

# Setup Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'room_usage_project.settings')
django.setup()

from django.contrib.auth.models import User
from django.core.exceptions import ValidationError
from django.db import IntegrityError
import getpass
import argparse
import json

class Colors:
    """ANSI color codes for terminal output"""
    RED = '\033[91m'
    GREEN = '\033[92m'
    YELLOW = '\033[93m'
    BLUE = '\033[94m'
    MAGENTA = '\033[95m'
    CYAN = '\033[96m'
    WHITE = '\033[97m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'
    END = '\033[0m'

def print_banner():
    """Print application banner"""
    print(f"{Colors.CYAN}{Colors.BOLD}")
    print("╔═══════════════════════════════════════════════════════════════╗")
    print("║                    Room Booking System                       ║")
    print("║                   Make Staff User Tool                       ║")
    print("╚═══════════════════════════════════════════════════════════════╝")
    print(f"{Colors.END}")

def log_success(message):
    """Print success message"""
    print(f"{Colors.GREEN}✅ {message}{Colors.END}")

def log_error(message):
    """Print error message"""
    print(f"{Colors.RED}❌ {message}{Colors.END}")

def log_warning(message):
    """Print warning message"""
    print(f"{Colors.YELLOW}⚠️  {message}{Colors.END}")

def log_info(message):
    """Print info message"""
    print(f"{Colors.BLUE}ℹ️  {message}{Colors.END}")

def validate_email(email):
    """Basic email validation"""
    import re
    pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    return re.match(pattern, email) is not None

def create_staff_user(username, email, password, first_name="", last_name="", is_superuser=False):
    """
    Create a staff user with given parameters
    
    Args:
        username (str): Username
        email (str): Email address
        password (str): Password
        first_name (str): First name (optional)
        last_name (str): Last name (optional)
        is_superuser (bool): Make user superuser (default: False)
    
    Returns:
        tuple: (success: bool, message: str, user: User|None)
    """
    try:
        # Check if user already exists
        if User.objects.filter(username=username).exists():
            return False, f"User '{username}' already exists", None
        
        if User.objects.filter(email=email).exists():
            return False, f"Email '{email}' is already in use", None
        
        # Validate email format
        if email and not validate_email(email):
            return False, f"Invalid email format: {email}", None
        
        # Create user
        user = User.objects.create_user(
            username=username,
            email=email,
            password=password,
            first_name=first_name,
            last_name=last_name
        )
        
        # Set staff status
        user.is_staff = True
        
        # Set superuser status if requested
        if is_superuser:
            user.is_superuser = True
        
        user.save()
        
        user_type = "superuser" if is_superuser else "staff"
        return True, f"{user_type.title()} user '{username}' created successfully", user
        
    except IntegrityError as e:
        return False, f"Database error: {str(e)}", None
    except ValidationError as e:
        return False, f"Validation error: {str(e)}", None
    except Exception as e:
        return False, f"Unexpected error: {str(e)}", None

def interactive_mode():
    """Interactive mode for creating staff users"""
    print(f"{Colors.BOLD}Interactive Staff User Creation{Colors.END}\n")
    
    try:
        # Get user input
        username = input("Username: ").strip()
        if not username:
            log_error("Username cannot be empty")
            return False
        
        email = input("Email: ").strip()
        if not email:
            log_error("Email cannot be empty")
            return False
        
        first_name = input("First Name (optional): ").strip()
        last_name = input("Last Name (optional): ").strip()
        
        # Get password securely
        while True:
            password = getpass.getpass("Password: ")
            if len(password) < 8:
                log_warning("Password should be at least 8 characters long")
                continue
            
            password_confirm = getpass.getpass("Confirm Password: ")
            if password != password_confirm:
                log_error("Passwords don't match. Please try again.")
                continue
            break
        
        # Ask for superuser status
        superuser_input = input("Make this user a superuser? (y/N): ").strip().lower()
        is_superuser = superuser_input in ['y', 'yes']
        
        # Create user
        success, message, user = create_staff_user(
            username=username,
            email=email,
            password=password,
            first_name=first_name,
            last_name=last_name,
            is_superuser=is_superuser
        )
        
        if success:
            log_success(message)
            print(f"\n{Colors.BOLD}User Details:{Colors.END}")
            print(f"Username: {user.username}")
            print(f"Email: {user.email}")
            print(f"Full Name: {user.get_full_name() or 'Not provided'}")
            print(f"Staff: {user.is_staff}")
            print(f"Superuser: {user.is_superuser}")
            print(f"Date Joined: {user.date_joined}")
            return True
        else:
            log_error(message)
            return False
            
    except KeyboardInterrupt:
        print(f"\n{Colors.YELLOW}Operation cancelled by user{Colors.END}")
        return False
    except Exception as e:
        log_error(f"Unexpected error: {str(e)}")
        return False

def batch_mode(users_data):
    """
    Batch mode for creating multiple staff users
    
    Args:
        users_data (list): List of user dictionaries
    """
    print(f"{Colors.BOLD}Batch Staff User Creation{Colors.END}\n")
    
    results = []
    total_users = len(users_data)
    
    for i, user_data in enumerate(users_data, 1):
        print(f"Creating user {i}/{total_users}: {user_data.get('username', 'Unknown')}")
        
        success, message, user = create_staff_user(
            username=user_data.get('username'),
            email=user_data.get('email'),
            password=user_data.get('password'),
            first_name=user_data.get('first_name', ''),
            last_name=user_data.get('last_name', ''),
            is_superuser=user_data.get('is_superuser', False)
        )
        
        if success:
            log_success(message)
        else:
            log_error(message)
        
        results.append({
            'username': user_data.get('username'),
            'success': success,
            'message': message
        })
    
    # Print summary
    print(f"\n{Colors.BOLD}Batch Creation Summary:{Colors.END}")
    successful = sum(1 for r in results if r['success'])
    failed = total_users - successful
    
    print(f"Total users: {total_users}")
    print(f"{Colors.GREEN}Successful: {successful}{Colors.END}")
    if failed > 0:
        print(f"{Colors.RED}Failed: {failed}{Colors.END}")
    
    return results

def list_staff_users():
    """List all existing staff users"""
    print(f"{Colors.BOLD}Existing Staff Users:{Colors.END}\n")
    
    staff_users = User.objects.filter(is_staff=True).order_by('username')
    
    if not staff_users.exists():
        log_info("No staff users found")
        return
    
    print(f"{'Username':<20} {'Email':<30} {'Name':<25} {'Superuser':<10} {'Active':<8}")
    print("-" * 95)
    
    for user in staff_users:
        full_name = user.get_full_name() or 'Not provided'
        superuser = '✅' if user.is_superuser else '❌'
        active = '✅' if user.is_active else '❌'
        
        print(f"{user.username:<20} {user.email:<30} {full_name:<25} {superuser:<10} {active:<8}")

def modify_user_permissions(username, action):
    """
    Modify user permissions
    
    Args:
        username (str): Username to modify
        action (str): 'promote' to make staff, 'demote' to remove staff, 'super' to make superuser
    """
    try:
        user = User.objects.get(username=username)
        
        if action == 'promote':
            user.is_staff = True
            user.save()
            log_success(f"User '{username}' promoted to staff")
        elif action == 'demote':
            user.is_staff = False
            user.is_superuser = False  # Remove superuser if demoting staff
            user.save()
            log_success(f"User '{username}' demoted from staff")
        elif action == 'super':
            user.is_staff = True  # Superuser must be staff
            user.is_superuser = True
            user.save()
            log_success(f"User '{username}' promoted to superuser")
        else:
            log_error(f"Unknown action: {action}")
            return False
        
        return True
        
    except User.DoesNotExist:
        log_error(f"User '{username}' not found")
        return False
    except Exception as e:
        log_error(f"Error modifying user: {str(e)}")
        return False

def main():
    """Main function"""
    parser = argparse.ArgumentParser(
        description="Create staff users for Room Booking System",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  %(prog)s                                    # Interactive mode
  %(prog)s --username admin --email admin@example.com --password secret123
  %(prog)s --batch users.json                # Batch create from JSON file
  %(prog)s --list                            # List existing staff users
  %(prog)s --promote username                # Promote user to staff
  %(prog)s --demote username                 # Demote user from staff
  %(prog)s --super username                  # Make user superuser

JSON format for batch mode:
[
  {
    "username": "staff1",
    "email": "staff1@example.com",
    "password": "password123",
    "first_name": "John",
    "last_name": "Doe",
    "is_superuser": false
  }
]
        """
    )
    
    parser.add_argument('--username', help='Username for the staff user')
    parser.add_argument('--email', help='Email for the staff user')
    parser.add_argument('--password', help='Password for the staff user')
    parser.add_argument('--first-name', help='First name (optional)')
    parser.add_argument('--last-name', help='Last name (optional)')
    parser.add_argument('--superuser', action='store_true', help='Make user a superuser')
    parser.add_argument('--batch', help='JSON file with user data for batch creation')
    parser.add_argument('--list', action='store_true', help='List all staff users')
    parser.add_argument('--promote', help='Promote existing user to staff')
    parser.add_argument('--demote', help='Demote user from staff')
    parser.add_argument('--super', help='Make existing user a superuser')
    
    args = parser.parse_args()
    
    print_banner()
    
    # List mode
    if args.list:
        list_staff_users()
        return
    
    # Promote user
    if args.promote:
        modify_user_permissions(args.promote, 'promote')
        return
    
    # Demote user
    if args.demote:
        modify_user_permissions(args.demote, 'demote')
        return
    
    # Make superuser
    if getattr(args, 'super'):
        modify_user_permissions(getattr(args, 'super'), 'super')
        return
    
    # Batch mode
    if args.batch:
        try:
            with open(args.batch, 'r') as f:
                users_data = json.load(f)
            batch_mode(users_data)
        except FileNotFoundError:
            log_error(f"File not found: {args.batch}")
        except json.JSONDecodeError:
            log_error(f"Invalid JSON format in file: {args.batch}")
        except Exception as e:
            log_error(f"Error reading batch file: {str(e)}")
        return
    
    # Command line mode
    if args.username and args.email and args.password:
        success, message, user = create_staff_user(
            username=args.username,
            email=args.email,
            password=args.password,
            first_name=args.first_name or '',
            last_name=args.last_name or '',
            is_superuser=args.superuser
        )
        
        if success:
            log_success(message)
        else:
            log_error(message)
        return
    
    # Interactive mode (default)
    interactive_mode()

if __name__ == '__main__':
    main()
