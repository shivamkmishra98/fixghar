import 'package:flutter/material.dart';

/// App-wide color constants for FixGhar
/// Using Material 3 color scheme with a modern blue-teal palette
class AppColors {
  AppColors._(); // Private constructor to prevent instantiation

  // Primary Brand Colors
  static const Color primary = Color(0xFF1565C0);       // Deep Blue
  static const Color primaryLight = Color(0xFF5E92F3);  // Light Blue
  static const Color primaryDark = Color(0xFF003C8F);   // Dark Blue

  // Secondary / Accent
  static const Color secondary = Color(0xFF00897B);     // Teal
  static const Color secondaryLight = Color(0xFF4EBAAA);
  static const Color secondaryDark = Color(0xFF005B4F);

  // Background & Surface
  static const Color background = Color(0xFFF5F7FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFEEF2F7);

  // Text
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textHint = Color(0xFFB0B8C4);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Status Colors
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Booking Status Colors
  static const Color statusPending = Color(0xFFF59E0B);
  static const Color statusConfirmed = Color(0xFF22C55E);
  static const Color statusRejected = Color(0xFFEF4444);
  static const Color statusCompleted = Color(0xFF6366F1);

  // Divider & Border
  static const Color divider = Color(0xFFE5E7EB);
  static const Color border = Color(0xFFD1D5DB);

  // Shadow
  static const Color shadow = Color(0x1A000000);

  // Card & Bottom Nav
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color bottomNavBackground = Color(0xFFFFFFFF);

  // Star Rating
  static const Color starActive = Color(0xFFFBBC05);
  static const Color starInactive = Color(0xFFE5E7EB);

  // Category Card colors (one per service category)
  static const List<Color> categoryColors = [
    Color(0xFFE3F0FF), // AC Repair - light blue
    Color(0xFFE8F5E9), // Cleaning - light green
    Color(0xFFE8EAF6), // Plumbing - light indigo
    Color(0xFFFFF3E0), // Carpentry - light orange
    Color(0xFFFFFDE7), // Electrical - light yellow
    Color(0xFFFCE4EC), // Pest Control - light pink
    Color(0xFFE0F7FA), // Appliance - light cyan
  ];

  static const List<Color> categoryIconColors = [
    Color(0xFF1565C0),
    Color(0xFF2E7D32),
    Color(0xFF283593),
    Color(0xFFE65100),
    Color(0xFFF9A825),
    Color(0xFFC62828),
    Color(0xFF00838F),
  ];
}
