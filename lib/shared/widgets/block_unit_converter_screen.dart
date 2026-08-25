import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/settings/number_format_settings.dart';
import '../../core/theme/app_theme.dart';
import '../converters/converter_unit.dart';
import 'number_format_settings_sheet.dart';

class _Block {
  _Block(this.unit)
      : controller = TextEditingController(),
        focusNode = FocusNode();

  ConverterUnit unit;
  final TextEditingController controller;
  final FocusNode focusNode;

  void dispose() {
    controller.dispose();
    focusNode.dispose();
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

  @override
  void initState() {
    super.initState();
    final defaultIds = widget.defaultUnitIds ?? widget.units.take(3).map((u) => u.id).toList();
    for (final id in defaultIds) {
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

  _Block _registerBlock(_Block block) {
    block.focusNode.addListener(() => _onFocusChange(block));
    return block;
  }

  @override
  void dispose() {
    for (final block in _blocks) {
      block.dispose();
    }
    super.dispose();
  }

  void _onFocusChange(_Block block) {
    final settings = context.read<NumberFormatSettings>();
    if (block.focusNode.hasFocus) {
      final value = settings.parse(block.controller.text) ?? double.tryParse(block.controller.text);
      block.controller.text = value == null ? '' : _plain(value);
    } else {
      final value = double.tryParse(block.controller.text);
      if (value != null) block.controller.text = settings.format(value);
    }
  }

  String _plain(double value) {
    if (value == value.roundToDouble() && value.abs() < 1e15) return value.toInt().toString();
    return value.toString();
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
    for (final block in _blocks) {
      if (block == source) continue;
      block.controller.text = settings.format(block.unit.fromBase(baseValue));
    }
    setState(() {});
  }

  double? _currentBaseValue() {
    final settings = context.read<NumberFormatSettings>();
    for (final block in _blocks) {
      final value = block.focusNode.hasFocus
          ? double.tryParse(block.controller.text)
          : (settings.parse(block.controller.text) ?? double.tryParse(block.controller.text));
      if (value != null) return block.unit.toBase(value);
    }
    return null;
  }

  Future<void> _addBlock() async {
    final unit = await _pickUnit();
    if (unit == null) return;
    final baseValue = _currentBaseValue();
    final settings = context.read<NumberFormatSettings>();
    final block = _registerBlock(_Block(unit));
    if (baseValue != null) {
      block.controller.text = settings.format(unit.fromBase(baseValue));
    }
    setState(() => _blocks.add(block));
  }

  Future<void> _changeUnit(_Block block) async {
    final settings = context.read<NumberFormatSettings>();
    final currentValue = settings.parse(block.controller.text) ?? double.tryParse(block.controller.text);
    final baseValue = currentValue != null ? block.unit.toBase(currentValue) : null;
    final newUnit = await _pickUnit();
    if (newUnit == null) return;
    setState(() {
      block.unit = newUnit;
      if (baseValue != null) {
        block.controller.text = settings.format(newUnit.fromBase(baseValue));
      }
    });
  }

  void _removeBlock(_Block block) {
    setState(() => _blocks.remove(block));
    block.dispose();
  }

  Future<ConverterUnit?> _pickUnit() async {
    var query = '';
    return showModalBottomSheet<ConverterUnit>(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            final filtered = widget.units.where((u) => u.label.toLowerCase().contains(query.toLowerCase())).toList();
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
                    child: ListView(
                      children: [
                        for (final unit in filtered)
                          ListTile(
                            title: Text(unit.label),
                            trailing: Text(unit.shortLabel, style: const TextStyle(color: AppColors.textSecondary)),
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
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                onReorder: (oldIndex, newIndex) {
                  setState(() {
                    if (newIndex > oldIndex) newIndex -= 1;
                    final item = _blocks.removeAt(oldIndex);
                    _blocks.insert(newIndex, item);
                  });
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          ReorderableDragStartListener(
            index: _blocks.indexOf(block),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Icon(Icons.drag_handle, color: AppColors.textSecondary),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () => _changeUnit(block),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            block.unit.label,
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Icon(Icons.arrow_drop_down, color: AppColors.textSecondary, size: 18),
                      ],
                    ),
                  ),
                ),
                TextField(
                  controller: block.controller,
                  focusNode: block.focusNode,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.\-]'))],
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                  decoration: InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.only(bottom: 10),
                    suffixText: block.unit.shortLabel,
                  ),
                  onChanged: (_) => _recalculateFrom(block),
                ),
              ],
            ),
          ),
          if (_blocks.length > 1)
            IconButton(
              icon: const Icon(Icons.close, size: 18, color: AppColors.textSecondary),
              onPressed: () => _removeBlock(block),
            ),
        ],
      ),
    );
  }
}
