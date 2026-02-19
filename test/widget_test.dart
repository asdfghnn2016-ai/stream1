// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_ui1/main.dart';

import 'package:provider/provider.dart';
import 'package:flutter_ui1/controllers/settings_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Splash screen rendering test', (WidgetTester tester) async {
    // Mock SharedPreferences
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => SettingsController()),
        ],
        child: const MyApp(),
      ),
    );

    // Verify Splash Screen elements
    expect(find.text('شوف TV'), findsOneWidget);
    expect(find.text('تخطي'), findsOneWidget);
  });
}
