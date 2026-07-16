import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

/// A single-series line chart with a gradient fill under the line.
/// No charting package required -- drawn by hand with CustomPainter.
///
/// Re-animates (draws itself in left-to-right) whenever `values` changes,
/// which is what makes switching between Day/Week/Year tabs feel alive.
class RevenueChart extends StatefulWidget {
  final List<double> values;
  final List<String> labels;
  final Color color;

  const RevenueChart({
    super.key,
    required this.values,
    required this.labels,
    this.color = AppColors.primary,
  });

  @override
  State<RevenueChart> createState() => _RevenueChartState();
}

class _RevenueChartState extends State<RevenueChart> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _reveal;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _reveal = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _controller.forward();
  }

  @override
  void didUpdateWidget(RevenueChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.values != widget.values) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: AnimatedBuilder(
        animation: _reveal,
        builder: (context, child) => CustomPaint(
          painter: _RevenueChartPainter(
            values: widget.values,
            labels: widget.labels,
            color: widget.color,
            progress: _reveal.value,
          ),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _RevenueChartPainter extends CustomPainter {
  final List<double> values;
  final List<String> labels;
  final Color color;
  final double progress;

  _RevenueChartPainter({
    required this.values,
    required this.labels,
    required this.color,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    const bottomReserved = 24.0; // space for x-axis labels
    final chartHeight = size.height - bottomReserved;
    final maxValue = values.reduce((a, b) => a > b ? a : b) * 1.2;
    final minValue = 0.0;

    // --- Grid lines ---
    final gridPaint = Paint()
      ..color = AppColors.outlineVariant.withOpacity(0.3)
      ..strokeWidth = 1;
    for (int i = 0; i <= 3; i++) {
      final y = chartHeight * (i / 3);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // --- Compute points ---
    final points = <Offset>[];
    for (int i = 0; i < values.length; i++) {
      final x = values.length == 1 ? 0.0 : size.width * (i / (values.length - 1));
      final normalized = (values[i] - minValue) / (maxValue - minValue);
      final y = chartHeight - (normalized * chartHeight);
      points.add(Offset(x, y));
    }

    // --- Smooth line path (quadratic bezier between midpoints) ---
    final linePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (int i = 0; i < points.length - 1; i++) {
      final mid = Offset(
        (points[i].dx + points[i + 1].dx) / 2,
        (points[i].dy + points[i + 1].dy) / 2,
      );
      linePath.quadraticBezierTo(points[i].dx, points[i].dy, mid.dx, mid.dy);
    }
    linePath.lineTo(points.last.dx, points.last.dy);

    // --- Clip to reveal progress (draws in left-to-right) ---
    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width * progress, size.height));

    // Gradient fill under the line
    final fillPath = Path.from(linePath)
      ..lineTo(points.last.dx, chartHeight)
      ..lineTo(points.first.dx, chartHeight)
      ..close();
    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [color.withOpacity(0.28), color.withOpacity(0.0)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, chartHeight));
    canvas.drawPath(fillPath, fillPaint);

    // The line itself
    final linePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(linePath, linePaint);

    // Data point dots
    final dotFill = Paint()..color = Colors.white;
    final dotStroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    for (final p in points) {
      canvas.drawCircle(p, 4, dotFill);
      canvas.drawCircle(p, 4, dotStroke);
    }

    canvas.restore();

    // --- X-axis labels (not clipped, always visible) ---
    for (int i = 0; i < labels.length; i++) {
      final tp = TextPainter(
        text: TextSpan(
          text: labels[i],
          style: const TextStyle(fontSize: 10.5, color: AppColors.onSurfaceVariant, fontWeight: FontWeight.w600),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      final x = points[i].dx - tp.width / 2;
      tp.paint(canvas, Offset(x.clamp(0, size.width - tp.width), size.height - bottomReserved + 6));
    }
  }

  @override
  bool shouldRepaint(covariant _RevenueChartPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.values != values;
  }
}