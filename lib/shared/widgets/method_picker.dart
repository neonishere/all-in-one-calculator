import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class MethodOption<T> {
  const MethodOption({required this.value, required this.title, this.subtitle, this.icon});

  final T value;
  final String title;
  final String? subtitle;
  final IconData? icon;
}

enum MethodPickerStyle {
  /// Tapping the card steps to the next option (wraps around) — for simple
  /// toggles like Yes/No or a 2-3 way switch.
  cycle,

  /// Tapping the card opens an anchored dropdown menu — for a longer list
  /// of meaningfully different choices.
  menu,
}

/// The tappable "Method" card used across algebra tools (percentage,
/// proportion, equations, ...).
class MethodPicker<T> extends StatelessWidget {
  const MethodPicker({
    super.key,
    required this.label,
    required this.options,
    required this.selected,
    required this.onChanged,
    this.helperText,
    this.style = MethodPickerStyle.cycle,
  });

  final String label;
  final String? helperText;
  final List<MethodOption<T>> options;
  final T selected;
  final ValueChanged<T> onChanged;
  final MethodPickerStyle style;

  MethodOption<T> get _current => options.firstWhere((o) => o.value == selected);

  @override
  Widget build(BuildContext context) {
    final card = _Card<T>(current: _current);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          Text(label, style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
          if (helperText != null) ...[
            const SizedBox(height: 2),
            Text(helperText!, style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          ],
          const SizedBox(height: 8),
        ],
        InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => style == MethodPickerStyle.cycle ? _cycleNext() : _openMenu(context),
          child: card,
        ),
      ],
    );
  }

  void _cycleNext() {
    final index = options.indexWhere((o) => o.value == selected);
    final next = options[(index + 1) % options.length];
    onChanged(next.value);
  }

  void _openMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetContext) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(vertical: 12),
          children: [
            for (final option in options)
              ListTile(
                leading: option.icon != null ? Icon(option.icon, color: AppColors.accent) : null,
                title: Text(option.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: option.subtitle != null ? Text(option.subtitle!) : null,
                selected: option.value == selected,
                onTap: () {
                  onChanged(option.value);
                  Navigator.of(sheetContext).pop();
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _Card<T> extends StatelessWidget {
  const _Card({required this.current});

  final MethodOption<T> current;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          if (current.icon != null) ...[
            Icon(current.icon, color: AppColors.accent),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(current.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                if (current.subtitle != null)
                  Text(current.subtitle!, style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              ],
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.keyboard_arrow_up, size: 18, color: AppColors.textSecondary),
              Icon(Icons.keyboard_arrow_down, size: 18, color: AppColors.textSecondary),
            ],
          ),
        ],
      ),
    );
  }
}
