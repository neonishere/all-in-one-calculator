import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// A calculator key with a subtle press animation, closer to how the
/// Windows Calculator keys feel than a plain flat button.
class CalcKeyButton extends StatefulWidget {
  const CalcKeyButton({
    super.key,
    required this.label,
    required this.onTap,
    this.onLongPress,
    this.sublabel,
    this.filled = false,
    this.accented = false,
    this.dimmed = false,
    this.themed = false,
    this.fontSize,
  });

  final String label;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final String? sublabel;
  final bool filled;
  final bool accented;
  final bool dimmed;

  /// Tints the button's background with the accent color, distinguishing
  /// it from the plain digit keys.
  final bool themed;
  final double? fontSize;

  @override
  State<CalcKeyButton> createState() => _CalcKeyButtonState();
}

class _CalcKeyButtonState extends State<CalcKeyButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final background = widget.filled
        ? AppColors.accent
        : (widget.themed ? AppColors.accent.withValues(alpha: 0.14) : AppColors.surface);
    final foreground = widget.filled
        ? Colors.black
        : (widget.accented ? AppColors.accent : (widget.dimmed ? AppColors.textSecondary : AppColors.textPrimary));

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
          onLongPress: widget.onLongPress,
          onTapDown: (_) => setState(() => _pressed = true),
          onTapUp: (_) => setState(() => _pressed = false),
          onTapCancel: () => setState(() => _pressed = false),
          splashColor: AppColors.accent.withValues(alpha: 0.25),
          highlightColor: AppColors.accent.withValues(alpha: 0.12),
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.label,
                    style: TextStyle(
                      fontSize: widget.fontSize ?? 18,
                      fontWeight: FontWeight.w500,
                      color: foreground,
                    ),
                  ),
                  if (widget.sublabel != null)
                    Text(
                      widget.sublabel!,
                      style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
