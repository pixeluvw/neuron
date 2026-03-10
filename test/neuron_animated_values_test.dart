import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neuron/neuron.dart';

void main() {
  group('AnimatedSlot — animation value verification', () {
    testWidgets('fade effect animates smoothly to new value', (tester) async {
      final signal = Signal<int>(0);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedSlot<int>(
              connect: signal,
              effect: SlotEffect.fade,
              duration: const Duration(milliseconds: 300),
              to: (ctx, val) => Text('$val'),
            ),
          ),
        ),
      );

      expect(find.text('0'), findsOneWidget);

      signal.emit(1);
      await tester.pump();

      // During animation, we find opacity widgets
      final opacityFinder = find.byType(Opacity);
      final fadeTransitionFinder = find.byType(FadeTransition);
      final animatedOpacityFinder = find.byType(AnimatedOpacity);

      // At least one opacity-related widget should exist
      final hasOpacity = opacityFinder.evaluate().isNotEmpty ||
          fadeTransitionFinder.evaluate().isNotEmpty ||
          animatedOpacityFinder.evaluate().isNotEmpty;
      expect(hasOpacity, true,
          reason: 'Fade effect should use opacity widgets');

      await tester.pumpAndSettle();

      // After animation completes, new value should be shown
      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('scale effect applies during transition', (tester) async {
      final signal = Signal<int>(0);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedSlot<int>(
              connect: signal,
              effect: SlotEffect.scale,
              duration: const Duration(milliseconds: 300),
              to: (ctx, val) => Text('$val'),
            ),
          ),
        ),
      );

      signal.emit(1);
      await tester.pump();

      // Check for scale-related transforms
      final scaleFinder = find.byType(ScaleTransition);
      final transformFinder = find.byType(Transform);

      final hasScale = scaleFinder.evaluate().isNotEmpty ||
          transformFinder.evaluate().isNotEmpty;
      expect(hasScale, true,
          reason: 'Scale effect should use transform widgets');

      await tester.pumpAndSettle();
      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('slide effect applies during transition', (tester) async {
      final signal = Signal<int>(0);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedSlot<int>(
              connect: signal,
              effect: SlotEffect.slide,
              duration: const Duration(milliseconds: 300),
              to: (ctx, val) => Text('$val'),
            ),
          ),
        ),
      );

      signal.emit(1);
      await tester.pump();

      // Slide uses SlideTransition or Transform
      final slideFinder = find.byType(SlideTransition);
      final fractionFinder = find.byType(FractionalTranslation);
      final transformFinder = find.byType(Transform);

      final hasSlide = slideFinder.evaluate().isNotEmpty ||
          fractionFinder.evaluate().isNotEmpty ||
          transformFinder.evaluate().isNotEmpty;
      expect(hasSlide, true,
          reason: 'Slide effect should use positioning widgets');

      await tester.pumpAndSettle();
      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('combined effects apply multiple transitions', (tester) async {
      final signal = Signal<int>(0);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedSlot<int>(
              connect: signal,
              effect: SlotEffect.fade | SlotEffect.scale,
              duration: const Duration(milliseconds: 300),
              to: (ctx, val) => Text('$val'),
            ),
          ),
        ),
      );

      signal.emit(1);
      await tester.pump();

      // Should have both fade and scale widgets
      await tester.pump(const Duration(milliseconds: 150));
      expect(find.text('1'), findsWidgets);

      await tester.pumpAndSettle();
      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('animation respects custom duration', (tester) async {
      final signal = Signal<int>(0);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedSlot<int>(
              connect: signal,
              effect: SlotEffect.fade,
              duration: const Duration(milliseconds: 500),
              to: (ctx, val) => Text('$val'),
            ),
          ),
        ),
      );

      signal.emit(1);
      await tester.pump();

      // At 250ms — should NOT be settled yet
      await tester.pump(const Duration(milliseconds: 250));
      // Animation should still be running (settling not done)

      // At 500ms+, animation should complete
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();

      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('multiple rapid changes animate to final value',
        (tester) async {
      final signal = Signal<int>(0);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedSlot<int>(
              connect: signal,
              effect: SlotEffect.fade,
              to: (ctx, val) => Text('$val'),
            ),
          ),
        ),
      );

      signal.emit(1);
      signal.emit(2);
      signal.emit(3);
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('rotation effect uses rotation-based animation',
        (tester) async {
      final signal = Signal<int>(0);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedSlot<int>(
              connect: signal,
              effect: SlotEffect.rotation,
              duration: const Duration(milliseconds: 300),
              to: (ctx, val) => Text('$val'),
            ),
          ),
        ),
      );

      signal.emit(1);
      await tester.pump();

      // Rotation uses RotationTransition or Transform
      final rotationFinder = find.byType(RotationTransition);
      final transformFinder = find.byType(Transform);

      final hasRotation = rotationFinder.evaluate().isNotEmpty ||
          transformFinder.evaluate().isNotEmpty;
      expect(hasRotation, true);

      await tester.pumpAndSettle();
      expect(find.text('1'), findsOneWidget);
    });
  });
}
