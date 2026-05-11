import 'package:adoven/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:adoven/features/utilities/domain/entities/utility_meter_summary.dart';
import 'package:adoven/features/utilities/domain/entities/utility_type.dart';
import 'package:adoven/features/utilities/presentation/providers/utility_meter_providers.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('dashboard shows utility experience', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          meterSummariesProvider.overrideWith(
            (ref) async => [
              UtilityMeterSummary(
                id: '1',
                propertyId: '1',
                propertyLabel: 'Flat 7, Windhoek West',
                utilityType: UtilityType.electricity,
                meterNumber: 'ELEC-9912',
                isActive: true,
                totalPurchasedUnits: Decimal.parse('412.000'),
                totalUsedUnits: Decimal.parse('120.000'),
                latestAvailableUnits: Decimal.parse('292.000'),
                latestAvailableUnitsAt: DateTime(2026, 4, 6, 8, 30),
                latestReadingValue: Decimal.parse('1334.900'),
                previousReadingValue: Decimal.parse('1280.400'),
                latestReadingAt: DateTime(2026, 4, 6, 8, 30),
                previousReadingAt: DateTime(2026, 4, 1, 8, 30),
                latestPurchaseAt: DateTime(2026, 4, 3, 8, 15),
              ),
            ],
          ),
        ],
        child: const MaterialApp(
          home: DashboardScreen(),
        ),
      ),
    );

    await tester.pump();

    expect(find.text('Home'), findsOneWidget);
    expect(
        find.text('Your meters are now the starting point.'), findsOneWidget);
    expect(find.text('Electricity meter'), findsOneWidget);
    expect(find.text('Running up'), findsAtLeastNWidgets(1));
  });
}
