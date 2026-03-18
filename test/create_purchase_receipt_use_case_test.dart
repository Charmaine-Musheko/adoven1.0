import 'package:adoven/application/use_cases/create_meter_use_case.dart';
import 'package:adoven/application/use_cases/create_purchase_receipt_use_case.dart';
import 'package:adoven/application/use_cases/parse_receipt_use_case.dart';
import 'package:adoven/data/repositories/in_memory/in_memory_audit_repository.dart';
import 'package:adoven/data/repositories/in_memory/in_memory_data_store.dart';
import 'package:adoven/data/repositories/in_memory/in_memory_meter_repository.dart';
import 'package:adoven/data/repositories/in_memory/in_memory_purchase_receipt_repository.dart';
import 'package:adoven/domain/entities/app_session.dart';
import 'package:adoven/domain/entities/meter.dart';
import 'package:adoven/domain/repositories/purchase_receipt_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const ownerUserId = 'user-1';
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

  late InMemoryDataStore store;
  late CreatePurchaseReceiptUseCase useCase;
  late CreateMeterUseCase createMeterUseCase;

  setUp(() {
    store = InMemoryDataStore();
    store.setSession(
      const AppSession(
        userId: ownerUserId,
        email: 'test@adoven.app',
        isDemoMode: true,
      ),
    );
    useCase = CreatePurchaseReceiptUseCase(
      meterRepository: InMemoryMeterRepository(store),
      purchaseReceiptRepository: InMemoryPurchaseReceiptRepository(store),
      auditRepository: InMemoryAuditRepository(store),
      parseReceiptUseCase: const ParseReceiptUseCase(),
    );
    createMeterUseCase = CreateMeterUseCase(InMemoryMeterRepository(store));
  });

  test('rejects duplicate receipts with the same idempotency key', () async {
    final meter = await createMeterUseCase.execute(
      ownerUserId: ownerUserId,
      propertyId: 'property-$ownerUserId',
      utilityType: UtilityType.electricity,
      meterNumber: '07123102910',
      label: 'Main meter',
    );

    await useCase.execute(
      ownerUserId: ownerUserId,
      meterId: meter.id,
      rawPayload: sampleReceipt,
    );

    expect(
      () => useCase.execute(
        ownerUserId: ownerUserId,
        meterId: meter.id,
        rawPayload: sampleReceipt,
      ),
      throwsA(isA<DuplicateReceiptException>()),
    );
  });
}
