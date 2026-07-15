import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// No mockup provided yet — placeholder shell with an empty state.
/// This is separate from the Bookings tab in the bottom nav; feel
/// free to merge them later if they end up meaning the same thing.
class MyAppointmentsScreen extends StatelessWidget {
  const MyAppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('My Appointments')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.calendar_month_outlined, size: 48, color: AppColors.outline),
              const SizedBox(height: 12),
              Text('No appointments yet', style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant)),
              const SizedBox(height: 4),
              Text(
                'Book a service or doctor visit to see it here.',
                style: AppTextStyles.bodySm,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
