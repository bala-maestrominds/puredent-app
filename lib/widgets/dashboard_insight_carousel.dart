import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import 'glass_card.dart';

class _Insight {
  final IconData icon;
  final String title;
  final String message;

  const _Insight({required this.icon, required this.title, required this.message});
}

const _insights = [
  _Insight(
    icon: Icons.trending_up_rounded,
    title: "You're on track",
    message: 'Revenue is up 15% compared to last week. Keep it up!',
  ),
  _Insight(
    icon: Icons.event_available_rounded,
    title: '3 appointments today',
    message: 'Your next patient, Jonathan Smith, arrives at 9:30 AM.',
  ),
  _Insight(
    icon: Icons.inventory_2_rounded,
    title: 'Inventory check',
    message: 'Surgical masks are running low — consider restocking soon.',
  ),
  _Insight(
    icon: Icons.star_rounded,
    title: 'Great reviews',
    message: 'Your clinic rating is 4.9 — patients love the care here.',
  ),
];

/// Fills otherwise-empty dashboard space with continuous, gentle motion:
/// a card that auto-rotates through short insights (fade + slide every few
/// seconds) and a small icon that floats up and down beside it in a loop.
class DashboardInsightCarousel extends StatefulWidget {
  const DashboardInsightCarousel({super.key});

  @override
  State<DashboardInsightCarousel> createState() => _DashboardInsightCarouselState();
}

class _DashboardInsightCarouselState extends State<DashboardInsightCarousel>
    with TickerProviderStateMixin {
  int _index = 0;

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
    final insight = _insights[_index];

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
                color: AppColors.secondaryContainer.withOpacity(0.4),
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