// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:neuron_examples/pages/home_page.dart';

void main() {
  testWidgets('App loads home page', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    // Use MaterialApp directly to avoid NeuronApp's devtools timers in tests
    await tester.pumpWidget(
      const MaterialApp(
        home: HomePage(),
      ),
    );

    // Verify that the home page loads with the title
    expect(find.text('AnimatedSlot'), findsOneWidget);
    expect(find.text('Interactive Examples'), findsOneWidget);
  });
}
