import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Text scale copied from the tailwind `fontSize` block.
///
/// The HTML mockups use "Plus Jakarta Sans" (headlines) and "Inter"
/// (body/label text) via Google Fonts. To keep this project buildable
/// offline with zero extra packages, these styles currently fall back
/// to the platform's default font. If you want the exact fonts later:
///   1. Download the .ttf files for Plus Jakarta Sans + Inter
///   2. Put them in assets/fonts/
///   3. Register them under `flutter: fonts:` in pubspec.yaml
///   4. Set `fontFamily: 'PlusJakartaSans'` / `'Inter'` below
/// (Alternatively, add the `google_fonts` package back to pubspec.yaml
/// and run `flutter pub get` with internet access — then swap these
/// TextStyle(...) calls for GoogleFonts.plusJakartaSans(...) / .inter(...).)
class AppTextStyles {
  AppTextStyles._();

  static TextStyle get headlineXl => TextStyle(
        fontSize: 48,
        height: 56 / 48,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.02 * 48,
        color: AppColors.onSurface,
      );

  static TextStyle get headlineLg => TextStyle(
        fontSize: 32,
        height: 40 / 32,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.02 * 32,
        color: AppColors.onSurface,
      );

  /// "headline-lg-mobile" in the HTML — used for page titles (H1) on
  /// service-list / doctor-list.
  static TextStyle get headlineLgMobile => TextStyle(
        fontSize: 28,
        height: 36 / 28,
        fontWeight: FontWeight.w700,
        color: AppColors.onSurface,
      );

  static TextStyle get headlineMd => TextStyle(
        fontSize: 24,
        height: 32 / 24,
        fontWeight: FontWeight.w600,
        color: AppColors.onSurface,
      );

  static TextStyle get headlineSm => TextStyle(
        fontSize: 20,
        height: 28 / 20,
        fontWeight: FontWeight.w600,
        color: AppColors.onSurface,
      );

  static TextStyle get bodyLg => TextStyle(
        fontSize: 18,
        height: 28 / 18,
        fontWeight: FontWeight.w400,
        color: AppColors.onSurface,
      );

  static TextStyle get bodyMd => TextStyle(
        fontSize: 16,
        height: 24 / 16,
        fontWeight: FontWeight.w400,
        color: AppColors.onSurface,
      );

  static TextStyle get bodySm => TextStyle(
        fontSize: 14,
        height: 20 / 14,
        fontWeight: FontWeight.w400,
        color: AppColors.onSurfaceVariant,
      );

  static TextStyle get labelMd => TextStyle(
        fontSize: 12,
        height: 16 / 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.05 * 12,
        color: AppColors.onSurfaceVariant,
      );
}
