# 🏢 Room Management Guide

Panduan lengkap untuk mengelola ruangan dalam Room Booking System, mulai dari menambah ruangan baru hingga maintenance dan monitoring.

## 🎯 Overview

Room Management adalah fitur core yang memungkinkan administrator untuk:
- ➕ **Menambah ruangan baru** dengan detail lengkap
- ✏️ **Mengedit informasi ruangan** yang sudah ada
- 👁️ **Melihat detail dan statistik** penggunaan ruangan
- 🗑️ **Menonaktifkan ruangan** sementara atau permanen
- 📊 **Monitoring penggunaan** dan analisis

## 🔐 Permission & Access Control

### Siapa yang Bisa Mengelola Ruangan?
| Role | Add Room | Edit Room | View Details | Delete Room |
|------|----------|-----------|--------------|-------------|
| **Super Admin** | ✅ | ✅ | ✅ | ✅ |
| **Staff** | ✅ | ✅ | ✅ | ❌ |
| **Regular User** | ❌ | ❌ | ✅ | ❌ |

### Cara Menjadi Staff
```bash
# Via Django shell
docker-compose exec web python manage.py shell
>>> from django.contrib.auth.models import User
>>> user = User.objects.get(username='username')
>>> user.is_staff = True
>>> user.save()

# Via custom script
docker-compose exec web python make_staff.py
```

## ➕ Adding New Rooms

### 1. Access Add Room Form

#### Via Web Interface
1. **Login** sebagai staff/admin
2. **Navigate** ke "Ruangan" dari menu utama
3. **Click** tombol hijau "Tambah Ruangan"
4. **Or** klik "Tambah Ruangan" di navbar (untuk staff)

#### Via Direct URL
```
http://localhost:8001/rooms/create/
```

### 2. Room Information Form

#### Required Fields ⭐
| Field | Description | Validation |
|-------|-------------|------------|
| **Nama Ruangan** | Unique room identifier | Max 200 chars, required |
| **Kapasitas** | Maximum occupancy | Positive integer, required |
| **Lokasi** | Room location/address | Max 200 chars, required |

#### Optional Fields
| Field | Description | Format |
|-------|-------------|--------|
| **Deskripsi** | Detailed room description | Text area, 500 chars |
| **Fasilitas** | Available facilities | Text area, comma-separated |
| **Foto Ruangan** | Room image | JPG/PNG/GIF, max 5MB |
| **Status Aktif** | Available for booking | Checkbox (default: true) |

### 3. Best Practices

#### Naming Convention
```
✅ Good Examples:
- "Ruang Rapat A - Lantai 2"
- "Auditorium Utama"
- "Meeting Room Alpha"
- "Ruang Diskusi Tim Marketing"

❌ Avoid:
- "Ruangan 1" (too generic)
- "Room" (no context)
- "A" (too short)
```

#### Capacity Guidelines
```
Small Meeting: 4-8 people
Medium Meeting: 10-20 people
Large Meeting: 25-50 people
Auditorium: 50+ people
```

#### Facility Examples
```
Basic: WiFi, AC, Meja, Kursi
Standard: + Proyektor, Whiteboard
Premium: + Sound System, Video Conference
Luxury: + Catering Area, Smart Board
```

### 4. Photo Upload Guidelines

#### Technical Requirements
- **Format**: JPG, PNG, GIF
- **Size**: Maximum 5MB
- **Resolution**: 1920x1080 recommended
- **Aspect Ratio**: 16:9 atau 4:3

#### Photo Tips
```
✅ Good Photos:
- Well-lit room shots
- Multiple angles (front, back, setup)
- Clean and organized space
- Show key facilities

❌ Avoid:
- Blurry or dark images
- Cluttered or messy rooms
- People in photos
- Extreme angles
```

## ✏️ Editing Existing Rooms

### 1. Access Edit Function

#### Via Room List
1. Go to **"Ruangan"** page
2. Find room to edit
3. Click **room name** to view details
4. Click **"Edit Room"** button (staff only)

#### Via Admin Panel
1. Go to **Admin Panel** (`/admin`)
2. Navigate to **"Rooms"** section
3. Select room to edit
4. Modify fields and save

### 2. Common Editing Scenarios

#### Update Capacity
```
Scenario: Room renovation increased capacity
Steps:
1. Edit room details
2. Update capacity number
3. Update description if needed
4. Save changes
```

#### Change Facilities
```
Scenario: New equipment added
Steps:
1. Edit room details
2. Update facilities list
3. Add new equipment to description
4. Upload new photos if needed
```

#### Temporary Deactivation
```
Scenario: Room maintenance
Steps:
1. Edit room details
2. Uncheck "Ruangan Aktif"
3. Add maintenance note to description
4. Save changes
```

## 👁️ Viewing Room Details

### Room Detail Page Features

#### Basic Information
- 📋 Room name and description
- 📍 Location details
- 👥 Capacity information
- 🛠️ Available facilities
- 📸 Room photos (if uploaded)

#### Booking Information
- 📅 **Upcoming bookings** for this room
- 📊 **Booking statistics** (total, this month)
- ⏰ **Availability calendar** (interactive)
- 📈 **Usage trends** and patterns

#### Action Buttons (Staff Only)
- ✏️ **Edit Room** - Modify room details
- 📅 **View Bookings** - All bookings for this room
- ➕ **Quick Book** - Create booking for this room

### Statistics & Analytics

#### Usage Metrics
```
📊 Room Utilization:
- Total bookings: 45
- This month: 12
- Average duration: 2.5 hours
- Peak hours: 10:00-12:00, 14:00-16:00

📈 Trends:
- Most booked day: Tuesday
- Least booked: Friday
- Popular time slots: Morning meetings
- Average attendees: 8 people
```

## 🗑️ Room Deactivation

### Soft Deactivation (Recommended)
```python
# Room remains in database but not bookable
room.is_active = False
room.save()
```

#### Use Cases:
- 🔧 **Temporary maintenance**
- 🏗️ **Renovation work**
- 📦 **Furniture updates**
- 🧹 **Deep cleaning**

### Effects of Deactivation:
- ❌ Room not shown in booking forms
- ❌ New bookings cannot be created
- ✅ Existing bookings remain valid
- ✅ Room details still viewable
- ✅ Can be reactivated anytime

### Reactivation Process:
1. Edit room details
2. Check "Ruangan Aktif" box
3. Save changes
4. Room immediately available for booking

## 📊 Room Monitoring

### Daily Monitoring Tasks

#### Morning Checklist
- [ ] Check overnight booking confirmations
- [ ] Review today's room schedule
- [ ] Verify room availability
- [ ] Check for conflicts or issues

#### Throughout the Day
- [ ] Monitor active bookings
- [ ] Address user questions/issues
- [ ] Update room status if needed
- [ ] Handle booking changes

#### End of Day
- [ ] Review day's usage
- [ ] Clean up cancelled bookings
- [ ] Prepare tomorrow's schedule
- [ ] Check maintenance needs

### Weekly Monitoring

#### Usage Analysis
```sql
-- Top utilized rooms
SELECT name, COUNT(*) as booking_count 
FROM rooms_room r
JOIN rooms_booking b ON r.id = b.room_id
WHERE b.created_at >= DATE_SUB(NOW(), INTERVAL 7 DAY)
GROUP BY r.name
ORDER BY booking_count DESC;
```

#### Performance Metrics
- 📊 **Booking success rate**
- ⏱️ **Average booking duration**
- 👥 **Average attendees per booking**
- 🔄 **Cancellation rate**

## 🛠️ Maintenance Management

### Scheduled Maintenance

#### Planning Maintenance
1. **Check booking schedule** - Avoid busy periods
2. **Set room to inactive** - Prevent new bookings
3. **Notify existing bookers** - Give advance notice
4. **Update room description** - Add maintenance note

#### During Maintenance
```
✅ Best Practices:
- Keep room deactivated
- Update progress in description
- Communicate with users
- Document any changes

❌ Avoid:
- Leaving room active during work
- Not communicating with users
- Forgetting to reactivate
- Not updating capacity if changed
```

#### Post-Maintenance
1. **Update room details** if changed
2. **Upload new photos** if appearance changed
3. **Test all facilities** to ensure working
4. **Reactivate room** for bookings
5. **Announce completion** to users

### Emergency Maintenance
```
Immediate Actions:
1. Deactivate room immediately
2. Cancel conflicting bookings
3. Notify affected users
4. Update room status
5. Arrange alternative rooms
```

## 📱 Mobile Management

### Mobile-Friendly Features
- ✅ **Responsive design** for all screen sizes
- ✅ **Touch-optimized** interface
- ✅ **Quick actions** for common tasks
- ✅ **Photo upload** from mobile camera

### Mobile Best Practices
- 📱 Use mobile browser for quick updates
- 📸 Take photos directly with mobile camera
- 📞 Keep contact info handy for user support
- 🔔 Enable notifications for urgent issues

## 🚨 Troubleshooting

### Common Issues

#### "Cannot Add Room" Error
```
Possible Causes:
- User not logged in as staff
- Form validation errors
- Database connection issues

Solutions:
1. Verify staff status
2. Check all required fields
3. Reduce image file size
4. Try refreshing page
```

#### Photo Upload Failures
```
Possible Causes:
- File too large (>5MB)
- Unsupported format
- Network connection issues

Solutions:
1. Compress image size
2. Convert to JPG/PNG
3. Check internet connection
4. Try uploading again
```

#### Room Not Appearing in Booking
```
Possible Causes:
- Room set to inactive
- Database sync issues
- Cache problems

Solutions:
1. Check "Ruangan Aktif" status
2. Refresh browser
3. Clear browser cache
4. Contact administrator
```

## 🎯 Advanced Features

### Bulk Operations (Admin Panel)
```python
# Via Django Admin
1. Select multiple rooms
2. Choose bulk action
3. Apply to selected rooms

# Available Actions:
- Activate/Deactivate rooms
- Update facilities
- Bulk delete (careful!)
```

### API Integration (Future)
```python
# Room API endpoints (coming soon)
GET /api/rooms/          # List all rooms
POST /api/rooms/         # Create new room
GET /api/rooms/{id}/     # Room details
PUT /api/rooms/{id}/     # Update room
DELETE /api/rooms/{id}/  # Delete room
```

### Custom Fields (Future Enhancement)
- 🏷️ **Room categories** (meeting, conference, training)
- 🎯 **Equipment inventory** tracking
- 💰 **Pricing tiers** for different room types
- 📱 **QR codes** for quick room identification

---

## ✅ Room Management Checklist

### Daily Tasks
- [ ] Monitor active bookings
- [ ] Check room availability
- [ ] Address user issues
- [ ] Update room status if needed

### Weekly Tasks
- [ ] Review usage analytics
- [ ] Plan maintenance schedules
- [ ] Update room information
- [ ] Check photo quality

### Monthly Tasks
- [ ] Comprehensive usage review
- [ ] Update facility information
- [ ] Review user feedback
- [ ] Plan room improvements

## 🎓 Training Resources

### For New Staff
1. **Room Management Basics** - This guide
2. **Booking System Overview** - [Booking Guide](booking-system.md)
3. **Admin Panel Training** - [Admin Guide](admin-panel.md)
4. **User Support** - [Support Guide](../troubleshooting.md)

### Video Tutorials (Coming Soon)
- 📹 Adding Your First Room
- 📹 Managing Room Photos
- 📹 Handling Booking Conflicts
- 📹 Monthly Analytics Review

---

## 🚀 Ready to Manage Rooms?

You're now equipped with everything needed to effectively manage rooms in the system!

**Next Steps:**
- Practice adding a test room
- Explore the admin panel features
- Learn about [Booking Management](booking-system.md)
- Set up [User Management](user-management.md)

**Need help? Check [Troubleshooting](../troubleshooting.md) or create a GitHub issue!**
