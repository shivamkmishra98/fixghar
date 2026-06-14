import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../widgets/booking_card.dart';

/// Shows the customer's upcoming and past bookings in two tabs
class BookingHistoryScreen extends StatefulWidget {
  const BookingHistoryScreen({super.key});

  @override
  State<BookingHistoryScreen> createState() => _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends State<BookingHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Start streaming bookings for the current user
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uid = context.read<AuthProvider>().currentUser?.uid;
      if (uid != null) {
        context.read<BookingProvider>().loadCustomerBookings(uid);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Show a confirmation dialog before cancelling a booking
  Future<void> _confirmCancel(
      BuildContext context, String bookingId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cancel Booking'),
        content: const Text(
          'Are you sure you want to cancel this booking? This cannot be undone.',
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No, keep it'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Yes, cancel'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success =
          await context.read<BookingProvider>().cancelBooking(bookingId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success
                ? 'Booking cancelled successfully.'
                : 'Failed to cancel. Please try again.'),
          ),
        );
      }
    }
  }

  // Show a rating dialog for a completed booking
  Future<void> _showRatingDialog(
      BuildContext context, String bookingId) async {
    double rating = 4.0;
    final reviewController = TextEditingController();

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Rate this Service'),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'How was your experience?',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 20),
              // Star rating row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return GestureDetector(
                    onTap: () =>
                        setDialogState(() => rating = index + 1.0),
                    child: Icon(
                      index < rating.round()
                          ? Icons.star_rounded
                          : Icons.star_border_rounded,
                      color: AppColors.starActive,
                      size: 36,
                    ),
                  );
                }),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: reviewController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Share your experience (optional)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        const BorderSide(color: AppColors.border),
                  ),
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Skip'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx);
                await context.read<BookingProvider>().rateBooking(
                      bookingId: bookingId,
                      rating: rating,
                      review: reviewController.text.trim().isEmpty
                          ? null
                          : reviewController.text.trim(),
                    );
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Thank you for your rating!')),
                  );
                }
              },
              child: const Text('Submit Rating'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bookingProvider = context.watch<BookingProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.myBookings),
        automaticallyImplyLeading: false,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          tabs: const [
            Tab(text: AppStrings.upcomingBookings),
            Tab(text: AppStrings.pastBookings),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // ----------------------------------------------------------------
          // Upcoming tab
          // ----------------------------------------------------------------
          _buildBookingList(
            isLoading: bookingProvider.isLoading,
            bookings: bookingProvider.upcomingBookings,
            emptyMessage: AppStrings.noUpcomingBookings,
            emptyIcon: Icons.calendar_today_rounded,
            onCancel: (id) => _confirmCancel(context, id),
          ),

          // ----------------------------------------------------------------
          // Past tab
          // ----------------------------------------------------------------
          _buildBookingList(
            isLoading: bookingProvider.isLoading,
            bookings: bookingProvider.pastBookings,
            emptyMessage: AppStrings.noPastBookings,
            emptyIcon: Icons.history_rounded,
            onRate: (id) => _showRatingDialog(context, id),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingList({
    required bool isLoading,
    required List bookings,
    required String emptyMessage,
    required IconData emptyIcon,
    void Function(String)? onCancel,
    void Function(String)? onRate,
  }) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (bookings.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(emptyIcon, size: 64, color: AppColors.textHint),
              const SizedBox(height: 16),
              Text(
                emptyMessage,
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final booking = bookings[index];
        return BookingCard(
          booking: booking,
          onCancel: onCancel != null ? () => onCancel(booking.id) : null,
          onRate: onRate != null ? () => onRate(booking.id) : null,
        );
      },
    );
  }
}
