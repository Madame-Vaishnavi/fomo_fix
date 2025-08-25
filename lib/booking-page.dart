import 'package:flutter/material.dart';
import '../config.dart';
import '../widgets/authenticated_image.dart';

// A model to hold event data. In a real app, this might come from an API.
class Event {
  final String title;
  final String imageUrl;
  final String date;
  final String location;
  final String price; // This can now represent the starting price

  const Event({
    required this.title,
    required this.imageUrl,
    required this.date,
    required this.location,
    required this.price,
  });
}

class BookingPage extends StatefulWidget {
  final Event event;

  const BookingPage({super.key, required this.event});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  // State for ticket counts
  int _standardTicketCount = 1;
  int _vipTicketCount = 0;

  // Prices for each ticket category. In a real app, this might be part of the Event model.
  final double _standardPrice = 2500.00;
  final double _vipPrice = 5000.00;

  // --- NEW: Add state for available tickets ---
  final int _standardTicketsAvailable = 50; // Example: 50 standard tickets left
  final int _vipTicketsAvailable = 12; // Example: 12 VIP tickets left

  // --- Ticket counter logic ---
  void _incrementStandard() => setState(() {
    if (_standardTicketCount < _standardTicketsAvailable)
      _standardTicketCount++;
  });
  void _decrementStandard() =>
      setState(() => _standardTicketCount > 0 ? _standardTicketCount-- : null);
  void _incrementVip() => setState(() {
    if (_vipTicketCount < _vipTicketsAvailable) _vipTicketCount++;
  });
  void _decrementVip() =>
      setState(() => _vipTicketCount > 0 ? _vipTicketCount-- : null);

  @override
  Widget build(BuildContext context) {
    // Calculate total price based on ticket counts
    final double totalPrice =
        (_standardTicketCount * _standardPrice) + (_vipTicketCount * _vipPrice);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Main scrollable content
          CustomScrollView(
            slivers: [
              // --- Collapsing App Bar with Event Image ---
              SliverAppBar(
                expandedHeight: 250.0,
                backgroundColor: Colors.transparent, // Make app bar transparent
                elevation: 0,
                pinned: true,
                // --- UPDATED: Custom circular back button ---
                leading: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: AuthenticatedImage(
                    imageUrl: widget.event.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Container(color: Colors.deepPurpleAccent),
                  ),
                  title: Text(
                    widget.event.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  centerTitle: true,
                  titlePadding: const EdgeInsets.only(
                    left: 60,
                    right: 60,
                    bottom: 16,
                  ),
                ),
              ),
              // --- Event Details Content ---
              SliverList(
                delegate: SliverChildListDelegate([
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDetailRow(
                          Icons.calendar_today,
                          widget.event.date,
                        ),
                        const SizedBox(height: 12),
                        _buildDetailRow(
                          Icons.location_on,
                          widget.event.location,
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'About this event',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Join us for an unforgettable experience. This event brings together the best talent for a night of entertainment and fun. Get your tickets now before they sell out!',
                          style: TextStyle(
                            color: Colors.grey[400],
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Divider(color: Colors.white24),
                        const SizedBox(height: 24),
                        // --- Ticket Selection ---
                        const Text(
                          'Select Tickets',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildTicketSelectorRow(
                          category: 'Standard',
                          price: _standardPrice,
                          ticketsLeft: _standardTicketsAvailable,
                          count: _standardTicketCount,
                          onDecrement: _decrementStandard,
                          onIncrement: _incrementStandard,
                        ),
                        const SizedBox(height: 16),
                        _buildTicketSelectorRow(
                          category: 'VIP',
                          price: _vipPrice,
                          ticketsLeft: _vipTicketsAvailable,
                          count: _vipTicketCount,
                          onDecrement: _decrementVip,
                          onIncrement: _incrementVip,
                        ),
                        const SizedBox(
                          height: 120,
                        ), // Space for the floating button
                      ],
                    ),
                  ),
                ]),
              ),
            ],
          ),
          // --- Floating "Book Now" Button ---
          _buildFloatingBookButton(totalPrice),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.deepPurpleAccent, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ],
    );
  }

  // A reusable widget for a single ticket category selector
  Widget _buildTicketSelectorRow({
    required String category,
    required double price,
    required int ticketsLeft, // New parameter
    required int count,
    required VoidCallback onDecrement,
    required VoidCallback onIncrement,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[900]?.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                category,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Rs ${price.toStringAsFixed(2)}',
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 4),
              // --- NEW: Tickets Left Indicator ---
              Text(
                '$ticketsLeft tickets left',
                style: TextStyle(
                  color: ticketsLeft > 10
                      ? Colors.greenAccent
                      : Colors.redAccent,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove, color: Colors.white),
                  onPressed: onDecrement,
                ),
                Text(
                  '$count',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add, color: Colors.white),
                  onPressed: onIncrement,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingBookButton(double totalPrice) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          16,
          16,
          16,
          32,
        ), // More padding for safe area
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.9),
          border: const Border(top: BorderSide(color: Colors.white24)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Total Price',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                Text(
                  'Rs ${totalPrice.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: (totalPrice > 0)
                  ? () {
                      // Handle booking logic
                      print(
                        'Booking $_standardTicketCount Standard and $_vipTicketCount VIP tickets for ${widget.event.title}',
                      );
                    }
                  : null, // Disable button if no tickets are selected
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurpleAccent,
                disabledBackgroundColor: Colors.grey[800],
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 16.0,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              child: const Text(
                'Book Now',
                style: TextStyle(fontSize: 18.0, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
