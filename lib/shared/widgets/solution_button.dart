import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';

import '../../core/theme/app_theme.dart';

/// The outlined "Σ Solution" button that opens a full-screen step-by-step
/// breakdown (its own page with a close button, not a sheet — matches how
/// the reference calculator presents solved steps).
/// Pass null for [steps] (or an empty list) to show it disabled.
///
/// Each step string is real LaTeX, rendered with [flutter_math_fork] —
/// the KaTeX fonts it ships are metrically the same family as Computer
/// Modern/Latin Modern, giving the standard textbook math look (proper
/// minus sign, a radical bar that spans the whole radicand, upright
/// function names like `\arccos`, italic variables, ...) for free. Wrap a
/// line in `{{...}}` to render it bold and slightly larger, for a
/// section's final answer.
///
/// Consecutive non-empty lines form one derivation block whose `=` signs
/// line up in a column (like a LaTeX `align` environment); an empty
/// string in [steps] starts a new block.
class SolutionButton extends StatelessWidget {
  const SolutionButton({super.key, required this.steps, this.title = 'Solution'});

  final List<String>? steps;
  final String title;

  @override
  Widget build(BuildContext context) {
    final enabled = steps != null && steps!.isNotEmpty;
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.only(top: 16),
        child: OutlinedButton.icon(
          onPressed: enabled
              ? () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => SolutionScreen(title: title, steps: steps!)),
                  )
              : null,
          icon: const Text('Σ', style: TextStyle(fontSize: 16)),
          label: const Text('Solution'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.textPrimary,
            side: BorderSide(color: AppColors.divider),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ),
    );
  }
}

class SolutionScreen extends StatelessWidget {
  const SolutionScreen({super.key, required this.title, required this.steps});

  final String title;
  final List<String> steps;

  List<List<String>> get _blocks {
    final blocks = <List<String>>[];
    var current = <String>[];
    for (final line in steps) {
      if (line.isEmpty) {
        if (current.isNotEmpty) blocks.add(current);
        current = [];
      } else {
        current.add(line);
      }
    }
    if (current.isNotEmpty) blocks.add(current);
    return blocks;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(title),
      ),
      body: SafeArea(
        // The formulas render at a fixed, "book" size instead of shrinking
        // or wrapping to fit the screen — pan and pinch-to-zoom to see the
        // parts that don't fit the viewport, instead of them overflowing
        // or getting clipped.
        child: InteractiveViewer(
          constrained: false,
          boundaryMargin: const EdgeInsets.all(120),
          minScale: 0.4,
          maxScale: 4,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
            child: _SolutionBody(blocks: _blocks),
          ),
        ),
      ),
    );
  }
}

/// Owns the `=`-alignment measurement for the whole page (not per block),
/// so every derivation block's `=` sign lands on the same shared vertical
/// line, not just the lines within one block.
class _SolutionBody extends StatefulWidget {
  const _SolutionBody({required this.blocks});

  final List<List<String>> blocks;

  @override
  State<_SolutionBody> createState() => _SolutionBodyState();
}

class _SolutionBodyState extends State<_SolutionBody> {
  final Map<int, double> _leftWidths = {};
  double? _maxLeftWidth;

  void _onLeftMeasured(int globalIndex, Size size) {
    if (_leftWidths[globalIndex] == size.width) return;
    _leftWidths[globalIndex] = size.width;
    final maxW = _leftWidths.values.fold<double>(0, (m, w) => w > m ? w : m);
    if (_maxLeftWidth != maxW) {
      setState(() => _maxLeftWidth = maxW);
    }
  }

  @override
  Widget build(BuildContext context) {
    var globalIndex = 0;
    final children = <Widget>[];
    for (final block in widget.blocks) {
      children.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: _AlignedBlock(
            lines: block,
            leftColumnWidth: _maxLeftWidth,
            // Each row gets a page-wide-unique index, so every row's
            // measurement lands in the same shared width map.
            indexStart: globalIndex,
            onLeftMeasured: _onLeftMeasured,
          ),
        ),
      );
      globalIndex += block.length;
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }
}

class _StepPiece {
  const _StepPiece({required this.left, required this.right, required this.bold});

  /// LaTeX before the first `=` (e.g. the "Angle BC" label), or empty for
  /// a continuation line.
  final String left;

  /// LaTeX from `=` onward, including the `=` itself.
  final String right;

  final bool bold;

  factory _StepPiece.parse(String raw) {
    final isFinal = raw.startsWith('{{') && raw.endsWith('}}');
    final content = isFinal ? raw.substring(2, raw.length - 2) : raw;
    final eqIndex = content.indexOf('=');
    if (eqIndex == -1) return _StepPiece(left: '', right: content, bold: isFinal);
    return _StepPiece(left: content.substring(0, eqIndex).trim(), right: content.substring(eqIndex).trim(), bold: isFinal);
  }
}

/// Renders one derivation block. [leftColumnWidth] is shared across every
/// block on the page (owned by [_SolutionBodyState]) so every block's `=`
/// lands on the same vertical line, not just the lines within this one.
///
/// The page is unconstrained (see [InteractiveViewer] above), so there's
/// no screen width to derive a column guess from — and a fixed guess
/// can't work anyway, since a too-narrow one would overflow. Instead each
/// "before =" piece reports its real laid-out width once rendered
/// (bypassing Flutter's intrinsic-dimensions protocol, which [Math]
/// widgets don't support) via [onLeftMeasured], keyed by [indexStart] + a
/// row offset so it lands in the page-wide width map.
class _AlignedBlock extends StatelessWidget {
  const _AlignedBlock({
    required this.lines,
    required this.leftColumnWidth,
    required this.indexStart,
    required this.onLeftMeasured,
  });

  final List<String> lines;
  final double? leftColumnWidth;
  final int indexStart;
  final void Function(int index, Size size) onLeftMeasured;

  static const _baseFontSize = 23.0;
  static const _boldFontSize = 27.0;

  @override
  Widget build(BuildContext context) {
    final pieces = lines.map(_StepPiece.parse).toList();
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < pieces.length; i++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: leftColumnWidth,
                  child: pieces[i].left.isEmpty
                      ? null
                      : Align(
                          alignment: Alignment.centerRight,
                          child: _MeasureSize(
                            onChange: (size) => onLeftMeasured(indexStart + i, size),
                            child: _MathPiece(
                              tex: pieces[i].left,
                              bold: pieces[i].bold,
                              fontSize: pieces[i].bold ? _boldFontSize : _baseFontSize,
                            ),
                          ),
                        ),
                ),
                const SizedBox(width: 10),
                _MathPiece(
                  tex: pieces[i].right,
                  bold: pieces[i].bold,
                  fontSize: pieces[i].bold ? _boldFontSize : _baseFontSize,
                ),
              ],
            ),
          ),
      ],
    );
  }
}

typedef _OnSizeChange = void Function(Size size);

/// Reports [child]'s real laid-out size after each frame, without using
/// the intrinsic-dimensions protocol (which [Math] widgets don't support).
class _MeasureSize extends StatefulWidget {
  const _MeasureSize({required this.onChange, required this.child});

  final _OnSizeChange onChange;
  final Widget child;

  @override
  State<_MeasureSize> createState() => _MeasureSizeState();
}

class _MeasureSizeState extends State<_MeasureSize> {
  Size? _lastSize;

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) => _report());
    return widget.child;
  }

  void _report() {
    if (!mounted) return;
    final size = (context.findRenderObject() as RenderBox?)?.size;
    if (size != null && size != _lastSize) {
      _lastSize = size;
      widget.onChange(size);
    }
  }
}

class _MathPiece extends StatelessWidget {
  const _MathPiece({required this.tex, required this.bold, required this.fontSize});

  final String tex;
  final bool bold;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Math.tex(
      bold ? '\\mathbf{$tex}' : tex,
      mathStyle: MathStyle.display,
      textStyle: TextStyle(fontSize: fontSize, color: AppColors.textPrimary),
      onErrorFallback: (_) => Text(
        tex,
        style: TextStyle(fontSize: fontSize, color: AppColors.textPrimary),
      ),
    );
  }
}
