import 'package:cloud_firestore/cloud_firestore.dart';

/// All possible states of a booking in FixGhar
enum BookingStatus {
  pending,    // Customer placed booking, waiting for provider
  confirmed,  // Provider accepted the booking
  rejected,   // Provider rejected the booking
  completed,  // Service has been delivered
  cancelled,  // Customer cancelled the booking
}

/// Extension to convert enum to/from string (for Firestore storage)
extension BookingStatusX on BookingStatus {
  String get value => name; // e.g. 'pending', 'confirmed'

  static BookingStatus fromString(String s) {
    return BookingStatus.values.firstWhere(
      (e) => e.name == s,
      orElse: () => BookingStatus.pending,
    );
  }

  /// Human-readable label for the status
  String get label {
    switch (this) {
      case BookingStatus.pending:
        return 'Pending';
      case BookingStatus.confirmed:
        return 'Confirmed';
      case BookingStatus.rejected:
        return 'Rejected';
      case BookingStatus.completed:
        return 'Completed';
      case BookingStatus.cancelled:
        return 'Cancelled';
    }
  }
}

/// Represents a single service booking in FixGhar
/// Maps to the 'bookings' collection in Firestore
class BookingModel {
  final String id;
  final String customerId;          // Reference to users collection
  final String customerName;
  final String customerPhone;
  final String providerId;          // Reference to providers collection
  final String providerName;
  final String serviceId;           // Reference to services collection
  final String serviceName;
  final String serviceCategory;     // e.g. 'ac_repair'
  final DateTime scheduledDate;     // Date for the service
  final String scheduledTime;       // e.g. '10:00 AM'
  final String address;             // Full delivery address
  final String? landmark;           // Optional landmark
  final String? notes;              // Special instructions
  final BookingStatus status;
  final double estimatedAmount;     // Price estimate in INR
  final String paymentMode;         // 'cash' or 'online'
  final bool isPaid;
  final double? customerRating;     // Rating given by customer after completion
  final String? customerReview;     // Written review
  final DateTime createdAt;
  final DateTime updatedAt;

  const BookingModel({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.customerPhone,
    required this.providerId,
    required this.providerName,
    required this.serviceId,
    required this.serviceName,
    required this.serviceCategory,
    required this.scheduledDate,
    required this.scheduledTime,
    required this.address,
    this.landmark,
    this.notes,
    this.status = BookingStatus.pending,
    required this.estimatedAmount,
    this.paymentMode = 'cash',
    this.isPaid = false,
    this.customerRating,
    this.customerReview,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Creates a BookingModel from a Firestore document snapshot
  factory BookingModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BookingModel(
      id: doc.id,
      customerId: data['customerId'] ?? '',
      customerName: data['customerName'] ?? '',
      customerPhone: data['customerPhone'] ?? '',
      providerId: data['providerId'] ?? '',
      providerName: data['providerName'] ?? '',
      serviceId: data['serviceId'] ?? '',
      serviceName: data['serviceName'] ?? '',
      serviceCategory: data['serviceCategory'] ?? '',
      scheduledDate:
          (data['scheduledDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      scheduledTime: data['scheduledTime'] ?? '',
      address: data['address'] ?? '',
      landmark: data['landmark'],
      notes: data['notes'],
      status: BookingStatusX.fromString(data['status'] ?? 'pending'),
      estimatedAmount: (data['estimatedAmount'] ?? 0).toDouble(),
      paymentMode: data['paymentMode'] ?? 'cash',
      isPaid: data['isPaid'] ?? false,
      customerRating: data['customerRating']?.toDouble(),
      customerReview: data['customerReview'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Converts BookingModel to Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'customerId': customerId,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'providerId': providerId,
      'providerName': providerName,
      'serviceId': serviceId,
      'serviceName': serviceName,
      'serviceCategory': serviceCategory,
      'scheduledDate': Timestamp.fromDate(scheduledDate),
      'scheduledTime': scheduledTime,
      'address': address,
      'landmark': landmark,
      'notes': notes,
      'status': status.value,
      'estimatedAmount': estimatedAmount,
      'paymentMode': paymentMode,
      'isPaid': isPaid,
      'customerRating': customerRating,
      'customerReview': customerReview,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// Returns a copy of this booking with updated fields
  BookingModel copyWith({
    BookingStatus? status,
    double? customerRating,
    String? customerReview,
    bool? isPaid,
    DateTime? updatedAt,
  }) {
    return BookingModel(
      id: id,
      customerId: customerId,
      customerName: customerName,
      customerPhone: customerPhone,
      providerId: providerId,
      providerName: providerName,
      serviceId: serviceId,
      serviceName: serviceName,
      serviceCategory: serviceCategory,
      scheduledDate: scheduledDate,
      scheduledTime: scheduledTime,
      address: address,
      landmark: landmark,
      notes: notes,
      status: status ?? this.status,
      estimatedAmount: estimatedAmount,
      paymentMode: paymentMode,
      isPaid: isPaid ?? this.isPaid,
      customerRating: customerRating ?? this.customerRating,
      customerReview: customerReview ?? this.customerReview,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Whether the booking is still in progress (not completed or cancelled)
  bool get isActive =>
      status == BookingStatus.pending || status == BookingStatus.confirmed;

  /// Returns formatted amount e.g. "₹499"
  String get formattedAmount => '₹${estimatedAmount.toStringAsFixed(0)}';

  @override
  String toString() =>
      'BookingModel(id: $id, service: $serviceName, status: ${status.label})';
}
