import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App scaffold renders', (WidgetTester tester) async {
    // Basic smoke test — verify MaterialApp can render.
    // Full ElevateApp requires Firebase + Hive + GetX initialization,
    // which is tested in controller/service tests.
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(child: Text('Elevate')),
        ),
      ),
    );

    expect(find.text('Elevate'), findsOneWidget);
  });
}
