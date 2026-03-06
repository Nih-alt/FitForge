import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fitforge/main.dart';

void main() {
  testWidgets('App renders splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const FitForgeApp(initialThemeMode: ThemeMode.system));
    await tester.pump();

    expect(find.text('FitForge'), findsOneWidget);
    expect(find.text('FORGE YOUR BEST SELF'), findsOneWidget);
  });
}
