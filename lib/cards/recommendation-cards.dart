import 'package:flutter/material.dart';
import '../models/event.dart';

// A reusable widget for the smaller recommendation cards.
class RecommendationCard extends StatefulWidget {
  final Event event;
  final VoidCallback onTap;
  final VoidCallback onFavoriteTap;

  const RecommendationCard({
    super.key,
    required this.event,
    required this.onTap,
    required this.onFavoriteTap,
  });

  @override
  State<RecommendationCard> createState() => _RecommendationCardState();
}

class _RecommendationCardState extends State<RecommendationCard> {
  @override
  Widget build(BuildContext context) {
    final cardWidth = (MediaQuery.of(context).size.width / 2) - 24;
    final event = widget.event;
    
    return InkWell(
      onTap: widget.onTap,
      borderRadius: BorderRadius.circular(16.0),
      child: Container(
        width: cardWidth,
        margin: const EdgeInsets.only(right: 16.0),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16.0)),
                  child: Image.network(
                    event.imageUrl ?? 'https://picsum.photos/300/200?random=1',
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 120,
                      color: Colors.purple,
                      child: const Center(child: Text('No Image')),
                    ),
                  ),
                ),
                // Category badge
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.deepPurpleAccent.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      event.categoryDisplayName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                // Ticket availability indicator
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: _getAvailabilityColor(event.reservationPercentage).withOpacity(0.9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${event.availableTickets} left',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: Colors.white70,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          event.location,
                          style: const TextStyle(color: Colors.white70, fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        color: Colors.yellow[700],
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          event.formattedDate,
                          style: TextStyle(color: Colors.yellow[700], fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.currency_rupee,
                        color: Colors.green[400],
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            text: '',
                            style: TextStyle(
                              color: Colors.green[400],
                              fontSize: 12,
                            ),
                            children: <TextSpan>[
                              TextSpan(
                                text: "${event.lowestPriceCategory?.pricePerSeat.toString()} onwards",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Ticket availability progress bar
                  Container(
                    width: double.infinity,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: event.reservationPercentage / 100,
                      child: Container(
                        decoration: BoxDecoration(
                          color: _getAvailabilityColor(event.reservationPercentage),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${event.reservationPercentage.toStringAsFixed(0)}% booked',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getAvailabilityColor(double percentage) {
    if (percentage >= 80) return Colors.red;
    if (percentage >= 60) return Colors.orange;
    if (percentage >= 40) return Colors.yellow;
    return Colors.green;
  }
}
