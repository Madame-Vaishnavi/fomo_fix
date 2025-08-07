import 'package:flutter/material.dart';

import '../booking-page.dart';
import '../cards/event-cards.dart';
import '../cards/event-category-row.dart';


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
  // --- FIX: Using a single master list for all events ---
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
      title: 'Anubhav Singh Bassi',
      imageUrl: 'https://placehold.co/300x400/27ae60/fff?text=Bassi',
      date: 'Sat, Jul 15 • 9:00 pm',
      location: 'The Comedy Store, Mumbai',
      price: '799',
      category: 'Comedy',
      creationDate: DateTime(2025, 6, 20),
      totalTickets: 200,
      ticketsSold: 150,
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
    Event(
      title: 'Mughal-e-Azam',
      imageUrl: 'https://placehold.co/300x400/8e44ad/fff?text=Theatre',
      date: 'Mon, Apr 25 • 10:00 pm',
      location: 'NCPA, Mumbai',
      price: '1200',
      category: 'Theatre',
      creationDate: DateTime(2025, 3, 15),
      totalTickets: 500,
      ticketsSold: 450,
    ),
  ];

  // --- FIX: Added helper functions to filter events ---
  List<Event> _getEventsByCategory(String category) {
    return _allEvents.where((event) => event.category == category).toList();
  }

  List<Event> _getRecommendedEvents() {
    final now = DateTime.now();
    return _allEvents.where((event) {
      final isNew = now.difference(event.creationDate).inDays <= 30;
      final isNotFull = event.reservationPercentage < 50;
      return isNew || isNotFull;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
                child: Image(
                  image: const AssetImage("assets/logo.png"),
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
                    _buildSearchBar(context, widget.onNavigate),
                    const SizedBox(height: 18),
                    _buildCategoryIcons(),
                    const SizedBox(height: 18),
                  ],
                ),
              ),

              // --- ADDED BACK: The top horizontal list of large event cards ---
              _buildEventList(),
              const SizedBox(height: 24),

              // --- FIX: Replaced old lists with modular, filtered category rows ---
              EventCategoryRow(
                categoryTitle: 'Recommendations',
                events: _getRecommendedEvents(),
              ),
              const SizedBox(height: 24),
              EventCategoryRow(
                categoryTitle: 'Music Concerts',
                events: _getEventsByCategory('Music'),
              ),
              const SizedBox(height: 24),
              EventCategoryRow(
                categoryTitle: 'Comedy Shows',
                events: _getEventsByCategory('Comedy'),
              ),
              const SizedBox(height: 24),
              EventCategoryRow(
                categoryTitle: 'Theatre & Arts',
                events: _getEventsByCategory('Theatre'),
              ),
              const SizedBox(height: 24),
              EventCategoryRow(
                categoryTitle: 'Sporting Events',
                events: _getEventsByCategory('Sports'),
              ),
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
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: const Row(
          children: [
            Icon(Icons.search, color: Colors.white54),
            SizedBox(width: 8),
            Text(
              "Search...",
              style: TextStyle(color: Colors.white54),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryIcons() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildCategoryItem(Icons.movie_creation, 'Theatre', Colors.green),
          const SizedBox(width: 10,),
          _buildCategoryItem(Icons.mic, 'Comedy', Colors.blue),
          const SizedBox(width: 10,),
          _buildCategoryItem(Icons.music_note_outlined, 'Music', Colors.orange),
          const SizedBox(width: 10,),
          _buildCategoryItem(Icons.sports_cricket, 'Sports', Colors.yellow),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(IconData icon, String label, Color color) {
    return InkWell(
      onTap: () {
        print('$label category tapped');
      },
      borderRadius: BorderRadius.circular(7),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(7),
            border: Border.all(color: Colors.grey.shade800)
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 10,),
            Text(label, style: const TextStyle(color: Colors.white70,fontSize: 13)),
          ],
        ),
      ),
    );
  }

  // --- ADDED BACK: Widget to build the top horizontal event list ---
  Widget _buildEventList() {
    // We'll feature the first 2 events from the main list, for example.
    final featuredEvents = _allEvents.take(2).toList();

    return SizedBox(
      height: 310,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: featuredEvents.length,
        padding: const EdgeInsets.only(left: 16.0),
        itemBuilder: (context, index) {
          final event = featuredEvents[index];
          return EventCard(
            imageUrl: event.imageUrl,
            date: event.date,
            title: event.title,
            price: event.price,
            onTap: () {
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
}
