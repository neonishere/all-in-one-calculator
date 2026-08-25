import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/catalog/tool_catalog.dart';
import '../../core/catalog/tool_category.dart';
import '../../core/catalog/tool_entry.dart';
import '../../core/routing/fade_pop_route.dart';
import '../../core/settings/favorites_store.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/coming_soon_screen.dart';
import '../settings/settings_screen.dart';

class ToolMenuScreen extends StatefulWidget {
  const ToolMenuScreen({super.key});

  @override
  State<ToolMenuScreen> createState() => _ToolMenuScreenState();
}

class _ToolMenuScreenState extends State<ToolMenuScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<FavoritesStore>();
    final query = _query.trim().toLowerCase();
    final filtered = query.isEmpty
        ? toolCatalog
        : toolCatalog.where((t) => t.title.toLowerCase().contains(query)).toList();

    final grouped = <ToolCategory, List<ToolEntry>>{};
    for (final tool in filtered) {
      grouped.putIfAbsent(tool.category, () => []).add(tool);
    }

    final favoriteTools = filtered.where((t) => favorites.isFavorite(t.id)).toList();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.settings_outlined),
          tooltip: 'Settings',
          onPressed: () => Navigator.of(context).push(
            fadePopRoute(const SettingsScreen()),
          ),
        ),
        title: const Text('All tools'),
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            tooltip: 'Back to calculator',
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
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
                  if (favoriteTools.isNotEmpty) ...[
                    _sectionHeader('Favorites'),
                    for (final tool in favoriteTools) _toolTile(tool, favorites),
                  ],
                  for (final category in ToolCategory.values)
                    if (grouped[category]?.isNotEmpty ?? false) ...[
                      _sectionHeader(category.label),
                      for (final tool in grouped[category]!) _toolTile(tool, favorites),
                    ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      child: Text(
        label,
        style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _toolTile(ToolEntry tool, FavoritesStore favorites) {
    final isFavorite = favorites.isFavorite(tool.id);
    return ListTile(
      leading: Icon(tool.icon),
      title: Text(tool.title),
      subtitle: tool.isImplemented ? null : Text('Coming soon', style: TextStyle(color: AppColors.textSecondary)),
      trailing: IconButton(
        icon: Icon(
          isFavorite ? Icons.star : Icons.star_border,
          color: isFavorite ? AppColors.accent : AppColors.textSecondary,
        ),
        tooltip: isFavorite ? 'Remove from favorites' : 'Add to favorites',
        onPressed: () => favorites.toggle(tool.id),
      ),
      onTap: () => Navigator.of(context).push(
        fadePopRoute(tool.builder?.call(context) ?? ComingSoonScreen(title: tool.title)),
      ),
    );
  }
}
