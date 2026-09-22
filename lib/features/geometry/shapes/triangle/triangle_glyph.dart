import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

/// Which side (of an equilateral reference triangle: A = left, B = bottom,
/// C = right) or vertex a [TriangleGlyph] annotation refers to.
enum TriSide { a, b, c }

enum TriVertex { t, l, r }

/// A small equilateral-triangle icon used next to triangle-tool inputs and
/// results, to show at a glance which side/angle/height it refers to.
class TriangleGlyph extends StatelessWidget {
  const TriangleGlyph({
    super.key,
    this.size = 32,
    this.filled = false,
    this.highlightSide,
    this.allAccent = false,
    this.angleVertex,
    this.heightSide,
  });

  final double size;

  /// Area icon: fills the whole triangle with the dim accent.
  final bool filled;

  /// Input icons: only this side is drawn in full accent, others dim.
  final TriSide? highlightSide;

  /// Perimeter icon: every side drawn in full accent.
  final bool allAccent;

  /// Angle icons: dim outline plus a filled wedge at this vertex.
  final TriVertex? angleVertex;

  /// Height icons: dim outline plus an accent line from the opposite
  /// vertex to the midpoint of this side.
  final TriSide? heightSide;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _TriangleGlyphPainter(
          filled: filled,
          highlightSide: highlightSide,
          allAccent: allAccent,
          angleVertex: angleVertex,
          heightSide: heightSide,
          accent: AppColors.accent,
          dim: AppColors.accent.withValues(alpha: 0.32),
        ),
      ),
    );
  }
}

class _TriangleGlyphPainter extends CustomPainter {
  _TriangleGlyphPainter({
    required this.filled,
    required this.highlightSide,
    required this.allAccent,
    required this.angleVertex,
    required this.heightSide,
    required this.accent,
    required this.dim,
  });

  final bool filled;
  final TriSide? highlightSide;
  final bool allAccent;
  final TriVertex? angleVertex;
  final TriSide? heightSide;
  final Color accent;
  final Color dim;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final pad = w * 0.14;
    final s = w - pad * 2;
    final triH = s * math.sqrt(3) / 2;
    final top = Offset(size.width / 2, (size.height - triH) / 2);
    final left = Offset(top.dx - s / 2, top.dy + triH);
    final right = Offset(top.dx + s / 2, top.dy + triH);

    final strokeWidth = math.max(1.3, w * 0.06);

    if (filled) {
      canvas.drawPath(_path(top, left, right), Paint()..color = dim);
    }

    Color colorFor(TriSide side) {
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

    drawSide(top, left, colorFor(TriSide.a));
    drawSide(left, right, colorFor(TriSide.b));
    drawSide(top, right, colorFor(TriSide.c));

    if (angleVertex != null) _drawAngleWedge(canvas, top, left, right, angleVertex!, s);
    if (heightSide != null) _drawHeight(canvas, top, left, right, heightSide!, strokeWidth);
  }

  Path _path(Offset top, Offset left, Offset right) => Path()
    ..moveTo(top.dx, top.dy)
    ..lineTo(right.dx, right.dy)
    ..lineTo(left.dx, left.dy)
    ..close();

  void _drawAngleWedge(Canvas canvas, Offset top, Offset left, Offset right, TriVertex vertex, double s) {
    late Offset center, a, b;
    switch (vertex) {
      case TriVertex.t:
        center = top;
        a = left;
        b = right;
      case TriVertex.l:
        center = left;
        a = top;
        b = right;
      case TriVertex.r:
        center = right;
        a = top;
        b = left;
    }
    final startAngle = math.atan2(a.dy - center.dy, a.dx - center.dx);
    final rawEnd = math.atan2(b.dy - center.dy, b.dx - center.dx);
    var sweep = rawEnd - startAngle;
    if (sweep <= -math.pi) sweep += 2 * math.pi;
    if (sweep > math.pi) sweep -= 2 * math.pi;
    final rect = Rect.fromCircle(center: center, radius: s * 0.3);
    canvas.drawArc(rect, startAngle, sweep, true, Paint()..color = accent);
  }

  void _drawHeight(Canvas canvas, Offset top, Offset left, Offset right, TriSide side, double strokeWidth) {
    late Offset apex, baseMid;
    switch (side) {
      case TriSide.a:
        apex = right;
        baseMid = Offset((top.dx + left.dx) / 2, (top.dy + left.dy) / 2);
      case TriSide.b:
        apex = top;
        baseMid = Offset((left.dx + right.dx) / 2, (left.dy + right.dy) / 2);
      case TriSide.c:
        apex = left;
        baseMid = Offset((top.dx + right.dx) / 2, (top.dy + right.dy) / 2);
    }
    canvas.drawLine(
      apex,
      baseMid,
      Paint()
        ..color = accent
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _TriangleGlyphPainter oldDelegate) =>
      oldDelegate.filled != filled ||
      oldDelegate.highlightSide != highlightSide ||
      oldDelegate.allAccent != allAccent ||
      oldDelegate.angleVertex != angleVertex ||
      oldDelegate.heightSide != heightSide;
}
