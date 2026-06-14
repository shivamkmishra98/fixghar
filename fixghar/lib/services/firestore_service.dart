import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/booking_model.dart';
import '../models/provider_model.dart';
import '../models/service_model.dart';

/// Handles all Firestore CRUD operations for FixGhar
/// Acts as a data layer between the app and Firebase
class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ---------------------------------------------------------------------------
  // Collection References (DRY helpers)
  // ---------------------------------------------------------------------------

  CollectionReference get _usersCol => _db.collection('users');
  CollectionReference get _providersCol => _db.collection('providers');
  CollectionReference get _bookingsCol => _db.collection('bookings');
  CollectionReference get _servicesCol => _db.collection('services');

  // ---------------------------------------------------------------------------
  // Services Collection
  // ---------------------------------------------------------------------------

  /// Fetches all active services from Firestore
  Future<List<ServiceModel>> getAllServices() async {
    final snapshot = await _servicesCol
        .where('isActive', isEqualTo: true)
        .orderBy('name')
        .get();

    return snapshot.docs
        .map((doc) => ServiceModel.fromFirestore(doc))
        .toList();
  }

  /// Fetches services filtered by category
  Future<List<ServiceModel>> getServicesByCategory(String category) async {
    final snapshot = await _servicesCol
        .where('category', isEqualTo: category)
        .where('isActive', isEqualTo: true)
        .get();

    return snapshot.docs
        .map((doc) => ServiceModel.fromFirestore(doc))
        .toList();
  }

  // ---------------------------------------------------------------------------
  // Providers Collection
  // ---------------------------------------------------------------------------

  /// Returns all available providers for a given service category
  Future<List<ProviderModel>> getProvidersByCategory(String category) async {
    final snapshot = await _providersCol
        .where('serviceCategories', arrayContains: category)
        .where('isAvailable', isEqualTo: true)
        .get();

    return snapshot.docs
        .map((doc) => ProviderModel.fromFirestore(doc))
        .toList();
  }

  /// Returns a live stream of a single provider's data
  Stream<ProviderModel?> providerStream(String providerId) {
    return _providersCol.doc(providerId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return ProviderModel.fromFirestore(doc);
    });
  }

  /// Fetches a single provider by their document ID
  Future<ProviderModel?> getProvider(String providerId) async {
    final doc = await _providersCol.doc(providerId).get();
    if (!doc.exists) return null;
    return ProviderModel.fromFirestore(doc);
  }

  // ---------------------------------------------------------------------------
  // Bookings Collection
  // ---------------------------------------------------------------------------

  /// Creates a new booking document in Firestore
  /// Returns the auto-generated booking ID
  Future<String> createBooking(BookingModel booking) async {
    final docRef = await _bookingsCol.add(booking.toFirestore());
    return docRef.id;
  }

  /// Updates the status of a booking (e.g. accept/reject by provider)
  Future<void> updateBookingStatus({
    required String bookingId,
    required BookingStatus status,
  }) async {
    await _bookingsCol.doc(bookingId).update({
      'status': status.value,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  /// Cancels a booking — only the customer can do this
  Future<void> cancelBooking(String bookingId) async {
    await updateBookingStatus(
      bookingId: bookingId,
      status: BookingStatus.cancelled,
    );
  }

  /// Marks a booking as completed (typically done by provider or admin)
  Future<void> completeBooking(String bookingId) async {
    await updateBookingStatus(
      bookingId: bookingId,
      status: BookingStatus.completed,
    );
  }

  /// Adds a customer's rating and review to a completed booking
  Future<void> rateBooking({
    required String bookingId,
    required double rating,
    String? review,
  }) async {
    await _bookingsCol.doc(bookingId).update({
      'customerRating': rating,
      'customerReview': review,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  /// Returns a live stream of all bookings for a specific customer
  Stream<List<BookingModel>> customerBookingsStream(String customerId) {
    return _bookingsCol
        .where('customerId', isEqualTo: customerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BookingModel.fromFirestore(doc))
            .toList());
  }

  /// Returns a live stream of all bookings assigned to a specific provider
  Stream<List<BookingModel>> providerBookingsStream(String providerId) {
    return _bookingsCol
        .where('providerId', isEqualTo: providerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BookingModel.fromFirestore(doc))
            .toList());
  }

  /// Returns upcoming bookings for a customer (pending + confirmed)
  Stream<List<BookingModel>> customerUpcomingBookingsStream(String customerId) {
    return _bookingsCol
        .where('customerId', isEqualTo: customerId)
        .where('status', whereIn: ['pending', 'confirmed'])
        .orderBy('scheduledDate')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BookingModel.fromFirestore(doc))
            .toList());
  }

  /// Returns past bookings for a customer (completed + cancelled + rejected)
  Stream<List<BookingModel>> customerPastBookingsStream(String customerId) {
    return _bookingsCol
        .where('customerId', isEqualTo: customerId)
        .where('status', whereIn: ['completed', 'cancelled', 'rejected'])
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BookingModel.fromFirestore(doc))
            .toList());
  }

  /// Returns pending booking requests for a provider
  Stream<List<BookingModel>> providerPendingBookingsStream(String providerId) {
    return _bookingsCol
        .where('providerId', isEqualTo: providerId)
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BookingModel.fromFirestore(doc))
            .toList());
  }

  // ---------------------------------------------------------------------------
  // Seed / Admin Helpers (call once to populate Firestore)
  // ---------------------------------------------------------------------------

  /// Seeds dummy provider data into Firestore (for development/testing)
  Future<void> seedDummyProviders() async {
    final providers = [
      {
        'userId': 'provider_user_1',
        'fullName': 'Ramesh Kumar',
        'email': 'ramesh@fixghar.com',
        'phoneNumber': '+919876543201',
        'serviceCategories': ['ac_repair', 'electrical'],
        'rating': 4.5,
        'totalRatings': 128,
        'totalJobsCompleted': 243,
        'chargePerHour': 350.0,
        'city': 'Mumbai',
        'area': 'Andheri West',
        'isAvailable': true,
        'isVerified': true,
        'bio': '10+ years of experience in AC repair and electrical work.',
        'skills': ['Split AC', 'Window AC', 'Inverter AC', 'Wiring'],
        'joinedAt': Timestamp.fromDate(DateTime(2022, 1, 15)),
      },
      {
        'userId': 'provider_user_2',
        'fullName': 'Suresh Yadav',
        'email': 'suresh@fixghar.com',
        'phoneNumber': '+919876543202',
        'serviceCategories': ['plumbing', 'carpentry'],
        'rating': 4.2,
        'totalRatings': 89,
        'totalJobsCompleted': 176,
        'chargePerHour': 299.0,
        'city': 'Mumbai',
        'area': 'Borivali',
        'isAvailable': true,
        'isVerified': true,
        'bio': '8 years in plumbing, handles all types of pipe work.',
        'skills': ['Pipe Fitting', 'Leak Repair', 'Bathroom Fitting'],
        'joinedAt': Timestamp.fromDate(DateTime(2022, 6, 1)),
      },
    ];

    for (final provider in providers) {
      await _providersCol.add(provider);
    }
  }

  /// Seeds service data into Firestore (call once from admin)
  Future<void> seedServices() async {
    final services = [
      {
        'name': 'AC Repair & Service',
        'description': 'Professional AC inspection, gas refilling, and repair.',
        'category': 'ac_repair',
        'iconName': 'ac_unit',
        'startingPrice': 299.0,
        'durationMinutes': 90,
        'isActive': true,
        'subServices': ['Gas Refilling', 'Deep Cleaning', 'PCB Repair'],
        'createdAt': Timestamp.now(),
      },
      {
        'name': 'Home Cleaning',
        'description': 'Full home deep cleaning service by trained professionals.',
        'category': 'cleaning',
        'iconName': 'cleaning_services',
        'startingPrice': 399.0,
        'durationMinutes': 180,
        'isActive': true,
        'subServices': ['Regular Cleaning', 'Deep Cleaning', 'Kitchen Cleaning'],
        'createdAt': Timestamp.now(),
      },
      {
        'name': 'Plumbing Services',
        'description': 'All types of plumbing work including pipe repair and installation.',
        'category': 'plumbing',
        'iconName': 'plumbing',
        'startingPrice': 199.0,
        'durationMinutes': 60,
        'isActive': true,
        'subServices': ['Leak Repair', 'Tap/Faucet', 'Blocked Drain'],
        'createdAt': Timestamp.now(),
      },
    ];

    for (final service in services) {
      await _servicesCol.add(service);
    }
  }
}
