import 'dart:async';
import 'package:flutter/material.dart';
import '../models/cart_item_model.dart';
import '../services/firestore_service.dart';

class CartProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  StreamSubscription<List<CartItemModel>>? _cartSubscription;

  String? _userId;
  List<CartItemModel> _items = [];
  bool _isLoading = false;

  List<CartItemModel> get items => _items;
  bool get isLoading => _isLoading;

  /// Total number of items (sum of quantities)
  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  /// Subtotal cost of items in cart
  double get subtotal => _items.fold(0.0, (sum, item) => sum + item.totalPrice);

  /// Total cost (subtotal + any taxes/fees, currently just subtotal)
  double get total => subtotal;

  /// Called by ChangeNotifierProxyProvider whenever AuthProvider changes
  void updateUser(String? userId) {
    if (_userId == userId) return; // No change

    _userId = userId;
    _items = [];
    _cartSubscription?.cancel();

    if (_userId != null) {
      _isLoading = true;
      notifyListeners();

      _cartSubscription = _firestoreService.cartStream(_userId!).listen(
        (cartItems) {
          _items = cartItems;
          _isLoading = false;
          notifyListeners();
        },
        onError: (e) {
          _isLoading = false;
          debugPrint('Error loading cart: $e');
          notifyListeners();
        },
      );
    } else {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _cartSubscription?.cancel();
    super.dispose();
  }

  /// Adds a new item or increments its quantity if it already exists
  Future<void> addItem(CartItemModel item) async {
    if (_userId == null) return;
    await _firestoreService.addToCart(_userId!, item);
  }

  /// Increases quantity by 1
  Future<void> increaseQuantity(String itemId) async {
    if (_userId == null) return;
    final item = _items.firstWhere((i) => i.id == itemId);
    await _firestoreService.updateCartItemQuantity(_userId!, itemId, item.quantity + 1);
  }

  /// Decreases quantity by 1, removes if it drops to 0
  Future<void> decreaseQuantity(String itemId) async {
    if (_userId == null) return;
    final item = _items.firstWhere((i) => i.id == itemId);
    await _firestoreService.updateCartItemQuantity(_userId!, itemId, item.quantity - 1);
  }

  /// Completely removes an item from the cart
  Future<void> removeItem(String itemId) async {
    if (_userId == null) return;
    await _firestoreService.removeFromCart(_userId!, itemId);
  }

  /// Clears the entire cart
  Future<void> clearCart() async {
    if (_userId == null) return;
    await _firestoreService.clearCart(_userId!);
  }
}