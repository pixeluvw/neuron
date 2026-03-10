import 'package:flutter_test/flutter_test.dart';
import 'package:neuron/neuron.dart';

void main() {
  group('batch()', () {
    test('coalesces multiple emissions into one notification per signal', () {
      final count = Signal<int>(0);
      var notifyCount = 0;
      count.addListener(() => notifyCount++);

      batch(() {
        count.emit(1);
        count.emit(2);
        count.emit(3);
      });

      expect(count.val, 3);
      expect(notifyCount, 1, reason: 'Should notify exactly once after batch');
    });

    test('each signal notifies only once', () {
      final a = Signal<int>(0);
      final b = Signal<String>('');
      var aCount = 0;
      var bCount = 0;
      a.addListener(() => aCount++);
      b.addListener(() => bCount++);

      batch(() {
        a.emit(1);
        b.emit('hello');
        a.emit(2);
        b.emit('world');
      });

      expect(a.val, 2);
      expect(b.val, 'world');
      expect(aCount, 1);
      expect(bCount, 1);
    });

    test('without batch, each emit fires immediately', () {
      final count = Signal<int>(0);
      var notifyCount = 0;
      count.addListener(() => notifyCount++);

      count.emit(1);
      count.emit(2);
      count.emit(3);

      expect(notifyCount, 3);
    });

    test('nested batch does not flush early', () {
      final count = Signal<int>(0);
      var notifyCount = 0;
      count.addListener(() => notifyCount++);

      batch(() {
        count.emit(1);
        batch(() {
          count.emit(2);
          count.emit(3);
        });
        expect(notifyCount, 0, reason: 'Inner batch should not flush');
        count.emit(4);
      });

      expect(count.val, 4);
      expect(notifyCount, 1, reason: 'Only outer batch flushes');
    });

    test('listeners see the final value', () {
      final count = Signal<int>(0);
      int? observedValue;
      count.addListener(() => observedValue = count.val);

      batch(() {
        count.emit(10);
        count.emit(20);
        count.emit(30);
      });

      expect(observedValue, 30);
    });

    test('error in callback still flushes pending notifications', () {
      final count = Signal<int>(0);
      var notified = false;
      count.addListener(() => notified = true);

      try {
        batch(() {
          count.emit(1);
          throw Exception('oops');
        });
      } catch (_) {}

      expect(notified, true, reason: 'Should flush even after error');
      expect(count.val, 1);
    });

    test('NeuronBatch.isBatching reflects state correctly', () {
      expect(NeuronBatch.isBatching, false);

      batch(() {
        expect(NeuronBatch.isBatching, true);
      });

      expect(NeuronBatch.isBatching, false);
    });
  });
}
