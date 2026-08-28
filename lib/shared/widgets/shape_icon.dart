import 'dart:math' as math;

import 'package:flutter/material.dart';

enum ShapeKind { triangle, rightTriangle, square, rectangle, trapezoid, rhombus, pentagon, hexagon, circle, circleArc, ellipse }

extension ShapeKindLabel on ShapeKind {
  String get label => switch (this) {
        ShapeKind.triangle => 'Triangle',
        ShapeKind.rightTriangle => 'Right triangle',
        ShapeKind.square => 'Square',
        ShapeKind.rectangle => 'Rectangle',
        ShapeKind.trapezoid => 'Trapezoid',
        ShapeKind.rhombus => 'Rhombus',
        ShapeKind.pentagon => 'Pentagon',
        ShapeKind.hexagon => 'Hexagon',
        ShapeKind.circle => 'Circle',
        ShapeKind.circleArc => 'Circle arc',
        ShapeKind.ellipse => 'Ellipse',
      };
}

/// A simple outline drawing of a shape — used both as a small grid icon and
/// (at a larger size) as the plain diagram atop single-dimension shapes.
class ShapeIcon extends StatelessWidget {
  const ShapeIcon({super.key, required this.kind, this.size = 28, this.color, this.showRadius = false, this.filled = false});

  final ShapeKind kind;
  final double size;
  final Color? color;
  final bool showRadius;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final resolvedColor = color ?? DefaultTextStyle.of(context).style.color ?? Colors.white;
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _ShapePainter(kind, resolvedColor, showRadius, filled)),
    );
  }
}

class _ShapePainter extends CustomPainter {
  _ShapePainter(this.kind, this.color, this.showRadius, this.filled);

  final ShapeKind kind;
  final Color color;
  final bool showRadius;
  final bool filled;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = filled ? PaintingStyle.fill : PaintingStyle.stroke
      ..strokeWidth = size.shortestSide * 0.045
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    final w = size.width;
    final h = size.height;

    switch (kind) {
      case ShapeKind.triangle:
        canvas.drawPath(_polygon([Offset(w / 2, 0), Offset(w, h), Offset(0, h)]), paint);
      case ShapeKind.rightTriangle:
        canvas.drawPath(_polygon([Offset(0, 0), Offset(0, h), Offset(w, h)]), paint);
      case ShapeKind.square:
        canvas.drawRect(Rect.fromLTWH(w * 0.08, h * 0.08, w * 0.84, h * 0.84), paint);
      case ShapeKind.rectangle:
        canvas.drawRect(Rect.fromLTWH(w * 0.05, h * 0.2, w * 0.9, h * 0.6), paint);
      case ShapeKind.trapezoid:
        canvas.drawPath(
          _polygon([Offset(w * 0.28, 0), Offset(w * 0.72, 0), Offset(w, h), Offset(0, h)]),
          paint,
        );
      case ShapeKind.rhombus:
        canvas.drawPath(
          _polygon([Offset(w / 2, 0), Offset(w, h / 2), Offset(w / 2, h), Offset(0, h / 2)]),
          paint,
        );
      case ShapeKind.pentagon:
        canvas.drawPath(_regularPolygon(w, h, 5), paint);
      case ShapeKind.hexagon:
        canvas.drawPath(_regularPolygon(w, h, 6), paint);
      case ShapeKind.circle:
        final center = Offset(w / 2, h / 2);
        final radius = size.shortestSide / 2 * 0.9;
        canvas.drawCircle(center, radius, paint);
        if (showRadius) {
          canvas.drawLine(center, Offset(center.dx, center.dy - radius), paint);
        }
      case ShapeKind.circleArc:
        final origin = Offset(w * 0.05, h * 0.05);
        final radius = (w < h ? w : h) * 0.9;
        final arcRect = Rect.fromCircle(center: origin, radius: radius);
        canvas.drawLine(origin, origin + Offset(0, radius), paint);
        canvas.drawLine(origin, origin + Offset(radius, 0), paint);
        canvas.drawArc(arcRect, 0, math.pi / 2, false, paint);
      case ShapeKind.ellipse:
        canvas.drawOval(Rect.fromLTWH(w * 0.03, h * 0.18, w * 0.94, h * 0.64), paint);
    }
  }

  Path _polygon(List<Offset> points) {
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (final p in points.skip(1)) {
      path.lineTo(p.dx, p.dy);
    }
    return path..close();
  }

  Path _regularPolygon(double w, double h, int sides) {
    final center = Offset(w / 2, h / 2);
    final radius = (w < h ? w : h) / 2 * 0.92;
    final points = <Offset>[];
    for (var i = 0; i < sides; i++) {
      final angle = -math.pi / 2 + i * 2 * math.pi / sides;
      points.add(center + Offset(radius * math.cos(angle), radius * math.sin(angle)));
    }
    return _polygon(points);
  }

  @override
  bool shouldRepaint(covariant _ShapePainter oldDelegate) =>
      oldDelegate.kind != kind || oldDelegate.color != color || oldDelegate.filled != filled;
}
