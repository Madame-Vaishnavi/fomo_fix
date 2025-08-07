import 'package:flutter/material.dart';

// A reusable widget for the smaller recommendation cards.
class RecommendationCard extends StatefulWidget {
  final String imageUrl;
  final String title;
  final String location;
  final String date;
  final String price;
  final VoidCallback onTap;
  final VoidCallback onFavoriteTap;

  const RecommendationCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.location,
    required this.date,
    required this.price,
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
                    widget.imageUrl,
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
                // Positioned(
                //   top: 8,
                //   right: 8,
                //   child: Container(
                //     decoration: BoxDecoration(
                //       color: Colors.black.withOpacity(0.3),
                //       shape: BoxShape.circle,
                //     ),
                //     child: IconButton(
                //       icon: const Icon(Icons.favorite_border, color: Colors.white),
                //       onPressed: widget.onFavoriteTap,
                //       constraints: const BoxConstraints(),
                //       padding: const EdgeInsets.all(6),
                //     ),
                //   ),
                // ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.location,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.date,
                    style: TextStyle(color: Colors.yellow[700], fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  Text.rich(
                    TextSpan(
                      text: '', // First part of the string
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.0,
                      ),
                      children: <TextSpan>[
                        TextSpan(
                          text: 'Rs.'+widget.price, // Second part with different style
                          style: TextStyle(
                            fontWeight: FontWeight.bold
                          ),
                        ),
                        TextSpan(
                          text: ' onwards', // Second part with different style
                          style: TextStyle(
                            fontSize: 12
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
