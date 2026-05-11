import 'package:adoven/features/receipts/domain/entities/create_purchase_receipt_input.dart';
import 'package:adoven/features/receipts/domain/entities/purchase_receipt.dart';
import 'package:adoven/features/receipts/domain/entities/receipt_filter.dart';
import 'package:adoven/features/receipts/domain/repositories/purchase_receipt_repository.dart';
import 'package:adoven/features/receipts/presentation/providers/receipt_providers.dart';
import 'package:adoven/features/receipts/presentation/screens/receipts_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

class _MemoryRepository implements PurchaseReceiptRepository {
  final List<CreatePurchaseReceiptInput> created = [];

  @override
  Future<void> createReceipt(CreatePurchaseReceiptInput input) async {
    created.add(input);
  }

  @override
  Future<List<PurchaseReceipt>> listReceipts({
    ReceiptFilter filter = const ReceiptFilter(),
  }) async {
    return [];
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('user can parse and submit a receipt', (tester) async {
    final repository = _MemoryRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          purchaseReceiptRepositoryProvider.overrideWithValue(repository),
        ],
        child: const MaterialApp(home: ReceiptsScreen()),
      ),
    );

    await tester.pumpAndSettle();
    await tester.tap(find.text('Add Receipt'));
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextFormField, 'Meter ID'), '1');
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Raw Receipt Payload'),
      '''
Token:4355-3559-0886-3984-2146
Date:09 03 2026 16:01:05
Meter:07123102910
Amount:N\$1300.00
Units:514.40
Utility:City of Windhoek
CentsPerUnit:1219.15
Receipt:1230896
''',
    );

    await tester.tap(find.text('Parse Receipt'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Save Receipt'),
      200,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(find.text('Save Receipt'));
    await tester.pumpAndSettle();

    expect(repository.created, hasLength(1));
    expect(repository.created.single.meterId, '1');
    expect(repository.created.single.meterNumber, '07123102910');
    expect(repository.created.single.receiptNumber, '1230896');
  });
}
