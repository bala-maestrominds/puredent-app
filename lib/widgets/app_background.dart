import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

/// Soft ambient background: base color + two blurred glow circles.
/// Mirrors the website's absolutely-positioned blurred gradient blobs.
class AppBackground extends StatelessWidget {
  final Widget child;

  const AppBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(child: Container(color: AppColors.background)),
        Positioned(
          top: -80,
          left: -80,
          child: _glowCircle(AppColors.secondary.withValues(alpha: 0.08), 260),
        ),
        Positioned(
          bottom: -100,
          right: -100,
          child: _glowCircle(AppColors.primary.withValues(alpha: 0.08), 300),
        ),
        child,
      ],
    );
  }

  Widget _glowCircle(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}