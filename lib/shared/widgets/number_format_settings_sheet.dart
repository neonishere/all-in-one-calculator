import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/settings/number_format_settings.dart';
import '../../core/theme/app_theme.dart';

class NumberFormatSettingsSheet extends StatelessWidget {
  const NumberFormatSettingsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<NumberFormatSettings>();
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Number format', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Decimal places'),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      color: AppColors.accent,
                      onPressed: settings.decimalPlaces > 0
                          ? () => settings.setDecimalPlaces(settings.decimalPlaces - 1)
                          : null,
                    ),
                    SizedBox(
                      width: 24,
                      child: Text(
                        '${settings.decimalPlaces}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      color: AppColors.accent,
                      onPressed: settings.decimalPlaces < 8
                          ? () => settings.setDecimalPlaces(settings.decimalPlaces + 1)
                          : null,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text('Thousands & decimal separator', style: TextStyle(color: AppColors.textSecondary)),
            for (final style in NumberFormatStyle.values)
              RadioListTile<NumberFormatStyle>(
                value: style,
                groupValue: settings.style,
                onChanged: (v) => settings.setStyle(v!),
                title: Text(style.example),
                activeColor: AppColors.accent,
                contentPadding: EdgeInsets.zero,
              ),
          ],
        ),
      ),
    );
  }
}
