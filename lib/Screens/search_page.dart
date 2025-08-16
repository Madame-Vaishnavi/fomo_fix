import 'dart:convert';

import 'package:flutter/material.dart';
import '../api-service.dart';
import '../config.dart';
import '../models/event.dart';
import 'booking-page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<Event> _allEvents = [];
  bool _isLoading = true;
  bool _isRefreshing = false;
  String? _errorMessage;

  final TextEditingController _searchController = TextEditingController();
  final List<String> _recentSearches = [];

  void _handleSearchSubmitted(String query) {
    final trimmedQuery = query.trim();

    if (trimmedQuery.isEmpty) {
      return;
    }

    setState(() {
      _recentSearches.remove(trimmedQuery);
      _recentSearches.insert(0, trimmedQuery);

      // MODIFIED: The limit is now 10
      if (_recentSearches.length > 10) {
        _recentSearches.removeLast();
      }
    });

    _searchController.clear();
    print('Searching for: $trimmedQuery');
  }

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

        setState(() {
          _allEvents = data.map((json) => Event.fromJson(json)).toList();
          _isLoading = false;
          _isRefreshing = false;
        });

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
        setState(() {
          _isLoading = false;
          _isRefreshing = false;
          _errorMessage = 'Server error: ${response.statusCode}';
        });
        print('Failed to load events: ${response.statusCode}');

        if (isRefresh && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Failed to refresh: Server error ${response.statusCode}',
              ),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
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

      if (isRefresh && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Refresh failed: $errorMsg'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  List<Event> _getRecommendedEvents() {
    final now = DateTime.now();
    return _allEvents.where((event) {
      final isNew =
          event.creationDate != null &&
              now.difference(event.creationDate!).inDays <= 30;
      final isNotFull = event.reservationPercentage < 50;
      return isNew || isNotFull;
    }).toList();
  }

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
      onSubmitted: _handleSearchSubmitted,
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
    if (_recentSearches.isEmpty) {
      return Text(
        'Your search history will appear here.',
        style: TextStyle(color: Colors.grey[500]),
      );
    }
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