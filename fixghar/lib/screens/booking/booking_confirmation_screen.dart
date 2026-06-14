import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../widgets/custom_button.dart';

/// Success screen shown after a booking is placed successfully
class BookingConfirmationScreen extends StatelessWidget {
  final String bookingId;
  final String providerName;
  final String serviceName;
  final String date;
  final String time;
  final String address;
  final double amount;

  const BookingConfirmationScreen({
    super.key,
    required this.bookingId,
    required this.providerName,
    required this.serviceName,
    required this.date,
    required this.time,
    required this.address,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 48),

              // Success animation / icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.success,
                  size: 60,
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                AppStrings.bookingConfirmed,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your booking request has been sent to $providerName.\nYou\'ll get a confirmation soon.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.6,
                ),
              ),

              const SizedBox(height: 36),

              // Booking details card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.shadow,
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          AppStrings.bookingDetails,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        // Booking ID chip
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '#${bookingId.substring(0, 6).toUpperCase()}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(height: 1, color: AppColors.divider),
                    const SizedBox(height: 14),
                    _DetailRow(
                      icon: Icons.home_repair_service_rounded,
                      label: AppStrings.serviceType,
                      value: serviceName,
                    ),
                    const SizedBox(height: 12),
                    _DetailRow(
                      icon: Icons.person_rounded,
                      label: AppStrings.providerName,
                      value: providerName,
                    ),
                    const SizedBox(height: 12),
                    _DetailRow(
                      icon: Icons.calendar_today_rounded,
                      label: AppStrings.scheduledDate,
                      value: date,
                    ),
                    const SizedBox(height: 12),
                    _DetailRow(
                      icon: Icons.access_time_rounded,
                      label: AppStrings.scheduledTime,
                      value: time,
                    ),
                    const SizedBox(height: 12),
                    _DetailRow(
                      icon: Icons.location_on_rounded,
                      label: 'Address',
                      value: address,
                    ),
                    const SizedBox(height: 12),
                    _DetailRow(
                      icon: Icons.currency_rupee_rounded,
                      label: AppStrings.totalAmount,
                      value: '₹${amount.toStringAsFixed(0)}',
                      valueColor: AppColors.primary,
                    ),
                    const SizedBox(height: 12),
                    const _DetailRow(
                      icon: Icons.payment_rounded,
                      label: AppStrings.paymentMode,
                      value: AppStrings.cashOnService,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Status pill
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.statusPending.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.schedule_rounded,
                        size: 14, color: AppColors.statusPending),
                    SizedBox(width: 6),
                    Text(
                      'Awaiting provider confirmation',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.statusPending,
                      ),
                    ),
                  ],
                ),
              ),

              // Go to My Bookings button
              CustomButton(
                label: 'View My Bookings',
                onPressed: () {
                  // Pop back to main nav and switch to bookings tab
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    '/',
                    (route) => false,
                    arguments: 1, // Tab index for Bookings
                  );
                },
                icon: Icons.receipt_long_rounded,
              ),
              const SizedBox(height: 16),
              CustomButton(
                label: 'Back to Home',
                onPressed: () {
                  Navigator.of(context)
                      .pushNamedAndRemoveUntil('/', (route) => false);
                },
                backgroundColor: Colors.transparent,
                textColor: AppColors.primary,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 15, color: AppColors.textSecondary),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textHint,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                value,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: valueColor ?? AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
