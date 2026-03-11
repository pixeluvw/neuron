import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neuron/neuron.dart';

void main() {
  group('Slot', () {
    testWidgets('renders initial value', (tester) async {
      final count = Signal<int>(0);

      await tester.pumpWidget(
        MaterialApp(
          home: Slot<int>(connect: count, to: (ctx, val) => Text('$val')),
        ),
      );

      expect(find.text('0'), findsOneWidget);
    });

    testWidgets('rebuilds when signal emits', (tester) async {
      final count = Signal<int>(0);

      await tester.pumpWidget(
        MaterialApp(
          home: Slot<int>(connect: count, to: (ctx, val) => Text('$val')),
        ),
      );

      count.emit(42);
      await tester.pump();

      expect(find.text('42'), findsOneWidget);
    });

    testWidgets('does not rebuild when same value emitted', (tester) async {
      final count = Signal<int>(5);
      var buildCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Slot<int>(
            connect: count,
            to: (ctx, val) {
              buildCount++;
              return Text('$val');
            },
          ),
        ),
      );

      final initialBuildCount = buildCount;
      count.emit(5); // same value
      await tester.pump();

      expect(buildCount, initialBuildCount);
    });

    testWidgets('updates across multiple rapid signal changes', (tester) async {
      final count = Signal<int>(0);

      await tester.pumpWidget(
        MaterialApp(
          home: Slot<int>(
            connect: count,
            to: (ctx, val) => Text('$val'),
          ),
        ),
      );

      count.emit(1);
      count.emit(2);
      count.emit(3);
      await tester.pump();

      expect(find.text('3'), findsOneWidget);
    });
  });

  group('AsyncSlot', () {
    testWidgets('shows loading state initially', (tester) async {
      final signal = AsyncSignal<String>(null);

      await tester.pumpWidget(
        MaterialApp(
          home: AsyncSlot<String>(
            connect: signal,
            onLoading: (ctx) => const Text('Loading...'),
            onData: (ctx, data) => Text('Data: $data'),
            onError: (ctx, err) => Text('Error: $err'),
          ),
        ),
      );

      expect(find.text('Loading...'), findsOneWidget);
    });

    testWidgets('shows data after execute completes', (tester) async {
      final signal = AsyncSignal<String>(null);
      signal.execute(() => Future.value('Hello'));

      await tester.pumpWidget(
        MaterialApp(
          home: AsyncSlot<String>(
            connect: signal,
            onLoading: (ctx) => const Text('Loading...'),
            onData: (ctx, data) => Text('Data: $data'),
            onError: (ctx, err) => Text('Error: $err'),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Data: Hello'), findsOneWidget);
    });

    testWidgets('shows error when future fails', (tester) async {
      final signal = AsyncSignal<String>(null);
      signal.execute(() => Future.error('Oops'));

      await tester.pumpWidget(
        MaterialApp(
          home: AsyncSlot<String>(
            connect: signal,
            onLoading: (ctx) => const Text('Loading...'),
            onData: (ctx, data) => Text('Data: $data'),
            onError: (ctx, err) => Text('Error: $err'),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Error: Oops'), findsOneWidget);
    });
  });

  group('SelectSlot', () {
    testWidgets('only rebuilds when selected part changes', (tester) async {
      final user = Signal<Map<String, dynamic>>({
        'name': 'Alice',
        'age': 25,
      });
      var buildCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: SelectSlot<Map<String, dynamic>, String>(
            connect: user,
            select: (u) => u['name'] as String,
            to: (ctx, name) {
              buildCount++;
              return Text(name);
            },
          ),
        ),
      );

      expect(find.text('Alice'), findsOneWidget);
      final initialBuild = buildCount;

      // Change age only — name unchanged
      user.emit({'name': 'Alice', 'age': 30});
      await tester.pump();

      expect(buildCount, initialBuild,
          reason: 'Should not rebuild — name unchanged');

      // Change name
      user.emit({'name': 'Bob', 'age': 30});
      await tester.pump();

      expect(find.text('Bob'), findsOneWidget);
    });
  });

  group('AnimatedSlot lifecycle', () {
    testWidgets('renders initial value without animation', (tester) async {
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

      expect(find.text('0'), findsOneWidget);
    });

    testWidgets('transitions when signal changes', (tester) async {
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
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('cleans up listeners on dispose', (tester) async {
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

      // Dispose by removing from tree
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: SizedBox()),
        ),
      );

      // Signal should still work without crashing
      signal.emit(99);
      expect(signal.val, 99);
    });

    testWidgets('combined effects work', (tester) async {
      final signal = Signal<int>(0);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedSlot<int>(
              connect: signal,
              effect: SlotEffect.fade | SlotEffect.scale | SlotEffect.slide,
              to: (ctx, val) => Text('$val'),
            ),
          ),
        ),
      );

      signal.emit(1);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('1'), findsOneWidget);
      await tester.pumpAndSettle();
    });

    testWidgets('custom duration is applied', (tester) async {
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

      // At 250ms, animation should still be in progress
      await tester.pump(const Duration(milliseconds: 250));
      // At 500ms+, it should be complete
      await tester.pumpAndSettle();

      expect(find.text('1'), findsOneWidget);
    });
  });

  group('MultiSlot', () {
    testWidgets('t2 renders with two signals', (tester) async {
      final name = Signal<String>('Alice');
      final age = Signal<int>(25);

      await tester.pumpWidget(
        MaterialApp(
          home: MultiSlot.t2(
            connect: (name, age),
            to: (ctx, v1, v2) => Text('$v1 is $v2'),
          ),
        ),
      );

      expect(find.text('Alice is 25'), findsOneWidget);
    });

    testWidgets('t2 rebuilds when any signal changes', (tester) async {
      final name = Signal<String>('Alice');
      final age = Signal<int>(25);

      await tester.pumpWidget(
        MaterialApp(
          home: MultiSlot.t2(
            connect: (name, age),
            to: (ctx, v1, v2) => Text('$v1 is $v2'),
          ),
        ),
      );

      age.emit(26);
      await tester.pump();

      expect(find.text('Alice is 26'), findsOneWidget);

      name.emit('Bob');
      await tester.pump();

      expect(find.text('Bob is 26'), findsOneWidget);
    });

    testWidgets('t3 renders with three signals', (tester) async {
      final a = Signal<int>(1);
      final b = Signal<int>(2);
      final c = Signal<int>(3);

      await tester.pumpWidget(
        MaterialApp(
          home: MultiSlot.t3(
            connect: (a, b, c),
            to: (ctx, v1, v2, v3) => Text('$v1+$v2+$v3=${v1 + v2 + v3}'),
          ),
        ),
      );

      expect(find.text('1+2+3=6'), findsOneWidget);
    });

    testWidgets('cleans up on dispose', (tester) async {
      final a = Signal<int>(0);
      final b = Signal<String>('ok');

      await tester.pumpWidget(
        MaterialApp(
          home: MultiSlot.t2(
            connect: (a, b),
            to: (ctx, v1, v2) => Text('$v1-$v2'),
          ),
        ),
      );

      // Remove from tree
      await tester.pumpWidget(
        const MaterialApp(home: SizedBox()),
      );

      // Should not crash
      a.emit(99);
      b.emit('gone');
    });
  });

  group('Computed reactivity with Slot', () {
    testWidgets('Slot rebuilds when Computed dependency changes',
        (tester) async {
      final count = Signal<int>(2);
      final doubled = Computed(() => count.val * 2);

      await tester.pumpWidget(
        MaterialApp(
          home: Slot<int>(
            connect: doubled,
            to: (ctx, val) => Text('$val'),
          ),
        ),
      );

      expect(find.text('4'), findsOneWidget);

      count.emit(5);
      await tester.pump();

      expect(find.text('10'), findsOneWidget);
    });
  });

  group('Computed edge cases', () {
    test('computes value on construction and tracks dependencies', () {
      var computeCount = 0;
      final count = Signal<int>(5);
      final doubled = Computed(() {
        computeCount++;
        return count.val * 2;
      });

      // Computes during construction (initial + dependency tracking)
      expect(computeCount, greaterThanOrEqualTo(1));
      expect(doubled.value, 10);
    });

    test('auto-tracks multiple dependencies', () {
      final a = Signal<int>(1);
      final b = Signal<int>(2);
      final sum = Computed(() => a.val + b.val);

      expect(sum.value, 3);

      a.emit(10);
      expect(sum.value, 12);

      b.emit(20);
      expect(sum.value, 30);
    });

    test('notifies listeners when dependency changes', () {
      final a = Signal<int>(1);
      final doubled = Computed(() => a.val * 2);
      var notified = false;
      doubled.addListener(() => notified = true);

      a.emit(5);
      expect(notified, true);
      expect(doubled.value, 10);
    });
  });
}
