import 'package:flutter_test/flutter_test.dart';
import 'package:neuron/neuron.dart';

void main() {
  group('ComputedAsync', () {
    test('starts in loading state', () {
      final trigger = Signal<int>(0);
      final computed = ComputedAsync<String>(
        () async {
          await Future.delayed(const Duration(milliseconds: 10));
          return 'result ${trigger.val}';
        },
        [trigger],
      );

      expect(computed.state.isLoading, true);
      computed.dispose();
    });

    test('transitions to data state after computation', () async {
      final trigger = Signal<int>(1);
      final computed = ComputedAsync<int>(
        () async => trigger.val * 10,
        [trigger],
      );

      // Wait for initial async computation
      await Future.delayed(const Duration(milliseconds: 50));

      expect(computed.state.hasData, true);
      expect((computed.state as AsyncData<int>).value, 10);

      computed.dispose();
    });

    test('recomputes when Signal dependency changes', () async {
      final trigger = Signal<int>(1);
      final computed = ComputedAsync<int>(
        () async => trigger.val * 10,
        [trigger],
      );

      // Wait for initial compute
      await Future.delayed(const Duration(milliseconds: 50));
      expect((computed.state as AsyncData<int>).value, 10);

      // Change dependency using Neuron's emit
      trigger.emit(5);

      // Wait for recompute
      await Future.delayed(const Duration(milliseconds: 50));

      expect(computed.state.hasData, true);
      expect((computed.state as AsyncData<int>).value, 50);

      computed.dispose();
    });

    test('handles error in computation', () async {
      var shouldFail = true;
      final trigger = Signal<int>(0);
      final computed = ComputedAsync<String>(
        () async {
          if (shouldFail) throw Exception('fail');
          return 'ok';
        },
        [trigger],
      );

      await Future.delayed(const Duration(milliseconds: 50));
      expect(computed.state.hasError, true);

      // Fix the error
      shouldFail = false;
      trigger.emit(1); // Trigger recompute
      await Future.delayed(const Duration(milliseconds: 50));

      expect(computed.state.hasData, true);
      expect((computed.state as AsyncData<String>).value, 'ok');

      computed.dispose();
    });

    test('listens to multiple Signal dependencies', () async {
      final a = Signal<int>(1);
      final b = Signal<int>(2);
      final computed = ComputedAsync<int>(
        () async => a.val + b.val,
        [a, b],
      );

      await Future.delayed(const Duration(milliseconds: 50));
      expect((computed.state as AsyncData<int>).value, 3);

      a.emit(10);
      await Future.delayed(const Duration(milliseconds: 50));
      expect((computed.state as AsyncData<int>).value, 12);

      b.emit(20);
      await Future.delayed(const Duration(milliseconds: 50));
      expect((computed.state as AsyncData<int>).value, 30);

      computed.dispose();
    });

    test('dispose stops listening to dependencies', () async {
      final trigger = Signal<int>(1);
      var computeCount = 0;
      final computed = ComputedAsync<int>(
        () async {
          computeCount++;
          return trigger.val;
        },
        [trigger],
      );

      await Future.delayed(const Duration(milliseconds: 50));
      final initialCount = computeCount;

      computed.dispose();

      // Change dependency after dispose — should NOT recompute
      trigger.emit(99);
      await Future.delayed(const Duration(milliseconds: 50));

      expect(computeCount, initialCount);
    });
  });
}
