import 'package:flutter_test/flutter_test.dart';
import 'package:neuron/neuron.dart';

void main() {
  group('SignalSelector', () {
    test('selects a sub-value from source signal', () {
      final source = Signal<String>('hello');
      final lengthSelector =
          SignalSelector<String, int>(source, (s) => s.length);

      expect(lengthSelector.value, 5);
    });

    test('updates when selected value changes', () {
      final source = Signal<String>('hi');
      final selector = SignalSelector<String, int>(source, (s) => s.length);
      var notifyCount = 0;
      selector.addListener(() => notifyCount++);

      source.emit('hello'); // length 2 -> 5
      expect(selector.value, 5);
      expect(notifyCount, 1);
    });

    test('does not emit when selected value is the same', () {
      final source = Signal<String>('hi');
      final selector = SignalSelector<String, int>(source, (s) => s.length);
      var notifyCount = 0;
      selector.addListener(() => notifyCount++);

      source.emit('yo'); // length 2 -> 2, no change
      expect(notifyCount, 0);
    });

    test('cold read returns correct value without listeners', () {
      final source = Signal<String>('world');
      final selector = SignalSelector<String, int>(source, (s) => s.length);

      // No listener added — cold read
      expect(selector.value, 5);

      source.emit('hi');
      expect(selector.value, 2);
    });

    test('unsubscribes from source when all listeners removed', () {
      final source = Signal<String>('test');
      final selector = SignalSelector<String, int>(source, (s) => s.length);

      final handle = selector.addListener(() {});
      selector.removeListener(handle);

      // After removing listener, selector should be inactive
      // Verify it still computes correctly via cold read
      source.emit('longer text');
      expect(selector.value, 11);
    });

    test('dispose cleans up subscription', () {
      final source = Signal<String>('test');
      final selector = SignalSelector<String, int>(source, (s) => s.length);
      selector.addListener(() {});

      selector.dispose();
      // Should not throw after dispose
      source.emit('hello');
    });

    test('works with complex selector function', () {
      final source = Signal<Map<String, int>>({'a': 1, 'b': 2});
      final sumSelector = SignalSelector<Map<String, int>, int>(
        source,
        (map) => map.values.fold(0, (sum, v) => sum + v),
      );

      expect(sumSelector.value, 3);

      source.emit({'a': 10, 'b': 20, 'c': 30});
      expect(sumSelector.value, 60);
    });
  });
}
