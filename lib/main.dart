import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'core/currency/currency_repository.dart';
import 'core/settings/number_format_settings.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CurrencyRepository()),
        ChangeNotifierProvider(create: (_) => NumberFormatSettings()..load()),
      ],
      child: const CalcApp(),
    ),
  );
}
