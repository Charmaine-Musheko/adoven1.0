import 'package:adoven/application/use_cases/parse_receipt_use_case.dart';
import 'package:adoven/core/logging/redacted_logger.dart';
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

  test('parses the sample receipt contract without losing leading zeros', () {
    const useCase = ParseReceiptUseCase();

    final parsed = useCase.execute(sampleReceipt);

    expect(parsed.meterNumber, '07123102910');
    expect(parsed.amount.minorUnits, 130000);
    expect(parsed.unitsPurchased, '514.40');
    expect(parsed.receiptNumber, '1230896');
    expect(parsed.token, '4355-3559-0886-3984-2146');
  });

  test('masks tokens in logs and UI previews', () {
    expect(
      RedactedLogger.maskToken('4355-3559-0886-3984-2146'),
      '****************2146',
    );
  });
}
