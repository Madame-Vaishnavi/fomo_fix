# Authentication Setup Guide

## Overview
This guide explains how to set up and use the new authentication features in the FOMO Fix app, including user registration and login with backend integration.

## Features Added

### 1. User Registration (Sign Up)
- **Fields**: Username, Email, Password, Confirm Password
- **Validation**: 
  - Username: Minimum 3 characters
  - Email: Valid email format
  - Password: Minimum 6 characters
  - Confirm Password: Must match password
- **API Endpoint**: `POST /api/users/register`

### 2. User Login (Sign In)
- **Fields**: Email, Password
- **Validation**: 
  - Email: Valid email format
  - Password: Required
- **API Endpoint**: `POST /api/users/login`

### 3. Backend Integration
- **User Service**: Handles registration, login, and profile retrieval
- **JWT Authentication**: Secure token-based authentication
- **API Gateway**: Centralized API access through port 8080

## Setup Instructions

### 1. Backend Requirements
Ensure your backend services are running:
```bash
# Start Eureka Server (Port 8761)
# Start User Service (Port 8085)
# Start API Gateway (Port 8080)
```

### 2. Configuration
Update `lib/config.dart` to match your server environment:
```dart
static const ServerEnvironment serverEnvironment = ServerEnvironment.localhost;
// or
static const ServerEnvironment serverEnvironment = ServerEnvironment.androidEmulator;
```

### 3. API Endpoints
The app will automatically use the correct base URL:
- **Localhost**: `http://localhost:8080/api`
- **Android Emulator**: `http://10.0.2.2:8080/api`
- **Physical Device**: Update IP address in config

## Usage

### Registration Flow
1. User taps "Sign up" on login page
2. Fills in username, email, and password
3. App validates input fields
4. Sends registration request to backend
5. Shows success/error message
6. Returns to login page on success

### Login Flow
1. User enters email and password
2. App validates input fields
3. Sends login request to backend
4. Backend returns JWT token
5. App retrieves user profile
6. Navigates to main app on success

## File Structure

```
lib/
├── Screens/
│   ├── login_page.dart      # Updated login page with backend integration
│   └── signup_page.dart     # New signup page
├── models/
│   └── user.dart            # User data model
├── services/
│   └── auth_service.dart    # Authentication service
├── api-service.dart         # Updated with user endpoints
└── config.dart              # Server configuration
```

## API Integration Details

### Registration Request
```json
POST /api/users/register
{
  "username": "john_doe",
  "email": "john@example.com",
  "password": "secure123"
}
```

### Login Request
```json
POST /api/users/login
{
  "email": "john@example.com",
  "password": "secure123"
}
```

### Login Response
```json
"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
```

### Profile Request (Authenticated)
```http
GET /api/users/profile
Authorization: Bearer <JWT_TOKEN>
```

### Profile Response
```json
{
  "id": 1,
  "email": "john@example.com",
  "username": "john_doe",
  "role": "ROLE_USER"
}
```

## Error Handling

### Network Errors
- Connection timeout
- Server unavailable
- Invalid response format

### Validation Errors
- Required field missing
- Invalid email format
- Password too short
- Passwords don't match

### Backend Errors
- User already exists
- Invalid credentials
- Server errors

## Security Features

### Input Validation
- Client-side validation for immediate feedback
- Server-side validation for security

### Password Security
- Password visibility toggle
- Minimum length requirements
- Secure transmission over HTTPS

### JWT Tokens
- Stateless authentication
- Automatic token inclusion in requests
- Secure token storage (TODO: implement secure storage)

## Future Enhancements

### 1. Secure Token Storage
- Implement SharedPreferences or secure storage
- Token refresh mechanism
- Automatic logout on token expiry

### 2. Password Recovery
- Forgot password functionality
- Email verification
- Password reset flow

### 3. Social Login
- Google Sign-In integration
- Facebook login
- Apple Sign-In (iOS)

### 4. Biometric Authentication
- Fingerprint authentication
- Face ID support
- Biometric fallback

## Testing

### Manual Testing
1. Test registration with valid data
2. Test registration with invalid data
3. Test login with valid credentials
4. Test login with invalid credentials
5. Test keyboard handling on both pages
6. Test navigation between pages

### Backend Testing
1. Ensure User Service is running
2. Verify API Gateway configuration
3. Check database connectivity
4. Test JWT token generation

## Troubleshooting

### Common Issues

#### 1. "Network error" messages
- Check if backend services are running
- Verify server URLs in config
- Check network connectivity

#### 2. Registration fails
- Verify backend is accessible
- Check server logs for errors
- Ensure database is running

#### 3. Login fails
- Verify user exists in database
- Check JWT configuration
- Verify API Gateway routing

#### 4. Keyboard overlap
- Both pages now handle keyboard properly
- Content scrolls when keyboard appears
- Dynamic spacing adjustments

## Support

For issues or questions:
1. Check backend service logs
2. Verify API endpoints are accessible
3. Test with Postman or similar tools
4. Check Flutter console for errors

## Notes

- JWT tokens are currently stored in memory (not persistent)
- App will lose authentication on app restart
- Implement secure storage for production use
- Consider adding token refresh mechanism
- Add proper error logging for debugging

