// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:adoven/app/app.dart';
import 'package:adoven/app/providers.dart';
import 'package:adoven/core/config/app_config.dart';
import 'package:adoven/data/repositories/in_memory/in_memory_data_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const sampleReceipt = '''
Token:4355-3559-0886-3984-2146
Date:09 03 2026 16:01:05
Meter:07123102910
Amount:N\$1300.00
Units:514.40
Utility:City of Windhoek
Name:. .
Address:Erf# 812, TUGELA ST, WANA
CentsPerUnit:1219.15
VAT:N\$0.00
VAT No:254605-015
Receipt:1230896
''';

  testWidgets('user can sign in, create meter, add receipt, and view it',
      (WidgetTester tester) async {
    final store = InMemoryDataStore();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appConfigProvider.overrideWithValue(const AppConfig.demo()),
          inMemoryDataStoreProvider.overrideWithValue(store),
        ],
        child: const AdovenApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Sign In'), findsOneWidget);

    await tester.tap(find.text('Sign In'));
    await tester.pumpAndSettle();

    expect(find.text('Add Meter'), findsOneWidget);

    await tester.tap(find.text('Add Meter'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Label'),
      'Main meter',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Meter number'),
      '07123102910',
    );
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Main meter'), findsOneWidget);

    await tester.tap(find.text('Receipts'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Add Receipt'));
    await tester.pumpAndSettle();

    await tester.enterText(
        find.byKey(const Key('raw-receipt-input')), sampleReceipt);
    await tester.tap(find.text('Parse Receipt'));
    await tester.pumpAndSettle();

    expect(find.text('Token: ****************2146'), findsOneWidget);

    await tester.tap(find.text('Save Receipt'));
    await tester.pumpAndSettle();

    expect(find.text('Receipt 1230896 saved'), findsOneWidget);
    expect(find.text('Receipt: 1230896'), findsOneWidget);
  });
}
