import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:elevate_ai_fitness/main.dart';

void main() {
  testWidgets('App renders splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const ElevateApp(initialThemeMode: ThemeMode.system));
    await tester.pump();

    expect(find.text('Elevate'), findsOneWidget);
    expect(find.text('YOUR AI FITNESS COMPANION'), findsOneWidget);
  });
}
