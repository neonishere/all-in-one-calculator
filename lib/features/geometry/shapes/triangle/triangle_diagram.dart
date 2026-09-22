import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

/// The big equilateral-triangle diagram shown atop the triangle tool, with
/// side letters (A left, C right, B bottom) drawn just outside the shape.
class TriangleDiagram extends StatelessWidget {
  const TriangleDiagram({super.key, this.size = 170});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size * 0.95,
      child: CustomPaint(
        painter: _TriangleDiagramPainter(
          lineColor: AppColors.textSecondary,
          labelColor: AppColors.textPrimary,
        ),
      ),
    );
  }
}

class _TriangleDiagramPainter extends CustomPainter {
  _TriangleDiagramPainter({required this.lineColor, required this.labelColor});

  final Color lineColor;
  final Color labelColor;

  static const _labelMargin = 24.0;
  static const _labelDistance = 16.0;

  @override
  void paint(Canvas canvas, Size size) {
    final availableW = size.width - _labelMargin * 2;
    final availableH = size.height - _labelMargin * 2;
    final maxTriH = availableW * math.sqrt(3) / 2;
    final s = maxTriH > availableH ? availableH * 2 / math.sqrt(3) : availableW;
    final triH = s * math.sqrt(3) / 2;

    final top = Offset(size.width / 2, (size.height - triH) / 2);
    final left = Offset(top.dx - s / 2, top.dy + triH);
    final right = Offset(top.dx + s / 2, top.dy + triH);
    final centroid = Offset((top.dx + left.dx + right.dx) / 3, (top.dy + left.dy + right.dy) / 3);

    final strokeWidth = math.max(1.4, s * 0.016);
    final paint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path()
      ..moveTo(top.dx, top.dy)
      ..lineTo(right.dx, right.dy)
      ..lineTo(left.dx, left.dy)
      ..close();
    canvas.drawPath(path, paint);

    // Filled wedge at each vertex, in the same color as the outline — the
    // same "filled-in corner" treatment as the angle mini icons.
    final cornerPaint = Paint()..color = lineColor;
    final cornerRadius = s * 0.1;
    _drawCornerWedge(canvas, top, left, right, cornerPaint, cornerRadius);
    _drawCornerWedge(canvas, left, top, right, cornerPaint, cornerRadius);
    _drawCornerWedge(canvas, right, top, left, cornerPaint, cornerRadius);

    _drawLabel(canvas, 'A', _outwardPoint(top, left, centroid), labelColor);
    _drawLabel(canvas, 'C', _outwardPoint(top, right, centroid), labelColor);
    _drawLabel(canvas, 'B', _outwardPoint(left, right, centroid), labelColor);
  }

  Offset _outwardPoint(Offset p1, Offset p2, Offset centroid) {
    final mid = Offset((p1.dx + p2.dx) / 2, (p1.dy + p2.dy) / 2);
    final edge = p2 - p1;
    var normal = Offset(-edge.dy, edge.dx);
    final toCentroid = centroid - mid;
    if (normal.dx * toCentroid.dx + normal.dy * toCentroid.dy > 0) {
      normal = Offset(-normal.dx, -normal.dy);
    }
    final len = normal.distance;
    if (len == 0) return mid;
    final unit = Offset(normal.dx / len, normal.dy / len);
    return mid + unit * _labelDistance;
  }

  void _drawCornerWedge(Canvas canvas, Offset center, Offset a, Offset b, Paint paint, double radius) {
    final startAngle = math.atan2(a.dy - center.dy, a.dx - center.dx);
    final rawEnd = math.atan2(b.dy - center.dy, b.dx - center.dx);
    var sweep = rawEnd - startAngle;
    if (sweep <= -math.pi) sweep += 2 * math.pi;
    if (sweep > math.pi) sweep -= 2 * math.pi;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), startAngle, sweep, true, paint);
  }

  void _drawLabel(Canvas canvas, String text, Offset center, Color color) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w400)),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(canvas, center - Offset(painter.width / 2, painter.height / 2));
  }

  @override
  bool shouldRepaint(covariant _TriangleDiagramPainter oldDelegate) =>
      oldDelegate.lineColor != lineColor || oldDelegate.labelColor != labelColor;
}
