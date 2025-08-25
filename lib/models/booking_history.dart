class BookingHistoryResponse {
  final List<BookingWithPayment> bookings;

  BookingHistoryResponse({required this.bookings});

  factory BookingHistoryResponse.fromJson(Map<String, dynamic> json) {
    return BookingHistoryResponse(
      bookings: (json['bookings'] as List)
          .map((booking) => BookingWithPayment.fromJson(booking))
          .toList(),
    );
  }
}

class BookingWithPayment {
  final int bookingId;
  final int eventId;
  final String eventName;
  final String categoryName;
  final int seatBooked;
  final double price;
  final DateTime bookingTime;
  final String status;
  final PaymentInfo? paymentInfo;

  BookingWithPayment({
    required this.bookingId,
    required this.eventId,
    required this.eventName,
    required this.categoryName,
    required this.seatBooked,
    required this.price,
    required this.bookingTime,
    required this.status,
    this.paymentInfo,
  });

  factory BookingWithPayment.fromJson(Map<String, dynamic> json) {
    return BookingWithPayment(
      bookingId: json['bookingId'],
      eventId: json['eventId'],
      eventName: json['eventName'],
      categoryName: json['categoryName'],
      seatBooked: json['seatBooked'],
      price: json['price'].toDouble(),
      bookingTime: DateTime.parse(json['bookingTime']),
      status: json['status'],
      paymentInfo: json['paymentInfo'] != null
          ? PaymentInfo.fromJson(json['paymentInfo'])
          : null,
    );
  }
}

class PaymentInfo {
  final int paymentId;
  final double? amount;
  final String? paymentMode;
  final String? status;
  final String? transactionId;
  final DateTime? paymentDate;

  PaymentInfo({
    required this.paymentId,
    this.amount,
    this.paymentMode,
    this.status,
    this.transactionId,
    this.paymentDate,
  });

  factory PaymentInfo.fromJson(Map<String, dynamic> json) {
    return PaymentInfo(
      paymentId: json['paymentId'],
      amount: json['amount']?.toDouble(),
      paymentMode: json['paymentMode'],
      status: json['status'],
      transactionId: json['transactionId'],
      paymentDate: json['paymentDate'] != null
          ? DateTime.parse(json['paymentDate'])
          : null,
    );
  }
}
