import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class ResultCard extends StatelessWidget {
  const ResultCard({super.key, required this.rows, this.leadingIcons});

  final List<(String label, String value)> rows;

  /// Optional leading icon per row (aligned by index), e.g. a mini shape
  /// glyph indicating what the row refers to. `null` entries or a shorter
  /// list than [rows] simply omit the icon for that row.
  final List<Widget?>? leadingIcons;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: [
                  if (leadingIcons != null && i < leadingIcons!.length && leadingIcons![i] != null) ...[
                    leadingIcons![i]!,
                    const SizedBox(width: 10),
                  ],
                  Text(rows[i].$1, style: TextStyle(color: AppColors.textSecondary, fontSize: 15)),
                  const Spacer(),
                  Text(
                    rows[i].$2,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
