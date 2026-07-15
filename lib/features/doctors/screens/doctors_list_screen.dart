import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';
import '../models/doctor_model.dart';
import '../widgets/doctor_card.dart';
import 'doctor_detail_screen.dart';

/// Converted from doctor-list.html
class DoctorsListScreen extends StatefulWidget {
  const DoctorsListScreen({super.key});

  @override
  State<DoctorsListScreen> createState() => _DoctorsListScreenState();
}

class _DoctorsListScreenState extends State<DoctorsListScreen> {
  static const _categories = ['All Doctors', 'Orthodontics', 'Periodontics', 'Surgery'];
  String _active = 'All Doctors';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            const CircleAvatar(radius: 20, backgroundColor: AppColors.surfaceContainerHigh),
            const SizedBox(width: AppSpacing.sm),
            Text('PureDent', style: AppTextStyles.headlineSm.copyWith(color: AppColors.primary)),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.notifications_outlined), onPressed: () {}),
          IconButton(icon: const Icon(Icons.tune), onPressed: () {}),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(AppSpacing.marginMobile, AppSpacing.md, AppSpacing.marginMobile, AppSpacing.xxl),
        children: [
          Text('Our Specialists', style: AppTextStyles.headlineLgMobile),
          const SizedBox(height: 8),
          Text('Find the perfect expert for your dental health journey.', style: AppTextStyles.bodySm),
          const SizedBox(height: AppSpacing.lg),
          TextField(
            decoration: InputDecoration(
              hintText: 'Search by name or specialty',
              prefixIcon: const Icon(Icons.search, color: AppColors.outline),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
              itemBuilder: (context, i) {
                final label = _categories[i];
                final selected = label == _active;
                return ChoiceChip(
                  label: Text(label),
                  selected: selected,
                  onSelected: (_) => setState(() => _active = label),
                  selectedColor: AppColors.primary,
                  backgroundColor: Colors.white,
                  labelStyle: AppTextStyles.labelMd.copyWith(color: selected ? AppColors.onPrimary : AppColors.onSurfaceVariant),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.full),
                    side: selected ? BorderSide.none : const BorderSide(color: AppColors.surfaceVariant),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          for (final doctor in demoDoctors) ...[
            DoctorCard(
              doctor: doctor,
              onViewProfile: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => DoctorDetailScreen(doctor: doctor)),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        ],
      ),
    );
  }
}
