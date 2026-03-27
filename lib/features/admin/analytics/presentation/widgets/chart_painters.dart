import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:style_cart/app/theme/app_colors.dart';
import 'package:style_cart/features/admin/analytics/domain/models/analytics_models.dart';

// ══════════════════════════════════════════════════════
// LINE CHART PAINTER
// Smooth bezier curve, gold gradient fill
// Supports multiple series (solid + dashed)
// ══════════════════════════════════════════════════════

class LineChartPainter extends CustomPainter {
  final List<TimeSeriesPoint> points;
  final Color lineColor;
  final bool showDots;
  final bool showGradient;
  final double animationValue; // 0.0 to 1.0

  const LineChartPainter({
    required this.points,
    this.lineColor = AppColors.gold,
    this.showDots = true,
    this.showGradient = true,
    this.animationValue = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final maxValue = points.map((p) => p.value).reduce((a, b) => a > b ? a : b);
    if (maxValue == 0) return;

    // Add 10% padding to max for visual breathing room
    final chartMax = maxValue * 1.1;
    final chartArea = Rect.fromLTWH(
      0,
      0,
      size.width,
      size.height,
    );

    // Compute pixel positions for each point
    Offset toPixel(TimeSeriesPoint p) {
      final x = chartArea.left + (points.indexOf(p) / (points.length - 1)) * chartArea.width;
      final y = chartArea.bottom - (p.value / chartMax) * chartArea.height;
      return Offset(x, y);
    }

    // Animate by limiting visible points
    final visibleCount = (points.length * animationValue).ceil().clamp(1, points.length);
    final visiblePoints = points.sublist(0, visibleCount);

    final pixelPoints = visiblePoints.map(toPixel).toList();

    // ── Draw gradient fill area ──────────────────────
    if (showGradient && pixelPoints.length > 1) {
      final fillPath = Path()
        ..moveTo(pixelPoints.first.dx, size.height)
        ..lineTo(pixelPoints.first.dx, pixelPoints.first.dy);

      for (int i = 0; i < pixelPoints.length - 1; i++) {
        final cp1 = Offset(
          (pixelPoints[i].dx + pixelPoints[i + 1].dx) / 2,
          pixelPoints[i].dy,
        );
        final cp2 = Offset(
          (pixelPoints[i].dx + pixelPoints[i + 1].dx) / 2,
          pixelPoints[i + 1].dy,
        );
        fillPath.cubicTo(
          cp1.dx,
          cp1.dy,
          cp2.dx,
          cp2.dy,
          pixelPoints[i + 1].dx,
          pixelPoints[i + 1].dy,
        );
      }

      fillPath
        ..lineTo(pixelPoints.last.dx, size.height)
        ..close();

      canvas.drawPath(
        fillPath,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              lineColor.withOpacity(0.35),
              lineColor.withOpacity(0.0),
            ],
          ).createShader(chartArea),
      );
    }

    // ── Draw smooth bezier line ───────────────────────
    if (pixelPoints.length > 1) {
      final linePath = Path()..moveTo(pixelPoints.first.dx, pixelPoints.first.dy);

      for (int i = 0; i < pixelPoints.length - 1; i++) {
        final cp1 = Offset(
          (pixelPoints[i].dx + pixelPoints[i + 1].dx) / 2,
          pixelPoints[i].dy,
        );
        final cp2 = Offset(
          (pixelPoints[i].dx + pixelPoints[i + 1].dx) / 2,
          pixelPoints[i + 1].dy,
        );
        linePath.cubicTo(
          cp1.dx,
          cp1.dy,
          cp2.dx,
          cp2.dy,
          pixelPoints[i + 1].dx,
          pixelPoints[i + 1].dy,
        );
      }

      canvas.drawPath(
        linePath,
        Paint()
          ..color = lineColor
          ..strokeWidth = 2.5
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round,
      );
    }

    // ── Draw data point dots ──────────────────────────
    if (showDots) {
      for (final pt in pixelPoints) {
        // Outer white circle
        canvas.drawCircle(pt, 5, Paint()..color = Colors.white);
        // Inner colored circle
        canvas.drawCircle(pt, 3.5, Paint()..color = lineColor);
        // Center dark dot
        canvas.drawCircle(pt, 1.5, Paint()..color = Colors.black);
      }
    }

    // ── Draw horizontal grid lines ────────────────────
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.04)
      ..strokeWidth = 1;

    for (int i = 1; i <= 4; i++) {
      final y = size.height - (i / 4) * size.height;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        gridPaint,
      );
    }
  }

  @override
  bool shouldRepaint(LineChartPainter old) => old.animationValue != animationValue || old.points != points;
}

// ══════════════════════════════════════════════════════
// BAR CHART PAINTER
// Animated bars, rounded tops, value labels
// ══════════════════════════════════════════════════════

class BarChartPainter extends CustomPainter {
  final List<TimeSeriesPoint> points;
  final Color barColor;
  final Color highlightColor; // today's bar
  final double animationValue;
  final int? highlightIndex; // which bar to highlight

  const BarChartPainter({
    required this.points,
    this.barColor = AppColors.gold,
    this.highlightColor = AppColors.primary,
    this.animationValue = 1.0,
    this.highlightIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final maxValue = points.map((p) => p.value).fold(0.0, (a, b) => b > a ? b : a);
    if (maxValue == 0) return;

    final barCount = points.length;
    const spacing = 8.0;
    final totalSpace = spacing * (barCount - 1);
    final barWidth = (size.width - totalSpace) / barCount;

    for (int i = 0; i < barCount; i++) {
      final pt = points[i];
      final normalizedHeight = (pt.value / maxValue) * size.height * animationValue * 0.85;

      final x = i * (barWidth + spacing);
      final y = size.height - normalizedHeight;

      final isHighlight = i == highlightIndex;
      final color = isHighlight ? highlightColor : barColor.withOpacity(0.75);

      // Draw rounded rectangle bar
      final rect = RRect.fromRectAndCorners(
        Rect.fromLTWH(x, y, barWidth, normalizedHeight),
        topLeft: const Radius.circular(6),
        topRight: const Radius.circular(6),
      );
      canvas.drawRRect(rect, Paint()..color = color);

      // Value label on top of bar (only for tall enough bars)
      if (normalizedHeight > 30 && pt.value > 0) {
        final label = pt.value >= 1000 ? '\$${(pt.value / 1000).toStringAsFixed(1)}k' : '\$${pt.value.toStringAsFixed(0)}';

        final textPainter = TextPainter(
          text: TextSpan(
            text: label,
            style: TextStyle(
              fontSize: 9,
              color: Colors.white.withOpacity(0.7),
              fontWeight: FontWeight.bold,
            ),
          ),
          textDirection: ui.TextDirection.ltr,
        )..layout();

        if (textPainter.width < barWidth) {
          textPainter.paint(
            canvas,
            Offset(
              x + barWidth / 2 - textPainter.width / 2,
              y - 14,
            ),
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(BarChartPainter old) => old.animationValue != animationValue || old.points != points;
}

// ══════════════════════════════════════════════════════
// DONUT CHART PAINTER (enhanced from Phase 8)
// Animated draw, hover-style selected segment
// ══════════════════════════════════════════════════════

class DonutChartPainter extends CustomPainter {
  final Map<String, double> data;
  final List<Color> colors;
  final int? selectedIndex;
  final double animationValue;
  final String centerLabel;
  final String centerValue;

  const DonutChartPainter({
    required this.data,
    required this.colors,
    this.selectedIndex,
    this.animationValue = 1.0,
    this.centerLabel = 'TOTAL',
    this.centerValue = '',
  });

  @override
  void paint(Canvas canvas, Size size) {
    final total = data.values.fold(0.0, (a, b) => a + b);
    if (total == 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = size.shortestSide / 2 - 10;
    const strokeWidth = 32.0;

    double startAngle = -pi / 2; // top

    data.entries.toList().asMap().forEach((idx, entry) {
      final fraction = entry.value / total;
      // Animate: progressively draw each segment
      final visibleFraction = (animationValue * data.length - idx).clamp(0.0, fraction.clamp(0.0, 1.0));
      final sweepAngle = visibleFraction * 2 * pi - 0.05;

      if (sweepAngle <= 0) {
        startAngle += fraction * 2 * pi;
        return;
      }

      final isSelected = idx == selectedIndex;
      final segmentRadius = isSelected ? outerRadius + 8 : outerRadius;

      canvas.drawArc(
        Rect.fromCircle(
          center: center,
          radius: segmentRadius,
        ),
        startAngle,
        sweepAngle,
        false,
        Paint()
          ..color = colors[idx % colors.length].withOpacity(isSelected ? 1.0 : 0.8)
          ..strokeWidth = isSelected ? strokeWidth + 4 : strokeWidth
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.butt,
      );
      startAngle += fraction * 2 * pi;
    });

    // ── Center text ───────────────────────────────────
    final valuePainter = TextPainter(
      text: TextSpan(
        children: [
          TextSpan(
            text: '$centerValue\n',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextSpan(
            text: centerLabel,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 11,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
      textAlign: TextAlign.center,
      textDirection: ui.TextDirection.ltr,
    )..layout();

    valuePainter.paint(
      canvas,
      Offset(
        center.dx - valuePainter.width / 2,
        center.dy - valuePainter.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(DonutChartPainter old) => old.animationValue != animationValue || old.selectedIndex != selectedIndex || old.data != data;
}

// ══════════════════════════════════════════════════════
// GAUGE CHART PAINTER (for rates like sell-through %)
// ══════════════════════════════════════════════════════

class GaugeChartPainter extends CustomPainter {
  final double value; // 0 to 100
  final Color trackColor;
  final Color valueColor;
  final double animationValue;

  const GaugeChartPainter({
    required this.value,
    this.trackColor = const Color(0xFF1F1010),
    this.valueColor = AppColors.gold,
    this.animationValue = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.75);
    final radius = size.shortestSide * 0.45;
    const startAngle = pi; // left (180°)
    const totalAngle = pi; // semicircle (180°)
    const strokeWidth = 16.0;

    // Track (background arc)
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      totalAngle,
      false,
      Paint()
        ..color = trackColor
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    // Value arc
    final sweepAngle = (value / 100 * totalAngle * animationValue).clamp(0.0, totalAngle);

    if (sweepAngle > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        Paint()
          ..shader = const SweepGradient(
            startAngle: startAngle,
            endAngle: startAngle + totalAngle,
            colors: [
              AppColors.error,
              AppColors.warning,
              AppColors.success,
            ],
            stops: [0.0, 0.5, 1.0],
          ).createShader(Rect.fromCircle(
            center: center,
            radius: radius,
          ))
          ..strokeWidth = strokeWidth
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round,
      );
    }

    // Needle
    final needleAngle = startAngle + sweepAngle;
    final needleEnd = Offset(
      center.dx + (radius - 10) * cos(needleAngle),
      center.dy + (radius - 10) * sin(needleAngle),
    );
    canvas.drawLine(
      center,
      needleEnd,
      Paint()
        ..color = Colors.white
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(
      center,
      5,
      Paint()..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(GaugeChartPainter old) => old.animationValue != animationValue || old.value != value;
}

// ══════════════════════════════════════════════════════
// ANIMATED CHART WRAPPER
// Wraps any CustomPainter with a reveal animation
// ══════════════════════════════════════════════════════

class AnimatedChart extends StatefulWidget {
  final CustomPainter Function(double animValue) painterBuilder;
  final double width;
  final double height;
  final Duration duration;

  const AnimatedChart({
    required this.painterBuilder,
    required this.width,
    required this.height,
    this.duration = const Duration(milliseconds: 900),
    super.key,
  });

  @override
  State<AnimatedChart> createState() => _AnimatedChartState();
}

class _AnimatedChartState extends State<AnimatedChart> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Restart animation on data change if needed
    // However, painter usually handles smooth transitions if animation is already at 1.0
    // But for a full reveal, we might want to reset.
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _animation,
        builder: (context, _) => CustomPaint(
          size: Size(widget.width, widget.height),
          painter: widget.painterBuilder(_animation.value),
        ),
      );
}
