from django.contrib import admin
from django.utils.html import format_html
from .models import Room, Booking, BookingHistory

@admin.register(Room)
class RoomAdmin(admin.ModelAdmin):
    list_display = ['name', 'location', 'capacity', 'is_active', 'created_at']
    list_filter = ['is_active', 'location', 'created_at']
    search_fields = ['name', 'location', 'description']
    list_editable = ['is_active']
    readonly_fields = ['created_at', 'updated_at']
    
    fieldsets = (
        ('Informasi Dasar', {
            'fields': ('name', 'description', 'capacity', 'location')
        }),
        ('Detail', {
            'fields': ('facilities', 'image', 'is_active')
        }),
        ('Waktu', {
            'fields': ('created_at', 'updated_at'),
            'classes': ('collapse',)
        }),
    )

@admin.register(Booking)
class BookingAdmin(admin.ModelAdmin):
    list_display = ['title', 'room', 'user', 'start_datetime', 'end_datetime', 'status', 'participants']
    list_filter = ['status', 'room', 'start_datetime', 'created_at']
    search_fields = ['title', 'user__username', 'user__first_name', 'user__last_name', 'room__name']
    list_editable = ['status']
    readonly_fields = ['created_at', 'updated_at', 'approved_at']
    date_hierarchy = 'start_datetime'
    
    fieldsets = (
        ('Informasi Booking', {
            'fields': ('user', 'room', 'title', 'description')
        }),
        ('Jadwal', {
            'fields': ('start_datetime', 'end_datetime', 'participants')
        }),
        ('Status', {
            'fields': ('status', 'notes', 'approved_by', 'approved_at')
        }),
        ('Waktu', {
            'fields': ('created_at', 'updated_at'),
            'classes': ('collapse',)
        }),
    )
    
    def get_queryset(self, request):
        return super().get_queryset(request).select_related('user', 'room', 'approved_by')

@admin.register(BookingHistory)
class BookingHistoryAdmin(admin.ModelAdmin):
    list_display = ['booking', 'old_status', 'new_status', 'changed_by', 'created_at']
    list_filter = ['old_status', 'new_status', 'created_at']
    search_fields = ['booking__title', 'changed_by__username']
    readonly_fields = ['created_at']
    
    def has_add_permission(self, request):
        return False
    
    def has_change_permission(self, request, obj=None):
        return False
