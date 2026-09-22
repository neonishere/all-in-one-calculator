import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:allinone_calculator/shared/widgets/solution_button.dart';

void main() {
  testWidgets('all "=" pieces in a block share the same left X position', (tester) async {
    final steps = [
      '\\text{Side } A = 7',
      '\\text{Side } B = 9',
      '\\text{Side } C = 6',
      '',
      '\\text{Angle } BC = \\frac{\\arccos\\left(\\frac{B^2+C^2-A^2}{2BC}\\right)}{\\pi}\\times 180',
      '= \\frac{\\arccos\\left(\\frac{9^2+6^2-7^2}{2\\times 9\\times 6}\\right)}{\\pi}\\times 180',
      '= \\frac{\\arccos(0.63)}{\\pi}\\times 180',
      '{{= 50.98}}',
    ];

    await tester.pumpWidget(
      MaterialApp(home: SolutionScreen(title: 'Triangle', steps: steps)),
    );
    // Give the post-frame measurement callbacks several rounds to settle.
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    await tester.pumpAndSettle();

    final mathFinder = find.byType(Math);
    final xs = <double>[];
    for (final element in mathFinder.evaluate()) {
      final renderBox = element.renderObject as RenderBox;
      final topLeft = renderBox.localToGlobal(Offset.zero);
      xs.add(topLeft.dx);
    }

    // The angle block's 4 "right of =" pieces (the last 4 X positions:
    // one per line, since only the first line has a left label) must all
    // start at the same X for the "=" signs to be vertically aligned.
    final angleBlockRightXs = xs.sublist(xs.length - 4);
    for (final x in angleBlockRightXs) {
      expect(x, closeTo(angleBlockRightXs.first, 0.5));
    }

    // The Side A/B/C block's "right of =" pieces (indices 1, 3, 5 — each
    // row is [left, right]) must share that SAME global column, not just
    // align within their own block.
    final sideBlockRightXs = [xs[1], xs[3], xs[5]];
    for (final x in sideBlockRightXs) {
      expect(x, closeTo(angleBlockRightXs.first, 0.5));
    }

    expect(tester.takeException(), isNull);
  });
}
