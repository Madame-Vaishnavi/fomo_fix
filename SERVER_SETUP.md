# Server Setup Guide for FOMO Fix App

## Quick Fix for Connection Issues

If you're getting "Connection refused" errors, follow these steps:

### 1. **Check Your Backend Server**
Make sure your backend server is running on port 8080. You should see something like:
```
Server running on http://localhost:8080
```

### 2. **Configure the App for Your Setup**

Open `lib/config.dart` and change the configuration:

#### For Localhost (Current Setup):
```dart
static const ServerEnvironment serverEnvironment = ServerEnvironment.localhost;
// This will use: http://localhost:8080/api
```

#### For Android Emulator:
```dart
static const ServerEnvironment serverEnvironment = ServerEnvironment.androidEmulator;
// This will use: http://10.0.2.2:8080/api
```

#### For iOS Simulator:
```dart
static const ServerEnvironment serverEnvironment = ServerEnvironment.iosSimulator;
// This will use: http://localhost:8080/api
```

#### For Physical Device:
```dart
static const ServerEnvironment serverEnvironment = ServerEnvironment.physicalDevice;
// You'll need to update the IP address in the switch statement
```

### 3. **Find Your Computer's IP Address**

#### On Windows:
```cmd
ipconfig
```
Look for "IPv4 Address" under your active network adapter.

#### On Mac/Linux:
```bash
ifconfig
# or
ip addr
```

### 4. **Test Your Server**
Open your browser and go to:
- `http://localhost:8080/api/events` (for local testing)
- `http://YOUR_IP:8080/api/events` (for mobile testing)

You should see a JSON response with your events data.

## Current Configuration

The app is currently configured to use:
- **Environment**: `ServerEnvironment.localhost`
- **Base URL**: `http://localhost:8080/api`
- **Events Endpoint**: `/events`
- **Full URL**: `http://localhost:8080/api/events`

**Note**: When running on Android emulator, `localhost` refers to the emulator itself, not your computer. To connect to your computer's localhost, change to `ServerEnvironment.androidEmulator`.

## Troubleshooting

### Error: "Connection refused"
- ✅ Check if your server is running
- ✅ Check if it's on port 8080
- ✅ Check if the URL in config.dart is correct

### Error: "Network error"
- ✅ Check your internet connection
- ✅ Check if your firewall is blocking the connection
- ✅ Try using your computer's IP instead of localhost

### App shows mock data
- ✅ This is normal when the API is unavailable
- ✅ The app will automatically show real data when the server is accessible

## Next Steps

1. **Start your backend server** on port 8080
2. **Update the config** in `lib/config.dart` if needed
3. **Test the connection** in your browser first
4. **Run the app** - it should now connect successfully

## Example Backend Response

Your server should return data in this format:
```json
[
  {
    "title": "Rock Concert 2024",
    "imageUrl": "https://example.com/image.jpg",
    "date": "2024-03-15",
    "location": "Central Park, NY",
    "price": "50",
    "category": "Music",
    "creationDate": "2024-03-01T00:00:00Z",
    "totalTickets": 1000,
    "ticketsSold": 750
  }
]
```
