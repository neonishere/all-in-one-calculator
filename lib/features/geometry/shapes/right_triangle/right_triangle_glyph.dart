import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

/// Sides/vertices of the reference right triangle used by
/// [RightTriangleGlyph] and the main diagram: A = left (vertical) leg,
/// B = bottom (horizontal) leg, hyp = hypotenuse. The right angle always
/// sits at the bottom-left vertex.
enum RtSide { a, b, hyp }

enum RtVertex { t, br }

/// A small right-triangle icon used next to right-triangle inputs and
/// results, mirroring [TriangleGlyph]'s conventions.
class RightTriangleGlyph extends StatelessWidget {
  const RightTriangleGlyph({
    super.key,
    this.size = 32,
    this.filled = false,
    this.highlightSide,
    this.allAccent = false,
    this.angleVertex,
  });

  final double size;
  final bool filled;
  final RtSide? highlightSide;
  final bool allAccent;
  final RtVertex? angleVertex;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RightTriangleGlyphPainter(
          filled: filled,
          highlightSide: highlightSide,
          allAccent: allAccent,
          angleVertex: angleVertex,
          accent: AppColors.accent,
          dim: AppColors.accent.withValues(alpha: 0.32),
        ),
      ),
    );
  }
}

class _RightTriangleGlyphPainter extends CustomPainter {
  _RightTriangleGlyphPainter({
    required this.filled,
    required this.highlightSide,
    required this.allAccent,
    required this.angleVertex,
    required this.accent,
    required this.dim,
  });

  final bool filled;
  final RtSide? highlightSide;
  final bool allAccent;
  final RtVertex? angleVertex;
  final Color accent;
  final Color dim;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final refSide = math.min(w, h * 2 / math.sqrt(3)) * 0.8;
    final vertLeg = refSide * math.sqrt(3) / 2;
    final horizLeg = w * 0.8;
    final left = (w - horizLeg) / 2;
    final top = (h - vertLeg) / 2;

    final t = Offset(left, top);
    final bl = Offset(left, top + vertLeg);
    final br = Offset(left + horizLeg, top + vertLeg);

    final strokeWidth = math.max(1.3, w * 0.06);

    if (filled) {
      canvas.drawPath(_path(t, bl, br), Paint()..color = dim);
    }

    Color colorFor(RtSide side) {
      if (allAccent) return accent;
      if (highlightSide == side) return accent;
      return dim;
    }

    void drawSide(Offset p1, Offset p2, Color color) {
      canvas.drawLine(
        p1,
        p2,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );
    }

    drawSide(t, bl, colorFor(RtSide.a));
    drawSide(bl, br, colorFor(RtSide.b));
    drawSide(t, br, colorFor(RtSide.hyp));

    // Small right-angle marker at the A/B corner, for shape identity.
    final markSize = strokeWidth * 2.4;
    canvas.drawRect(
      Rect.fromLTWH(bl.dx, bl.dy - markSize, markSize, markSize),
      Paint()
        ..color = dim
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth * 0.7,
    );

    if (angleVertex != null) _drawAngleWedge(canvas, t, bl, br, angleVertex!, refSide);
  }

  Path _path(Offset t, Offset bl, Offset br) => Path()
    ..moveTo(t.dx, t.dy)
    ..lineTo(br.dx, br.dy)
    ..lineTo(bl.dx, bl.dy)
    ..close();

  void _drawAngleWedge(Canvas canvas, Offset t, Offset bl, Offset br, RtVertex vertex, double refSide) {
    late Offset center, a, b;
    switch (vertex) {
      case RtVertex.t:
        center = t;
        a = bl;
        b = br;
      case RtVertex.br:
        center = br;
        a = bl;
        b = t;
    }
    final startAngle = math.atan2(a.dy - center.dy, a.dx - center.dx);
    final rawEnd = math.atan2(b.dy - center.dy, b.dx - center.dx);
    var sweep = rawEnd - startAngle;
    if (sweep <= -math.pi) sweep += 2 * math.pi;
    if (sweep > math.pi) sweep -= 2 * math.pi;
    final rect = Rect.fromCircle(center: center, radius: refSide * 0.3);
    canvas.drawArc(rect, startAngle, sweep, true, Paint()..color = accent);
  }

  @override
  bool shouldRepaint(covariant _RightTriangleGlyphPainter oldDelegate) =>
      oldDelegate.filled != filled ||
      oldDelegate.highlightSide != highlightSide ||
      oldDelegate.allAccent != allAccent ||
      oldDelegate.angleVertex != angleVertex;
}
