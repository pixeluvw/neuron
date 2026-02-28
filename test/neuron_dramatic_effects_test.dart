import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neuron/neuron.dart';

void main() {
  group('Dramatic Effects in AnimatedSlot', () {
    testWidgets('wobble effect should apply RotationTransition',
        (WidgetTester tester) async {
      final signal = Signal<int>(0);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedSlot<int>(
              connect: signal,
              effect: SlotEffect.wobble,
              to: (context, value) => Text('$value'),
            ),
          ),
        ),
      );

      expect(find.text('0'), findsOneWidget);

      // Trigger animation
      signal.value = 1;
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('swing effect should apply AnimatedBuilder with Transform',
        (WidgetTester tester) async {
      final signal = Signal<int>(0);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedSlot<int>(
              connect: signal,
              effect: SlotEffect.swing,
              to: (context, value) => Text('$value'),
            ),
          ),
        ),
      );

      expect(find.text('0'), findsOneWidget);

      // Trigger animation
      signal.value = 1;
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('shake effect should apply SlideTransition',
        (WidgetTester tester) async {
      final signal = Signal<int>(0);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedSlot<int>(
              connect: signal,
              effect: SlotEffect.shake,
              to: (context, value) => Text('$value'),
            ),
          ),
        ),
      );

      expect(find.text('0'), findsOneWidget);

      // Trigger animation
      signal.value = 1;
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('bounce effect should apply ScaleTransition with bounceOut',
        (WidgetTester tester) async {
      final signal = Signal<int>(0);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedSlot<int>(
              connect: signal,
              effect: SlotEffect.bounce,
              to: (context, value) => Text('$value'),
            ),
          ),
        ),
      );

      expect(find.text('0'), findsOneWidget);

      // Trigger animation
      signal.value = 1;
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('elastic effect should apply ScaleTransition with elasticOut',
        (WidgetTester tester) async {
      final signal = Signal<int>(0);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedSlot<int>(
              connect: signal,
              effect: SlotEffect.elastic,
              to: (context, value) => Text('$value'),
            ),
          ),
        ),
      );

      expect(find.text('0'), findsOneWidget);

      // Trigger animation
      signal.value = 1;
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('pulse effect should apply ScaleTransition from 0.85 to 1.0',
        (WidgetTester tester) async {
      final signal = Signal<int>(0);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedSlot<int>(
              connect: signal,
              effect: SlotEffect.pulse,
              to: (context, value) => Text('$value'),
            ),
          ),
        ),
      );

      expect(find.text('0'), findsOneWidget);

      // Trigger animation
      signal.value = 1;
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('dramatic effects can be combined with other effects',
        (WidgetTester tester) async {
      final signal = Signal<int>(0);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedSlot<int>(
              connect: signal,
              effect: SlotEffect.bounce | SlotEffect.fade,
              to: (context, value) => Text('$value'),
            ),
          ),
        ),
      );

      expect(find.text('0'), findsOneWidget);

      // Trigger animation
      signal.value = 1;
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('all dramatic effects can be applied individually',
        (WidgetTester tester) async {
      final effects = [
        SlotEffect.wobble,
        SlotEffect.swing,
        SlotEffect.shake,
        SlotEffect.bounce,
        SlotEffect.elastic,
        SlotEffect.pulse,
      ];

      for (final effect in effects) {
        final signal = Signal<int>(0);

        await tester.pumpWidget(
          MaterialApp(
            key: UniqueKey(),
            home: Scaffold(
              body: AnimatedSlot<int>(
                key: UniqueKey(),
                connect: signal,
                effect: effect,
                to: (context, value) => Text('$value'),
              ),
            ),
          ),
        );

        expect(find.text('0'), findsOneWidget);

        // Trigger animation
        signal.value = 1;
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50));

        expect(find.text('1'), findsOneWidget);

        // Complete animation
        await tester.pumpAndSettle();
      }
    });
  });
}
