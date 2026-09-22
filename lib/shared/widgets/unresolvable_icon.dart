import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// A filled circle with a hollow X cut through the middle — used to flag a
/// shape/value that can't be resolved from the given inputs.
class UnresolvableIcon extends StatelessWidget {
  const UnresolvableIcon({super.key, this.size = 28});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _UnresolvableIconPainter(fill: AppColors.accent, hollow: AppColors.background),
      ),
    );
  }
}

class _UnresolvableIconPainter extends CustomPainter {
  _UnresolvableIconPainter({required this.fill, required this.hollow});

  final Color fill;
  final Color hollow;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide / 2;
    canvas.drawCircle(center, radius, Paint()..color = fill);

    final inset = radius * 0.42;
    final paint = Paint()
      ..color = hollow
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.shortestSide * 0.12
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(center + Offset(-inset, -inset), center + Offset(inset, inset), paint);
    canvas.drawLine(center + Offset(-inset, inset), center + Offset(inset, -inset), paint);
  }

  @override
  bool shouldRepaint(covariant _UnresolvableIconPainter oldDelegate) =>
      oldDelegate.fill != fill || oldDelegate.hollow != hollow;
}
