import 'package:adoven/app/app.dart';
import 'package:adoven/app/providers.dart';
import 'package:adoven/core/config/app_config.dart';
import 'package:adoven/data/repositories/in_memory/in_memory_data_store.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('receipt flow integration smoke test', (tester) async {
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
  });
}
