import 'package:flutter/material.dart';

// A model to hold event data. In a real app, this might come from an API.
class Event {
  final String title;
  final String imageUrl;
  final String date;
  final String location;
  final String price;

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
  int _ticketCount = 1;

  void _incrementTickets() {
    setState(() {
      _ticketCount++;
    });
  }

  void _decrementTickets() {
    setState(() {
      if (_ticketCount > 1) {
        _ticketCount--;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
                backgroundColor: Colors.black,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Image.network(
                    widget.event.imageUrl,
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
                        _buildDetailRow(Icons.calendar_today, widget.event.date),
                        const SizedBox(height: 12),
                        _buildDetailRow(Icons.location_on, widget.event.location),
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
                          style: TextStyle(color: Colors.grey[400], height: 1.5),
                        ),
                        const SizedBox(height: 24),
                        const Divider(color: Colors.white24),
                        const SizedBox(height: 24),
                        // --- Ticket Selection ---
                        _buildTicketSelector(),
                        const SizedBox(height: 100), // Space for the floating button
                      ],
                    ),
                  ),
                ]),
              ),
            ],
          ),
          // --- Floating "Book Now" Button ---
          _buildFloatingBookButton(),
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

  Widget _buildTicketSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Select Tickets',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove, color: Colors.white),
                onPressed: _decrementTickets,
              ),
              Text(
                '$_ticketCount',
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.add, color: Colors.white),
                onPressed: _incrementTickets,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFloatingBookButton() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.8),
          border: const Border(top: BorderSide(color: Colors.white24)),
        ),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              // Handle booking logic
              print('Booking $_ticketCount tickets for ${widget.event.title}');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurpleAccent,
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
            ),
            child: const Text(
              'Book Now',
              style: TextStyle(fontSize: 18.0, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
