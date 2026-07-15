import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';
import '../models/service_model.dart';
import '../widgets/service_card.dart';
import 'service_detail_screen.dart';

/// Converted from service-list.html
class ServicesListScreen extends StatefulWidget {
  const ServicesListScreen({super.key});

  @override
  State<ServicesListScreen> createState() => _ServicesListScreenState();
}

class _ServicesListScreenState extends State<ServicesListScreen> {
  static const _filters = ['All Services', 'Preventive', 'Restorative', 'Cosmetic', 'Orthodontics'];
  String _activeFilter = 'All Services';

  List<ServiceModel> get _filtered => _activeFilter == 'All Services'
      ? demoServices
      : demoServices.where((s) => s.category == _activeFilter).toList();

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
            Text('PureDent', style: AppTextStyles.headlineLgMobile.copyWith(fontSize: 20, color: AppColors.primary)),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.notifications_outlined), onPressed: () {}),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.marginMobile,
          AppSpacing.md,
          AppSpacing.marginMobile,
          AppSpacing.xxl,
        ),
        children: [
          Text('Our Services', style: AppTextStyles.headlineLgMobile.copyWith(color: AppColors.primary)),
          const SizedBox(height: 4),
          Text('Comprehensive care for your dental health', style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant)),
          const SizedBox(height: AppSpacing.lg),
          TextField(
            decoration: InputDecoration(
              hintText: 'Search for a service or treatment',
              prefixIcon: const Icon(Icons.search, color: AppColors.outline),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _filters.length,
              separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
              itemBuilder: (context, i) {
                final label = _filters[i];
                final selected = label == _activeFilter;
                return ChoiceChip(
                  label: Text(label),
                  selected: selected,
                  onSelected: (_) => setState(() => _activeFilter = label),
                  selectedColor: AppColors.primary,
                  backgroundColor: AppColors.surfaceContainerHigh,
                  labelStyle: AppTextStyles.labelMd.copyWith(
                    color: selected ? AppColors.onPrimary : AppColors.onSurfaceVariant,
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.full)),
                  side: BorderSide.none,
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          for (final service in _filtered) ...[
            ServiceCard(
              service: service,
              onViewDetails: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => ServiceDetailScreen(service: service)),
              ),
              onBookNow: () {
                // TODO: wire up booking flow
              },
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ],
      ),
    );
  }
}
