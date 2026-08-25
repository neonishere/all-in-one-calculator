import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../config/api_config.dart';

enum CurrencyFetchStatus { idle, loading, ready, error, missingKey }

/// Holds exchange rates for a single base currency, fetched from
/// exchangerate-api.com and cached locally so the converter keeps working offline.
class CurrencyRepository extends ChangeNotifier {
  static const _cachedRatesKey = 'currency_rates_v1';
  static const _cachedBaseKey = 'currency_base_v1';
  static const _cachedAtKey = 'currency_fetched_at_v1';

  Map<String, double> _rates = {};
  String _base = 'USD';
  DateTime? _fetchedAt;
  CurrencyFetchStatus _status = CurrencyFetchStatus.idle;
  String? _errorMessage;

  Map<String, double> get rates => _rates;
  String get base => _base;
  DateTime? get fetchedAt => _fetchedAt;
  CurrencyFetchStatus get status => _status;
  String? get errorMessage => _errorMessage;

  Future<void> loadCached() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_cachedRatesKey);
    if (raw == null) return;
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    _rates = decoded.map((k, v) => MapEntry(k, (v as num).toDouble()));
    _base = prefs.getString(_cachedBaseKey) ?? 'USD';
    final at = prefs.getString(_cachedAtKey);
    _fetchedAt = at != null ? DateTime.tryParse(at) : null;
    _status = CurrencyFetchStatus.ready;
    notifyListeners();
  }

  Future<void> refresh({String base = 'USD'}) async {
    if (exchangeRateApiKey.isEmpty) {
      _status = CurrencyFetchStatus.missingKey;
      notifyListeners();
      return;
    }

    _status = CurrencyFetchStatus.loading;
    notifyListeners();

    try {
      final uri = Uri.parse(
        'https://v6.exchangerate-api.com/v6/$exchangeRateApiKey/latest/$base',
      );
      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      final body = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode != 200 || body['result'] != 'success') {
        _status = CurrencyFetchStatus.error;
        _errorMessage = body['error-type']?.toString() ?? 'Request failed';
        notifyListeners();
        return;
      }

      final conversionRates = body['conversion_rates'] as Map<String, dynamic>;
      _rates = conversionRates.map((k, v) => MapEntry(k, (v as num).toDouble()));
      _base = base;
      _fetchedAt = DateTime.now();
      _status = CurrencyFetchStatus.ready;
      _errorMessage = null;
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cachedRatesKey, jsonEncode(_rates));
      await prefs.setString(_cachedBaseKey, _base);
      await prefs.setString(_cachedAtKey, _fetchedAt!.toIso8601String());
    } catch (e) {
      _status = CurrencyFetchStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  double? convert({required String from, required String to, required double amount}) {
    if (_rates.isEmpty) return null;
    final fromRate = from == _base ? 1.0 : _rates[from];
    final toRate = to == _base ? 1.0 : _rates[to];
    if (fromRate == null || toRate == null) return null;
    final amountInBase = amount / fromRate;
    return amountInBase * toRate;
  }
}
