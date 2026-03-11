import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:neuron/neuron.dart';

void main() {
  group('SignalUtils', () {
    test('fromStream creates signal that updates from stream', () async {
      final controller = StreamController<int>();
      final signal = SignalUtils.fromStream(controller.stream, 0);

      expect(signal.val, 0);

      controller.add(42);
      await Future.delayed(Duration.zero);

      expect(signal.val, 42);

      await controller.close();
    });

    test('fromFuture creates async signal from future', () async {
      final signal = SignalUtils.fromFuture(Future.value(42));

      // Initially loading
      expect(signal.state.isLoading, true);

      await Future.delayed(const Duration(milliseconds: 50));

      expect(signal.state.hasData, true);
      expect((signal.state as AsyncData<int>).value, 42);
    });

    test('bind synchronizes two signals bidirectionally', () async {
      final a = Signal<int>(0);
      final b = Signal<int>(0);

      SignalUtils.bind(a, b);

      a.emit(5);
      await Future.delayed(Duration.zero);
      expect(b.val, 5);

      b.emit(10);
      await Future.delayed(Duration.zero);
      expect(a.val, 10);
    });

    test('lazy creates signal with initializer result', () {
      var called = false;
      final signal = SignalUtils.lazy(() {
        called = true;
        return 42;
      });

      expect(called, true);
      expect(signal.val, 42);
    });

    test('waitFor resolves when condition is already met', () async {
      final signal = Signal<int>(10);

      final result = await SignalUtils.waitFor(signal, (v) => v > 5);
      expect(result, 10);
    });

    test('waitFor resolves when condition becomes true', () async {
      final signal = Signal<int>(0);

      final future = SignalUtils.waitFor(signal, (v) => v >= 5);

      // Fire after a small delay
      Future.delayed(const Duration(milliseconds: 10), () {
        signal.emit(5);
      });

      final result = await future;
      expect(result, 5);
    });

    test('waitFor times out when condition never met', () async {
      final signal = Signal<int>(0);

      expect(
        () => SignalUtils.waitFor(
          signal,
          (v) => v > 100,
          timeout: const Duration(milliseconds: 50),
        ),
        throwsA(isA<TimeoutException>()),
      );
    });

    test('validated creates middleware signal', () {
      final signal =
          SignalUtils.validated<int>(0, (v) => v >= 0, fallback: (_) => 0);

      signal.emit(5);
      expect(signal.val, 5);

      signal.emit(-1);
      expect(signal.val, 0); // Falls back
    });

    test('clamped creates clamped signal', () {
      final signal = SignalUtils.clamped(50, min: 0, max: 100);

      signal.emit(150);
      expect(signal.val, 100);

      signal.emit(-50);
      expect(signal.val, 0);
    });

    test('toggle creates boolean signal', () {
      final signal = SignalUtils.toggle(false);
      expect(signal.val, false);

      signal.emit(true);
      expect(signal.val, true);
    });
  });

  group('SignalExtensions', () {
    test('toggle flips boolean signal', () {
      final signal = Signal<bool>(false);

      signal.toggle();
      expect(signal.val, true);

      signal.toggle();
      expect(signal.val, false);
    });

    test('increment adds to numeric signal', () {
      final signal = Signal<int>(0);

      signal.increment();
      expect(signal.val, 1);

      signal.increment(5);
      expect(signal.val, 6);
    });

    test('decrement subtracts from numeric signal', () {
      final signal = Signal<int>(10);

      signal.decrement();
      expect(signal.val, 9);

      signal.decrement(4);
      expect(signal.val, 5);
    });

    test('inc/dec are aliases for increment/decrement', () {
      final signal = Signal<int>(0);

      signal.inc();
      expect(signal.val, 1);

      signal.inc(3);
      expect(signal.val, 4);

      signal.dec();
      expect(signal.val, 3);

      signal.dec(2);
      expect(signal.val, 1);
    });

    test('add/sub work correctly', () {
      final signal = Signal<int>(10);

      signal.add(5);
      expect(signal.val, 15);

      signal.sub(3);
      expect(signal.val, 12);
    });

    test('snapshot returns current value', () {
      final signal = Signal<String>('hello');
      expect(signal.snapshot(), 'hello');

      signal.emit('world');
      expect(signal.snapshot(), 'world');
    });

    test('pipeTo forwards values to target signal', () async {
      final source = Signal<int>(0);
      final target = Signal<int>(0);

      source.pipeTo(target);

      source.emit(42);
      await Future.delayed(Duration.zero);

      expect(target.val, 42);
    });
  });
}
