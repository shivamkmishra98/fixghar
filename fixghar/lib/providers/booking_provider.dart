import 'package:flutter/foundation.dart';
import '../models/booking_model.dart';
import '../services/firestore_service.dart';

/// Manages booking state — creation, fetching, status updates
class BookingProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  // ---------------------------------------------------------------------------
  // State
  // ---------------------------------------------------------------------------

  List<BookingModel> _upcomingBookings = [];
  List<BookingModel> _pastBookings = [];
  List<BookingModel> _providerIncomingBookings = [];
  bool _isLoading = false;
  bool _isCreating = false;
  String? _errorMessage;
  String? _lastCreatedBookingId;

  // Getters
  List<BookingModel> get upcomingBookings => _upcomingBookings;
  List<BookingModel> get pastBookings => _pastBookings;
  List<BookingModel> get providerIncomingBookings => _providerIncomingBookings;
  bool get isLoading => _isLoading;
  bool get isCreating => _isCreating;
  String? get errorMessage => _errorMessage;
  String? get lastCreatedBookingId => _lastCreatedBookingId;

  // ---------------------------------------------------------------------------
  // Load Customer Bookings (called after login)
  // ---------------------------------------------------------------------------

  /// Sets up real-time streams for the logged-in customer's bookings
  void loadCustomerBookings(String customerId) {
    // Upcoming (pending + confirmed)
    _firestoreService
        .customerUpcomingBookingsStream(customerId)
        .listen((bookings) {
      _upcomingBookings = bookings;
      notifyListeners();
    });

    // Past (completed + cancelled + rejected)
    _firestoreService
        .customerPastBookingsStream(customerId)
        .listen((bookings) {
      _pastBookings = bookings;
      notifyListeners();
    });
  }

  /// Sets up real-time stream for a provider's incoming booking requests
  void loadProviderBookings(String providerId) {
    _firestoreService
        .providerPendingBookingsStream(providerId)
        .listen((bookings) {
      _providerIncomingBookings = bookings;
      notifyListeners();
    });
  }

  // ---------------------------------------------------------------------------
  // Create Booking
  // ---------------------------------------------------------------------------

  /// Places a new service booking in Firestore
  /// Returns true on success, false on failure
  Future<bool> createBooking({
    required String customerId,
    required String customerName,
    required String customerPhone,
    required String providerId,
    required String providerName,
    required String serviceId,
    required String serviceName,
    required String serviceCategory,
    required DateTime scheduledDate,
    required String scheduledTime,
    required String address,
    String? landmark,
    String? notes,
    required double estimatedAmount,
  }) async {
    try {
      _isCreating = true;
      _clearError();
      notifyListeners();

      final booking = BookingModel(
        id: '', // Will be assigned by Firestore
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
        status: BookingStatus.pending,
        estimatedAmount: estimatedAmount,
        paymentMode: 'cash',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      _lastCreatedBookingId = await _firestoreService.createBooking(booking);
      return true;
    } catch (e) {
      _setError('Failed to place booking: ${e.toString()}');
      return false;
    } finally {
      _isCreating = false;
      notifyListeners();
    }
  }

  // ---------------------------------------------------------------------------
  // Status Updates
  // ---------------------------------------------------------------------------

  /// Customer cancels their booking
  Future<bool> cancelBooking(String bookingId) async {
    return await _updateStatus(bookingId, BookingStatus.cancelled);
  }

  /// Provider accepts an incoming booking request
  Future<bool> acceptBooking(String bookingId) async {
    return await _updateStatus(bookingId, BookingStatus.confirmed);
  }

  /// Provider rejects an incoming booking request
  Future<bool> rejectBooking(String bookingId) async {
    return await _updateStatus(bookingId, BookingStatus.rejected);
  }

  /// Marks a booking as completed
  Future<bool> completeBooking(String bookingId) async {
    return await _updateStatus(bookingId, BookingStatus.completed);
  }

  Future<bool> _updateStatus(String bookingId, BookingStatus status) async {
    try {
      _setLoading(true);
      await _firestoreService.updateBookingStatus(
        bookingId: bookingId,
        status: status,
      );
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ---------------------------------------------------------------------------
  // Rating
  // ---------------------------------------------------------------------------

  /// Submits the customer's rating for a completed booking
  Future<bool> rateBooking({
    required String bookingId,
    required double rating,
    String? review,
  }) async {
    try {
      _setLoading(true);
      await _firestoreService.rateBooking(
        bookingId: bookingId,
        rating: rating,
        review: review,
      );
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() => _errorMessage = null;
}
