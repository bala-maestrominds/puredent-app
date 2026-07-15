import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/admin_page_scaffold.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/staggered_fade_in.dart';

class _Payment {
  final String id;
  final String patient;
  final String treatment;
  final String date;
  final int amount;
  final String method;
  final String status;

  const _Payment({
    required this.id,
    required this.patient,
    required this.treatment,
    required this.date,
    required this.amount,
    required this.method,
    required this.status,
  });
}

const _payments = [
  _Payment(id: 'INV-3301', patient: 'Jonathan Smith', treatment: 'Root Canal Therapy', date: '2024-07-10', amount: 900, method: 'Card', status: 'Paid'),
  _Payment(id: 'INV-3300', patient: 'Alice Wonderland', treatment: 'Teeth Whitening', date: '2024-07-10', amount: 350, method: 'Insurance', status: 'Paid'),
  _Payment(id: 'INV-3299', patient: 'Robert Lewandowski', treatment: 'Routine Checkup', date: '2024-07-10', amount: 60, method: 'Cash', status: 'Pending'),
  _Payment(id: 'INV-3298', patient: 'Maria Gonzalez', treatment: 'Dental Implants', date: '2024-07-01', amount: 2200, method: 'Card', status: 'Paid'),
  _Payment(id: 'INV-3297', patient: 'David Okafor', treatment: 'Gum Treatment', date: '2024-06-28', amount: 400, method: 'Insurance', status: 'Overdue'),
];

class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({super.key});

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  String _statusFilter = 'All';
  final _statusFilters = const ['All', 'Paid', 'Pending', 'Overdue'];

  static const _statusColors = {
    'Paid': AppColors.secondaryContainer,
    'Pending': AppColors.surfaceContainerHigh,
    'Overdue': AppColors.errorContainer,
  };

  @override
  Widget build(BuildContext context) {
    final filtered = _statusFilter == 'All' ? _payments : _payments.where((p) => p.status == _statusFilter).toList();

    final paidTotal = _payments.where((p) => p.status == 'Paid').fold<int>(0, (sum, p) => sum + p.amount);
    final pendingTotal = _payments.where((p) => p.status == 'Pending').fold<int>(0, (sum, p) => sum + p.amount);
    final overdueTotal = _payments.where((p) => p.status == 'Overdue').fold<int>(0, (sum, p) => sum + p.amount);

    return AdminPageScaffold(
      title: 'Payments',
      subtitle: 'Invoices & transactions',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(child: _TotalCard(label: 'Collected', value: paidTotal, color: AppColors.secondary)),
                const SizedBox(width: 10),
                Expanded(child: _TotalCard(label: 'Pending', value: pendingTotal, color: AppColors.onSurfaceVariant)),
                const SizedBox(width: 10),
                Expanded(child: _TotalCard(label: 'Overdue', value: overdueTotal, color: AppColors.error)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _statusFilters.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final s = _statusFilters[index];
                final selected = _statusFilter == s;
                return GestureDetector(
                  onTap: () => setState(() => _statusFilter = s),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: selected ? AppColors.primary : AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(s, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: selected ? Colors.white : AppColors.onSurfaceVariant)),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              itemCount: filtered.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final p = filtered[index];
                return StaggeredFadeIn(
                  index: index,
                  child: GlassCard(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(p.id, style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary, fontSize: 13)),
                              const SizedBox(height: 2),
                              Text(p.patient, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 14)),
                              Text('${p.treatment} · ${p.method}', style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('\$${p.amount}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: (_statusColors[p.status] ?? AppColors.surfaceContainerHigh).withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(p.status, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700)),
                            ),
                          ],
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

class _TotalCard extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _TotalCard({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: value.toDouble()),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutCubic,
            builder: (context, animatedValue, child) => Text(
              '\$${animatedValue.toInt()}',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: color),
            ),
          ),
        ],
      ),
    );
  }
}