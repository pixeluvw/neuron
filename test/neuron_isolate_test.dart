import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:neuron/neuron.dart';

void main() {
  group('IsolateSignal Tests', () {
    test('computes result in background isolate', () async {
      // Create an IsolateSignal that calculates the sum of all numbers up to N
      final heavyMath = IsolateSignal<int, int>(
        100, // Process 100
        (int count) {
          int result = 0;
          for (int i = 0; i <= count; i++) {
            result += i;
          }
          return result;
        },
      );

      expect(heavyMath.state.isLoading, isTrue);

      final completer1 = Completer<int>();
      heavyMath.subscribe(() {
        if (heavyMath.state.hasData && !completer1.isCompleted) {
          completer1.complete((heavyMath.state as AsyncData<int>).value);
        }
      });

      final result1 = await completer1.future;
      expect(result1, 5050);
      expect(heavyMath.state.hasData, isTrue);

      heavyMath.dispose();
    });

    test('recomputes when compute() is called with new message', () async {
      final heavyMath = IsolateSignal<int, int>(
        5,
        (int count) => count * 10,
      );

      final completer1 = Completer<int>();
      final cancel1 = heavyMath.subscribe(() {
        if (heavyMath.state.hasData && !completer1.isCompleted) {
          completer1.complete((heavyMath.state as AsyncData<int>).value);
        }
      });

      final result1 = await completer1.future;
      expect(result1, 50);
      cancel1();

      heavyMath.compute(10);

      final completer2 = Completer<int>();
      heavyMath.subscribe(() {
        if (heavyMath.state.hasData && !completer2.isCompleted) {
          completer2.complete((heavyMath.state as AsyncData<int>).value);
        }
      });

      final result2 = await completer2.future;
      expect(result2, 100);

      heavyMath.dispose();
    });
  });
}
