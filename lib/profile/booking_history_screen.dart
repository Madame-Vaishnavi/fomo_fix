import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import '../services/api-service.dart';
import '../models/booking_history.dart';

class BookingHistoryScreen extends StatefulWidget {
  const BookingHistoryScreen({Key? key}) : super(key: key);

  @override
  _BookingHistoryScreenState createState() => _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends State<BookingHistoryScreen> {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  BookingHistoryResponse? _bookingHistory;
  bool _isLoading = true;
  String? _error;
  int? _expandedCardIndex; // Track which card is expanded (null = none expanded)


  @override
  void initState() {
    super.initState();
    _loadBookingHistory();
  }

  Future<void> _loadBookingHistory() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final userId = await _secureStorage.read(key: 'userId');
      final token= await _secureStorage.read(key: 'token');
      if (userId == null) {
        setState(() {
          _error = 'User not found';
          _isLoading = false;
        });
        return;
      }

      final response = await ApiService.getBookingHistoryByUserId(userId,token!);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _bookingHistory = BookingHistoryResponse.fromJson(data);
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Failed to load booking history: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error loading booking history: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Booking History',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadBookingHistory,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurpleAccent),
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadBookingHistory,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurpleAccent,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_bookingHistory == null || _bookingHistory!.bookings.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No booking history found',
              style: TextStyle(color: Colors.grey, fontSize: 18),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadBookingHistory,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _bookingHistory!.bookings.length,
        itemBuilder: (context, index) {
          final booking = _bookingHistory!.bookings[index];
          return _buildBookingCard(booking, index); // Pass index
        },

      ),
    );
  }

  Widget _buildBookingCard(BookingWithPayment booking, int index) {
    final isExpanded = _expandedCardIndex == index;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: Colors.grey[900],
      child: InkWell(
        onTap: () {
          setState(() {
            // Toggle: if this card is expanded, close it; otherwise, open it
            _expandedCardIndex = isExpanded ? null : index;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Basic booking info (always visible)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        booking.eventName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        _buildTag(
                          booking.status,
                          _getBookingStatusColor(booking.status),
                        ),
                        const SizedBox(width: 6),
                        _buildTag(
                          _getPaymentStatusLabel(booking.paymentInfo?.status),
                          _getPaymentStatusColor(booking.paymentInfo?.status),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  booking.categoryName,
                  style: TextStyle(color: Colors.grey[400], fontSize: 14),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.event_seat, color: Colors.grey[400], size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${booking.seatBooked} seats',
                      style: TextStyle(color: Colors.grey[400], fontSize: 14),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.attach_money, color: Colors.grey[400], size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '\$${booking.price.toStringAsFixed(2)}',
                      style: TextStyle(color: Colors.grey[400], fontSize: 14),
                    ),
                    const Spacer(),
                    // Expand/collapse indicator
                    Icon(
                      isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                      color: Colors.grey[400],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.schedule, color: Colors.grey[400], size: 16),
                    const SizedBox(width: 4),
                    Text(
                      'Booked on ${_formatDate(booking.bookingTime)}',
                      style: TextStyle(color: Colors.grey[400], fontSize: 14),
                    ),
                  ],
                ),

                // Payment info (conditionally visible with animation)
                AnimatedCrossFade(
                  duration: const Duration(milliseconds: 300),
                  crossFadeState: isExpanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  firstChild: const SizedBox.shrink(), // Hidden state
                  secondChild: booking.paymentInfo != null
                      ? Column(
                    children: [
                      const SizedBox(height: 12),
                      const Divider(color: Colors.grey),
                      const SizedBox(height: 8),
                      Text(
                        'Payment Information',
                        style: TextStyle(
                          color: Colors.grey[300],
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildPaymentInfo(booking.paymentInfo!),
                    ],
                  )
                      : const Padding(
                    padding: EdgeInsets.only(top: 12),
                    child: Text(
                      'No payment information available',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildPaymentInfo(PaymentInfo paymentInfo) {
    return Column(
      children: [
        Row(
          children: [
            Icon(Icons.payment, color: Colors.grey[400], size: 16),
            const SizedBox(width: 4),
            Text(
              'Payment ID: ${paymentInfo.paymentId}',
              style: TextStyle(color: Colors.grey[400], fontSize: 14),
            ),
          ],
        ),
        const SizedBox(height: 4),
        if (paymentInfo.amount != null) ...[
          Row(
            children: [
              Icon(Icons.attach_money, color: Colors.grey[400], size: 16),
              const SizedBox(width: 4),
              Text(
                'Amount: \$${paymentInfo.amount!.toStringAsFixed(2)}',
                style: TextStyle(color: Colors.grey[400], fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 4),
        ],
        if (paymentInfo.paymentMode != null) ...[
          Row(
            children: [
              Icon(Icons.credit_card, color: Colors.grey[400], size: 16),
              const SizedBox(width: 4),
              Text(
                'Payment Mode: ${paymentInfo.paymentMode}',
                style: TextStyle(color: Colors.grey[400], fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 4),
        ],
        if (paymentInfo.status != null) ...[
          Row(
            children: [
              Icon(Icons.check_circle, color: Colors.grey[400], size: 16),
              const SizedBox(width: 4),
              Text(
                'Status: ${paymentInfo.status}',
                style: TextStyle(color: Colors.grey[400], fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 4),
        ],
        if (paymentInfo.transactionId != null) ...[
          Row(
            children: [
              Icon(Icons.receipt, color: Colors.grey[400], size: 16),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  'Transaction ID: ${paymentInfo.transactionId}',
                  style: TextStyle(color: Colors.grey[400], fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
        ],
        if (paymentInfo.paymentDate != null) ...[
          Row(
            children: [
              Icon(Icons.schedule, color: Colors.grey[400], size: 16),
              const SizedBox(width: 4),
              Text(
                'Payment Date: ${_formatDate(paymentInfo.paymentDate!)}',
                style: TextStyle(color: Colors.grey[400], fontSize: 14),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      case 'completed':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  // Helper for compact status chips
  Widget _buildTag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // Booking status colors (existing mapping preserved, moved to separate fn)
  Color _getBookingStatusColor(String status) {
    return _getStatusColor(status);
  }

  // Payment status helpers
  String _getPaymentStatusLabel(String? status) {
    if (status == null || status.isEmpty) return 'NO PAYMENT';
    switch (status.toUpperCase()) {
      case 'SUCCESS':
        return 'SUCCESS';
      case 'FAILED':
        return 'FAILED';
      case 'PENDING':
        return 'PENDING';
      default:
        return status.toUpperCase();
    }
  }

  Color _getPaymentStatusColor(String? status) {
    if (status == null || status.isEmpty) return Colors.grey;
    switch (status.toUpperCase()) {
      case 'SUCCESS':
        return Colors.green;
      case 'FAILED':
        return Colors.red;
      case 'PENDING':
        return Colors.orange;
      default:
        return Colors.blueGrey;
    }
  }
}
