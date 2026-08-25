import 'package:flutter/widgets.dart';

import 'tool_category.dart';

class ToolEntry {
  const ToolEntry({
    required this.id,
    required this.title,
    required this.category,
    required this.icon,
    this.builder,
  });

  final String id;
  final String title;
  final ToolCategory category;
  final IconData icon;

  /// Null when the tool is on the roadmap but not implemented yet.
  final WidgetBuilder? builder;

  bool get isImplemented => builder != null;
}
