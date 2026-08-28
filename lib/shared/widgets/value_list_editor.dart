import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import 'number_field.dart';

/// An addable/removable list of labeled number fields (A, B, C, ...), used
/// by tools that operate on a variable-length set of values (average,
/// GCF & LCM, ...).
class ValueListEditor extends StatefulWidget {
  const ValueListEditor({
    super.key,
    required this.onChanged,
    this.minCount = 2,
    this.initialCount = 2,
  });

  final ValueChanged<List<double?>> onChanged;
  final int minCount;
  final int initialCount;

  @override
  State<ValueListEditor> createState() => ValueListEditorState();
}

class ValueListEditorState extends State<ValueListEditor> {
  final List<TextEditingController> _controllers = [];

  @override
  void initState() {
    super.initState();
    for (var i = 0; i < widget.initialCount; i++) {
      _controllers.add(TextEditingController());
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  String _labelFor(int index) => String.fromCharCode('A'.codeUnitAt(0) + (index % 26));

  void _notify() {
    widget.onChanged([for (final c in _controllers) double.tryParse(c.text)]);
  }

  void _addValue() {
    setState(() => _controllers.add(TextEditingController()));
    _notify();
  }

  void _removeAt(int index) {
    setState(() => _controllers.removeAt(index).dispose());
    _notify();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final itemWidth = (constraints.maxWidth - 10) / 2;
            return Wrap(
              spacing: 10,
              runSpacing: 0,
              children: [
                for (var i = 0; i < _controllers.length; i++)
                  SizedBox(
                    width: itemWidth,
                    child: Stack(
                      children: [
                        NumberField(
                          label: _labelFor(i),
                          controller: _controllers[i],
                          allowNegative: true,
                          onChanged: (_) => _notify(),
                        ),
                        if (_controllers.length > widget.minCount)
                          Positioned(
                            right: 0,
                            top: 0,
                            child: IconButton(
                              icon: Icon(Icons.close, size: 16, color: AppColors.textSecondary),
                              onPressed: () => _removeAt(i),
                            ),
                          ),
                      ],
                    ),
                  ),
              ],
            );
          },
        ),
        TextButton.icon(
          onPressed: _addValue,
          icon: const Icon(Icons.add),
          label: const Text('Add value'),
        ),
      ],
    );
  }
}
