import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linksy/main.dart';
import 'package:linksy/core/theme/theme_provider.dart';

void main() {
  testWidgets('Dashboard smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: ProviderContainer(
          overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        ),
        child: const MyBondsApp(),
      ),
    );

    // Initial pump might have some async operations (loading people)
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    // Verify that our app starts on the Reminders/Dashboard tab
    expect(find.text('Reminders'), findsWidgets);
  });
}
