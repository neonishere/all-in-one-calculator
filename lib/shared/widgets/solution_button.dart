import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// The outlined "Σ Solution" button that opens a full-screen step-by-step
/// breakdown (its own page with a close button, not a sheet — matches how
/// the reference calculator presents solved steps).
/// Pass null for [steps] (or an empty list) to show it disabled.
///
/// Step strings may embed a fraction as `[[numerator/denominator]]`, which
/// renders as a stacked fraction with a divider bar instead of a slash —
/// see [SolutionScreen].
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(title),
        actions: [
          IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(context).pop()),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
          children: [
            for (final line in steps)
              line.isEmpty
                  ? const SizedBox(height: 20)
                  : Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: _StepLine(text: line),
                    ),
          ],
        ),
      ),
    );
  }
}

class _StepLine extends StatelessWidget {
  const _StepLine({required this.text});

  final String text;

  static final _fractionPattern = RegExp(r'\[\[([^\[\]/]+)/([^\[\]/]+)\]\]');
  static const _textStyle = TextStyle(fontSize: 24, fontWeight: FontWeight.w400);

  @override
  Widget build(BuildContext context) {
    final matches = _fractionPattern.allMatches(text).toList();
    if (matches.isEmpty) {
      return Text(text, textAlign: TextAlign.center, style: _textStyle);
    }

    final pieces = <Widget>[];
    var cursor = 0;
    for (final match in matches) {
      if (match.start > cursor) {
        pieces.add(Text(text.substring(cursor, match.start), style: _textStyle));
      }
      pieces.add(_Fraction(numerator: match.group(1)!, denominator: match.group(2)!));
      cursor = match.end;
    }
    if (cursor < text.length) {
      pieces.add(Text(text.substring(cursor), style: _textStyle));
    }

    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 6,
      children: pieces,
    );
  }
}

class _Fraction extends StatelessWidget {
  const _Fraction({required this.numerator, required this.denominator});

  final String numerator;
  final String denominator;

  @override
  Widget build(BuildContext context) {
    return IntrinsicWidth(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(numerator.trim(), textAlign: TextAlign.center, style: const TextStyle(fontSize: 19)),
          Container(margin: const EdgeInsets.symmetric(vertical: 3), height: 1.5, color: AppColors.textPrimary),
          Text(denominator.trim(), textAlign: TextAlign.center, style: const TextStyle(fontSize: 19)),
        ],
      ),
    );
  }
}
