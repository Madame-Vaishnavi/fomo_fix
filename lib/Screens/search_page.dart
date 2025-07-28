import 'package:flutter/material.dart';

// A placeholder for your event detail page.
// You would navigate to this when a user taps on a trending event.
class EventDetailPage extends StatefulWidget {
  final String eventTitle;
  const EventDetailPage({super.key, required this.eventTitle});

  @override
  State<EventDetailPage> createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<EventDetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.eventTitle), backgroundColor: Colors.black),
      backgroundColor: Colors.black,
      body: Center(
        child: Text(
          'Details for ${widget.eventTitle}',
          style: const TextStyle(color: Colors.white, fontSize: 24),
        ),
      ),
    );
  }
}

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
        automaticallyImplyLeading: false, // Hides the back button
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0,vertical: 8.0),
        child: ListView(
          children: [
            // --- Search Input Field ---
            _buildSearchField(),
            const SizedBox(height: 24),

            // --- Recent Searches Section ---
            _buildSectionHeader('Recent Searches'),
            const SizedBox(height: 12),
            _buildRecentSearchChips(),
            const SizedBox(height: 24),

            // --- Trending Events Section ---
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
          // --- UPDATED: More explicit styling to remove any border/shadow ---
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
    // This could be a ListView or a Column depending on your needs.
    // Using a Column here for a simple, non-scrolling list within the main ListView.
    return Column(
      children: [
        _buildEventListItem(
          imageUrl: 'https://placehold.co/200x200/e74c3c/white?text=Concert',
          title: 'Indie Rock Fest',
          category: 'Music Concert',
          rating: 4.8,
        ),
        const SizedBox(height: 16),
        _buildEventListItem(
          imageUrl: 'https://placehold.co/200x200/3498db/white?text=Comedy',
          title: 'Laugh Riot Night',
          category: 'Stand-up Comedy',
          rating: 4.5,
        ),
        const SizedBox(height: 16),
        _buildEventListItem(
          imageUrl: 'https://placehold.co/200x200/2ecc71/white?text=Workshop',
          title: 'Flutter Dev Workshop',
          category: 'Tech Workshop',
          rating: 4.9,
        ),
      ],
    );
  }

  // --- Reusable Widget for a single list item in the "Trending" section ---
  Widget _buildEventListItem({
    required String imageUrl,
    required String title,
    required String category,
    required double rating,
  }) {
    return InkWell(
      onTap: () {
        // Navigate to a detail page for the event
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EventDetailPage(eventTitle: title),
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
                imageUrl,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    category,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        rating.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ],
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
