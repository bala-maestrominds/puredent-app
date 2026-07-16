import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/admin_page_scaffold.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/staggered_fade_in.dart';

class _InventoryItem {
  final String name;
  final String category;
  int stock;
  final int reorderAt;
  final String unit;

  _InventoryItem({required this.name, required this.category, required this.stock, required this.reorderAt, required this.unit});
}

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final _inventory = [
    _InventoryItem(name: 'Dental Composite Resin', category: 'Restorative', stock: 42, reorderAt: 20, unit: 'tubes'),
    _InventoryItem(name: 'Disposable Gloves (M)', category: 'Safety', stock: 8, reorderAt: 30, unit: 'boxes'),
    _InventoryItem(name: 'Local Anesthetic Cartridges', category: 'Pharmaceutical', stock: 65, reorderAt: 25, unit: 'units'),
    _InventoryItem(name: 'Sterilization Pouches', category: 'Sterilization', stock: 12, reorderAt: 15, unit: 'packs'),
    _InventoryItem(name: 'Surgical Masks', category: 'Safety', stock: 5, reorderAt: 25, unit: 'boxes'),
    _InventoryItem(name: 'X-Ray Film', category: 'Diagnostic', stock: 30, reorderAt: 15, unit: 'packs'),
  ];

  bool _showLowOnly = false;

  void _restock(_InventoryItem item) {
    setState(() => item.stock += item.reorderAt * 2);
  }

  @override
  Widget build(BuildContext context) {
    final lowStockCount = _inventory.where((i) => i.stock <= i.reorderAt).length;
    final visible = _showLowOnly ? _inventory.where((i) => i.stock <= i.reorderAt).toList() : _inventory;

    return AdminPageScaffold(
      title: 'Inventory',
      subtitle: '${_inventory.length} tracked items',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (lowStockCount > 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.errorContainer.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.error.withValues(alpha: 0.15)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '$lowStockCount item${lowStockCount > 1 ? 's are' : ' is'} at or below reorder level.',
                        style: const TextStyle(color: AppColors.error, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => setState(() => _showLowOnly = !_showLowOnly),
                      child: Text(
                        _showLowOnly ? 'Show all' : 'View low',
                        style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.w700, fontSize: 12, decoration: TextDecoration.underline),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              itemCount: visible.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = visible[index];
                final low = item.stock <= item.reorderAt;
                final pct = (item.stock / (item.reorderAt * 3)).clamp(0.0, 1.0);

                return StaggeredFadeIn(
                  index: index,
                  child: GlassCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.name, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 14)),
                                  Text(item.category, style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
                                ],
                              ),
                            ),
                            if (low)
                              ElevatedButton(
                                onPressed: () => _restock(item),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: const Text('Restock', style: TextStyle(fontSize: 12)),
                              )
                            else
                              const Text('In stock', style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0, end: pct),
                            duration: const Duration(milliseconds: 600),
                            curve: Curves.easeOutCubic,
                            builder: (context, value, child) => LinearProgressIndicator(
                              value: value,
                              minHeight: 8,
                              backgroundColor: AppColors.surfaceContainerHigh,
                              valueColor: AlwaysStoppedAnimation(low ? AppColors.error : AppColors.secondary),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${item.stock} ${item.unit} in stock · reorder at ${item.reorderAt}',
                          style: TextStyle(fontSize: 11, color: low ? AppColors.error : AppColors.onSurfaceVariant, fontWeight: FontWeight.w600),
                        ),
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