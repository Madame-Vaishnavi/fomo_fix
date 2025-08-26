import 'dart:convert';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../booking/booking-page.dart';
import '../services/api-service.dart';
import '../config/config.dart';
import '../models/event.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../widgets/authenticated_image.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<Event> _allEvents = [];
  List<Event> _searchResults = [];
  bool _isLoading = true;
  bool _isRefreshing = false;
  bool _isSearching = false;
  String? _errorMessage;

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final TextEditingController _searchController = TextEditingController();
  final List<String> _recentSearches = [];
  String _currentSearchQuery = '';
  String? _selectedCategory;
  Timer? _searchDebounceTimer;

  // Available categories for filtering
  final List<String> _categories = [
    'All Categories',
    'CONCERT',
    'THEATER',
    'SPORTS',
    'CONFERENCE',
    'WORKSHOP',
    'EXHIBITION',
    'OTHER',
  ];

  void _handleSearchChanged(String query) {
    setState(() {
      _currentSearchQuery = query.trim();
    });

    // Cancel previous timer
    _searchDebounceTimer?.cancel();

    if (_currentSearchQuery.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    // Debounce search requests
    _searchDebounceTimer = Timer(const Duration(milliseconds: 500), () {
      _performSearch(_currentSearchQuery);
    });
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) return;

    setState(() {
      _isSearching = true;
      _errorMessage = null;
    });

    try {
      final token = await _secureStorage.read(key: 'token');
      if (token == null || token.isEmpty) {
        setState(() {
          _isSearching = false;
          _errorMessage = 'Not authenticated. Please log in again.';
        });
        return;
      }

      http.Response response;

      // Use category-specific search if a category is selected
      if (_selectedCategory != null && _selectedCategory != 'All Categories') {
        response = await ApiService.searchEventsByCategoryWithAuth(
          token,
          query,
          _selectedCategory!,
        );
      } else {
        response = await ApiService.searchEventsWithAuth(token, query);
      }

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _searchResults = data.map((json) => Event.fromJson(json)).toList();
          _isSearching = false;
        });
      } else if (response.statusCode == 401) {
        setState(() {
          _isSearching = false;
          _errorMessage = 'Session expired. Please log in again.';
        });
      } else {
        setState(() {
          _isSearching = false;
          _errorMessage = 'Search failed: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _isSearching = false;
        _errorMessage = 'Search error: $e';
      });
    }
  }

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

    print('Searching for: $trimmedQuery');
  }

  void _selectRecentSearch(String searchTerm) {
    _searchController.text = searchTerm;
    _handleSearchChanged(searchTerm);
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _currentSearchQuery = '';
      _selectedCategory = null;
      _searchResults = [];
      _isSearching = false;
    });
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

      final token = await _secureStorage.read(key: 'token');
      final response = await ApiService.getWithAuth('/events', token!);

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
      } else if (response.statusCode == 401) {
        setState(() {
          _isLoading = false;
          _isRefreshing = false;
          _errorMessage = 'Session expired. Please log in again.';
        });
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

  @override
  void dispose() {
    _searchController.dispose();
    _searchDebounceTimer?.cancel();
    super.dispose();
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
        actions: [
          if (_currentSearchQuery.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: () => _fetchEvents(isRefresh: true),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          children: [
            _buildSearchField(),
            const SizedBox(height: 16),
            Expanded(
              child: _currentSearchQuery.isEmpty
                  ? _buildDefaultContent()
                  : _buildSearchResults(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return Column(
      children: [
        TextField(
          controller: _searchController,
          style: const TextStyle(color: Colors.white),
          onChanged: _handleSearchChanged,
          onSubmitted: _handleSearchSubmitted,
          decoration: InputDecoration(
            hintText: "Search for Events, Plays, Activities..",
            hintStyle: TextStyle(color: Colors.grey[600]),
            prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
            suffixIcon: _currentSearchQuery.isNotEmpty
                ? _isSearching
                      ? Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.grey[600],
                            ),
                          ),
                        )
                      : IconButton(
                          icon: Icon(Icons.clear, color: Colors.grey[600]),
                          onPressed: _clearSearch,
                        )
                : null,
            filled: true,
            fillColor: Colors.grey[900],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        if (_currentSearchQuery.isNotEmpty) ...[
          const SizedBox(height: 12),
          _buildCategoryFilter(),
        ],
      ],
    );
  }

  Widget _buildCategoryFilter() {
    return Container(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected =
              _selectedCategory == category ||
              (_selectedCategory == null && category == 'All Categories');

          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: FilterChip(
              label: Text(
                category,
                style: TextStyle(
                  color: isSelected ? Colors.black : Colors.white70,
                  fontSize: 12,
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedCategory = selected ? category : null;
                });
                // Trigger search with new category filter
                if (_currentSearchQuery.isNotEmpty) {
                  _performSearch(_currentSearchQuery);
                }
              },
              backgroundColor: Colors.grey[800],
              selectedColor: Colors.white,
              checkmarkColor: Colors.black,
              side: BorderSide.none,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDefaultContent() {
    return ListView(
      children: [
        _buildSectionHeader('Recent Searches'),
        const SizedBox(height: 12),
        _buildRecentSearchChips(),
        const SizedBox(height: 24),
        _buildSectionHeader('Trending Events'),
        const SizedBox(height: 16),
        _buildTrendingEventsList(),
      ],
    );
  }

  Widget _buildSearchResults() {
    if (_isSearching) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 16),
            Text('Searching...', style: TextStyle(color: Colors.white70)),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.grey[600], size: 64),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[400]),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _performSearch(_currentSearchQuery),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_searchResults.isEmpty && _currentSearchQuery.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, color: Colors.grey[600], size: 64),
            const SizedBox(height: 16),
            Text(
              'No events found for "$_currentSearchQuery"',
              style: TextStyle(color: Colors.grey[400], fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Try searching with different keywords',
              style: TextStyle(color: Colors.grey[500], fontSize: 14),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${_searchResults.length} events found',
          style: TextStyle(color: Colors.grey[400], fontSize: 14),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.separated(
            itemCount: _searchResults.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final event = _searchResults[index];
              return _buildEventListItem(
                event: event,
                highlightQuery: _currentSearchQuery,
              );
            },
          ),
        ),
      ],
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
        return GestureDetector(
          onTap: () => _selectRecentSearch(term),
          child: Chip(
            label: Text(term, style: const TextStyle(color: Colors.white70)),
            backgroundColor: Colors.grey[850],
            deleteIcon: const Icon(
              Icons.close,
              size: 16,
              color: Colors.white70,
            ),
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
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTrendingEventsList() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          children: [
            Icon(Icons.error_outline, color: Colors.grey[600], size: 48),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[400]),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _fetchEvents(isRefresh: true),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final trendingEvents = _getRecommendedEvents().take(3).toList();

    if (trendingEvents.isEmpty) {
      return Center(
        child: Text(
          'No trending events available',
          style: TextStyle(color: Colors.grey[500]),
        ),
      );
    }

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

  Widget _buildEventListItem({required Event event, String? highlightQuery}) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => BookingPage(event: event)),
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
              child: AuthenticatedImage(
                imageUrl: event.imageUrl,
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
                  _buildHighlightedText(
                    text: event.name,
                    query: highlightQuery,
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

  Widget _buildHighlightedText({
    required String text,
    String? query,
    required TextStyle style,
  }) {
    if (query == null || query.isEmpty) {
      return Text(text, style: style);
    }

    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();
    final index = lowerText.indexOf(lowerQuery);

    if (index == -1) {
      return Text(text, style: style);
    }

    return RichText(
      text: TextSpan(
        children: [
          if (index > 0) TextSpan(text: text.substring(0, index), style: style),
          TextSpan(
            text: text.substring(index, index + query.length),
            style: style.copyWith(
              backgroundColor: Colors.yellow.withOpacity(0.3),
              color: Colors.yellow[100],
            ),
          ),
          if (index + query.length < text.length)
            TextSpan(text: text.substring(index + query.length), style: style),
        ],
      ),
    );
  }
}
