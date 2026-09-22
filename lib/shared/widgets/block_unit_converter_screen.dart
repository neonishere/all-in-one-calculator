import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/settings/number_format_settings.dart';
import '../../core/theme/app_theme.dart';
import '../converters/converter_unit.dart';
import 'mini_calculator_popup.dart';
import 'number_format_settings_sheet.dart';

class _Block {
  _Block(this.unit) : controller = TextEditingController();

  ConverterUnit unit;
  final TextEditingController controller;

  void dispose() {
    controller.dispose();
  }
}

/// A converter made of draggable, addable "blocks" — one per unit — where
/// typing into any block live-updates every other block to match.
class BlockUnitConverterScreen extends StatefulWidget {
  const BlockUnitConverterScreen({
    super.key,
    required this.title,
    required this.units,
    this.defaultUnitIds,
  });

  final String title;
  final List<ConverterUnit> units;

  /// Ids of units shown by default. Falls back to the first three units.
  final List<String>? defaultUnitIds;

  @override
  State<BlockUnitConverterScreen> createState() => _BlockUnitConverterScreenState();
}

class _BlockUnitConverterScreenState extends State<BlockUnitConverterScreen> {
  final List<_Block> _blocks = [];

  String get _storageKey => 'block_units_v1_${widget.title.toLowerCase().replaceAll(' ', '_')}';

  @override
  void initState() {
    super.initState();
    final defaultIds = widget.defaultUnitIds ?? widget.units.take(3).map((u) => u.id).toList();
    _buildBlocks(defaultIds);
    _loadSavedUnits();
  }

  void _buildBlocks(List<String> ids) {
    for (final id in ids) {
      ConverterUnit? unit;
      for (final u in widget.units) {
        if (u.id == id) {
          unit = u;
          break;
        }
      }
      if (unit != null) _blocks.add(_registerBlock(_Block(unit)));
    }
    if (_blocks.isNotEmpty) {
      final settings = context.read<NumberFormatSettings>();
      _blocks.first.controller.text = '1';
      final baseValue = _blocks.first.unit.toBase(1);
      for (final block in _blocks.skip(1)) {
        block.controller.text = settings.format(block.unit.fromBase(baseValue));
      }
    }
  }

  Future<void> _loadSavedUnits() async {
    final prefs = await SharedPreferences.getInstance();
    final savedIds = prefs.getStringList(_storageKey);
    if (savedIds == null || !mounted) return;
    final validIds = savedIds.where((id) => widget.units.any((u) => u.id == id)).toList();
    if (validIds.isEmpty) return;
    for (final block in _blocks) {
      block.dispose();
    }
    _blocks.clear();
    _buildBlocks(validIds);
    setState(() {});
  }

  Future<void> _saveBlocks() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_storageKey, _blocks.map((b) => b.unit.id).toList());
  }

  _Block _registerBlock(_Block block) => block;

  @override
  void dispose() {
    for (final block in _blocks) {
      block.dispose();
    }
    super.dispose();
  }

  void _recalculateFrom(_Block source) {
    final value = double.tryParse(source.controller.text);
    if (value == null) {
      for (final block in _blocks) {
        if (block != source) block.controller.text = '';
      }
      setState(() {});
      return;
    }
    final settings = context.read<NumberFormatSettings>();
    final baseValue = source.unit.toBase(value);
    source.controller.text = settings.format(value);
    for (final block in _blocks) {
      if (block == source) continue;
      block.controller.text = settings.format(block.unit.fromBase(baseValue));
    }
    setState(() {});
  }

  double? _currentBaseValue() {
    final settings = context.read<NumberFormatSettings>();
    for (final block in _blocks) {
      final value = settings.parse(block.controller.text) ?? double.tryParse(block.controller.text);
      if (value != null) return block.unit.toBase(value);
    }
    return null;
  }

  Future<void> _openBlockPopup(_Block block) async {
    final result = await showMiniCalculatorPopup(
      context,
      title: block.unit.label,
      initialValue: block.controller.text,
    );
    if (result == null) return;
    block.controller.text = result;
    _recalculateFrom(block);
  }

  Future<void> _addBlock() async {
    final usedIds = _blocks.map((b) => b.unit.id).toSet();
    final unit = await _pickUnit(excludeIds: usedIds);
    if (unit == null) return;
    final baseValue = _currentBaseValue();
    final settings = context.read<NumberFormatSettings>();
    final block = _registerBlock(_Block(unit));
    if (baseValue != null) {
      block.controller.text = settings.format(unit.fromBase(baseValue));
    }
    setState(() => _blocks.add(block));
    _saveBlocks();
  }

  Future<void> _changeUnit(_Block block) async {
    final settings = context.read<NumberFormatSettings>();
    final currentValue = settings.parse(block.controller.text) ?? double.tryParse(block.controller.text);
    final baseValue = currentValue != null ? block.unit.toBase(currentValue) : null;
    final usedIds = _blocks.where((b) => b != block).map((b) => b.unit.id).toSet();
    final newUnit = await _pickUnit(excludeIds: usedIds);
    if (newUnit == null) return;
    setState(() {
      block.unit = newUnit;
      if (baseValue != null) {
        block.controller.text = settings.format(newUnit.fromBase(baseValue));
      }
    });
    _saveBlocks();
  }

  void _removeBlock(_Block block) {
    setState(() => _blocks.remove(block));
    block.dispose();
    _saveBlocks();
  }

  Future<ConverterUnit?> _pickUnit({Set<String> excludeIds = const {}}) async {
    var query = '';
    return showModalBottomSheet<ConverterUnit>(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            final available = widget.units.where((u) => !excludeIds.contains(u.id));
            final filtered = available.where((u) => u.label.toLowerCase().contains(query.toLowerCase())).toList();
            return SizedBox(
              height: MediaQuery.of(sheetContext).size.height * 0.7,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: TextField(
                      onChanged: (v) => setSheetState(() => query = v),
                      decoration: InputDecoration(
                        hintText: 'Search units',
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: AppColors.surfaceAlt,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                  ),
                  Expanded(
                    child: filtered.isEmpty
                        ? Center(
                            child: Text(
                              'All units already added',
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                          )
                        : ListView(
                            children: [
                              for (final unit in filtered)
                                ListTile(
                                  title: Text(unit.label),
                                  trailing: Text(unit.shortLabel, style: TextStyle(color: AppColors.textSecondary)),
                                  onTap: () => Navigator.of(sheetContext).pop(unit),
                                ),
                            ],
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _openFormatSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => const NumberFormatSettingsSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(icon: const Icon(Icons.more_vert), tooltip: 'Number format', onPressed: _openFormatSettings),
        ],
      ),
      body: SafeArea(
        child: _blocks.isEmpty
            ? Center(
                child: TextButton.icon(
                  onPressed: _addBlock,
                  icon: const Icon(Icons.add),
                  label: const Text('Add a unit'),
                ),
              )
            : ReorderableListView(
                buildDefaultDragHandles: false,
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                onReorder: (oldIndex, newIndex) {
                  setState(() {
                    if (newIndex > oldIndex) newIndex -= 1;
                    final item = _blocks.removeAt(oldIndex);
                    _blocks.insert(newIndex, item);
                  });
                  _saveBlocks();
                },
                children: [for (final block in _blocks) _blockTile(block)],
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addBlock,
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.black,
        tooltip: 'Add unit',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _blockTile(_Block block) {
    return Container(
      key: ValueKey(block),
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(4, 10, 8, 10),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ReorderableDragStartListener(
            index: _blocks.indexOf(block),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Icon(Icons.drag_handle, color: AppColors.textSecondary),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: () => _changeUnit(block),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          block.unit.label,
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(Icons.arrow_drop_down, color: AppColors.textSecondary, size: 18),
                    ],
                  ),
                ),
                TextField(
                  controller: block.controller,
                  readOnly: true,
                  onTap: () => _openBlockPopup(block),
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                  decoration: const InputDecoration(
                    isDense: true,
                    isCollapsed: true,
                    border: InputBorder.none,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          SizedBox(
            width: 44,
            child: Text(
              block.unit.shortLabel,
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
            ),
          ),
          SizedBox(
            width: 40,
            child: _blocks.length > 1
                ? IconButton(
                    padding: EdgeInsets.zero,
                    icon: Icon(Icons.close, size: 18, color: AppColors.textSecondary),
                    onPressed: () => _removeBlock(block),
                  )
                : null,
          ),
        ],
      ),
    );
  }
}
