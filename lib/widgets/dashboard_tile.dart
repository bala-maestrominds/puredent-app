import 'package:flutter/material.dart';
import '../core/models/dashboard_item.dart';

/// A single tappable icon tile in the dashboard grid.
///
/// Two animations layer on top of each other:
/// 1. Entrance: fades + slides up when the dashboard first appears, with a
///    small delay per tile (`index`) so they cascade in one after another
///    instead of all popping in at once.
/// 2. Press feedback: scales down slightly on tap for a tactile "bounce".
class DashboardTile extends StatefulWidget {
  final DashboardItem item;
  final int index;
  final VoidCallback onTap;

  const DashboardTile({
    super.key,
    required this.item,
    required this.index,
    required this.onTap,
  });

  @override
  State<DashboardTile> createState() => _DashboardTileState();
}

class _DashboardTileState extends State<DashboardTile> with SingleTickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _fade = CurvedAnimation(parent: _entranceController, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.25), end: Offset.zero)
        .animate(CurvedAnimation(parent: _entranceController, curve: Curves.easeOutCubic));

    // Stagger: each tile waits a little longer than the one before it.
    Future.delayed(Duration(milliseconds: 60 * widget.index), () {
      if (mounted) _entranceController.forward();
    });
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: GestureDetector(
          onTapDown: (_) => setState(() => _pressed = true),
          onTapUp: (_) => setState(() => _pressed = false),
          onTapCancel: () => setState(() => _pressed = false),
          onTap: widget.onTap,
          child: AnimatedScale(
            scale: _pressed ? 0.92 : 1.0,
            duration: const Duration(milliseconds: 120),
            curve: Curves.easeOut,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: widget.item.color.withOpacity(_pressed ? 0.25 : 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(widget.item.icon, color: widget.item.color, size: 28),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.item.label,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurface,
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