#!/usr/bin/env python
"""
🔧 User Management Script - Room Booking System
Convert regular users to staff/admin for management access
"""
import os
import sys
import django
import argparse

# Setup Django
project_root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.append(project_root)
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'room_usage_project.settings')
django.setup()

from django.contrib.auth.models import User

def list_users():
    """Display all users with their current status"""
    users = User.objects.all().order_by('username')
    
    print("\n📋 Current Users:")
    print("=" * 60)
    print(f"{'Username':<15} {'Name':<20} {'Status':<10} {'Last Login'}")
    print("-" * 60)
    
    for user in users:
        if user.is_superuser:
            status = "🔥 Super"
        elif user.is_staff:
            status = "⭐ Staff"
        else:
            status = "👤 User"
            
        name = f"{user.first_name} {user.last_name}".strip() or "-"
        last_login = user.last_login.strftime("%Y-%m-%d") if user.last_login else "Never"
        
        print(f"{user.username:<15} {name:<20} {status:<10} {last_login}")
    
    print("-" * 60)
    return users

def make_user_staff(username, verbose=True):
    """Convert user to staff"""
    try:
        user = User.objects.get(username=username)
        
        if user.is_staff:
            if verbose:
                status = "superuser" if user.is_superuser else "staff"
                print(f"ℹ️  User '{username}' is already {status}")
            return True
            
        user.is_staff = True
        user.save()
        
        if verbose:
            print(f"✅ Success! User '{username}' is now staff")
            print(f"   They can now access admin panel: /admin")
        return True
        
    except User.DoesNotExist:
        if verbose:
            print(f"❌ Error: User '{username}' not found")
        return False

def interactive_mode():
    """Interactive user selection mode"""
    print("🎯 Interactive Mode - Select User to Make Staff")
    print("=" * 50)
    
    users = list_users()
    
    if not users:
        print("❌ No users found in database")
        return
    
    print(f"\n� Enter username to convert to staff (or 'q' to quit):")
    
    while True:
        try:
            choice = input("\n👤 Username: ").strip()
            
            if choice.lower() in ['q', 'quit', 'exit']:
                print("👋 Goodbye!")
                break
                
            if not choice:
                print("⚠️  Please enter a username")
                continue
            
            success = make_user_staff(choice)
            if success:
                print(f"\n🎉 Done! User '{choice}' can now access admin features")
                
                # Ask if user wants to continue
                continue_choice = input("\n❓ Convert another user? (y/N): ").strip().lower()
                if continue_choice not in ['y', 'yes']:
                    break
            else:
                print(f"💡 Available users: {', '.join([u.username for u in users])}")
                
        except KeyboardInterrupt:
            print("\n\n👋 Goodbye!")
            break

def main():
    parser = argparse.ArgumentParser(
        description="🔧 Room Booking System - User Management Tool",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  python make_staff.py                    # Interactive mode
  python make_staff.py --username john    # Make 'john' staff
  python make_staff.py --list             # Just list users
  python make_staff.py --username admin --username user1  # Multiple users
        """
    )
    
    parser.add_argument('--username', '-u', action='append', 
                       help='Username to make staff (can be used multiple times)')
    parser.add_argument('--list', '-l', action='store_true',
                       help='List all users and exit')
    parser.add_argument('--quiet', '-q', action='store_true',
                       help='Minimal output')
    
    args = parser.parse_args()
    
    if not args.quiet:
        print("🔧 Room Booking System - User Management")
        print("=" * 40)
    
    # List users mode
    if args.list:
        list_users()
        return
    
    # Command line mode with usernames
    if args.username:
        if not args.quiet:
            list_users()
            print(f"\n🔄 Converting {len(args.username)} user(s) to staff...")
        
        success_count = 0
        for username in args.username:
            if make_user_staff(username, not args.quiet):
                success_count += 1
        
        if not args.quiet:
            print(f"\n📊 Result: {success_count}/{len(args.username)} users converted successfully")
        return
    
    # Interactive mode (default)
    if not args.quiet:
        interactive_mode()
    else:
        print("❌ Error: Quiet mode requires --username or --list")
        sys.exit(1)

if __name__ == "__main__":
    main()
