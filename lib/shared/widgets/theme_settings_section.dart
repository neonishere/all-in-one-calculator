import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/settings/theme_settings.dart';
import '../../core/theme/app_theme.dart';

class ThemeSettingsSection extends StatelessWidget {
  const ThemeSettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<ThemeSettings>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Theme', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        Text('Base', style: TextStyle(color: AppColors.textSecondary)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final base in AppBaseTheme.values)
              _BaseSwatch(
                base: base,
                selected: base == settings.base,
                onTap: () => settings.setBase(base),
              ),
          ],
        ),
        const SizedBox(height: 20),
        Text('Accent color', style: TextStyle(color: AppColors.textSecondary)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final accent in AppAccentColor.values)
              _AccentSwatch(
                accent: accent,
                selected: accent == settings.accentColor,
                onTap: () => settings.setAccent(accent),
              ),
          ],
        ),
      ],
    );
  }
}

class _BaseSwatch extends StatelessWidget {
  const _BaseSwatch({required this.base, required this.selected, required this.onTap});

  final AppBaseTheme base;
  final bool selected;
  final VoidCallback onTap;

  static const _previewBg = {
    AppBaseTheme.slate: Color(0xFF14161C),
    AppBaseTheme.midnightBlue: Color(0xFF0B1220),
    AppBaseTheme.black: Color(0xFF000000),
    AppBaseTheme.light: Color(0xFFF5F6F8),
  };

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 84,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: _previewBg[base],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? AppColors.accent : AppColors.divider, width: selected ? 2 : 1),
        ),
        child: Column(
          children: [
            Text(
              base.label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: base == AppBaseTheme.light ? Colors.black87 : Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccentSwatch extends StatelessWidget {
  const _AccentSwatch({required this.accent, required this.selected, required this.onTap});

  final AppAccentColor accent;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: accent.color,
          shape: BoxShape.circle,
          border: Border.all(color: selected ? AppColors.textPrimary : Colors.transparent, width: 2),
        ),
        child: selected ? const Icon(Icons.check, color: Colors.black, size: 20) : null,
      ),
    );
  }
}
