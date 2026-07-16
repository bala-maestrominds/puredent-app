import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Typography scale mirroring `DESIGN.md` (headline-* uses Plus Jakarta Sans,
/// body/label uses Inter).
class AppTypography {
  AppTypography._();

  static TextStyle _jakarta({
    required double size,
    required FontWeight weight,
    required double height,
    double letterSpacing = 0,
    Color color = AppColors.onSurface,
  }) =>
      GoogleFonts.plusJakartaSans(
        fontSize: size,
        fontWeight: weight,
        height: height / size,
        letterSpacing: letterSpacing,
        color: color,
      );

  static TextStyle _inter({
    required double size,
    required FontWeight weight,
    required double height,
    double letterSpacing = 0,
    Color color = AppColors.onSurface,
  }) =>
      GoogleFonts.inter(
        fontSize: size,
        fontWeight: weight,
        height: height / size,
        letterSpacing: letterSpacing,
        color: color,
      );

  static TextStyle headlineXl({Color? color}) => _jakarta(
      size: 40, weight: FontWeight.w700, height: 48, letterSpacing: -0.8, color: color ?? AppColors.onSurface);
  static TextStyle headlineLg({Color? color}) => _jakarta(
      size: 28, weight: FontWeight.w700, height: 36, letterSpacing: -0.56, color: color ?? AppColors.onSurface);
  static TextStyle headlineMd({Color? color}) =>
      _jakarta(size: 22, weight: FontWeight.w600, height: 28, color: color ?? AppColors.onSurface);
  static TextStyle headlineSm({Color? color}) =>
      _jakarta(size: 18, weight: FontWeight.w600, height: 24, color: color ?? AppColors.onSurface);

  static TextStyle bodyLg({Color? color}) =>
      _inter(size: 17, weight: FontWeight.w400, height: 26, color: color ?? AppColors.onSurfaceVariant);
  static TextStyle bodyMd({Color? color}) =>
      _inter(size: 15, weight: FontWeight.w400, height: 22, color: color ?? AppColors.onSurfaceVariant);
  static TextStyle bodySm({Color? color}) =>
      _inter(size: 13, weight: FontWeight.w400, height: 18, color: color ?? AppColors.onSurfaceVariant);

  static TextStyle labelMd({Color? color}) => _inter(
      size: 12, weight: FontWeight.w600, height: 16, letterSpacing: 0.6, color: color ?? AppColors.onSurfaceVariant);

  static TextStyle button({Color? color}) =>
      _inter(size: 15, weight: FontWeight.w600, height: 20, color: color ?? AppColors.onPrimary);
}
