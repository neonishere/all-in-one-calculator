import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'core/currency/currency_repository.dart';
import 'core/history/history_store.dart';
import 'core/settings/favorites_store.dart';
import 'core/settings/number_format_settings.dart';
import 'core/settings/theme_settings.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CurrencyRepository()),
        ChangeNotifierProvider(create: (_) => NumberFormatSettings()..load()),
        ChangeNotifierProvider(create: (_) => ThemeSettings()..load()),
        ChangeNotifierProvider(create: (_) => FavoritesStore()..load()),
        ChangeNotifierProvider(create: (_) => HistoryStore()..load()),
      ],
      child: const CalcApp(),
    ),
  );
}
