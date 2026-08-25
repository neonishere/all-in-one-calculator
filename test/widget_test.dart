import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:allinone_calculator/app.dart';
import 'package:allinone_calculator/core/currency/currency_repository.dart';
import 'package:allinone_calculator/core/history/history_store.dart';
import 'package:allinone_calculator/core/settings/favorites_store.dart';
import 'package:allinone_calculator/core/settings/number_format_settings.dart';
import 'package:allinone_calculator/core/settings/theme_settings.dart';

void main() {
  Widget buildApp() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CurrencyRepository()),
        ChangeNotifierProvider(create: (_) => NumberFormatSettings()),
        ChangeNotifierProvider(create: (_) => ThemeSettings()),
        ChangeNotifierProvider(create: (_) => FavoritesStore()),
        ChangeNotifierProvider(create: (_) => HistoryStore()),
      ],
      child: const CalcApp(),
    );
  }

  testWidgets('basic calculator evaluates an expression', (WidgetTester tester) async {
    await tester.pumpWidget(buildApp());

    for (final key in ['1', '2', '+', '8']) {
      await tester.tap(find.text(key));
      await tester.pump();
    }
    await tester.tap(find.text('='));
    await tester.pump();

    expect(find.text('20'), findsOneWidget);
  });

  testWidgets('grid icon opens the all-tools menu', (WidgetTester tester) async {
    await tester.pumpWidget(buildApp());

    await tester.tap(find.byIcon(Icons.grid_view_rounded));
    await tester.pumpAndSettle();

    expect(find.text('All tools'), findsOneWidget);
    expect(find.text('Percentage'), findsOneWidget);
  });
}
