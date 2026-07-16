import 'package:flutter/material.dart';
import '../../core/models/payment.dart';
import '../../core/services/payments_service.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/admin_page_scaffold.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/staggered_fade_in.dart';

class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({super.key});

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  String _statusFilter = 'All';
  final _statusFilters = const ['All', 'Paid', 'Partially Paid', 'Pending', 'Overdue'];

  static const _statusColors = {
    'Paid': AppColors.secondaryContainer,
    'Partially Paid': AppColors.tertiaryFixed,
    'Pending': AppColors.surfaceContainerHigh,
    'Overdue': AppColors.errorContainer,
  };

  late Future<List<Payment>> _future;

  @override
  void initState() {
    super.initState();
    _future = PaymentsService.instance.list();
  }

  Future<void> _refresh() async {
    final future = PaymentsService.instance.list();
    setState(() => _future = future);
    await future;
  }

  @override
  Widget build(BuildContext context) {
    return AdminPageScaffold(
      title: 'Payments',
      subtitle: 'Invoices & transactions',
      child: FutureBuilder<List<Payment>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _ErrorState(message: '${snapshot.error}', onRetry: _refresh);
          }

          final payments = snapshot.data ?? const [];
          final filtered = _statusFilter == 'All' ? payments : payments.where((p) => p.status == _statusFilter).toList();

          final paidTotal = payments.fold<num>(0, (sum, p) => sum + p.amountPaid);
          final outstandingTotal = payments
              .where((p) => p.status != 'Paid')
              .fold<num>(0, (sum, p) => sum + p.balanceDue);
          final overdueTotal = payments.where((p) => p.status == 'Overdue').fold<num>(0, (sum, p) => sum + p.balanceDue);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(child: _TotalCard(label: 'Collected', value: paidTotal, color: AppColors.secondary)),
                    const SizedBox(width: 10),
                    Expanded(child: _TotalCard(label: 'Outstanding', value: outstandingTotal, color: AppColors.onSurfaceVariant)),
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
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
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
                child: filtered.isEmpty
                    ? Center(child: Text('No payments match this filter.', style: Theme.of(context).textTheme.bodyMedium))
                    : RefreshIndicator(
                        color: AppColors.primary,
                        onRefresh: _refresh,
                        child: ListView.separated(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final p = filtered[index];
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
                                              Text(p.appointmentCode, style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary, fontSize: 13)),
                                              const SizedBox(height: 2),
                                              Text(p.patientName, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 14)),
                                              Text('${p.serviceName} · ${p.method}', style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
                                            ],
                                          ),
                                        ),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            Text('\$${p.amountPaid}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                                            if (p.status != 'Paid')
                                              Text('of \$${p.amount}', style: const TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant)),
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
                                    if (p.paymentOption == 'Consultation Fee Only' && p.balanceDue > 0) ...[
                                      const Divider(height: 18, color: AppColors.outlineVariant),
                                      Row(
                                        children: [
                                          const Icon(Icons.receipt_long_rounded, size: 14, color: AppColors.tertiary),
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: Text(
                                              'Consultation fee only — \$${p.balanceDue} due at visit',
                                              style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded, color: AppColors.outline, size: 40),
            const SizedBox(height: 12),
            Text('Could not load payments', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12)),
            const SizedBox(height: 16),
            OutlinedButton.icon(onPressed: onRetry, icon: const Icon(Icons.refresh_rounded), label: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}

class _TotalCard extends StatelessWidget {
  final String label;
  final num value;
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
