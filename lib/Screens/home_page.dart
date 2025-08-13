import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fomo_fix/api-service.dart';
import 'package:fomo_fix/cards/event-category-row.dart';
import 'package:fomo_fix/Screens/category_page.dart';
import 'package:fomo_fix/config.dart';
import 'booking-page.dart';

class HomePage extends StatefulWidget {
  final Function(int) onNavigate;

  const HomePage({super.key, required this.onNavigate});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // --- State for API data and loading status ---
  List<Event> _allEvents = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Fetch events when the page first loads
    _fetchEvents();
  }

  // --- FIX: Fetches and PARSES all events once ---
  Future<void> _fetchEvents() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Assuming ApiService.get returns a Future<http.Response>
      final baseUrl = ApiService.baseUrl;
      print('=== API Connection Debug ===');
      print('Base URL: $baseUrl');
      print('Full endpoint: $baseUrl/events');
      print('Config useLocalServer: ${AppConfig.useLocalServer}');
      print('Config androidEmulatorUrl: ${AppConfig.androidEmulatorUrl}');
      print('Config localhostUrl: ${AppConfig.localhostUrl}');
      print('===========================');

      final response = await ApiService.get('/events');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print(response);
        setState(() {
          // Parse the list of maps into a list of Event objects
          _allEvents = data.map((json) => Event.fromJson(json)).toList();
          _isLoading = false;
        });
      } else {
        // Handle server errors
        setState(() {
          _isLoading = false;
          _errorMessage = 'Server error: ${response.statusCode}';
        });
        print('Failed to load events: ${response.statusCode}');
      }
    } catch (e) {
      // Handle network or other errors
      String errorMsg = 'Network error occurred';

      if (e.toString().contains('Connection refused')) {
        errorMsg =
            'Cannot connect to server. Please check if your backend is running on port 8080.';
      } else if (e.toString().contains('SocketException')) {
        errorMsg =
            'Network connection failed. Please check your internet connection and server status.';
      } else if (e.toString().contains('localhost')) {
        errorMsg =
            'Server connection failed. For mobile devices, use 10.0.2.2:8080 instead of localhost:8080.';
      }

      setState(() {
        _isLoading = false;
        _errorMessage = errorMsg;
      });
      print('An error occurred: $e');

      // Load mock data for development/testing
      _loadMockData();
    }
  }

  // Load mock data when API is not available
  void _loadMockData() {
    setState(() {
      _allEvents = [
        Event(
          title: 'Rock Concert 2024',
          imageUrl: 'https://picsum.photos/300/200?random=1',
          date: '2024-03-15',
          location: 'Central Park, NY',
          price: '50',
          category: 'Music',
          creationDate: DateTime.now().subtract(const Duration(days: 5)),
          totalTickets: 1000,
          ticketsSold: 750,
        ),
        Event(
          title: 'Comedy Night',
          imageUrl: 'https://picsum.photos/300/200?random=2',
          date: '2024-03-20',
          location: 'Comedy Club, LA',
          price: '25',
          category: 'Comedy',
          creationDate: DateTime.now().subtract(const Duration(days: 10)),
          totalTickets: 200,
          ticketsSold: 50,
        ),
        Event(
          title: 'Shakespeare in the Park',
          imageUrl: 'https://picsum.photos/300/200?random=3',
          date: '2024-03-25',
          location: 'Theatre District, NY',
          price: '35',
          category: 'Theatre',
          creationDate: DateTime.now().subtract(const Duration(days: 15)),
          totalTickets: 500,
          ticketsSold: 300,
        ),
        Event(
          title: 'Basketball Championship',
          imageUrl: 'https://picsum.photos/300/200?random=4',
          date: '2024-03-30',
          location: 'Madison Square Garden',
          price: '80',
          category: 'Sports',
          creationDate: DateTime.now().subtract(const Duration(days: 20)),
          totalTickets: 20000,
          ticketsSold: 18000,
        ),
      ];
      _isLoading = false;
      _errorMessage = null;
    });
  }

  // --- FIX: Now a synchronous function that filters the local list ---
  List<Event> _getEventsByCategory(String category) {
    return _allEvents.where((event) => event.category == category).toList();
  }

  // --- FIX: Now correctly filters the local list of Event objects ---
  List<Event> _getRecommendedEvents() {
    final now = DateTime.now();
    return _allEvents.where((event) {
      // Set a threshold for what "newly created" means, e.g., 30 days
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
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: Colors.deepPurpleAccent,
                ),
              )
            : _errorMessage != null
            ? _buildErrorWidget()
            : RefreshIndicator(
                onRefresh: _fetchEvents,
                color: Colors.deepPurpleAccent,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15.0,
                          vertical: 8.0,
                        ),
                        child: Image(
                          image: const AssetImage("assets/logo.png"),
                          width: 180,
                          errorBuilder: (context, error, stackTrace) =>
                              const Text(
                                'Logo not found',
                                style: TextStyle(color: Colors.red),
                              ),
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
                      const SizedBox(height: 24),
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
            Text("Search...", style: TextStyle(color: Colors.white54)),
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
          const SizedBox(width: 10),
          _buildCategoryItem(Icons.mic, 'Comedy', Colors.blue),
          const SizedBox(width: 10),
          _buildCategoryItem(Icons.music_note_outlined, 'Music', Colors.orange),
          const SizedBox(width: 10),
          _buildCategoryItem(Icons.sports_cricket, 'Sports', Colors.yellow),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(IconData icon, String label, Color color) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CategoryPage(
              categoryTitle: '$label Events',
              events: _getEventsByCategory(label),
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(7),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(7),
          border: Border.all(color: Colors.grey.shade800),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 64),
          const SizedBox(height: 16),
          Text(
            'Failed to load events',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage ?? 'Unknown error',
            style: const TextStyle(color: Colors.white70, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _fetchEvents,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurpleAccent,
              foregroundColor: Colors.white,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
