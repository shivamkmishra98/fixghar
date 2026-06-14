import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/constants/app_colors.dart';
import '../models/booking_model.dart';

/// Displays a single booking in the Bookings History screen
/// Shows service name, provider, date/time, status badge, and action buttons
class BookingCard extends StatelessWidget {
  final BookingModel booking;
  final VoidCallback? onCancel;
  final VoidCallback? onRate;

  const BookingCard({
    super.key,
    required this.booking,
    this.onCancel,
    this.onRate,
  });

  Color _statusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return AppColors.statusPending;
      case BookingStatus.confirmed:
        return AppColors.statusConfirmed;
      case BookingStatus.rejected:
        return AppColors.statusRejected;
      case BookingStatus.completed:
        return AppColors.statusCompleted;
      case BookingStatus.cancelled:
        return AppColors.error;
    }
  }

  IconData _statusIcon(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return Icons.schedule_rounded;
      case BookingStatus.confirmed:
        return Icons.check_circle_rounded;
      case BookingStatus.rejected:
        return Icons.cancel_rounded;
      case BookingStatus.completed:
        return Icons.task_alt_rounded;
      case BookingStatus.cancelled:
        return Icons.do_not_disturb_alt_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(booking.status);
    final formattedDate =
        DateFormat('EEE, d MMM yyyy').format(booking.scheduledDate);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: statusColor.withValues(alpha: 0.25), width: 1),
      ),
      elevation: 1.5,
      shadowColor: AppColors.shadow,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: service name + status badge
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.serviceName,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'By ${booking.providerName}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                // Status badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_statusIcon(booking.status),
                          size: 13, color: statusColor),
                      const SizedBox(width: 4),
                      Text(
                        booking.status.label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),
            const Divider(height: 1, color: AppColors.divider),
            const SizedBox(height: 12),

            // Date, time, address row
            _InfoRow(
              icon: Icons.calendar_today_rounded,
              text: formattedDate,
            ),
            const SizedBox(height: 6),
            _InfoRow(
              icon: Icons.access_time_rounded,
              text: booking.scheduledTime,
            ),
            const SizedBox(height: 6),
            _InfoRow(
              icon: Icons.location_on_rounded,
              text: booking.address,
              maxLines: 2,
            ),

            const SizedBox(height: 12),

            // Amount row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Estimated Amount',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  booking.formattedAmount,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),

            // Action buttons (only for active or completed bookings)
            if (booking.isActive || booking.status == BookingStatus.completed)
              const SizedBox(height: 14),

            if (booking.isActive || booking.status == BookingStatus.completed)
              Row(
                children: [
                  // Cancel (only for active bookings)
                  if (booking.isActive && onCancel != null)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onCancel,
                        icon: const Icon(Icons.close_rounded, size: 15),
                        label: const Text('Cancel'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                          side: const BorderSide(color: AppColors.error),
                          padding: const EdgeInsets.symmetric(vertical: 9),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  if (booking.isActive && onCancel != null)
                    const SizedBox(width: 10),
                  // Rate (only for completed bookings without a rating)
                  if (booking.status == BookingStatus.completed &&
                      booking.customerRating == null &&
                      onRate != null)
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onRate,
                        icon: const Icon(Icons.star_rounded, size: 15),
                        label: const Text('Rate Service'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.starActive,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 9),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  // Show rating if already rated
                  if (booking.status == BookingStatus.completed &&
                      booking.customerRating != null)
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.star_rounded,
                              color: AppColors.starActive, size: 18),
                          const SizedBox(width: 4),
                          Text(
                            'You rated ${booking.customerRating!.toStringAsFixed(1)}',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

/// Internal helper widget for icon + text info rows
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final int maxLines;

  const _InfoRow({
    required this.icon,
    required this.text,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment:
          maxLines > 1 ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 14, color: AppColors.textSecondary),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}
