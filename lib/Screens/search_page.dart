import 'package:flutter/material.dart';

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
      title: 'Arijit Singh Live',
      imageUrl: 'https://placehold.co/600x300/ff4081/white?text=Arijit',
      date: '24 May 2025, 7 PM',
      location: 'Jio World Centre, Mumbai',
      price: '2500',
      category: 'Music',
      creationDate: DateTime(2025, 8, 1),
      totalTickets: 1000,
      ticketsSold: 800,
    ),
    Event(
      title: 'Sunburn Festival Goa',
      imageUrl: 'https://placehold.co/600x300/e67e22/white?text=Sunburn',
      date: '28 Dec 2025, 2 PM',
      location: 'Vagator, Goa',
      price: '3000',
      category: 'Music',
      creationDate: DateTime(2025, 8, 5),
      totalTickets: 5000,
      ticketsSold: 100,
    ),
    Event(
      title: 'Zakir Khan Live',
      imageUrl: 'https://placehold.co/300x400/c0392b/fff?text=Zakir',
      date: 'Fri, Jun 10 • 8:00 pm',
      location: 'Hard Rock Cafe, Delhi',
      price: '999',
      category: 'Comedy',
      creationDate: DateTime(2025, 5, 1),
      totalTickets: 300,
      ticketsSold: 100,
    ),
    Event(
      title: 'India vs Australia',
      imageUrl: 'https://placehold.co/300x400/3498db/fff?text=Cricket',
      date: 'Sun, Nov 05 • 2:00 pm',
      location: 'Wankhede Stadium, Mumbai',
      price: '1500',
      category: 'Sports',
      creationDate: DateTime(2025, 8, 1),
      totalTickets: 10000,
      ticketsSold: 2000,
    ),
  ];

  List<Event> _getRecommendedEvents() {
    final now = DateTime.now();
    return _allEvents.where((event) {
      final isNew = now.difference(event.creationDate).inDays <= 30;
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
                event.imageUrl,
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
                    event.title,
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
