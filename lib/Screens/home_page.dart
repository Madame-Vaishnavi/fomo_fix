import 'package:flutter/material.dart';
import 'package:fomo_fix/booking-page.dart';
import 'package:fomo_fix/cards/event-cards.dart';
import 'package:fomo_fix/cards/recommendation-cards.dart';

class HomePage extends StatefulWidget {
  final Function(int) onNavigate;

  const HomePage({
    super.key,
    required this.onNavigate,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Sample data for main events
  final List<Event> _mainEvents = [
    const Event(
      title: 'Arijit Singh Live In Concert',
      imageUrl: 'https://placehold.co/600x300/ff4081/white?text=Arijit+Singh',
      date: '24 May 2025, 7 PM',
      location: 'Jio World Centre, Mumbai',
      price: 'Starts from Rs2500',
    ),
    const Event(
      title: 'Sunburn Festival Goa',
      imageUrl: 'https://placehold.co/600x300/e67e22/white?text=Sunburn',
      date: '28 Dec 2025, 2 PM',
      location: 'Vagator, Goa',
      price: 'Starts from Rs3000',
    ),
  ];

  // Sample data for recommended events
  final List<Event> _recommendedEvents = [
    const Event(
      title: 'An Evening of Elegance',
      imageUrl: 'https://placehold.co/300x400/8e44ad/fff?text=Ghazal',
      date: 'Mon, Apr 25 • 10:00 pm',
      location: '833 Ballistreri Station. UK',
      price: 'CA\$50.00',
    ),
    const Event(
      title: 'Rock On Stage',
      imageUrl: 'https://placehold.co/300x400/c0392b/fff?text=Rock',
      date: 'Fri, Jun 10 • 8:00 pm',
      location: 'Hard Rock Cafe, Delhi',
      price: 'Rs1500.00',
    ),
    const Event(
      title: 'Comedy Nights',
      imageUrl: 'https://placehold.co/300x400/27ae60/fff?text=Comedy',
      date: 'Sat, Jul 15 • 9:00 pm',
      location: 'The Comedy Store, Mumbai',
      price: 'Rs799.00',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Your new logo
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
                child: Image(
                  image: const AssetImage("assets/logo.png"), // Make sure this asset exists
                  width: 180,
                  errorBuilder: (context, error, stackTrace) =>
                  const Text('Logo not found', style: TextStyle(color: Colors.red)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    _buildSearchBar(context, widget.onNavigate),
                    const SizedBox(height: 24),
                    _buildCategoryIcons(), // Your new categories
                    const SizedBox(height: 24),
                  ],
                ),
              ),
              _buildEventList(),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: _buildRecommendationsHeader(),
              ),
              const SizedBox(height: 16),
              _buildRecommendationsList(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, Function(int) onNavigate) {
    return GestureDetector(
      onTap: () {
        onNavigate(1);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: const Row(
          children: [
            Icon(Icons.search, color: Colors.white54),
            SizedBox(width: 8),
            Text(
              "Search...", // Your updated hint text
              style: TextStyle(color: Colors.white54),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryIcons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Your updated categories
        _buildCategoryItem(Icons.movie_creation, 'Theatre', Colors.green),
        _buildCategoryItem(Icons.mic, 'Comedy', Colors.blue),
        _buildCategoryItem(Icons.music_note_outlined, 'Music', Colors.orange),
        _buildCategoryItem(Icons.sports_cricket, 'Sports', Colors.yellow),
      ],
    );
  }

  Widget _buildCategoryItem(IconData icon, String label, Color color) {
    return InkWell(
      onTap: () {
        print('$label category tapped');
      },
      borderRadius: BorderRadius.circular(12),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[850],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 30),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }

  // --- UPDATED to navigate to BookingPage ---
  Widget _buildEventList() {
    return SizedBox(
      height: 310,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _mainEvents.length,
        padding: const EdgeInsets.only(left: 16.0),
        itemBuilder: (context, index) {
          final event = _mainEvents[index];
          return EventCard(
            imageUrl: event.imageUrl,
            date: event.date,
            title: event.title,
            price: event.price,
            onTap: () {
              // Navigate to BookingPage with the selected event data
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BookingPage(event: event),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildRecommendationsHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Recommendations',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
      ],
    );
  }

  // --- UPDATED to navigate to BookingPage ---
  Widget _buildRecommendationsList() {
    return SizedBox(
      height: 280,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _recommendedEvents.length,
        padding: const EdgeInsets.only(left: 16.0),
        itemBuilder: (context, index) {
          final event = _recommendedEvents[index];
          return RecommendationCard(
            imageUrl: event.imageUrl,
            title: event.title,
            location: event.location,
            date: event.date,
            price: event.price,
            onTap: () {
              // Navigate to BookingPage with the selected event data
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BookingPage(event: event),
                ),
              );
            },
            onFavoriteTap: () {
              print('Favorite tapped on ${event.title}');
            },
          );
        },
      ),
    );
  }
}
