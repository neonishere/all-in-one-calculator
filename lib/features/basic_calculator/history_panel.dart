import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/history/history_entry.dart';
import '../../core/history/history_store.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/swipe_actions_tile.dart';

class HistoryPanel extends StatelessWidget {
  const HistoryPanel({super.key, required this.onClose});

  final VoidCallback onClose;

  String _dateGroupLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final that = DateTime(date.year, date.month, date.day);
    final diff = today.difference(that).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<HistoryStore>();
    final entries = store.entries;

    final groups = <String, List<HistoryEntry>>{};
    for (final entry in entries) {
      groups.putIfAbsent(_dateGroupLabel(entry.timestamp), () => []).add(entry);
    }

    return Material(
      color: AppColors.background,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 12, 12, 4),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary),
                  tooltip: 'Close history',
                  onPressed: onClose,
                ),
                const Expanded(
                  child: Text('History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                ),
                if (entries.isNotEmpty)
                  TextButton(
                    onPressed: () => store.clear(),
                    child: const Text('Clear history'),
                  ),
              ],
            ),
          ),
          Expanded(
            child: entries.isEmpty
                ? Center(child: Text('No history yet', style: TextStyle(color: AppColors.textSecondary)))
                : ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    children: [
                      for (final label in groups.keys) ...[
                        Padding(
                          padding: const EdgeInsets.fromLTRB(8, 12, 8, 4),
                          child: Text(label, style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                        ),
                        for (final entry in groups[label]!) _HistoryTile(entry: entry),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({required this.entry});

  final HistoryEntry entry;

  String get _time {
    final h = entry.timestamp.hour.toString().padLeft(2, '0');
    final m = entry.timestamp.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  Future<void> _addNote(BuildContext context) async {
    final controller = TextEditingController(text: entry.note ?? '');
    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Note'),
        content: TextField(controller: controller, autofocus: true, maxLength: 40),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(''), child: const Text('Clear')),
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(controller.text), child: const Text('Save')),
        ],
      ),
    );
    if (result != null && context.mounted) {
      context.read<HistoryStore>().setNote(entry.id, result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SwipeActionsTile(
          actionsWidth: 168,
          actions: [
            Expanded(
              child: Material(
                color: AppColors.accentDim,
                child: InkWell(
                  onTap: () => _addNote(context),
                  child: const Center(child: Icon(Icons.note_add_outlined, color: Colors.white)),
                ),
              ),
            ),
            Expanded(
              child: Material(
                color: Colors.red.shade400,
                child: InkWell(
                  onTap: () => context.read<HistoryStore>().remove(entry.id),
                  child: const Center(child: Icon(Icons.delete_outline, color: Colors.white)),
                ),
              ),
            ),
          ],
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            color: AppColors.surface,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(entry.expression, style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                      const SizedBox(height: 2),
                      Text(entry.result, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                if (entry.note != null && entry.note!.isNotEmpty) ...[
                  Flexible(
                    child: Text(
                      entry.note!,
                      style: TextStyle(color: AppColors.accent, fontStyle: FontStyle.italic),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Text(_time, style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
