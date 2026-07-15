import 'package:flutter/material.dart';

/// Colors copied 1:1 from the `tailwind.config` block that appears in
/// every PureDent HTML mockup (service-list, service-detail, doctor-list,
/// doctor-detail). Keeping the same names (camelCased) makes it easy to
/// diff against the HTML if you add new screens later.
class AppColors {
  AppColors._();

  static const primary = Color(0xFF005C55);
  static const onPrimary = Color(0xFFFFFFFF);
  static const primaryContainer = Color(0xFF0F766E);
  static const onPrimaryContainer = Color(0xFFA3FAEF);
  static const primaryFixed = Color(0xFF9CF2E8);
  static const primaryFixedDim = Color(0xFF80D5CB);
  static const onPrimaryFixed = Color(0xFF00201D);
  static const onPrimaryFixedVariant = Color(0xFF00504A);
  static const inversePrimary = Color(0xFF80D5CB);

  static const secondary = Color(0xFF006B5F);
  static const onSecondary = Color(0xFFFFFFFF);
  static const secondaryContainer = Color(0xFF6DF5E1);
  static const onSecondaryContainer = Color(0xFF006F64);
  static const secondaryFixed = Color(0xFF71F8E4);
  static const secondaryFixedDim = Color(0xFF4FDBC8);
  static const onSecondaryFixed = Color(0xFF00201C);
  static const onSecondaryFixedVariant = Color(0xFF005048);

  static const tertiary = Color(0xFF7F4025);
  static const onTertiary = Color(0xFFFFFFFF);
  static const tertiaryContainer = Color(0xFF9C573A);
  static const onTertiaryContainer = Color(0xFFFFE5DB);
  static const tertiaryFixed = Color(0xFFFFDBCE);
  static const tertiaryFixedDim = Color(0xFFFFB598);
  static const onTertiaryFixed = Color(0xFF370E00);
  static const onTertiaryFixedVariant = Color(0xFF72361B);

  static const error = Color(0xFFBA1A1A);
  static const onError = Color(0xFFFFFFFF);
  static const errorContainer = Color(0xFFFFDAD6);
  static const onErrorContainer = Color(0xFF93000A);

  static const background = Color(0xFFF7FAF8);
  static const onBackground = Color(0xFF181C1C);
  static const surface = Color(0xFFF7FAF8);
  static const onSurface = Color(0xFF181C1C);
  static const surfaceDim = Color(0xFFD7DBD9);
  static const surfaceBright = Color(0xFFF7FAF8);
  static const surfaceVariant = Color(0xFFE0E3E1);
  static const onSurfaceVariant = Color(0xFF3E4947);

  static const surfaceContainerLowest = Color(0xFFFFFFFF);
  static const surfaceContainerLow = Color(0xFFF1F4F3);
  static const surfaceContainer = Color(0xFFEBEFED);
  static const surfaceContainerHigh = Color(0xFFE5E9E7);
  static const surfaceContainerHighest = Color(0xFFE0E3E1);

  static const inverseSurface = Color(0xFF2D3130);
  static const inverseOnSurface = Color(0xFFEEF1F0);

  static const outline = Color(0xFF6E7977);
  static const outlineVariant = Color(0xFFBDC9C6);

  static const surfaceTint = Color(0xFF006A63);
}
