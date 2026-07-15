import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/admin_page_scaffold.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/revenue_chart.dart';
import '../../widgets/staggered_fade_in.dart';

class _RevenuePeriod {
  final List<double> values;
  final List<String> labels;
  final double previousTotal;

  const _RevenuePeriod({required this.values, required this.labels, required this.previousTotal});

  double get total => values.fold(0, (sum, v) => sum + v);
  double get average => total / values.length;
  double get max => values.reduce((a, b) => a > b ? a : b);
  String get maxLabel => labels[values.indexOf(max)];
  double get percentChange => previousTotal == 0 ? 0 : ((total - previousTotal) / previousTotal) * 100;
}

const _periods = {
  'Day': _RevenuePeriod(
    values: [120, 340, 610, 450, 780, 590, 260],
    labels: ['9AM', '10AM', '11AM', '12PM', '2PM', '4PM', '6PM'],
    previousTotal: 2900,
  ),
  'Week': _RevenuePeriod(
    values: [1200, 1800, 900, 2200, 1400, 1100, 1700],
    labels: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
    previousTotal: 8600,
  ),
  'Year': _RevenuePeriod(
    values: [32000, 35000, 41000, 38000, 44000, 47000, 43000, 49000, 46000, 52000, 55000, 58000],
    labels: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'],
    previousTotal: 460000,
  ),
};

const _paymentMethods = [
  ('Card', 0.58, AppColors.primary),
  ('Insurance', 0.28, AppColors.secondary),
  ('Cash', 0.14, AppColors.tertiary),
];

const _topTreatments = [
  ('Dental Implants', 2200.0),
  ('Root Canal Therapy', 900.0),
  ('Orthodontic Braces', 3800.0),
  ('Teeth Whitening', 350.0),
];

class RevenueScreen extends StatefulWidget {
  const RevenueScreen({super.key});

  @override
  State<RevenueScreen> createState() => _RevenueScreenState();
}

class _RevenueScreenState extends State<RevenueScreen> {
  String _selectedPeriod = 'Week';

  @override
  Widget build(BuildContext context) {
    final period = _periods[_selectedPeriod]!;
    final isUp = period.percentChange >= 0;
    final maxTreatment = _topTreatments.map((t) => t.$2).reduce((a, b) => a > b ? a : b);

    return AdminPageScaffold(
      title: 'Revenue',
      subtitle: 'Detailed breakdown & trends',
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Period toggle ---
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(color: AppColors.surfaceContainerLow, borderRadius: BorderRadius.circular(14)),
              child: Row(
                children: _periods.keys.map((p) {
                  final selected = _selectedPeriod == p;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedPeriod = p),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: selected ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(11),
                          boxShadow: selected
                              ? [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 6, offset: const Offset(0, 2))]
                              : null,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          p,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: selected ? AppColors.primary : AppColors.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),

            // --- Chart card ---
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Total Revenue', style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 2),
                            Text(
                              '\$${period.total.toStringAsFixed(0)}',
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: (isUp ? AppColors.secondaryContainer : AppColors.errorContainer).withOpacity(0.5),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isUp ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                              size: 15,
                              color: isUp ? AppColors.secondary : AppColors.error,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              '${period.percentChange.abs().toStringAsFixed(1)}%',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: isUp ? AppColors.onSecondaryContainer : AppColors.error,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  RevenueChart(
                    key: ValueKey(_selectedPeriod),
                    values: period.values,
                    labels: period.labels,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // --- Quick stats row ---
            Row(
              children: [
                Expanded(child: _miniStat('Average', '\$${period.average.toStringAsFixed(0)}')),
                const SizedBox(width: 10),
                Expanded(child: _miniStat('Best: ${period.maxLabel}', '\$${period.max.toStringAsFixed(0)}')),
              ],
            ),
            const SizedBox(height: 24),

            // --- Payment method breakdown ---
            Text('Payment Methods', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            GlassCard(
              child: Column(
                children: List.generate(_paymentMethods.length, (i) {
                  final (label, pct, color) = _paymentMethods[i];
                  return Padding(
                    padding: EdgeInsets.only(bottom: i == _paymentMethods.length - 1 ? 0 : 14),
                    child: StaggeredFadeIn(
                      index: i,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                              Text('${(pct * 100).toStringAsFixed(0)}%', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(999),
                            child: TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0, end: pct),
                              duration: const Duration(milliseconds: 700),
                              curve: Curves.easeOutCubic,
                              builder: (context, value, child) => LinearProgressIndicator(
                                value: value,
                                minHeight: 8,
                                backgroundColor: AppColors.surfaceContainerHigh,
                                valueColor: AlwaysStoppedAnimation(color),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 24),

            // --- Top treatments by revenue ---
            Text('Top Treatments by Revenue', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            GlassCard(
              child: Column(
                children: List.generate(_topTreatments.length, (i) {
                  final (name, amount) = _topTreatments[i];
                  final pct = amount / maxTreatment;
                  return Padding(
                    padding: EdgeInsets.only(bottom: i == _topTreatments.length - 1 ? 0 : 14),
                    child: StaggeredFadeIn(
                      index: i,
                      child: Row(
                        children: [
                          SizedBox(
                            width: 110,
                            child: Text(name, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis),
                          ),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(999),
                              child: TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0, end: pct),
                                duration: const Duration(milliseconds: 700),
                                curve: Curves.easeOutCubic,
                                builder: (context, value, child) => LinearProgressIndicator(
                                  value: value,
                                  minHeight: 8,
                                  backgroundColor: AppColors.surfaceContainerHigh,
                                  valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text('\$${amount.toStringAsFixed(0)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _miniStat(String label, String value) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 10.5, color: AppColors.onSurfaceVariant, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.primary)),
        ],
      ),
    );
  }
}