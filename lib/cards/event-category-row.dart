import 'package:flutter/material.dart';
import '../booking-page.dart';
import '../cards/recommendation-cards.dart'; // Adjust the import path as needed


class EventCategoryRow extends StatelessWidget {
  final String categoryTitle;
  final List<Event> events;

  const EventCategoryRow({
    super.key,
    required this.categoryTitle,
    required this.events,
  });

  @override
  Widget build(BuildContext context) {
    // If there are no events in this category, don't build the widget
    if (events.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- Category Header ---
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                categoryTitle,
                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text(
                'See All',
                style: TextStyle(color: Colors.deepPurpleAccent[100], fontSize: 14),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // --- Horizontal List of Event Cards ---
        SizedBox(
          height: 280,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: events.length,
            padding: const EdgeInsets.only(left: 16.0),
            itemBuilder: (context, index) {
              final event = events[index];
              return RecommendationCard(
                imageUrl: event.imageUrl,
                title: event.title,
                location: event.location,
                date: event.date,
                price: event.price,
                onTap: () {
                  // Navigate to the booking page with the specific event details
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
        ),
      ],
    );
  }
}
