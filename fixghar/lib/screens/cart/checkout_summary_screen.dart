import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../services/firestore_service.dart';
import '../../models/booking_model.dart';


class CheckoutSummaryScreen extends StatefulWidget {
  final String selectedAddress;

  const CheckoutSummaryScreen({super.key, required this.selectedAddress});

  @override
  State<CheckoutSummaryScreen> createState() => _CheckoutSummaryScreenState();
}

class _CheckoutSummaryScreenState extends State<CheckoutSummaryScreen> {
  bool _isProcessing = false;

  Future<void> _processCheckout(BuildContext context) async {
    setState(() => _isProcessing = true);

    try {
      final cartProvider = context.read<CartProvider>();
      final authProvider = context.read<AuthProvider>();
      final firestoreService = FirestoreService();
      final user = authProvider.currentUser;

      if (user == null) throw Exception("User not found");

      // Generate bookings for each cart item
      // We will create separate bookings as they may be for different providers
      for (final item in cartProvider.items) {
        final booking = BookingModel(
          id: '', // Will be assigned by Firestore
          customerId: user.uid,
          customerName: user.fullName,
          customerPhone: user.phoneNumber,
          providerId: item.providerId,
          providerName: item.providerName,
          serviceId: item.serviceId,
          serviceName: item.serviceName,
          serviceCategory: item.serviceCategory,
          scheduledDate: DateTime.now().add(const Duration(days: 1)), // Default to tomorrow
          scheduledTime: '10:00 AM', // Default time
          address: widget.selectedAddress,
          status: BookingStatus.pending,
          estimatedAmount: item.totalPrice, // Quantity * price
          paymentMode: 'cash', // Default to cash for now
          isPaid: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await firestoreService.createBooking(booking);
      }

      // Clear the cart
      await cartProvider.clearCart();

      if (!context.mounted) return;

      // Show success and go to bookings
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Booking Successful!'),
          backgroundColor: AppColors.success,
        ),
      );

      // Navigate to Bookings tab (index 1)
      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false, arguments: 1);
    } catch (e) {
      setState(() => _isProcessing = false);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to process checkout: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();
    final items = cartProvider.items;

    if (items.isEmpty && !_isProcessing) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Checkout Summary'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.remove_shopping_cart_outlined, size: 80, color: AppColors.textHint.withValues(alpha: 0.5)),
              const SizedBox(height: 16),
              const Text(
                'Order Complete',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your cart is now empty.',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Checkout Summary'),
      ),
      body: Container(
        color: Colors.red,
        width: double.infinity,
        height: double.infinity,
        child: const Center(
          child: Text(
            'CHECKOUT SCREEN LOADED',
            style: TextStyle(
              fontSize: 24,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
