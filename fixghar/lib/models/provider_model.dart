import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a service provider in FixGhar
/// Maps to the 'providers' collection in Firestore
class ProviderModel {
  final String id;
  final String userId;          // Links to users collection
  final String fullName;
  final String email;
  final String phoneNumber;
  final String? profileImageUrl;
  final List<String> serviceCategories; // List of category IDs they offer
  final double rating;           // Average rating (0.0 - 5.0)
  final int totalRatings;        // Number of ratings received
  final int totalJobsCompleted;
  final double chargePerHour;    // Per hour rate in INR
  final String city;
  final String area;             // Service area/locality
  final bool isAvailable;        // Currently accepting new bookings
  final bool isVerified;         // Admin-verified provider
  final String bio;              // Short description / experience
  final List<String> skills;     // Specific skills / certifications
  final DateTime joinedAt;

  const ProviderModel({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    this.profileImageUrl,
    required this.serviceCategories,
    this.rating = 0.0,
    this.totalRatings = 0,
    this.totalJobsCompleted = 0,
    required this.chargePerHour,
    required this.city,
    required this.area,
    this.isAvailable = true,
    this.isVerified = false,
    this.bio = '',
    this.skills = const [],
    required this.joinedAt,
  });

  /// Creates a ProviderModel from a Firestore document snapshot
  factory ProviderModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProviderModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      fullName: data['fullName'] ?? '',
      email: data['email'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      profileImageUrl: data['profileImageUrl'],
      serviceCategories: List<String>.from(data['serviceCategories'] ?? []),
      rating: (data['rating'] ?? 0.0).toDouble(),
      totalRatings: data['totalRatings'] ?? 0,
      totalJobsCompleted: data['totalJobsCompleted'] ?? 0,
      chargePerHour: (data['chargePerHour'] ?? 0).toDouble(),
      city: data['city'] ?? '',
      area: data['area'] ?? '',
      isAvailable: data['isAvailable'] ?? true,
      isVerified: data['isVerified'] ?? false,
      bio: data['bio'] ?? '',
      skills: List<String>.from(data['skills'] ?? []),
      joinedAt: (data['joinedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Converts ProviderModel to Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'fullName': fullName,
      'email': email,
      'phoneNumber': phoneNumber,
      'profileImageUrl': profileImageUrl,
      'serviceCategories': serviceCategories,
      'rating': rating,
      'totalRatings': totalRatings,
      'totalJobsCompleted': totalJobsCompleted,
      'chargePerHour': chargePerHour,
      'city': city,
      'area': area,
      'isAvailable': isAvailable,
      'isVerified': isVerified,
      'bio': bio,
      'skills': skills,
      'joinedAt': Timestamp.fromDate(joinedAt),
    };
  }

  /// Returns formatted rating string e.g. "4.5 (120 ratings)"
  String get formattedRating =>
      '${rating.toStringAsFixed(1)} ($totalRatings ratings)';

  /// Returns formatted hourly rate e.g. "₹350/hr"
  String get formattedCharge => '₹${chargePerHour.toStringAsFixed(0)}/hr';

  @override
  String toString() => 'ProviderModel(id: $id, name: $fullName)';
}
