# Image Upload Guide for FOMO Fix App

## Overview
This guide explains how image upload functionality works in the Flutter app and how it integrates with the Spring Boot backend.

## Backend Integration

### Spring Boot Controller Endpoint
The app uses the `/api/events/with-image` endpoint from your Spring Boot controller:

```java
@PostMapping(value = "/with-image", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
public ResponseEntity<EventResponseDTO> createEventWithImage(@ModelAttribute EventCreateRequestDTO request)
```

### Expected Request Format
The endpoint expects:
- **Content-Type**: `multipart/form-data`
- **Image field name**: `image` (MultipartFile)
- **Form fields**: All event data as form fields
- **Authentication**: Bearer token in Authorization header

## Flutter Implementation

### Key Components

#### 1. Image Picker
- Uses `image_picker` package
- Allows users to select images from gallery
- Image quality: 80%
- Max dimensions: 1920x1080 for performance
- Optional feature - users can create events without images

#### 2. API Service Method
```dart
static Future<http.Response> uploadFileWithAuth(
  String token,
  String endpoint, {
  required Map<String, String> fields,
  required List<http.MultipartFile> files,
})
```

#### 3. Event Creation Flow
1. **Form Validation**: Validates all required fields
2. **Image Processing**: If image selected, validates file exists
3. **Request Preparation**: 
   - With image: Uses multipart form data
   - Without image: Uses JSON payload
4. **API Call**: Sends to appropriate endpoint
5. **Response Handling**: Shows success/error messages

### File Structure
```
lib/
├── Screens/
│   └── event_listing.dart      # Main event creation screen
├── services/
│   └── api-service.dart        # API communication methods
└── config.dart                 # Server configuration
```

## Usage Instructions

### For Users
1. Navigate to "List Your Event" screen
2. Fill in event details (title, description, location, etc.)
3. **Optional**: Tap the image area to select an event banner
4. Tap the red X button to remove selected image
5. Add ticket tiers and pricing
6. Tap "List Event" to submit

### For Developers

#### Adding Image Upload to New Screens
1. Import required packages:
```dart
import 'dart:io';
import 'package:image_picker/image_picker.dart';
```

2. Add state variable:
```dart
File? _selectedImage;
```

3. Add image picker method:
```dart
Future<void> _pickImage() async {
  final ImagePicker picker = ImagePicker();
  final XFile? image = await picker.pickImage(
    source: ImageSource.gallery,
    imageQuality: 80,
    maxWidth: 1920,
    maxHeight: 1080,
  );
  if (image != null) {
    setState(() {
      _selectedImage = File(image.path);
    });
  }
}
```

4. Use `ApiService.uploadFileWithAuth()` for multipart requests

## Error Handling

### Common Issues
1. **Permission Denied**: Ensure `READ_MEDIA_IMAGES` permission in AndroidManifest.xml
2. **File Not Found**: Validate file exists before upload
3. **Network Errors**: Handle timeout and connection issues
4. **Server Errors**: Parse and display error messages from backend

### Validation
- Image file existence check
- File size limits (handled by backend)
- Supported image formats (handled by backend)
- Network connectivity

## Configuration

### Android Permissions
```xml
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES"/>
<uses-permission android:name="android.permission.INTERNET"/>
```

### Dependencies
```yaml
dependencies:
  image_picker: ^1.1.2
  http: ^1.1.0
```

## Testing

### Manual Testing
1. Create event without image
2. Create event with image
3. Test image removal
4. Test with different image sizes
5. Test network error scenarios

### Debug Information
The app logs:
- Selected image path
- File size
- Request data
- Response status and body
- Error details

## Troubleshooting

### Image Not Uploading
1. Check network connectivity
2. Verify backend server is running
3. Check authentication token
4. Validate image file exists
5. Check server logs for errors

### Permission Issues
1. Ensure Android permissions are granted
2. Check AndroidManifest.xml configuration
3. Test on different Android versions

### Performance Issues
1. Image compression is already applied (80% quality)
2. Max dimensions limit file size
3. Consider implementing image caching for better UX
