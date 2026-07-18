import 'package:flutter/material.dart';
import '../../core/models/dashboard_item.dart';
import '../../core/models/dashboard_stats.dart';
import '../../core/services/admin_api_service.dart';
import '../../core/services/auth_service.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/dashboard_tile.dart';
import '../../widgets/dashboard_insight_carousel.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/revenue_chart.dart';
import '../login/admin_login_screen.dart';
import '../add_dentist/add_dentist_screen.dart';
import '../appointments/appointments_screen.dart';
import '../patients/patients_screen.dart';
import '../treatments/treatments_screen.dart';
import '../payments/payments_screen.dart';
import '../inventory/inventory_screen.dart';
import '../settings/settings_screen.dart';
import '../dentists/dentists_screen.dart';
import '../revenue/revenue_screen.dart';
import '../scan/qr_scan_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _headerController;
  late final Animation<double> _headerFade;

  late final List<DashboardItem> _items;
  Future<DashboardStats>? _statsFuture;

  @override
  void initState() {
    super.initState();
    _headerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _headerFade = CurvedAnimation(
      parent: _headerController,
      curve: Curves.easeOut,
    );
    _headerController.forward();
    _statsFuture = AdminApiService.instance.getStats();

    _items = [
      DashboardItem(
        label: 'Appointments',
        icon: Icons.calendar_month_rounded,
        color: AppColors.primary,
        screenBuilder: () => const AppointmentsScreen(),
      ),
      DashboardItem(
        label: 'Patients',
        icon: Icons.groups_rounded,
        color: AppColors.secondary,
        screenBuilder: () => const PatientsScreen(),
      ),
      DashboardItem(
        label: 'Treatments',
        icon: Icons.medical_services_rounded,
        color: AppColors.tertiary,
        screenBuilder: () => const TreatmentsScreen(),
      ),
      DashboardItem(
        label: 'Payments',
        icon: Icons.payments_rounded,
        color: AppColors.primaryContainer,
        screenBuilder: () => const PaymentsScreen(),
      ),
      DashboardItem(
        label: 'Inventory',
        icon: Icons.inventory_2_rounded,
        color: AppColors.secondary,
        screenBuilder: () => const InventoryScreen(),
      ),
      DashboardItem(
        label: 'Add Dentist',
        icon: Icons.person_add_alt_1_rounded,
        color: AppColors.primary,
        screenBuilder: () => const AddDentistScreen(),
      ),
      DashboardItem(
        label: 'Settings',
        icon: Icons.settings_rounded,
        color: AppColors.onSurfaceVariant,
        screenBuilder: () => const SettingsScreen(),
      ),
      DashboardItem(
        label: 'Dentists',
        icon: Icons.badge_rounded,
        color: AppColors.tertiary,
        screenBuilder: () => const DentistsScreen(),
      ),
      DashboardItem(
        label: 'Revenue',
        icon: Icons.show_chart_rounded,
        color: AppColors.secondaryContainer,
        screenBuilder: () => const RevenueScreen(),
      ),
    ];
  }

  @override
  void dispose() {
    _headerController.dispose();
    super.dispose();
  }

  void _openScreen(DashboardItem item) {
    _pushAnimated(item.screenBuilder());
  }

  void _pushAnimated(Widget screen) {
    Navigator.of(context)
        .push(
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 350),
            pageBuilder: (_, animation, __) => screen,
            transitionsBuilder: (_, animation, __, child) {
              final curved = CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              );
              return FadeTransition(
                opacity: curved,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.06),
                    end: Offset.zero,
                  ).animate(curved),
                  child: child,
                ),
              );
            },
          ),
        )
        .then((_) => _refreshStats());
  }

  void _refreshStats() {
    setState(() => _statsFuture = AdminApiService.instance.getStats());
  }

  Future<void> _openScanner(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => const QrScanScreen(),
      ),
    );
    _refreshStats();
  }

  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Log out?'),
        content: const Text(
          'You will need to sign in again to access the admin panel.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Log out',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await AuthService.instance.logout();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const AdminLoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final adminName =
        AuthService.instance.currentUser?['name'] as String? ?? 'Admin';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async {
            final future = AdminApiService.instance.getStats();
            setState(() => _statsFuture = future);
            await future;
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Header ---
                FadeTransition(
                  opacity: _headerFade,
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 26,
                        backgroundColor: AppColors.secondaryContainer,
                        child: Icon(
                          Icons.person_rounded,
                          color: AppColors.primary,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome back',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            Text(
                              adminName,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => _openScanner(context),
                        icon: const Icon(
                          Icons.qr_code_scanner_rounded,
                          color: AppColors.primary,
                        ),
                        tooltip: 'Scan patient QR to check in',
                      ),
                      IconButton(
                        onPressed: _confirmLogout,
                        icon: const Icon(
                          Icons.logout_rounded,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // --- Today's income (moved above the stat cards; tap to open full Revenue screen) ---
                FadeTransition(
                  opacity: _headerFade,
                  child: FutureBuilder<DashboardStats>(
                    future: _statsFuture,
                    builder: (context, snapshot) {
                      final stats = snapshot.data;
                      final loading =
                          snapshot.connectionState == ConnectionState.waiting;
                      return _TodayIncomeCard(
                        loading: loading,
                        revenue: stats?.todayRevenue,
                        onTap: () => _pushAnimated(const RevenueScreen()),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // --- Stat cards row ---
                FadeTransition(
                  opacity: _headerFade,
                  child: FutureBuilder<DashboardStats>(
                    future: _statsFuture,
                    builder: (context, snapshot) {
                      final stats = snapshot.data;
                      final loading =
                          snapshot.connectionState == ConnectionState.waiting;
                      return Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              label: "Today's Appointments",
                              value: loading
                                  ? '…'
                                  : '${stats?.todaysAppointments ?? 0}',
                              icon: Icons.event_available_rounded,
                              color: AppColors.secondary,
                              onTap: () =>
                                  _pushAnimated(const AppointmentsScreen()),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _StatCard(
                              label: 'Total Patients',
                              value: loading
                                  ? '…'
                                  : '${stats?.totalPatients ?? 0}',
                              icon: Icons.group_add_rounded,
                              color: AppColors.primary,
                              onTap: () =>
                                  _pushAnimated(const PatientsScreen()),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                FadeTransition(
                  opacity: _headerFade,
                  child: FutureBuilder<DashboardStats>(
                    future: _statsFuture,
                    builder: (context, snapshot) {
                      final stats = snapshot.data;
                      final loading =
                          snapshot.connectionState == ConnectionState.waiting;
                      return Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              label: 'Pending Appointments',
                              value: loading
                                  ? '…'
                                  : '${stats?.pendingAppointments ?? 0}',
                              icon: Icons.hourglass_top_rounded,
                              color: AppColors.tertiary,
                              onTap: () =>
                                  _pushAnimated(const AppointmentsScreen()),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _StatCard(
                              label: 'Active Dentists',
                              value: loading
                                  ? '…'
                                  : '${stats?.activeDoctors ?? 0}',
                              icon: Icons.badge_rounded,
                              color: AppColors.primaryContainer,
                              onTap: () =>
                                  _pushAnimated(const DentistsScreen()),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 28),

                Text(
                  'Quick Actions',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  'Everything you need to run the clinic, one tap away.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 20),

                // --- Icon grid (replaces the website's sidebar) ---
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _items.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 8,
                    childAspectRatio: 0.8,
                  ),
                  itemBuilder: (context, index) {
                    final item = _items[index];
                    return DashboardTile(
                      item: item,
                      index: index,
                      onTap: () => _openScreen(item),
                    );
                  },
                ),

                const SizedBox(height: 32),
                FadeTransition(
                  opacity: _headerFade,
                  child: FutureBuilder<DashboardStats>(
                    future: _statsFuture,
                    builder: (context, snapshot) {
                      final stats = snapshot.data;
                      if (stats == null) return const SizedBox.shrink();
                      return DashboardInsightCarousel(stats: stats);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TodayIncomeCard extends StatefulWidget {
  final bool loading;
  final TodayRevenue? revenue;
  final VoidCallback onTap;

  const _TodayIncomeCard({
    required this.loading,
    required this.revenue,
    required this.onTap,
  });

  @override
  State<_TodayIncomeCard> createState() => _TodayIncomeCardState();
}

class _TodayIncomeCardState extends State<_TodayIncomeCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final revenue = widget.revenue;
    final hasData =
        !widget.loading && revenue != null && revenue.values.any((v) => v > 0);

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: GlassCard(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.payments_rounded,
                      color: AppColors.secondary,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Today's Income",
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          widget.loading
                              ? '…'
                              : '₹${(revenue?.total ?? 0).toStringAsFixed(0)}',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.outline,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 70,
                width: double.infinity,
                child: widget.loading
                    ? const Center(
                        child: SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : hasData
                    ? RevenueChart(
                        values: revenue.values,
                        labels: revenue.labels,
                        color: AppColors.secondary,
                      )
                    : const Center(
                        child: Text(
                          'No income recorded yet today.',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatefulWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  State<_StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<_StatCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onTap == null
          ? null
          : (_) => setState(() => _pressed = true),
      onTapUp: widget.onTap == null
          ? null
          : (_) => setState(() => _pressed = false),
      onTapCancel: widget.onTap == null
          ? null
          : () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: GlassCard(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            // --- Fixed height to keep grids aligned perfectly ---
            height: 104,
            width: double
                .infinity, // Allows parent Expanded grid constraint to dictate width
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment
                  .spaceBetween, // Distributes components top-to-bottom evenly
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: widget.color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(widget.icon, color: widget.color, size: 20),
                    ),
                    if (widget.onTap != null)
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.outline,
                        size: 18,
                      ),
                  ],
                ),
                // --- Group labels together so they anchor nicely ---
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.label,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        height: 1.2, // Avoids extra baseline spacing gaps
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.value,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
