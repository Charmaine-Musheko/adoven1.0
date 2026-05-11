import 'package:adoven/features/receipts/domain/entities/receipt_filter.dart';
import 'package:adoven/features/receipts/domain/entities/purchase_receipt.dart';
import 'package:adoven/features/receipts/domain/repositories/purchase_receipt_repository.dart';
import 'package:adoven/features/receipts/presentation/providers/receipt_providers.dart';
import 'package:adoven/features/receipts/presentation/screens/receipts_screen.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _StubRepository implements PurchaseReceiptRepository {
  _StubRepository(this.items);

  final List<PurchaseReceipt> items;

  @override
  Future<void> createReceipt(input) async {}

  @override
  Future<List<PurchaseReceipt>> listReceipts({
    ReceiptFilter filter = const ReceiptFilter(),
  }) async {
    if (filter.query.trim().isEmpty) {
      return items;
    }
    final query = filter.query.toLowerCase();
    return items
        .where(
          (receipt) =>
              receipt.utilityProvider.toLowerCase().contains(query) ||
              receipt.meterNumber.contains(query) ||
              receipt.receiptNumber.contains(query),
        )
        .toList();
  }
}

void main() {
  testWidgets('shows saved receipt details', (tester) async {
    final repository = _StubRepository([
      PurchaseReceipt(
        id: '1',
        meterId: '7',
        meterNumber: '07123102910',
        token: '4355-3559-0886-3984-2146',
        receiptNumber: '1230896',
        purchaseTimestamp: DateTime(2026, 3, 9, 16, 1, 5),
        amount: Decimal.parse('1300.00'),
        units: Decimal.parse('514.40'),
        utilityProvider: 'City of Windhoek',
        centsPerUnit: Decimal.parse('1219.15'),
      ),
    ]);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          purchaseReceiptRepositoryProvider.overrideWithValue(repository),
        ],
        child: const MaterialApp(home: ReceiptsScreen()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Receipts'), findsOneWidget);
    expect(find.text('City of Windhoek'), findsOneWidget);
    expect(find.textContaining('Receipt 1230896'), findsOneWidget);
    expect(find.textContaining('Token '), findsOneWidget);
    expect(find.textContaining('2146'), findsOneWidget);
  });
}
