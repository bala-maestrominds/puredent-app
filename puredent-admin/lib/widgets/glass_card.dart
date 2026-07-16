import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

/// Matches the website's `.glass-card` CSS: translucent white, soft shadow,
/// subtle border. Used everywhere a "card" appears across the app.
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.borderRadius = 24,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.05)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}