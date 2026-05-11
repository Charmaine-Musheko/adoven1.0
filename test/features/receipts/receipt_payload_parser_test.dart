import 'package:adoven/features/receipts/domain/services/receipt_payload_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ReceiptPayloadParser', () {
    test('parses the provided receipt sample correctly', () {
      const rawPayload = '''
- Token:4355-3559-0886-3984-2146
- Date:09 03 2026 16:01:05
- Meter:07123102910
- Amount:N\$1300.00
- Units:514.40
- Utility:City of Windhoek
- Name:. .
- Address:Erf# 812, TUGELA ST, WANA
- CentsPerUnit:1219.15
- VAT:N\$0.00
- VAT No:254605-015
- Receipt:1230896
''';

      final parser = ReceiptPayloadParser();
      final parsed = parser.parse(meterId: '42', rawPayload: rawPayload);

      expect(parsed.meterId, '42');
      expect(parsed.meterNumber, '07123102910');
      expect(parsed.token, '4355-3559-0886-3984-2146');
      expect(parsed.receiptNumber, '1230896');
      expect(parsed.utilityProvider, 'City of Windhoek');
      expect(parsed.amount.toString(), '1300');
      expect(parsed.units.toString(), '514.4');
      expect(parsed.centsPerUnit.toString(), '1219.15');
      expect(parsed.vatAmount?.toString(), '0');
      expect(parsed.vatNumber, '254605-015');
      expect(parsed.customerName, isNull);
      expect(parsed.address, 'Erf# 812, TUGELA ST, WANA');
      expect(parsed.idempotencyKey, isNotEmpty);
    });
  });
}
