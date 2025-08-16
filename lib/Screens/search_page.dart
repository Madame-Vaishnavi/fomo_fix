import 'package:flutter/material.dart';
import '../models/event.dart';
import 'booking-page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final List<String> _recentSearches = [
    'Concerts',
    'Stand-up',
    'Workshops',
    'Theatre',
    'Exhibitions',
  ];

  // --- Event data and filtering logic from HomePage ---
  final List<Event> _allEvents = [
    Event(
      name: 'Arijit Singh Live',
      description: 'Live performance by Arijit Singh',
      imageUrl: 'https://placehold.co/600x300/ff4081/white?text=Arijit',
      date: '2025-05-24T19:00:00',
      location: 'Jio World Centre, Mumbai',
      category: 'CONCERT',
      seatCategories: [
        SeatCategory(
          categoryName: 'VIP',
          totalSeats: 200,
          availableSeats: 50,
          pricePerSeat: 5000.0,
        ),
        SeatCategory(
          categoryName: 'General',
          totalSeats: 800,
          availableSeats: 200,
          pricePerSeat: 2500.0,
        ),
      ],
      creationDate: DateTime(2025, 8, 1),
    ),
    Event(
      name: 'Sunburn Festival Goa',
      description: 'Annual electronic dance music festival',
      imageUrl: 'https://placehold.co/600x300/e67e22/white?text=Sunburn',
      date: '2025-12-28T14:00:00',
      location: 'Vagator, Goa',
      category: 'FESTIVAL',
      seatCategories: [
        SeatCategory(
          categoryName: 'Early Bird',
          totalSeats: 2000,
          availableSeats: 1900,
          pricePerSeat: 2500.0,
        ),
        SeatCategory(
          categoryName: 'Regular',
          totalSeats: 3000,
          availableSeats: 2900,
          pricePerSeat: 3000.0,
        ),
      ],
      creationDate: DateTime(2025, 8, 5),
    ),
    Event(
      name: 'Zakir Khan Live',
      description: 'Stand-up comedy by Zakir Khan',
      imageUrl: 'https://placehold.co/300x400/c0392b/fff?text=Zakir',
      date: '2025-06-10T20:00:00',
      location: 'Hard Rock Cafe, Delhi',
      category: 'COMEDY',
      seatCategories: [
        SeatCategory(
          categoryName: 'Premium',
          totalSeats: 100,
          availableSeats: 80,
          pricePerSeat: 1500.0,
        ),
        SeatCategory(
          categoryName: 'Standard',
          totalSeats: 200,
          availableSeats: 100,
          pricePerSeat: 999.0,
        ),
      ],
      creationDate: DateTime(2025, 5, 1),
    ),
    Event(
      name: 'India vs Australia',
      description: 'Cricket match between India and Australia',
      imageUrl: 'https://placehold.co/300x400/3498db/fff?text=Cricket',
      date: '2025-11-05T14:00:00',
      location: 'Wankhede Stadium, Mumbai',
      category: 'SPORTS',
      seatCategories: [
        SeatCategory(
          categoryName: 'Premium',
          totalSeats: 2000,
          availableSeats: 500,
          pricePerSeat: 3000.0,
        ),
        SeatCategory(
          categoryName: 'General',
          totalSeats: 8000,
          availableSeats: 6000,
          pricePerSeat: 1500.0,
        ),
      ],
      creationDate: DateTime(2025, 8, 1),
    ),
  ];

  List<Event> _getRecommendedEvents() {
    final now = DateTime.now();
    return _allEvents.where((event) {
      final isNew = event.creationDate != null && 
          now.difference(event.creationDate!).inDays <= 30;
      final isNotFull = event.reservationPercentage < 50;
      return isNew || isNotFull;
    }).toList();
  }
  // --- END of added logic ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Search',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: ListView(
          children: [
            _buildSearchField(),
            const SizedBox(height: 24),
            _buildSectionHeader('Recent Searches'),
            const SizedBox(height: 12),
            _buildRecentSearchChips(),
            const SizedBox(height: 24),
            _buildSectionHeader('Trending Events'),
            const SizedBox(height: 16),
            _buildTrendingEventsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: "Search for Events, Plays, Activities..",
        hintStyle: TextStyle(color: Colors.grey[600]),
        prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
        filled: true,
        fillColor: Colors.grey[900],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildRecentSearchChips() {
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: _recentSearches.map((term) {
        return Chip(
          label: Text(term, style: const TextStyle(color: Colors.white70)),
          backgroundColor: Colors.grey[850],
          deleteIcon: const Icon(Icons.close, size: 16, color: Colors.white70),
          onDeleted: () {
            setState(() {
              _recentSearches.remove(term);
            });
          },
          side: BorderSide.none,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          elevation: 0,
        );
      }).toList(),
    );
  }

  // --- UPDATED: This widget now builds the trending events with the old list item style ---
  Widget _buildTrendingEventsList() {
    final trendingEvents = _getRecommendedEvents().take(3).toList();

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: trendingEvents.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final event = trendingEvents[index];
        return _buildEventListItem(event: event);
      },
    );
  }

  // --- NEW: Re-added the old list item builder for the trending section ---
  Widget _buildEventListItem({required Event event}) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BookingPage(event: event),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12.0),
      child: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.network(
                event.imageUrl ?? 'https://picsum.photos/300/200?random=1',
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Container(width: 80, height: 80, color: Colors.grey[800]),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    event.category,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white54,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
