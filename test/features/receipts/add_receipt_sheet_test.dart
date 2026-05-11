import 'package:adoven/features/receipts/presentation/widgets/add_receipt_sheet.dart';
import 'package:adoven/features/utilities/domain/entities/meter.dart';
import 'package:adoven/features/utilities/domain/entities/utility_type.dart';
import 'package:adoven/features/utilities/presentation/providers/utility_meter_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows receipt guidance and defaults', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          availableMetersProvider.overrideWith(
            (ref) async => [
              UtilityMeter(
                id: '2',
                propertyId: '1',
                utilityType: UtilityType.electricity,
                meterNumber: 'ELEC-9912',
                isActive: true,
              ),
            ],
          ),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: AddReceiptSheet(),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Quick start'), findsOneWidget);
    expect(find.text('Use Sample Receipt'), findsOneWidget);
    expect(find.text('Parse Sample'), findsOneWidget);
    expect(find.text('Electricity • ELEC-9912'), findsOneWidget);
    expect(find.textContaining('1234-5678-9012-3456-7890'), findsOneWidget);
  });
}
