import 'package:flutter/material.dart';
import '../../core/models/revenue_report.dart';
import '../../core/services/admin_api_service.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/admin_page_scaffold.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/revenue_chart.dart';
import '../../widgets/staggered_fade_in.dart';

class RevenueScreen extends StatefulWidget {
  const RevenueScreen({super.key});

  @override
  State<RevenueScreen> createState() => _RevenueScreenState();
}

class _RevenueScreenState extends State<RevenueScreen> {
  static const _periods = ['Day', 'Week', 'Month'];
  String _selectedPeriod = 'Week';
  late Future<RevenueReport> _future;

  @override
  void initState() {
    super.initState();
    _future = AdminApiService.instance.getRevenue(period: _selectedPeriod.toLowerCase());
  }

  void _selectPeriod(String period) {
    setState(() {
      _selectedPeriod = period;
      _future = AdminApiService.instance.getRevenue(period: period.toLowerCase());
    });
  }

  Future<void> _refresh() async {
    final future = AdminApiService.instance.getRevenue(period: _selectedPeriod.toLowerCase());
    setState(() => _future = future);
    await future;
  }

  @override
  Widget build(BuildContext context) {
    return AdminPageScaffold(
      title: 'Revenue',
      subtitle: 'Detailed breakdown & trends',
      child: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: _refresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Period toggle ---
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(color: AppColors.surfaceContainerLow, borderRadius: BorderRadius.circular(14)),
                child: Row(
                  children: _periods.map((p) {
                    final selected = _selectedPeriod == p;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => _selectPeriod(p),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: selected ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(11),
                            boxShadow: selected
                                ? [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 6, offset: const Offset(0, 2))]
                                : null,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            p,
                            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: selected ? AppColors.primary : AppColors.onSurfaceVariant),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),

              FutureBuilder<RevenueReport>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 60),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (snapshot.hasError) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Column(
                        children: [
                          const Icon(Icons.cloud_off_rounded, color: AppColors.outline, size: 40),
                          const SizedBox(height: 12),
                          Text('Could not load revenue', style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 6),
                          Text('${snapshot.error}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
                          const SizedBox(height: 16),
                          OutlinedButton.icon(onPressed: _refresh, icon: const Icon(Icons.refresh_rounded), label: const Text('Retry')),
                        ],
                      ),
                    );
                  }

                  final report = snapshot.data!;
                  final isUp = report.percentChange >= 0;
                  final maxServiceAmount = report.topServices.isEmpty
                      ? 1.0
                      : report.topServices.map((t) => t.amount.toDouble()).reduce((a, b) => a > b ? a : b);

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                                      Text('\$${report.total.toStringAsFixed(0)}', style: Theme.of(context).textTheme.headlineMedium),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: (isUp ? AppColors.secondaryContainer : AppColors.errorContainer).withValues(alpha: 0.5),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(isUp ? Icons.trending_up_rounded : Icons.trending_down_rounded, size: 15, color: isUp ? AppColors.secondary : AppColors.error),
                                      const SizedBox(width: 3),
                                      Text(
                                        '${report.percentChange.abs().toStringAsFixed(1)}%',
                                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: isUp ? AppColors.onSecondaryContainer : AppColors.error),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            report.values.isEmpty || report.values.every((v) => v == 0)
                                ? const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 24),
                                    child: Center(child: Text('No paid revenue yet for this period.', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12))),
                                  )
                                : RevenueChart(
                                    key: ValueKey(_selectedPeriod),
                                    values: report.values,
                                    labels: report.labels,
                                    color: AppColors.primary,
                                  ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // --- Quick stats row ---
                      Row(
                        children: [
                          Expanded(child: _miniStat('Average', '\$${report.average.toStringAsFixed(0)}')),
                          const SizedBox(width: 10),
                          Expanded(child: _miniStat('Best: ${report.maxLabel}', '\$${report.maxValue.toStringAsFixed(0)}')),
                        ],
                      ),
                      if (report.outstandingBalance > 0) ...[
                        const SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.tertiaryFixed.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.receipt_long_rounded, color: AppColors.primary, size: 20),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Outstanding Balance', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700)),
                                    Text(
                                      'From consultation-fee-only bookings, due at visit.',
                                      style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                '\$${report.outstandingBalance.toStringAsFixed(0)}',
                                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.primary),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),

                      // --- Payment method breakdown ---
                      Text('Payment Methods', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 12),
                      report.paymentMethods.isEmpty
                          ? const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Text('No paid transactions in this period.', style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
                            )
                          : GlassCard(
                              child: Column(
                                children: List.generate(report.paymentMethods.length, (i) {
                                  final m = report.paymentMethods[i];
                                  final colors = [AppColors.primary, AppColors.secondary, AppColors.tertiary, AppColors.onSurfaceVariant];
                                  final color = colors[i % colors.length];
                                  return Padding(
                                    padding: EdgeInsets.only(bottom: i == report.paymentMethods.length - 1 ? 0 : 14),
                                    child: StaggeredFadeIn(
                                      index: i,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(m.method, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                                              Text('${(m.percent * 100).toStringAsFixed(0)}%', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                                            ],
                                          ),
                                          const SizedBox(height: 6),
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(999),
                                            child: TweenAnimationBuilder<double>(
                                              tween: Tween(begin: 0, end: m.percent),
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

                      // --- Top services by revenue ---
                      Text('Top Treatments by Revenue', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 12),
                      report.topServices.isEmpty
                          ? const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Text('No paid transactions in this period.', style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
                            )
                          : GlassCard(
                              child: Column(
                                children: List.generate(report.topServices.length, (i) {
                                  final s = report.topServices[i];
                                  final pct = s.amount / maxServiceAmount;
                                  return Padding(
                                    padding: EdgeInsets.only(bottom: i == report.topServices.length - 1 ? 0 : 14),
                                    child: StaggeredFadeIn(
                                      index: i,
                                      child: Row(
                                        children: [
                                          SizedBox(
                                            width: 110,
                                            child: Text(s.name, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis),
                                          ),
                                          Expanded(
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(999),
                                              child: TweenAnimationBuilder<double>(
                                                tween: Tween(begin: 0, end: pct.toDouble()),
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
                                          Text('\$${s.amount.toStringAsFixed(0)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            ),
                      const SizedBox(height: 24),

                      // --- Per-doctor, per-treatment breakdown ---
                      Text('Revenue by Treatment & Dentist', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 4),
                      const Text(
                        'Which service, done by which dentist, earned how much.',
                        style: TextStyle(fontSize: 11.5, color: AppColors.onSurfaceVariant),
                      ),
                      const SizedBox(height: 12),
                      report.breakdown.isEmpty
                          ? const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Text('No paid transactions in this period.', style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
                            )
                          : GlassCard(
                              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                              child: Column(
                                children: List.generate(report.breakdown.length, (i) {
                                  final b = report.breakdown[i];
                                  return StaggeredFadeIn(
                                    index: i,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                      decoration: i == report.breakdown.length - 1
                                          ? null
                                          : const BoxDecoration(
                                              border: Border(bottom: BorderSide(color: AppColors.outlineVariant, width: 0.6)),
                                            ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 34,
                                            height: 34,
                                            decoration: BoxDecoration(
                                              color: AppColors.primary.withValues(alpha: 0.1),
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: const Icon(Icons.medical_services_rounded, color: AppColors.primary, size: 16),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  b.serviceName,
                                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                Text(
                                                  '${b.doctorName} · ${b.visits} visit${b.visits == 1 ? '' : 's'}',
                                                  style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text('\$${b.amount}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5, color: AppColors.primary)),
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            ),
                    ],
                  );
                },
              ),
            ],
          ),
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
