import 'package:flutter/material.dart';
import 'package:fomo_fix/cards/recommendation-cards.dart';
import 'package:fomo_fix/models/event.dart';
import 'booking-page.dart';


class CategoryPage extends StatefulWidget {
  final String categoryTitle;
  final List<Event> events;

  const CategoryPage({
    super.key,
    required this.categoryTitle,
    required this.events,
  });

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  // --- Pagination State ---
  int _currentPage = 0;
  final int _eventsPerPage = 20;

  // --- Pagination Logic ---
  List<Event> get _paginatedEvents {
    final startIndex = _currentPage * _eventsPerPage;
    final endIndex = startIndex + _eventsPerPage;
    // Ensure endIndex doesn't exceed the list length
    return widget.events.sublist(startIndex, endIndex > widget.events.length ? widget.events.length : endIndex);
  }

  void _nextPage() {
    if ((_currentPage + 1) * _eventsPerPage < widget.events.length) {
      setState(() {
        _currentPage++;
      });
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      setState(() {
        _currentPage--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalPages = (widget.events.length / _eventsPerPage).ceil();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.categoryTitle, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.grey[900],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // Display two cards per row
                mainAxisSpacing: 16,
                childAspectRatio: 0.70, // Adjust aspect ratio for card height
              ),
              itemCount: _paginatedEvents.length,
              itemBuilder: (context, index) {
                final event = _paginatedEvents[index];
                return RecommendationCard(
                  event: event,
                  categoryTitle: widget.categoryTitle,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => BookingPage(event: event)),
                    );
                  },
                );
              },
            ),
          ),
          // --- Pagination Controls ---
          if (totalPages > 1)
            _buildPaginationControls(totalPages),
        ],
      ),
    );
  }

  Widget _buildPaginationControls(int totalPages) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      color: Colors.grey[900],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: _currentPage == 0 ? null : _previousPage,
          ),
          Text(
            'Page ${_currentPage + 1} of $totalPages',
            style: const TextStyle(color: Colors.white),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios, color: Colors.white),
            onPressed: (_currentPage + 1) >= totalPages ? null : _nextPage,
          ),
        ],
      ),
    );
  }
}
