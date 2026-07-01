import 'package:aaochat_sip/src/providers/theme_provider.dart';
import 'package:aaochat_sip/src/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('Splash shows app branding', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeProvider().currentTheme,
        home: const Splashscreen(),
      ),
    );
    expect(find.text('Aao VOIP'), findsOneWidget);
  });
}
