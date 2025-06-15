#!/usr/bin/env python
"""
Script untuk mengubah user menjadi staff/admin
"""
import os
import sys
import django

# Setup Django
sys.path.append('/code')
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'room_usage_project.settings')
django.setup()

from django.contrib.auth.models import User

def make_user_staff(username):
    """Membuat user menjadi staff"""
    try:
        user = User.objects.get(username=username)
        user.is_staff = True
        user.save()
        print(f"✅ User '{username}' telah dijadikan staff!")
        return True
    except User.DoesNotExist:
        print(f"❌ User '{username}' tidak ditemukan!")
        return False

def list_users():
    """Menampilkan daftar semua user"""
    users = User.objects.all()
    print("\n📋 Daftar User:")
    print("-" * 50)
    for user in users:
        status = "Admin" if user.is_superuser else "Staff" if user.is_staff else "User"
        print(f"- {user.username} ({user.first_name} {user.last_name}) - {status}")
    print("-" * 50)

if __name__ == "__main__":
    print("🔧 Script Manajemen User")
    print("=" * 30)
    
    # Tampilkan daftar user
    list_users()
    
    # Jadikan user1 sebagai staff
    print("\n🔄 Mengubah user1 menjadi staff...")
    make_user_staff('user1')
    
    # Tampilkan daftar user setelah perubahan
    print("\n📋 Setelah perubahan:")
    list_users()
