import 'package:adoven/core/errors/app_exception.dart';
import 'package:adoven/features/receipts/application/receipt_service.dart';
import 'package:adoven/features/receipts/domain/entities/create_purchase_receipt_input.dart';
import 'package:adoven/features/receipts/domain/entities/purchase_receipt.dart';
import 'package:adoven/features/receipts/domain/entities/receipt_filter.dart';
import 'package:adoven/features/receipts/domain/repositories/purchase_receipt_repository.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakePurchaseReceiptRepository implements PurchaseReceiptRepository {
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
  group('ReceiptService', () {
    test('rejects negative values', () async {
      final repository = _FakePurchaseReceiptRepository();
      final service = ReceiptService(repository);

      final input = CreatePurchaseReceiptInput(
        meterId: '1',
        meterNumber: '07123102910',
        token: '1234',
        receiptNumber: '111',
        purchaseTimestamp: DateTime(2026, 3, 9),
        amount: Decimal.parse('-1'),
        units: Decimal.parse('1'),
        utilityProvider: 'City of Windhoek',
        centsPerUnit: Decimal.parse('1219.15'),
        idempotencyKey: 'key',
      );

      expect(
        () => service.createReceipt(input),
        throwsA(isA<AppException>()),
      );
    });

    test('parses raw receipts through the use case', () {
      final repository = _FakePurchaseReceiptRepository();
      final service = ReceiptService(repository);

      const rawPayload = '''
Token:4355-3559-0886-3984-2146
Date:09 03 2026 16:01:05
Meter:07123102910
Amount:N\$1300.00
Units:514.40
Utility:City of Windhoek
CentsPerUnit:1219.15
Receipt:1230896
''';

      final parsed = service.parseRawReceipt(meterId: '4', rawPayload: rawPayload);

      expect(parsed.meterNumber, '07123102910');
      expect(parsed.amount.toString(), '1300');
      expect(parsed.receiptNumber, '1230896');
    });
  });
}
