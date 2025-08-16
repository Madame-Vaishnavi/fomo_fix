import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fomo_fix/api-service.dart';
import 'package:fomo_fix/cards/event-category-row.dart';
import 'package:fomo_fix/Screens/category_page.dart';
import 'package:fomo_fix/config.dart';
import 'package:fomo_fix/models/event.dart';

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
  bool _isRefreshing = false; // NEW: Track refresh state separately
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Fetch events when the page first loads
    _fetchEvents();
  }

  // --- ENHANCED: Fetches and PARSES all events with refresh support ---
  Future<void> _fetchEvents({bool isRefresh = false}) async {
    try {
      setState(() {
        if (isRefresh) {
          _isRefreshing = true;
        } else {
          _isLoading = true;
        }
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
      print('Is Refresh: $isRefresh');
      print('===========================');

      final response = await ApiService.get('/events');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print('Events loaded successfully: ${data.length} events');
        print(data);

        setState(() {
          // Parse the list of maps into a list of Event objects
          _allEvents = data.map((json) => Event.fromJson(json)).toList();
          _isLoading = false;
          _isRefreshing = false;
        });

        // Show success message only on manual refresh
        if (isRefresh && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Events refreshed successfully!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        // Handle server errors
        setState(() {
          _isLoading = false;
          _isRefreshing = false;
          _errorMessage = 'Server error: ${response.statusCode}';
        });
        print('Failed to load events: ${response.statusCode}');

        // Show error message on refresh
        if (isRefresh && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to refresh: Server error ${response.statusCode}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
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
        _isRefreshing = false;
        _errorMessage = errorMsg;
      });
      print('An error occurred: $e');

      // Show error message on refresh
      if (isRefresh && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Refresh failed: $errorMsg'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }

      // Load mock data for development/testing (only if not refreshing)
      if (!isRefresh || _allEvents.isEmpty) {
        _loadMockData();
      }
    }
  }

  // NEW: Enhanced refresh handler
  Future<void> _handleRefresh() async {
    await _fetchEvents(isRefresh: true);
  }

  // Load mock data when API is not available
  void _loadMockData() {
    setState(() {
      _allEvents = [
        Event(
          name: 'Rock Concert 2024',
          description: 'Amazing rock concert featuring top artists',
          imageUrl: 'https://picsum.photos/300/200?random=1',
          date: '2024-03-15T19:00:00',
          location: 'Central Park, NY',
          category: 'CONCERT',
          seatCategories: [
            SeatCategory(
              categoryName: 'VIP',
              totalSeats: 200,
              availableSeats: 50,
              pricePerSeat: 150.0,
            ),
            SeatCategory(
              categoryName: 'General',
              totalSeats: 800,
              availableSeats: 200,
              pricePerSeat: 75.0,
            ),
          ],
          creationDate: DateTime.now().subtract(const Duration(days: 5)),
        ),
        Event(
          name: 'Comedy Night',
          description: 'Laugh your heart out with top comedians',
          imageUrl: 'https://picsum.photos/300/200?random=2',
          date: '2024-03-20T20:00:00',
          location: 'Comedy Club, LA',
          category: 'COMEDY',
          seatCategories: [
            SeatCategory(
              categoryName: 'Premium',
              totalSeats: 100,
              availableSeats: 80,
              pricePerSeat: 50.0,
            ),
            SeatCategory(
              categoryName: 'Standard',
              totalSeats: 100,
              availableSeats: 70,
              pricePerSeat: 25.0,
            ),
          ],
          creationDate: DateTime.now().subtract(const Duration(days: 10)),
        ),
        Event(
          name: 'Shakespeare in the Park',
          description: 'Classic Shakespeare performed outdoors',
          imageUrl: 'https://picsum.photos/300/200?random=3',
          date: '2024-03-25T18:00:00',
          location: 'Theatre District, NY',
          category: 'THEATER',
          seatCategories: [
            SeatCategory(
              categoryName: 'Front Row',
              totalSeats: 100,
              availableSeats: 20,
              pricePerSeat: 100.0,
            ),
            SeatCategory(
              categoryName: 'General Admission',
              totalSeats: 400,
              availableSeats: 200,
              pricePerSeat: 35.0,
            ),
          ],
          creationDate: DateTime.now().subtract(const Duration(days: 15)),
        ),
        Event(
          name: 'Basketball Championship',
          description: 'Championship game with top teams',
          imageUrl: 'https://picsum.photos/300/200?random=4',
          date: '2024-03-30T19:30:00',
          location: 'Madison Square Garden',
          category: 'SPORTS',
          seatCategories: [
            SeatCategory(
              categoryName: 'Courtside',
              totalSeats: 50,
              availableSeats: 5,
              pricePerSeat: 500.0,
            ),
            SeatCategory(
              categoryName: 'Lower Bowl',
              totalSeats: 5000,
              availableSeats: 500,
              pricePerSeat: 150.0,
            ),
            SeatCategory(
              categoryName: 'Upper Bowl',
              totalSeats: 15000,
              availableSeats: 2000,
              pricePerSeat: 80.0,
            ),
          ],
          creationDate: DateTime.now().subtract(const Duration(days: 20)),
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
      final isNew = event.creationDate != null && 
          now.difference(event.creationDate!).inDays <= 30;
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
          onRefresh: _handleRefresh,
          color: Colors.deepPurpleAccent,
          backgroundColor: Colors.grey[900],
          strokeWidth: 3.0,
          displacement: 40.0, // Distance from top of the widget
          child: Stack(
            children: [
              SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(), // Ensure scroll is always enabled
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

                    // NEW: Show refresh indicator when refreshing
                    if (_isRefreshing)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(
                                color: Colors.deepPurpleAccent,
                                strokeWidth: 2,
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Refreshing events...',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),

                    EventCategoryRow(
                      categoryTitle: 'Recommendations',
                      events: _getRecommendedEvents(),
                    ),
                    const SizedBox(height: 24),
                    EventCategoryRow(
                      categoryTitle: 'Music Concerts',
                      events: _getEventsByCategory('CONCERT'),
                    ),
                    const SizedBox(height: 24),
                    EventCategoryRow(
                      categoryTitle: 'Comedy Shows',
                      events: _getEventsByCategory('COMEDY'),
                    ),
                    const SizedBox(height: 24),
                    EventCategoryRow(
                      categoryTitle: 'Theatre & Arts',
                      events: _getEventsByCategory('THEATER'),
                    ),
                    const SizedBox(height: 24),
                    EventCategoryRow(
                      categoryTitle: 'Sporting Events',
                      events: _getEventsByCategory('SPORTS'),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
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
          _buildCategoryItem(Icons.movie_creation, 'THEATER', Colors.green),
          const SizedBox(width: 10),
          _buildCategoryItem(Icons.mic, 'COMEDY', Colors.blue),
          const SizedBox(width: 10),
          _buildCategoryItem(Icons.music_note_outlined, 'CONCERT', Colors.orange),
          const SizedBox(width: 10),
          _buildCategoryItem(Icons.sports_cricket, 'SPORTS', Colors.yellow),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(IconData icon, String category, Color color) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CategoryPage(
              categoryTitle: '${_getCategoryDisplayName(category)} Events',
              events: _getEventsByCategory(category),
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
              _getCategoryDisplayName(category),
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to get display names for categories
  String _getCategoryDisplayName(String category) {
    switch (category.toUpperCase()) {
      case 'CONCERT':
        return 'Music';
      case 'THEATER':
        return 'Theatre';
      case 'SPORTS':
        return 'Sports';
      case 'COMEDY':
        return 'Comedy';
      case 'CONFERENCE':
        return 'Conference';
      case 'WORKSHOP':
        return 'Workshop';
      case 'EXHIBITION':
        return 'Exhibition';
      case 'FESTIVAL':
        return 'Festival';
      case 'DANCE':
        return 'Dance';
      case 'MOVIE':
        return 'Movie';
      default:
        return category;
    }
  }

  // ENHANCED: Better error widget with refresh option
  Widget _buildErrorWidget() {
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      color: Colors.deepPurpleAccent,
      backgroundColor: Colors.grey[900],
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.8,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 64),
                const SizedBox(height: 16),
                const Text(
                  'Failed to load events',
                  style: TextStyle(
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _isRefreshing ? null : () => _fetchEvents(),
                      icon: _isRefreshing
                          ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                          : const Icon(Icons.refresh),
                      label: Text(_isRefreshing ? 'Retrying...' : 'Retry'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurpleAccent,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 16),
                    OutlinedButton.icon(
                      onPressed: _loadMockData,
                      icon: const Icon(Icons.data_object),
                      label: const Text('Load Sample Data'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white54),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Pull down to refresh',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}