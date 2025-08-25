import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../services/api-service.dart';
import '../models/event.dart'; // Your updated event model
import '../config/config.dart';
import '../widgets/authenticated_image.dart';

class BookingPage extends StatefulWidget {
  final Event event;

  const BookingPage({super.key, required this.event});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  // State variables
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  Event? _detailedEvent;
  bool _isLoading = true;
  String? _errorMessage;
  bool _isBooking = false;

  Map<String, int> _ticketCounts = {};

  @override
  void initState() {
    super.initState();
    _fetchEventDetails();
  }

  Future<void> _fetchEventDetails() async {
    try {
      final token = await _secureStorage.read(key: 'token');
      final response = await ApiService.getWithAuth(
        '/events/${widget.event.id}',
        token!,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _detailedEvent = Event.fromJson(data);
          print(data);
          _detailedEvent?.seatCategories.forEach((category) {
            _ticketCounts[category.categoryName] = 0;
          });
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage =
              'Failed to load event details: ${response.statusCode}';
          print(response.body);
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _handleBooking() async {
    final token = await _secureStorage.read(key: 'token');
    final userId = await _secureStorage.read(key: 'userId');
    final bookingsToMake = _ticketCounts.entries
        .where((entry) => entry.value > 0)
        .toList();

    if (bookingsToMake.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one ticket.')),
      );
      return;
    }

    setState(() => _isBooking = true);

    List<String> successfulBookings = [];
    List<String> failedBookings = [];

    for (var bookingEntry in bookingsToMake) {
      try {
        final bookingBody = {
          "eventId": _detailedEvent!.id,
          "userEmail": "user@example.com", // Replace with actual user email
          "categoryName": bookingEntry.key,
          "seatsRequested": bookingEntry.value,
          "userId": userId,
        };

        final response = await ApiService.postWithAuth(
          token!,
          '/bookings',
          bookingBody,
        );
        print(response.body);
        print(bookingBody);
        if (response.statusCode == 200 || response.statusCode == 201) {
          successfulBookings.add(bookingEntry.key);
        } else {
          failedBookings.add(bookingEntry.key);
        }
      } catch (e) {
        failedBookings.add(bookingEntry.key);
      }
    }

    if (!mounted) return;

    if (failedBookings.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All tickets booked successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Some bookings failed: ${failedBookings.join(', ')}. Please try again.',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }

    setState(() => _isBooking = false);
  }

  void _incrementTickets(SeatCategory category) {
    setState(() {
      int currentCount = _ticketCounts[category.categoryName] ?? 0;
      if (currentCount < category.availableSeats) {
        _ticketCounts[category.categoryName] = currentCount + 1;
      }
    });
  }

  void _decrementTickets(SeatCategory category) {
    setState(() {
      int currentCount = _ticketCounts[category.categoryName] ?? 0;
      if (currentCount > 0) {
        _ticketCounts[category.categoryName] = currentCount - 1;
      }
    });
  }

  double get _totalPrice {
    if (_detailedEvent == null) return 0.0;
    double total = 0.0;
    _ticketCounts.forEach((categoryName, count) {
      final category = _detailedEvent!.seatCategories.firstWhere(
        (c) => c.categoryName == categoryName,
      );
      total += count * category.pricePerSeat;
    });
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            )
          : _buildContent(),
    );
  }

  Widget _buildContent() {
    final event = _detailedEvent!;

    return Stack(
      children: [
        CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 250.0,
              backgroundColor: Colors.black,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: AuthenticatedImage(
                  imageUrl: widget.event.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      Container(color: Colors.deepPurpleAccent),
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildListDelegate([
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      Text(
                        event.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildDetailRow(
                        Icons.calendar_today,
                        event.formattedDate,
                      ),
                      const SizedBox(height: 10),
                      _buildDetailRow(Icons.location_on, event.location),
                      const SizedBox(height: 10),
                      _buildDetailRow(
                        Icons.category_outlined,
                        event.categoryDisplayName,
                      ),
                      const SizedBox(height: 20),
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
                        event.description,
                        style: TextStyle(color: Colors.grey[400], height: 1.4),
                      ),
                      const SizedBox(height: 20),
                      const Divider(color: Colors.white24),
                      const SizedBox(height: 20),
                      _buildTicketSelector(),
                      const SizedBox(height: 110),
                    ],
                  ),
                ),
              ]),
            ),
          ],
        ),
        _buildFloatingBookButton(),
      ],
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
            style: const TextStyle(color: Colors.white, fontSize: 15),
          ),
        ),
      ],
    );
  }

  Widget _buildTicketSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Tickets',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        // The SizedBox is removed from here
        ListView.separated(
          itemCount: _detailedEvent!.seatCategories.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          // MODIFIED: Padding is now applied directly to the ListView
          padding: const EdgeInsets.only(top: 12),
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final category = _detailedEvent!.seatCategories[index];
            return _buildCategoryTicketCounter(category);
          },
        ),
      ],
    );
  }

  Widget _buildCategoryTicketCounter(SeatCategory category) {
    int currentCount = _ticketCounts[category.categoryName] ?? 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.categoryName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '₹ ${category.pricePerSeat.toStringAsFixed(0)}',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  '${category.availableSeats} seats available',
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove, color: Colors.white),
                  onPressed: () => _decrementTickets(category),
                ),
                Text(
                  '$currentCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add, color: Colors.white),
                  onPressed: () => _incrementTickets(category),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingBookButton() {
    final totalPrice = _totalPrice;

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 12.0,
        ).copyWith(bottom: MediaQuery.of(context).padding.bottom + 12),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.9),
          border: const Border(top: BorderSide(color: Colors.white24)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Price',
                  style: TextStyle(color: Colors.grey[400], fontSize: 14),
                ),
                Text(
                  '₹ ${totalPrice.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(
              width: 150,
              child: ElevatedButton(
                onPressed: _isBooking || _detailedEvent == null
                    ? null
                    : _handleBooking,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurpleAccent,
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                child: _isBooking
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Book Now',
                        style: TextStyle(fontSize: 18.0, color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
