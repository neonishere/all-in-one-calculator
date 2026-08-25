import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class MemoryPanel extends StatelessWidget {
  const MemoryPanel({
    super.key,
    required this.value,
    required this.formattedValue,
    required this.onRecall,
    required this.onClear,
  });

  final double value;
  final String formattedValue;
  final VoidCallback onRecall;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Memory', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppColors.surfaceAlt, borderRadius: BorderRadius.circular(12)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(formattedValue, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
                  if (value != 0)
                    Row(
                      children: [
                        TextButton(onPressed: onRecall, child: const Text('Recall')),
                        TextButton(onPressed: onClear, child: const Text('Clear')),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
