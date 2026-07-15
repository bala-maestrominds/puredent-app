import 'package:flutter/material.dart';
import '../../core/models/dashboard_item.dart';
import '../../core/services/auth_service.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/dashboard_tile.dart';
import '../../widgets/dashboard_insight_carousel.dart';
import '../../widgets/glass_card.dart';
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

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _headerController;
  late final Animation<double> _headerFade;

  late final List<DashboardItem> _items;

  @override
  void initState() {
    super.initState();
    _headerController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _headerFade = CurvedAnimation(parent: _headerController, curve: Curves.easeOut);
    _headerController.forward();

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
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 350),
        pageBuilder: (_, animation, __) => screen,
        transitionsBuilder: (_, animation, __, child) {
          final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
          return FadeTransition(
            opacity: curved,
            child: SlideTransition(
              position: Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero).animate(curved),
              child: child,
            ),
          );
        },
      ),
    );
  }

  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Log out?'),
        content: const Text('You will need to sign in again to access the admin panel.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Log out', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      AuthService.instance.logout();
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const AdminLoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async {
            await Future.delayed(const Duration(milliseconds: 800));
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
                        child: Icon(Icons.person_rounded, color: AppColors.primary, size: 28),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Welcome back', style: Theme.of(context).textTheme.bodyMedium),
                            Text('Dr. Sarah Jenkins', style: Theme.of(context).textTheme.titleMedium),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.notifications_none_rounded, color: AppColors.primary),
                      ),
                      IconButton(
                        onPressed: _confirmLogout,
                        icon: const Icon(Icons.logout_rounded, color: AppColors.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // --- Stat cards row ---
                FadeTransition(
                  opacity: _headerFade,
                  child: Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          label: "Today's Revenue",
                          value: '\$4,250',
                          icon: Icons.trending_up_rounded,
                          color: AppColors.secondary,
                          onTap: () => _pushAnimated(const RevenueScreen()),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          label: 'New Patients',
                          value: '142',
                          icon: Icons.group_add_rounded,
                          color: AppColors.primary,
                          onTap: () => _pushAnimated(const PatientsScreen()),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                Text('Quick Actions', style: Theme.of(context).textTheme.headlineSmall),
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
                  child: const DashboardInsightCarousel(),
                ),
              ],
            ),
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

  const _StatCard({required this.label, required this.value, required this.icon, required this.color, this.onTap});

  @override
  State<_StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<_StatCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onTap == null ? null : (_) => setState(() => _pressed = true),
      onTapUp: widget.onTap == null ? null : (_) => setState(() => _pressed = false),
      onTapCancel: widget.onTap == null ? null : () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: GlassCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: widget.color.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
                    child: Icon(widget.icon, color: widget.color, size: 20),
                  ),
                  if (widget.onTap != null)
                    const Icon(Icons.chevron_right_rounded, color: AppColors.outline, size: 18),
                ],
              ),
              const SizedBox(height: 10),
              Text(widget.label, style: Theme.of(context).textTheme.labelMedium),
              const SizedBox(height: 2),
              Text(widget.value, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 20)),
            ],
          ),
        ),
      ),
    );
  }
}