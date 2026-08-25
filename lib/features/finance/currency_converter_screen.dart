import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/currency/currency_repository.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/number_field.dart';
import '../../shared/widgets/result_value_card.dart';
import '../../shared/widgets/tool_scaffold.dart';

class CurrencyConverterScreen extends StatefulWidget {
  const CurrencyConverterScreen({super.key});

  @override
  State<CurrencyConverterScreen> createState() => _CurrencyConverterScreenState();
}

class _CurrencyConverterScreenState extends State<CurrencyConverterScreen> {
  final _valueController = TextEditingController(text: '1');
  String? _from;
  String? _to;

  @override
  void initState() {
    super.initState();
    final repo = context.read<CurrencyRepository>();
    repo.loadCached().then((_) {
      if (repo.rates.isEmpty) repo.refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<CurrencyRepository>();
    final codes = repo.rates.keys.toList()..sort();
    _from ??= codes.contains('USD') ? 'USD' : (codes.isNotEmpty ? codes.first : null);
    _to ??= codes.contains('EUR') ? 'EUR' : (codes.length > 1 ? codes[1] : null);

    final value = double.tryParse(_valueController.text);
    final result = (value != null && _from != null && _to != null)
        ? repo.convert(from: _from!, to: _to!, amount: value)
        : null;

    return ToolScaffold(
      title: 'Currency converter',
      children: [
        if (repo.status == CurrencyFetchStatus.missingKey)
          _statusBanner('Add a free exchangerate-api.com key in lib/core/config/api_config.dart to enable live rates.')
        else if (repo.status == CurrencyFetchStatus.error)
          _statusBanner('Could not fetch live rates (${repo.errorMessage ?? 'unknown error'}). Showing cached data if available.')
        else if (repo.status == CurrencyFetchStatus.loading)
          const Padding(padding: EdgeInsets.only(bottom: 14), child: LinearProgressIndicator()),
        NumberField(label: 'Amount', controller: _valueController, onChanged: (_) => setState(() {})),
        if (codes.isNotEmpty)
          Row(
            children: [
              Expanded(child: _codeDropdown(codes, _from, (v) => setState(() => _from = v))),
              Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: Icon(Icons.arrow_forward, color: AppColors.textSecondary)),
              Expanded(child: _codeDropdown(codes, _to, (v) => setState(() => _to = v))),
            ],
          ),
        ResultValueCard(value: result),
        const SizedBox(height: 12),
        TextButton.icon(
          onPressed: repo.status == CurrencyFetchStatus.loading ? null : () => repo.refresh(),
          icon: const Icon(Icons.refresh),
          label: Text(repo.fetchedAt == null ? 'Fetch live rates' : 'Refresh (updated ${repo.fetchedAt!.toLocal().toString().substring(0, 16)})'),
        ),
      ],
    );
  }

  Widget _statusBanner(String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.surfaceAlt, borderRadius: BorderRadius.circular(12)),
      child: Text(text, style: TextStyle(color: AppColors.textSecondary)),
    );
  }

  Widget _codeDropdown(List<String> codes, String? selected, ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      initialValue: selected,
      isExpanded: true,
      dropdownColor: AppColors.surface,
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
      items: [for (final c in codes) DropdownMenuItem(value: c, child: Text(c))],
      onChanged: onChanged,
    );
  }
}
