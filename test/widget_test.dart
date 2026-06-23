import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_earth_map/main.dart';
import 'package:live_earth_map/spalsh/spalsh_screen.dart';

void main() {
  testWidgets('App starts with SplashScreen', (WidgetTester tester) async {
    // Build our app wrapped in ProviderScope and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: MyApp(),
      ),
    );

    // Verify that SplashScreen is rendered initially
    expect(find.byType(SplashScreen), findsOneWidget);
    expect(find.byType(Scaffold), findsOneWidget);

    // Settle the pending splash timer so it goes to the OnboardingScreen
    await tester.pumpAndSettle(const Duration(seconds: 2));
  });
}

