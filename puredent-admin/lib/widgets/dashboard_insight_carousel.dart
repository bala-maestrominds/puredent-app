import 'package:flutter/material.dart';
import '../core/models/dashboard_stats.dart';
import '../core/theme/app_colors.dart';
import 'glass_card.dart';

class _Insight {
  final IconData icon;
  final String title;
  final String message;

  const _Insight({required this.icon, required this.title, required this.message});
}

/// Builds a rotation of real, backend-derived insights out of the dashboard
/// stats -- replaces what used to be a handful of hardcoded strings.
List<_Insight> _buildInsights(DashboardStats stats) {
  final insights = <_Insight>[];

  if (stats.nextAppointment != null) {
    final a = stats.nextAppointment!;
    insights.add(_Insight(
      icon: Icons.event_available_rounded,
      title: 'Up next today',
      message: '${a.patientName} with ${a.doctorName} at ${a.time} for ${a.serviceName}.',
    ));
  } else if (stats.todaysAppointments > 0) {
    insights.add(_Insight(
      icon: Icons.event_available_rounded,
      title: '${stats.todaysAppointments} appointment${stats.todaysAppointments == 1 ? '' : 's'} today',
      message: 'All of today\'s scheduled visits are already underway or done.',
    ));
  } else {
    insights.add(const _Insight(
      icon: Icons.event_busy_rounded,
      title: 'No appointments today',
      message: 'The schedule is clear for today so far.',
    ));
  }

  if (stats.todayRevenue.total > 0) {
    insights.add(_Insight(
      icon: Icons.trending_up_rounded,
      title: "Today's earnings",
      message: '\$${stats.todayRevenue.total.toStringAsFixed(0)} collected so far today. Tap the income card to see the full breakdown.',
    ));
  }

  if (stats.pendingAppointments > 0) {
    insights.add(_Insight(
      icon: Icons.hourglass_top_rounded,
      title: '${stats.pendingAppointments} appointment${stats.pendingAppointments == 1 ? '' : 's'} pending',
      message: 'These are waiting on confirmation or check-in.',
    ));
  }

  insights.add(_Insight(
    icon: Icons.groups_rounded,
    title: '${stats.totalPatients} patients on record',
    message: '${stats.activeDoctors} active dentist${stats.activeDoctors == 1 ? '' : 's'} currently seeing patients.',
  ));

  if (stats.completedAppointments > 0) {
    insights.add(_Insight(
      icon: Icons.task_alt_rounded,
      title: '${stats.completedAppointments} completed visits',
      message: 'Out of ${stats.totalAppointments} appointments booked in total.',
    ));
  }

  return insights;
}

/// Fills otherwise-empty dashboard space with continuous, gentle motion:
/// a card that auto-rotates through short, real insights (fade + slide every
/// few seconds) and a small icon that floats up and down beside it in a loop.
class DashboardInsightCarousel extends StatefulWidget {
  final DashboardStats stats;

  const DashboardInsightCarousel({super.key, required this.stats});

  @override
  State<DashboardInsightCarousel> createState() => _DashboardInsightCarouselState();
}

class _DashboardInsightCarouselState extends State<DashboardInsightCarousel>
    with TickerProviderStateMixin {
  int _index = 0;
  late List<_Insight> _insights;

  // Controls the fade/slide swap between insights.
  late final AnimationController _swapController;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  // Controls the continuous up/down float of the icon -- this is the part
  // that's always moving, even while the text isn't changing.
  late final AnimationController _floatController;
  late final Animation<double> _floatOffset;

  @override
  void initState() {
    super.initState();
    _insights = _buildInsights(widget.stats);

    _swapController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _fade = CurvedAnimation(parent: _swapController, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero)
        .animate(CurvedAnimation(parent: _swapController, curve: Curves.easeOutCubic));
    _swapController.forward();

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _floatOffset = Tween<double>(begin: -6, end: 6).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    _scheduleNext();
  }

  @override
  void didUpdateWidget(covariant DashboardInsightCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.stats != widget.stats) {
      _insights = _buildInsights(widget.stats);
      if (_index >= _insights.length) _index = 0;
    }
  }

  void _scheduleNext() {
    Future.delayed(const Duration(seconds: 5), () async {
      if (!mounted) return;
      await _swapController.reverse();
      if (!mounted) return;
      setState(() => _index = (_index + 1) % _insights.length);
      await _swapController.forward();
      _scheduleNext();
    });
  }

  @override
  void dispose() {
    _swapController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_insights.isEmpty) return const SizedBox.shrink();
    final insight = _insights[_index % _insights.length];

    return GlassCard(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          // Continuously floating icon -- never stops moving.
          AnimatedBuilder(
            animation: _floatOffset,
            builder: (context, child) => Transform.translate(
              offset: Offset(0, _floatOffset.value),
              child: child,
            ),
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.secondaryContainer.withValues(alpha: 0.4),
                shape: BoxShape.circle,
              ),
              child: Icon(insight.icon, color: AppColors.primary, size: 24),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ClipRect(
              child: FadeTransition(
                opacity: _fade,
                child: SlideTransition(
                  position: _slide,
                  child: Column(
                    key: ValueKey(_index),
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        insight.title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 14),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        insight.message,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12.5),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Dots indicating position in the rotation.
          Column(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(_insights.length, (i) {
              final active = i == _index;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(vertical: 2),
                width: 6,
                height: active ? 16 : 6,
                decoration: BoxDecoration(
                  color: active ? AppColors.primary : AppColors.outlineVariant,
                  borderRadius: BorderRadius.circular(999),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
