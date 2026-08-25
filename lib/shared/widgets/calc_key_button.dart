import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// A calculator key with a subtle press animation, closer to how the
/// Windows Calculator keys feel than a plain flat button.
class CalcKeyButton extends StatefulWidget {
  const CalcKeyButton({
    super.key,
    required this.label,
    required this.onTap,
    this.filled = false,
    this.accented = false,
    this.fontSize,
  });

  final String label;
  final VoidCallback onTap;
  final bool filled;
  final bool accented;
  final double? fontSize;

  @override
  State<CalcKeyButton> createState() => _CalcKeyButtonState();
}

class _CalcKeyButtonState extends State<CalcKeyButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final background = widget.filled ? AppColors.accent : AppColors.surface;
    final foreground = widget.filled
        ? Colors.black
        : (widget.accented ? AppColors.accent : AppColors.textPrimary);

    return AnimatedScale(
      scale: _pressed ? 0.93 : 1.0,
      duration: const Duration(milliseconds: 90),
      curve: Curves.easeOut,
      child: Material(
        color: background,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: widget.onTap,
          onTapDown: (_) => setState(() => _pressed = true),
          onTapUp: (_) => setState(() => _pressed = false),
          onTapCancel: () => setState(() => _pressed = false),
          splashColor: AppColors.accent.withValues(alpha: 0.25),
          highlightColor: AppColors.accent.withValues(alpha: 0.12),
          child: Center(
            child: Text(
              widget.label,
              style: TextStyle(
                fontSize: widget.fontSize ?? 20,
                fontWeight: FontWeight.w500,
                color: foreground,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
