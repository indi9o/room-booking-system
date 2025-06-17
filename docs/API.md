# � API Documentation

> **📍 Navigation**: [📋 Documentation Index](README.md) | [🔧 Developer Guide](DEVELOPER.md) | [🤝 Contributing](CONTRIBUTING.md)

REST API endpoints untuk Room Booking System.

## 🌐 Base URL

```
http://localhost:8001/api/v1/
```

## 🔐 Authentication

Sistem menggunakan Django Session Authentication dan CSRF protection.

### Login
```http
POST /accounts/login/
Content-Type: application/x-www-form-urlencoded

username=your_username&password=your_password
```

### Logout
```http
POST /accounts/logout/
```

### CSRF Token
```http
GET /csrf/
```

Response:
```json
{
    "csrfToken": "your-csrf-token-here"
}
```

## 🏢 Rooms API

### List All Rooms
```http
GET /rooms/
```

Response:
```json
{
    "status": "success",
    "data": [
        {
            "id": 1,
            "name": "Conference Room A",
            "location": "2nd Floor",
            "capacity": 20,
            "description": "Large conference room with projector",
            "image": "/media/rooms/room1.jpg",
            "is_active": true,
            "features": "Projector, Whiteboard, AC",
            "created_at": "2024-01-15T10:30:00Z",
            "updated_at": "2024-01-15T10:30:00Z"
        }
    ]
}
```

### Get Room Detail
```http
GET /rooms/{id}/
```

Response:
```json
{
    "status": "success",
    "data": {
        "id": 1,
        "name": "Conference Room A",
        "location": "2nd Floor",
        "capacity": 20,
        "description": "Large conference room with projector",
        "image": "/media/rooms/room1.jpg",
        "is_active": true,
        "features": "Projector, Whiteboard, AC",
        "created_at": "2024-01-15T10:30:00Z",
        "updated_at": "2024-01-15T10:30:00Z",
        "current_bookings": [
            {
                "id": 1,
                "title": "Team Meeting",
                "start_time": "2024-01-16T09:00:00Z",
                "end_time": "2024-01-16T11:00:00Z",
                "status": "approved"
            }
        ]
    }
}
```

### Create Room (Admin Only)
```http
POST /rooms/create/
Content-Type: application/json
X-CSRFToken: your-csrf-token

{
    "name": "Meeting Room B",
    "location": "1st Floor",
    "capacity": 10,
    "description": "Small meeting room",
    "features": "TV Screen, Whiteboard"
}
```

Response:
```json
{
    "status": "success",
    "message": "Room created successfully",
    "data": {
        "id": 2,
        "name": "Meeting Room B",
        "location": "1st Floor",
        "capacity": 10,
        "description": "Small meeting room",
        "features": "TV Screen, Whiteboard",
        "is_active": true
    }
}
```

### Update Room (Admin Only)
```http
PUT /rooms/{id}/edit/
Content-Type: application/json
X-CSRFToken: your-csrf-token

{
    "name": "Updated Room Name",
    "capacity": 15
}
```

### Delete Room (Admin Only)
```http
DELETE /rooms/{id}/delete/
X-CSRFToken: your-csrf-token
```

Response:
```json
{
    "status": "success",
    "message": "Room deleted successfully"
}
```

## 📅 Bookings API

### List User Bookings
```http
GET /bookings/
```

Query Parameters:
- `status`: Filter by status (pending, approved, rejected, cancelled, completed)
- `room_id`: Filter by room ID
- `date_from`: Filter bookings from date (YYYY-MM-DD)
- `date_to`: Filter bookings to date (YYYY-MM-DD)

Response:
```json
{
    "status": "success",
    "data": [
        {
            "id": 1,
            "title": "Team Meeting",
            "description": "Weekly team standup",
            "room": {
                "id": 1,
                "name": "Conference Room A"
            },
            "start_time": "2024-01-16T09:00:00Z",
            "end_time": "2024-01-16T11:00:00Z",
            "attendees": 8,
            "status": "approved",
            "created_at": "2024-01-15T14:30:00Z",
            "updated_at": "2024-01-15T15:45:00Z"
        }
    ]
}
```

### Get Booking Detail
```http
GET /bookings/{id}/
```

Response:
```json
{
    "status": "success",
    "data": {
        "id": 1,
        "title": "Team Meeting",
        "description": "Weekly team standup",
        "room": {
            "id": 1,
            "name": "Conference Room A",
            "location": "2nd Floor",
            "capacity": 20
        },
        "user": {
            "id": 2,
            "username": "john_doe",
            "email": "john@example.com"
        },
        "start_time": "2024-01-16T09:00:00Z",
        "end_time": "2024-01-16T11:00:00Z",
        "attendees": 8,
        "status": "approved",
        "admin_notes": "Approved for weekly meeting",
        "created_at": "2024-01-15T14:30:00Z",
        "updated_at": "2024-01-15T15:45:00Z"
    }
}
```

### Create Booking
```http
POST /bookings/create/
Content-Type: application/json
X-CSRFToken: your-csrf-token

{
    "title": "Project Discussion",
    "description": "Quarterly project review",
    "room_id": 1,
    "start_time": "2024-01-20T14:00:00Z",
    "end_time": "2024-01-20T16:00:00Z",
    "attendees": 12
}
```

Response:
```json
{
    "status": "success",
    "message": "Booking created successfully",
    "data": {
        "id": 3,
        "title": "Project Discussion",
        "description": "Quarterly project review",
        "room_id": 1,
        "start_time": "2024-01-20T14:00:00Z",
        "end_time": "2024-01-20T16:00:00Z",
        "attendees": 12,
        "status": "pending"
    }
}
```

### Update Booking
```http
PUT /bookings/{id}/edit/
Content-Type: application/json
X-CSRFToken: your-csrf-token

{
    "title": "Updated Meeting Title",
    "attendees": 15
}
```

### Cancel Booking
```http
DELETE /bookings/{id}/cancel/
X-CSRFToken: your-csrf-token
```

Response:
```json
{
    "status": "success",
    "message": "Booking cancelled successfully"
}
```

## 👥 Admin API

### List All Bookings (Admin Only)
```http
GET /admin/bookings/
```

Query Parameters:
- `status`: Filter by status
- `room_id`: Filter by room
- `user_id`: Filter by user
- `date_from`: From date
- `date_to`: To date

### Approve Booking (Admin Only)
```http
POST /admin/bookings/{id}/approve/
Content-Type: application/json
X-CSRFToken: your-csrf-token

{
    "admin_notes": "Approved for important meeting"
}
```

### Reject Booking (Admin Only)
```http
POST /admin/bookings/{id}/reject/
Content-Type: application/json
X-CSRFToken: your-csrf-token

{
    "admin_notes": "Room not available at requested time"
}
```

### User Management (Admin Only)
```http
GET /admin/users/
POST /admin/users/{id}/make_staff/
POST /admin/users/{id}/remove_staff/
DELETE /admin/users/{id}/deactivate/
```

## 📊 Analytics API

### Room Usage Statistics (Admin Only)
```http
GET /admin/analytics/room-usage/
```

Query Parameters:
- `period`: daily, weekly, monthly, yearly
- `room_id`: Specific room (optional)

Response:
```json
{
    "status": "success",
    "data": {
        "total_bookings": 150,
        "approved_bookings": 140,
        "rejected_bookings": 10,
        "utilization_rate": 85.5,
        "popular_rooms": [
            {
                "room_id": 1,
                "room_name": "Conference Room A",
                "booking_count": 45
            }
        ],
        "booking_trends": [
            {
                "date": "2024-01-15",
                "count": 8
            }
        ]
    }
}
```

### User Activity (Admin Only)
```http
GET /admin/analytics/user-activity/
```

## 🔍 Search API

### Search Rooms
```http
GET /search/rooms/
```

Query Parameters:
- `q`: Search query
- `capacity_min`: Minimum capacity
- `capacity_max`: Maximum capacity
- `location`: Location filter
- `features`: Features filter

### Check Room Availability
```http
GET /search/availability/
```

Query Parameters:
- `room_id`: Room ID
- `start_time`: Start datetime (ISO format)
- `end_time`: End datetime (ISO format)

Response:
```json
{
    "status": "success",
    "data": {
        "available": true,
        "conflicts": []
    }
}
```

## ❌ Error Responses

### 400 Bad Request
```json
{
    "status": "error",
    "message": "Invalid request data",
    "errors": {
        "start_time": ["This field is required."],
        "end_time": ["End time must be after start time."]
    }
}
```

### 401 Unauthorized
```json
{
    "status": "error",
    "message": "Authentication required"
}
```

### 403 Forbidden
```json
{
    "status": "error",
    "message": "Permission denied"
}
```

### 404 Not Found
```json
{
    "status": "error",
    "message": "Resource not found"
}
```

### 409 Conflict
```json
{
    "status": "error",
    "message": "Room is already booked for the requested time",
    "data": {
        "conflicts": [
            {
                "booking_id": 5,
                "title": "Existing Meeting",
                "start_time": "2024-01-20T14:30:00Z",
                "end_time": "2024-01-20T15:30:00Z"
            }
        ]
    }
}
```

### 500 Internal Server Error
```json
{
    "status": "error",
    "message": "Internal server error"
}
```

## 📝 Rate Limiting

API menggunakan rate limiting untuk mencegah abuse:

- **Authenticated users**: 1000 requests per hour
- **Anonymous users**: 100 requests per hour
- **Admin endpoints**: 500 requests per hour

Rate limit headers:
```
X-RateLimit-Limit: 1000
X-RateLimit-Remaining: 999
X-RateLimit-Reset: 1642694400
```

## 🔧 Testing API

### Using cURL

```bash
# Get CSRF token
curl -c cookies.txt http://localhost:8001/csrf/

# Login
curl -b cookies.txt -c cookies.txt -X POST \
  -d "username=admin&password=admin123" \
  http://localhost:8001/accounts/login/

# List rooms
curl -b cookies.txt http://localhost:8001/rooms/

# Create booking
curl -b cookies.txt -X POST \
  -H "Content-Type: application/json" \
  -H "X-CSRFToken: your-csrf-token" \
  -d '{"title":"Test Meeting","room_id":1,"start_time":"2024-01-20T10:00:00Z","end_time":"2024-01-20T11:00:00Z","attendees":5}' \
  http://localhost:8001/bookings/create/
```

### Using Python Requests

```python
import requests

# Start session
session = requests.Session()

# Get CSRF token
csrf_response = session.get('http://localhost:8001/csrf/')
csrf_token = csrf_response.json()['csrfToken']

# Login
login_data = {
    'username': 'admin',
    'password': 'admin123'
}
session.post('http://localhost:8001/accounts/login/', data=login_data)

# Create booking
booking_data = {
    'title': 'Test Meeting',
    'room_id': 1,
    'start_time': '2024-01-20T10:00:00Z',
    'end_time': '2024-01-20T11:00:00Z',
    'attendees': 5
}
headers = {
    'X-CSRFToken': csrf_token,
    'Content-Type': 'application/json'
}
response = session.post(
    'http://localhost:8001/bookings/create/',
    json=booking_data,
    headers=headers
)

print(response.json())
```

---

**📡 API Documentation - Room Booking System v1.0**
