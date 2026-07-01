import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../models/provider_model.dart';

/// Displays a provider card on the service listing screen
/// Shows name, rating, price, area, and a "Book Now" button
class ServiceCard extends StatelessWidget {
  final ProviderModel provider;
  final VoidCallback onBookTap;
  final VoidCallback? onViewProfile;
  final VoidCallback? onAddToCartTap;

  const ServiceCard({
    super.key,
    required this.provider,
    required this.onBookTap,
    this.onViewProfile,
    this.onAddToCartTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      shadowColor: AppColors.shadow,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: Avatar + Name + Verified badge
            Row(
              children: [
                // Provider avatar
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.primaryLight.withValues(alpha: 0.2),
                  backgroundImage: provider.profileImageUrl != null
                      ? NetworkImage(provider.profileImageUrl!)
                      : null,
                  child: provider.profileImageUrl == null
                      ? Text(
                          provider.fullName.isNotEmpty
                              ? provider.fullName[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                // Name & area
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              provider.fullName,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (provider.isVerified) ...[
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.verified_rounded,
                              size: 16,
                              color: AppColors.primary,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_rounded,
                            size: 13,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '${provider.area}, ${provider.city}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Availability badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: provider.isAvailable
                        ? AppColors.success.withValues(alpha: 0.12)
                        : AppColors.error.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    provider.isAvailable ? 'Available' : 'Busy',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: provider.isAvailable
                          ? AppColors.success
                          : AppColors.error,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),
            const Divider(height: 1, color: AppColors.divider),
            const SizedBox(height: 12),

            // Stats row: Rating | Jobs | Price
            Row(
              children: [
                _StatChip(
                  icon: Icons.star_rounded,
                  iconColor: AppColors.starActive,
                  label: provider.rating.toStringAsFixed(1),
                  sub: '(${provider.totalRatings})',
                ),
                const SizedBox(width: 16),
                _StatChip(
                  icon: Icons.check_circle_rounded,
                  iconColor: AppColors.success,
                  label: '${provider.totalJobsCompleted}',
                  sub: 'jobs',
                ),
                const SizedBox(width: 16),
                _StatChip(
                  icon: Icons.currency_rupee_rounded,
                  iconColor: AppColors.secondary,
                  label: provider.chargePerHour.toStringAsFixed(0),
                  sub: '/hr',
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Bio / experience snippet
            if (provider.bio.isNotEmpty)
              Text(
                provider.bio,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),

            const SizedBox(height: 14),

            // Action buttons
            Row(
              children: [
                if (onViewProfile != null)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onViewProfile,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        side: const BorderSide(
                            color: AppColors.primary, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'View Profile',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                if (onViewProfile != null) const SizedBox(width: 10),
                Expanded(
                 child: OutlinedButton.icon(
                   onPressed: onAddToCartTap ?? () {
                     ScaffoldMessenger.of(context).showSnackBar(
                       const SnackBar(
                          content: Text("Added to Cart"),
                        ),
                      );
                    },
                    icon: const Icon(Icons.shopping_cart_outlined),
                    label: const Text("Cart"),
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: ElevatedButton(
                    onPressed: provider.isAvailable ? onBookTap : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Book Now',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                   ),
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

/// Internal widget for the stats row on the service card
class _StatChip extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String sub;

  const _StatChip({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.sub,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 15, color: iconColor),
        const SizedBox(width: 3),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(width: 2),
        Text(
          sub,
          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
