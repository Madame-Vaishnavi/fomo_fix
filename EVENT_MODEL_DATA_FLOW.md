# Event Model Data Flow Documentation

## Overview
This document explains how event data flows from the API through the Event model to the recommendation cards in the Flutter application.

## 1. Event Model Structure

### 1.1 SeatCategory Model
```dart
class SeatCategory {
  final String categoryName;      // e.g., "VIP", "General", "Front Row"
  final int totalSeats;          // Total seats in this category
  final int availableSeats;      // Available seats in this category
  final double pricePerSeat;     // Price per seat in this category
}
```

### 1.2 Event Model
```dart
class Event {
  final int? id;                 // Event ID from API
  final String name;             // Event name (e.g., "Rock Concert 2024")
  final String description;      // Event description
  final String location;         // Event location
  final String date;             // Event date (ISO 8601 format)
  final String category;         // API category (e.g., "CONCERT", "THEATER")
  final List<SeatCategory> seatCategories; // Different ticket types
  final String? imageUrl;        // Optional event image
  final DateTime? creationDate;  // Optional creation date
}
```

## 2. Data Flow Architecture

```
API Response → Event.fromJson() → Event Object → RecommendationCard → UI Display
     ↓              ↓                ↓              ↓              ↓
JSON Data    Parsed Fields    Computed Values   Visual Elements   User Sees
```

## 3. Detailed Data Flow

### 3.1 API Response to Event Model
```json
{
    "id": 1,
    "name": "Rock Concert 2024",
    "description": "Amazing rock concert featuring top artists",
    "location": "Madison Square Garden",
    "date": "2024-06-15T19:00:00",
    "category": "CONCERT",
    "seatCategories": [
        {
            "categoryName": "VIP",
            "totalSeats": 100,
            "availableSeats": 95,
            "pricePerSeat": 150.0
        },
        {
            "categoryName": "General",
            "totalSeats": 500,
            "availableSeats": 400,
            "pricePerSeat": 75.0
        }
    ]
}
```

### 3.2 Event.fromJson() Parsing
```dart
factory Event.fromJson(Map<String, dynamic> json) {
  return Event(
    id: json['id'],
    name: json['name'] ?? '',
    description: json['description'] ?? '',
    location: json['location'] ?? '',
    date: json['date'] ?? '',
    category: json['category'] ?? '',
    seatCategories: (json['seatCategories'] as List<dynamic>?)
        ?.map((seatJson) => SeatCategory.fromJson(seatJson))
        .toList() ?? [],
    imageUrl: json['imageUrl'],
    creationDate: json['creationDate'] != null
        ? DateTime.parse(json['creationDate'])
        : null,
  );
}
```

### 3.3 Computed Properties (Helper Getters)
The Event model provides computed properties that the UI can use directly:

```dart
// Title alias for backward compatibility
String get title => name;

// Price range from seat categories
String get priceRange => "Rs. 75 - Rs. 150";

// Total tickets across all categories
int get totalTickets => 600; // 100 VIP + 500 General

// Available tickets
int get availableTickets => 495; // 95 VIP + 400 General

// Sold tickets
int get ticketsSold => 105; // 5 VIP + 100 General

// Reservation percentage
double get reservationPercentage => 17.5; // (105/600) * 100

// Formatted date for display
String get formattedDate => "3 days"; // Smart date formatting

// Category display name
String get categoryDisplayName => "Music"; // Convert CONCERT to Music
```

## 4. How Data Reaches Recommendation Cards

### 4.1 Data Fetching (home_page.dart)
```dart
// 1. Fetch events from API
final response = await ApiService.get('/events');
final List<dynamic> data = json.decode(response.body);

// 2. Parse JSON into Event objects
_allEvents = data.map((json) => Event.fromJson(json)).toList();

// 3. Filter events by category
List<Event> _getEventsByCategory(String category) {
  return _allEvents.where((event) => event.category == category).toList();
}

// 4. Pass events to EventCategoryRow
EventCategoryRow(
  categoryTitle: 'Music Concerts',
  events: _getEventsByCategory('CONCERT'),
),
```

### 4.2 EventCategoryRow Processing (event-category-row.dart)
```dart
// 1. Receive list of events
final List<Event> events;

// 2. Create horizontal scrollable list
ListView.builder(
  itemBuilder: (context, index) {
    final event = events[index];
    
    // 3. Pass Event object to RecommendationCard
    return RecommendationCard(
      event: event,  // ← Pass the entire Event object
      onTap: () => Navigator.push(...),
      onFavoriteTap: () => print('...'),
    );
  },
)
```

### 4.3 RecommendationCard Display (recommendation-cards.dart)
```dart
// 1. Receive Event object
final Event event;

// 2. Access computed properties directly
Widget build(BuildContext context) {
  return Container(
    child: Column(
      children: [
        // Display event title
        Text(event.title),  // Uses event.name
        
        // Display location with icon
        Row(
          children: [
            Icon(Icons.location_on),
            Text(event.location),  // Direct field access
          ],
        ),
        
        // Display smart formatted date
        Text(event.formattedDate),  // Uses computed getter
        
        // Display price range
        Text(event.priceRange),     // Uses computed getter
        
        // Display availability
        Text('${event.availableTickets} left'),  // Uses computed getter
        
        // Display category
        Text(event.categoryDisplayName),  // Uses computed getter
        
        // Display progress bar
        FractionallySizedBox(
          widthFactor: event.reservationPercentage / 100,  // Uses computed getter
        ),
      ],
    ),
  );
}
```

## 5. Key Benefits of This Architecture

### 5.1 Separation of Concerns
- **Event Model**: Handles data parsing, validation, and computation
- **UI Components**: Focus only on display and user interaction
- **Business Logic**: Centralized in the model's computed properties

### 5.2 Data Consistency
- All UI components use the same computed values
- Changes to calculation logic only need to be made in one place
- No risk of different components calculating values differently

### 5.3 Easy Maintenance
- Adding new computed properties doesn't require UI changes
- API structure changes only affect the model parsing
- UI components automatically benefit from model improvements

### 5.4 Type Safety
- Strong typing prevents runtime errors
- IDE autocomplete provides all available properties
- Compile-time checking catches type mismatches

## 6. Example: Adding a New Display Field

### 6.1 Add to Event Model
```dart
// Add new computed property
String get eventStatus {
  if (isSoldOut) return 'Sold Out';
  if (reservationPercentage > 80) return 'Almost Full';
  if (reservationPercentage > 50) return 'Limited Availability';
  return 'Available';
}
```

### 6.2 Use in RecommendationCard
```dart
// Automatically available without changing constructor
Text(
  event.eventStatus,  // ← New property automatically available
  style: TextStyle(color: Colors.orange),
)
```

## 7. Data Flow Summary

```
API Response
     ↓
Event.fromJson() → Creates Event object with computed properties
     ↓
Event object passed to EventCategoryRow
     ↓
EventCategoryRow creates RecommendationCard with event parameter
     ↓
RecommendationCard accesses event properties and computed values
     ↓
UI displays formatted information to user
```

This architecture ensures that:
- Data flows in one direction (API → Model → UI)
- Computed values are calculated once and reused
- UI components remain simple and focused
- Changes to data structure only affect the model layer
- All components automatically benefit from model improvements
