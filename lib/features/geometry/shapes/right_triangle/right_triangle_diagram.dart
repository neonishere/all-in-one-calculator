import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

/// The big right-triangle diagram shown atop the right-triangle tool: a
/// short vertical leg (A, left) and a longer horizontal leg (B, bottom),
/// with side letters drawn just outside the shape. The two non-right
/// corners get a filled wedge like [TriangleDiagram]; the right-angle
/// corner (between A and B) gets a filled square instead.
class RightTriangleDiagram extends StatelessWidget {
  const RightTriangleDiagram({super.key, this.size = 170});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size * 0.95,
      child: CustomPaint(
        painter: _RightTriangleDiagramPainter(
          lineColor: AppColors.textSecondary,
          labelColor: AppColors.textPrimary,
        ),
      ),
    );
  }
}

class _RightTriangleDiagramPainter extends CustomPainter {
  _RightTriangleDiagramPainter({required this.lineColor, required this.labelColor});

  final Color lineColor;
  final Color labelColor;

  static const _labelMargin = 24.0;
  static const _labelDistance = 14.0;

  @override
  void paint(Canvas canvas, Size size) {
    final availableW = size.width - _labelMargin * 2;
    final availableH = size.height - _labelMargin * 2;
    final horizLeg = availableW;
    final vertLeg = math.min(availableH, horizLeg * 0.62);

    final left = (size.width - horizLeg) / 2;
    final top = (size.height - vertLeg) / 2;

    final t = Offset(left, top);
    final bl = Offset(left, top + vertLeg);
    final br = Offset(left + horizLeg, top + vertLeg);

    final strokeWidth = math.max(1.4, horizLeg * 0.014);
    final paint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path()
      ..moveTo(t.dx, t.dy)
      ..lineTo(br.dx, br.dy)
      ..lineTo(bl.dx, bl.dy)
      ..close();
    canvas.drawPath(path, paint);

    // Filled wedges at the two non-right corners, same color as the
    // outline — matching TriangleDiagram's "filled-in corner" look.
    final cornerPaint = Paint()..color = lineColor;
    final cornerRadius = horizLeg * 0.09;
    _drawCornerWedge(canvas, t, bl, br, cornerPaint, cornerRadius);
    _drawCornerWedge(canvas, br, t, bl, cornerPaint, cornerRadius);

    // The right-angle corner (A/B) gets a filled square instead of a wedge.
    final squareSide = cornerRadius * 0.85;
    canvas.drawRect(Rect.fromLTWH(bl.dx, bl.dy - squareSide, squareSide, squareSide), cornerPaint);

    _drawLabel(canvas, 'A', Offset(t.dx - _labelDistance - _labelMargin * 0.25, (t.dy + bl.dy) / 2), labelColor);
    _drawLabel(canvas, 'B', Offset((bl.dx + br.dx) / 2, bl.dy + _labelDistance + 6), labelColor);
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
  bool shouldRepaint(covariant _RightTriangleDiagramPainter oldDelegate) =>
      oldDelegate.lineColor != lineColor || oldDelegate.labelColor != labelColor;
}
