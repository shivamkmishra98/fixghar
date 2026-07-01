import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a single item in the user's cart
/// Maps to the 'users/{uid}/cart/{itemId}' collection in Firestore
class CartItemModel {
  final String id;
  final String providerId;
  final String providerName;
  final String serviceId;
  final String serviceName;
  final String serviceCategory;
  final double price;
  final int quantity;
  final String iconName;
  final DateTime addedAt;

  const CartItemModel({
    required this.id,
    required this.providerId,
    required this.providerName,
    required this.serviceId,
    required this.serviceName,
    required this.serviceCategory,
    required this.price,
    required this.quantity,
    required this.iconName,
    required this.addedAt,
  });

  /// Creates a CartItemModel from a Firestore document snapshot
  factory CartItemModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CartItemModel(
      id: doc.id,
      providerId: data['providerId'] ?? '',
      providerName: data['providerName'] ?? '',
      serviceId: data['serviceId'] ?? '',
      serviceName: data['serviceName'] ?? '',
      serviceCategory: data['serviceCategory'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      quantity: data['quantity'] ?? 1,
      iconName: data['iconName'] ?? 'build',
      addedAt: (data['addedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Converts CartItemModel to Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'providerId': providerId,
      'providerName': providerName,
      'serviceId': serviceId,
      'serviceName': serviceName,
      'serviceCategory': serviceCategory,
      'price': price,
      'quantity': quantity,
      'iconName': iconName,
      'addedAt': Timestamp.fromDate(addedAt),
    };
  }

  /// Returns a copy of this CartItemModel with updated fields
  CartItemModel copyWith({
    int? quantity,
  }) {
    return CartItemModel(
      id: id,
      providerId: providerId,
      providerName: providerName,
      serviceId: serviceId,
      serviceName: serviceName,
      serviceCategory: serviceCategory,
      price: price,
      quantity: quantity ?? this.quantity,
      iconName: iconName,
      addedAt: addedAt,
    );
  }

  /// Total price for this item based on quantity
  double get totalPrice => price * quantity;

  @override
  String toString() =>
      'CartItemModel(id: $id, service: $serviceName, qty: $quantity)';
}
