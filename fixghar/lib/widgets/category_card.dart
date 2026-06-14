import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../models/service_model.dart';

/// Displays a single service category in the home screen grid
/// Tapping navigates to the service listing for that category
class CategoryCard extends StatelessWidget {
  final ServiceCategory category;
  final VoidCallback onTap;

  const CategoryCard({
    super.key,
    required this.category,
    required this.onTap,
  });

  // Maps category ID to a Material icon
  IconData _getIcon(String categoryId) {
    switch (categoryId) {
      case 'ac_repair':
        return Icons.ac_unit_rounded;
      case 'cleaning':
        return Icons.cleaning_services_rounded;
      case 'plumbing':
        return Icons.plumbing_rounded;
      case 'carpentry':
        return Icons.handyman_rounded;
      case 'electrical':
        return Icons.electrical_services_rounded;
      case 'pest_control':
        return Icons.bug_report_rounded;
      case 'appliance_repair':
        return Icons.kitchen_rounded;
      default:
        return Icons.build_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = AppColors.categoryColors[category.colorIndex];
    final iconColor = AppColors.categoryIconColors[category.colorIndex];

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: iconColor.withValues(alpha: 0.12),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon container
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getIcon(category.id),
                color: iconColor,
                size: 22,
              ),
            ),
            const SizedBox(height: 6),
            // Category label
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                category.name,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: iconColor,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
