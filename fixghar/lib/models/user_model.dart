import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a customer user in the FixGhar app
/// Maps directly to the 'users' collection in Firestore
class UserModel {
  final String uid;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String? profileImageUrl;
  final String role; // 'customer' or 'provider'
  final List<String> savedAddresses;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserModel({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    this.profileImageUrl,
    this.role = 'customer',
    this.savedAddresses = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  /// Creates a UserModel from a Firestore document snapshot
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      fullName: data['fullName'] ?? '',
      email: data['email'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      profileImageUrl: data['profileImageUrl'],
      role: data['role'] ?? 'customer',
      savedAddresses: List<String>.from(data['savedAddresses'] ?? []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Converts UserModel to a Map for Firestore storage
  Map<String, dynamic> toFirestore() {
    return {
      'fullName': fullName,
      'email': email,
      'phoneNumber': phoneNumber,
      'profileImageUrl': profileImageUrl,
      'role': role,
      'savedAddresses': savedAddresses,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// Creates a copy of UserModel with updated fields
  UserModel copyWith({
    String? fullName,
    String? email,
    String? phoneNumber,
    String? profileImageUrl,
    String? role,
    List<String>? savedAddresses,
    DateTime? updatedAt,
  }) {
    return UserModel(
      uid: uid,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      role: role ?? this.role,
      savedAddresses: savedAddresses ?? this.savedAddresses,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() => 'UserModel(uid: $uid, name: $fullName, role: $role)';
}
