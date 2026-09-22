import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Shows a "Clear screen?" confirmation with Yes/No stacked vertically,
/// Yes highlighted as the primary action. Returns true if confirmed.
Future<bool> confirmClearScreen(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: AppColors.surface,
      title: const Text('Clear screen?'),
      actionsAlignment: MainAxisAlignment.center,
      actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
      actions: [
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Yes'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('No'),
            ),
          ],
        ),
      ],
    ),
  );
  return result ?? false;
}

/// AppBar action that only appears once [visible] (e.g. "has any input")
/// is true, opening the clear-screen confirmation before calling
/// [onConfirmed].
class ClearScreenAction extends StatelessWidget {
  const ClearScreenAction({super.key, required this.visible, required this.onConfirmed});

  final bool visible;
  final VoidCallback onConfirmed;

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();
    return IconButton(
      icon: const Icon(Icons.close),
      tooltip: 'Clear screen',
      onPressed: () async {
        final confirmed = await confirmClearScreen(context);
        if (confirmed) onConfirmed();
      },
    );
  }
}
