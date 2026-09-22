import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import 'mini_calculator_popup.dart';

/// A shape-tool numeric input: an optional mini glyph on the left, and a
/// single right-aligned slot that shows [placeholder] (a side letter, or
/// "--" when the side/angle is picked elsewhere) until a value is entered,
/// at which point the value replaces it in place. Tapping opens the mini
/// calculator popup instead of the system keyboard.
class ShapeValueField extends StatelessWidget {
  const ShapeValueField({
    super.key,
    required this.controller,
    required this.placeholder,
    required this.popupTitle,
    this.glyph,
    this.onChanged,
  });

  final TextEditingController controller;
  final String placeholder;
  final String popupTitle;
  final Widget? glyph;
  final ValueChanged<String>? onChanged;

  Future<void> _open(BuildContext context) async {
    final result = await showMiniCalculatorPopup(context, title: popupTitle, initialValue: controller.text);
    if (result == null) return;
    controller.text = result;
    onChanged?.call(result);
  }

  @override
  Widget build(BuildContext context) {
    final hasValue = controller.text.isNotEmpty;
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _open(context),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              if (glyph != null) ...[glyph!, const SizedBox(width: 10)],
              const Spacer(),
              Text(
                hasValue ? controller.text : placeholder,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: hasValue ? AppColors.textPrimary : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
