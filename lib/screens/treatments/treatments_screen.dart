import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/admin_page_scaffold.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/staggered_fade_in.dart';

class _Treatment {
  final String name;
  final String category;
  final String duration;
  final int price;
  final IconData icon;

  const _Treatment({required this.name, required this.category, required this.duration, required this.price, required this.icon});
}

const _treatments = [
  _Treatment(name: 'Teeth Cleaning', category: 'General', duration: '30 min', price: 80, icon: Icons.clean_hands_rounded),
  _Treatment(name: 'Cavity Filling', category: 'General', duration: '45 min', price: 150, icon: Icons.medical_services_rounded),
  _Treatment(name: 'Root Canal Therapy', category: 'Endodontics', duration: '90 min', price: 900, icon: Icons.healing_rounded),
  _Treatment(name: 'Dental Implants', category: 'Oral Surgery', duration: '120 min', price: 2200, icon: Icons.medical_information_rounded),
  _Treatment(name: 'Teeth Whitening', category: 'Cosmetic', duration: '60 min', price: 350, icon: Icons.auto_awesome_rounded),
  _Treatment(name: 'Orthodontic Braces', category: 'Orthodontics', duration: '45 min', price: 3800, icon: Icons.health_and_safety_rounded),
  _Treatment(name: 'Gum Treatment', category: 'Periodontics', duration: '60 min', price: 400, icon: Icons.spa_rounded),
  _Treatment(name: 'Routine Checkup', category: 'General', duration: '20 min', price: 60, icon: Icons.search_rounded),
];

class TreatmentsScreen extends StatefulWidget {
  const TreatmentsScreen({super.key});

  @override
  State<TreatmentsScreen> createState() => _TreatmentsScreenState();
}

class _TreatmentsScreenState extends State<TreatmentsScreen> {
  String _category = 'All';
  late final List<String> _categories;

  @override
  void initState() {
    super.initState();
    _categories = ['All', ..._treatments.map((t) => t.category).toSet()];
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _category == 'All' ? _treatments : _treatments.where((t) => t.category == _category).toList();

    return AdminPageScaffold(
      title: 'Treatments',
      subtitle: '${_treatments.length} services offered',
      action: IconButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Hook this up to open an "Add Treatment" form.')),
          );
        },
        icon: const Icon(Icons.add_circle_rounded, color: AppColors.primary, size: 28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _categories.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final c = _categories[index];
                final selected = _category == c;
                return GestureDetector(
                  onTap: () => setState(() => _category = c),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: selected ? AppColors.primary : AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      c,
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: selected ? Colors.white : AppColors.onSurfaceVariant),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              itemCount: filtered.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 0.85,
              ),
              itemBuilder: (context, index) {
                final t = filtered[index];
                return StaggeredFadeIn(
                  index: index,
                  child: GlassCard(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                          child: Icon(t.icon, color: AppColors.primary, size: 22),
                        ),
                        const Spacer(),
                        Text(t.name, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 14)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.schedule_rounded, size: 13, color: AppColors.onSurfaceVariant),
                            const SizedBox(width: 4),
                            Text(t.duration, style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('\$${t.price}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: AppColors.primary)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}