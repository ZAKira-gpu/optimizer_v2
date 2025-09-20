import 'package:flutter/material.dart';

/// App color constants
///
/// This file contains all the color definitions used throughout the app.
/// This makes it easy to maintain consistent theming and update colors globally.
class AppColors {
  // Private constructor to prevent instantiation
  AppColors._();

  // Primary Colors
  static const Color primary = Color(0xFF667eea);
  static const Color primaryDark = Color(0xFF764ba2);
  static const Color primaryLight = Color(0xFFf093fb);

  // Secondary Colors
  static const Color secondary = Color(0xFF764ba2);
  static const Color accent = Color(0xFFf093fb);

  // Neutral Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color grey = Color(0xFF718096);
  static const Color lightGrey = Color(0xFFF7FAFC);
  static const Color darkGrey = Color(0xFF2D3748);

  // Background Colors
  static const Color background = Color(0xFFF7FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color cardBackground = Color(0xFFFFFFFF);

  // Text Colors
  static const Color textPrimary = Color(0xFF2D3748);
  static const Color textSecondary = Color(0xFF718096);
  static const Color textLight = Color(0xFFA0AEC0);

  // Status Colors
  static const Color success = Color(0xFF48BB78);
  static const Color warning = Color(0xFFED8936);
  static const Color error = Color(0xFFE53E3E);
  static const Color info = Color(0xFF4299E1);

  // Gradient Colors
  static const List<Color> primaryGradient = [
    Color(0xFF667eea),
    Color(0xFF764ba2),
    Color(0xFFf093fb),
  ];

  static const List<Color> cardGradient = [
    Color(0xFF667eea),
    Color(0xFF764ba2),
  ];
}
