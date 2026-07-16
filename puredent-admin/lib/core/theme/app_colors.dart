import 'package:flutter/material.dart';

/// Colors ported 1:1 from the website's tailwind.config.js / index.css
/// so the Flutter app and the web admin panel look like the same product.
class AppColors {
  AppColors._();

  static const primary = Color(0xFF005C55);
  static const onPrimary = Color(0xFFFFFFFF);
  static const primaryContainer = Color(0xFF0F766E);
  static const primaryFixed = Color(0xFF9CF2E8);

  static const secondary = Color(0xFF006B5F);
  static const onSecondary = Color(0xFFFFFFFF);
  static const secondaryContainer = Color(0xFF6DF5E1);
  static const onSecondaryContainer = Color(0xFF006F64);

  static const tertiary = Color(0xFF7F4025);
  static const tertiaryContainer = Color(0xFF9C573A);
  static const tertiaryFixed = Color(0xFFFFDBCE);
  static const onTertiaryFixedVariant = Color(0xFF72361B);

  static const background = Color(0xFFF7FAF8);
  static const surface = Color(0xFFF7FAF8);
  static const surfaceContainerLowest = Color(0xFFFFFFFF);
  static const surfaceContainerLow = Color(0xFFF1F4F3);
  static const surfaceContainer = Color(0xFFEBEFED);
  static const surfaceContainerHigh = Color(0xFFE5E9E7);
  static const surfaceContainerHighest = Color(0xFFE0E3E1);

  static const onBackground = Color(0xFF181C1C);
  static const onSurface = Color(0xFF181C1C);
  static const onSurfaceVariant = Color(0xFF3E4947);
  static const outline = Color(0xFF6E7977);
  static const outlineVariant = Color(0xFFBDC9C6);

  static const error = Color(0xFFBA1A1A);
  static const onError = Color(0xFFFFFFFF);
  static const errorContainer = Color(0xFFFFDAD6);
  static const onErrorContainer = Color(0xFF93000A);

  /// Soft glow used behind gradients / decorative blur circles.
  static const secondaryGlow = Color(0x14006B5F); // secondary at ~8% opacity
  static const primaryGlow = Color(0x14005C55); // primary at ~8% opacity
}