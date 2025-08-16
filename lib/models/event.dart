// Seat category model for different ticket types
class SeatCategory {
  final String categoryName;
  final int totalSeats;
  final int availableSeats;
  final double pricePerSeat;

  const SeatCategory({
    required this.categoryName,
    required this.totalSeats,
    required this.availableSeats,
    required this.pricePerSeat,
  });

  // Factory constructor to create SeatCategory from JSON
  factory SeatCategory.fromJson(Map<String, dynamic> json) {
    return SeatCategory(
      categoryName: json['categoryName'] ?? '',
      totalSeats: json['totalSeats'] ?? 0,
      availableSeats: json['availableSeats'] ?? 0,
      pricePerSeat: (json['pricePerSeat'] ?? 0.0).toDouble(),
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'categoryName': categoryName,
      'totalSeats': totalSeats,
      'availableSeats': availableSeats,
      'pricePerSeat': pricePerSeat,
    };
  }

  // Helper to calculate sold seats
  int get soldSeats => totalSeats - availableSeats;

  // Helper to calculate reservation percentage
  double get reservationPercentage => (soldSeats / totalSeats) * 100;

  // Helper to check if category is available
  bool get isAvailable => availableSeats > 0;
}

// Main Event model that matches the API structure
class Event {
  final int? id;
  final String name;
  final String description;
  final String location;
  final String date;
  final String category;
  final List<SeatCategory> seatCategories;
  final String? imageUrl; // Optional field for UI display
  final DateTime? creationDate; // Optional field for sorting/filtering

  const Event({
    this.id,
    required this.name,
    required this.description,
    required this.location,
    required this.date,
    required this.category,
    required this.seatCategories,
    this.imageUrl,
    this.creationDate,
  });

  // Factory constructor to create Event from JSON
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
              .toList() ??
          [],
      imageUrl: json['imageUrl'],
      creationDate: json['creationDate'] != null
          ? DateTime.parse(json['creationDate'])
          : null,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'location': location,
      'date': date,
      'category': category,
      'seatCategories': seatCategories.map((seat) => seat.toJson()).toList(),
      'imageUrl': imageUrl,
      'creationDate': creationDate?.toIso8601String(),
    };
  }

  // Helper getters for backward compatibility and UI convenience
  
  // Title (alias for name)
  String get title => name;
  
  // Price - returns the lowest price from available seat categories
  String get price {
    if (seatCategories.isEmpty) return '0';
    
    final availableCategories = seatCategories.where((seat) => seat.isAvailable);
    if (availableCategories.isEmpty) return 'Sold Out';
    
    final lowestPrice = availableCategories
        .map((seat) => seat.pricePerSeat)
        .reduce((a, b) => a < b ? a : b);
    
    return lowestPrice.toStringAsFixed(0);
  }
  
  // Total tickets across all seat categories
  int get totalTickets {
    return seatCategories.fold(0, (sum, seat) => sum + seat.totalSeats);
  }
  
  // Total tickets sold across all seat categories
  int get ticketsSold {
    return seatCategories.fold(0, (sum, seat) => sum + seat.soldSeats);
  }
  
  // Total available tickets across all seat categories
  int get availableTickets {
    return seatCategories.fold(0, (sum, seat) => sum + seat.availableSeats);
  }
  
  // Overall reservation percentage
  double get reservationPercentage {
    if (totalTickets == 0) return 0.0;
    return (ticketsSold / totalTickets) * 100;
  }
  
  // Check if event has any available tickets
  bool get hasAvailableTickets => availableTickets > 0;
  
  // Check if event is sold out
  bool get isSoldOut => availableTickets == 0;
  
  // Get the lowest price seat category
  SeatCategory? get lowestPriceCategory {
    if (seatCategories.isEmpty) return null;
    
    return seatCategories.reduce((a, b) => 
        a.pricePerSeat < b.pricePerSeat ? a : b);
  }
  
  // Get the highest price seat category
  SeatCategory? get highestPriceCategory {
    if (seatCategories.isEmpty) return null;
    
    return seatCategories.reduce((a, b) => 
        a.pricePerSeat > b.pricePerSeat ? a : b);
  }
  
  // Get price range string (e.g., "Rs. 75 - Rs. 150")
  String get priceRange {
    if (seatCategories.isEmpty) return 'Price not available';
    
    final lowest = lowestPriceCategory;
    final highest = highestPriceCategory;
    
    if (lowest == null || highest == null) return 'Price not available';
    
    if (lowest.pricePerSeat == highest.pricePerSeat) {
      return 'Rs. ${lowest.pricePerSeat.toStringAsFixed(0)}';
    }
    
    return 'Rs. ${lowest.pricePerSeat.toStringAsFixed(0)} - Rs. ${highest.pricePerSeat.toStringAsFixed(0)}';
  }
  
  // Format date for display
  String get formattedDate {
    try {
      final dateTime = DateTime.parse(date);
      final now = DateTime.now();
      final difference = dateTime.difference(now).inDays;
      
      if (difference == 0) return 'Today';
      else if (difference == 1) return 'Tomorrow';
      else return '${dateTime.day}/${dateTime.month}/${dateTime.year}';

    } catch (e) {
      return date;
    }
  }
  
  // Get category display name (convert from API format to display format)
  String get categoryDisplayName {
    switch (category.toUpperCase()) {
      case 'CONCERT':
        return 'Music';
      case 'THEATER':
        return 'Theatre';
      case 'SPORTS':
        return 'Sports';
      case 'CONFERENCE':
        return 'Conference';
      case 'WORKSHOP':
        return 'Workshop';
      case 'EXHIBITION':
        return 'Exhibition';
      case 'FESTIVAL':
        return 'Festival';
      case 'COMEDY':
        return 'Comedy';
      case 'DANCE':
        return 'Dance';
      case 'MOVIE':
        return 'Movie';
      default:
        return category;
    }
  }
}
