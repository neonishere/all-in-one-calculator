import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import 'mini_calculator_popup.dart';

class NumberField extends StatelessWidget {
  const NumberField({
    super.key,
    required this.label,
    required this.controller,
    this.suffix,
    this.onChanged,
    this.allowNegative = false,
    this.popupTitle,
  });

  final String label;
  final TextEditingController controller;
  final String? suffix;
  final ValueChanged<String>? onChanged;
  final bool allowNegative;

  /// Title shown atop the popup calculator. Defaults to [label], combined
  /// with [suffix] when both are set (e.g. "Side: A"), falling back to
  /// [suffix] alone or "Value" when neither is present.
  final String? popupTitle;

  String get _resolvedPopupTitle {
    if (popupTitle != null) return popupTitle!;
    if (label.isNotEmpty && suffix != null && suffix != label) return '$label: $suffix';
    if (label.isNotEmpty) return label;
    if (suffix != null && suffix!.isNotEmpty) return suffix!;
    return 'Value';
  }

  Future<void> _openPopup(BuildContext context) async {
    final result = await showMiniCalculatorPopup(
      context,
      title: _resolvedPopupTitle,
      initialValue: controller.text,
    );
    if (result == null) return;
    controller.text = result;
    onChanged?.call(result);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        readOnly: true,
        showCursor: true,
        onTap: () => _openPopup(context),
        style: const TextStyle(fontSize: 18),
        decoration: InputDecoration(
          labelText: label,
          suffixText: suffix,
          filled: true,
          fillColor: AppColors.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
