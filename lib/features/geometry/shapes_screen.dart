import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../shared/widgets/shape_icon.dart';
import 'shapes/circle_arc_screen.dart';
import 'shapes/circle_screen.dart';
import 'shapes/ellipse_screen.dart';
import 'shapes/rectangle_screen.dart';
import 'shapes/regular_polygon_screen.dart';
import 'shapes/rhombus_screen.dart';
import 'shapes/right_triangle_screen.dart';
import 'shapes/trapezoid_screen.dart';
import 'shapes/triangle_screen.dart';

class ShapesScreen extends StatelessWidget {
  const ShapesScreen({super.key});

  static final _entries = <(ShapeKind, WidgetBuilder)>[
    (ShapeKind.triangle, (_) => const TriangleScreen()),
    (ShapeKind.rightTriangle, (_) => const RightTriangleScreen()),
    (ShapeKind.square, (_) => const RegularPolygonScreen(sides: 4, kind: ShapeKind.square)),
    (ShapeKind.rectangle, (_) => const RectangleScreen()),
    (ShapeKind.trapezoid, (_) => const TrapezoidScreen()),
    (ShapeKind.rhombus, (_) => const RhombusScreen()),
    (ShapeKind.pentagon, (_) => const RegularPolygonScreen(sides: 5, kind: ShapeKind.pentagon)),
    (ShapeKind.hexagon, (_) => const RegularPolygonScreen(sides: 6, kind: ShapeKind.hexagon)),
    (ShapeKind.circle, (_) => const CircleScreen()),
    (ShapeKind.circleArc, (_) => const CircleArcScreen()),
    (ShapeKind.ellipse, (_) => const EllipseScreen()),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Shapes')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16)),
            child: GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              childAspectRatio: 0.9,
              children: [
                for (final (kind, builder) in _entries)
                  InkWell(
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: builder)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ShapeIcon(kind: kind, size: 48, color: AppColors.accent),
                        const SizedBox(height: 10),
                        Text(kind.label, style: const TextStyle(fontWeight: FontWeight.w600), textAlign: TextAlign.center),
                      ],
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
