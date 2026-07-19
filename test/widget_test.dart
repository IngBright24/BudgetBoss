import 'package:flutter_test/flutter_test.dart';
import 'package:budget_boss/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('BudgetBoss initial smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: BudgetBossApp(),
      ),
    );

    // Verify that the welcome text is present.
    expect(find.text('Welcome to BudgetBoss'), findsOneWidget);
  });
}
