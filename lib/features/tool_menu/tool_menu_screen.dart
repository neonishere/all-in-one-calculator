import 'package:flutter/material.dart';

import '../../core/catalog/tool_catalog.dart';
import '../../core/catalog/tool_category.dart';
import '../../core/catalog/tool_entry.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/coming_soon_screen.dart';

class ToolMenuScreen extends StatefulWidget {
  const ToolMenuScreen({super.key});

  @override
  State<ToolMenuScreen> createState() => _ToolMenuScreenState();
}

class _ToolMenuScreenState extends State<ToolMenuScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final query = _query.trim().toLowerCase();
    final filtered = query.isEmpty
        ? toolCatalog
        : toolCatalog.where((t) => t.title.toLowerCase().contains(query)).toList();

    final grouped = <ToolCategory, List<ToolEntry>>{};
    for (final tool in filtered) {
      grouped.putIfAbsent(tool.category, () => []).add(tool);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('All tools')),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: TextField(
                onChanged: (v) => setState(() => _query = v),
                decoration: InputDecoration(
                  hintText: 'Search tools',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                children: [
                  for (final category in ToolCategory.values)
                    if (grouped[category]?.isNotEmpty ?? false) ...[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
                        child: Text(
                          category.label,
                          style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                        ),
                      ),
                      for (final tool in grouped[category]!) _toolTile(tool),
                    ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _toolTile(ToolEntry tool) {
    return ListTile(
      leading: Icon(tool.icon),
      title: Text(tool.title),
      subtitle: tool.isImplemented ? null : const Text('Coming soon', style: TextStyle(color: AppColors.textSecondary)),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: tool.builder ?? (_) => ComingSoonScreen(title: tool.title),
        ),
      ),
    );
  }
}
