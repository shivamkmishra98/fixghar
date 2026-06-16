import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a home service category/type in FixGhar
/// Maps to the 'services' collection in Firestore
class ServiceModel {
  final String id;
  final String name;
  final String description;
  final String category;
  final String iconName; // Material icon name or asset path
  final double startingPrice; // Minimum price shown on listing
  final int durationMinutes; // Estimated duration in minutes
  final bool isActive;
  final List<String> subServices; // E.g. ['Deep Cleaning', 'Regular Cleaning']
  final DateTime createdAt;

  const ServiceModel({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.iconName,
    required this.startingPrice,
    required this.durationMinutes,
    this.isActive = true,
    this.subServices = const [],
    required this.createdAt,
  });

  /// Creates a ServiceModel from a Firestore document snapshot
  factory ServiceModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ServiceModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      iconName: data['iconName'] ?? 'build',
      startingPrice: (data['startingPrice'] ?? 0).toDouble(),
      durationMinutes: data['durationMinutes'] ?? 60,
      isActive: data['isActive'] ?? true,
      subServices: List<String>.from(data['subServices'] ?? []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Converts ServiceModel to Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'category': category,
      'iconName': iconName,
      'startingPrice': startingPrice,
      'durationMinutes': durationMinutes,
      'isActive': isActive,
      'subServices': subServices,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// Returns formatted price string e.g. "₹299 onwards"
  String get formattedPrice => '₹${startingPrice.toStringAsFixed(0)} onwards';

  /// Returns formatted duration e.g. "2 hours"
  String get formattedDuration {
    if (durationMinutes < 60) return '$durationMinutes mins';
    final hours = durationMinutes ~/ 60;
    final mins = durationMinutes % 60;
    return mins > 0 ? '$hours hr $mins min' : '$hours hr';
  }

  @override
  String toString() => 'ServiceModel(id: $id, name: $name)';
}

/// Predefined list of service categories shown on the home screen
class ServiceCategory {
  final String id;
  final String name;
  final String iconAsset; // e.g. 'assets/icons/ac.png'
  final int colorIndex; // Index into AppColors.categoryColors

  const ServiceCategory({
    required this.id,
    required this.name,
    required this.iconAsset,
    required this.colorIndex,
  });

  /// All available home service categories in FixGhar
  static List<ServiceCategory> get all => [
        const ServiceCategory(
          id: 'ac_repair',
          name: 'AC Repair',
          iconAsset: 'ac',
          colorIndex: 0,
        ),
        const ServiceCategory(
          id: 'cleaning',
          name: 'Cleaning',
          iconAsset: 'cleaning',
          colorIndex: 1,
        ),
        const ServiceCategory(
          id: 'plumbing',
          name: 'Plumbing',
          iconAsset: 'plumbing',
          colorIndex: 2,
        ),
        const ServiceCategory(
          id: 'carpentry',
          name: 'Carpentry',
          iconAsset: 'carpentry',
          colorIndex: 3,
        ),
        const ServiceCategory(
          id: 'electrical',
          name: 'Electrical',
          iconAsset: 'electrical',
          colorIndex: 4,
        ),
        const ServiceCategory(
          id: 'pest_control',
          name: 'Pest Control',
          iconAsset: 'pest_control',
          colorIndex: 5,
        ),
        const ServiceCategory(
          id: 'appliance_repair',
          name: 'Appliance Repair',
          iconAsset: 'appliance',
          colorIndex: 6,
        ),
      ];
}
