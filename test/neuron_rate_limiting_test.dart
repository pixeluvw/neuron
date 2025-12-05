import 'package:flutter_test/flutter_test.dart';
import 'package:neuron/neuron.dart';

void main() {
  group('DebouncedSignal', () {
    test('should debounce rapid emissions', () async {
      final source = Signal<int>(0);
      final signal = DebouncedSignal<int>(
        source,
        Duration(milliseconds: 100),
      );

      var emitCount = 0;
      signal.addListener(() {
        emitCount++;
      });

      // Emit multiple values rapidly
      source.emit(1);
      source.emit(2);
      source.emit(3);

      // Should not have emitted yet
      expect(emitCount, 0);

      // Wait for debounce duration
      await Future.delayed(Duration(milliseconds: 150));

      // Should have emitted only once with final value
      expect(emitCount, 1);
      expect(signal.val, 3);
    });

    test('should emit after quiet period', () async {
      final source = Signal<String>('initial');
      final signal = DebouncedSignal<String>(
        source,
        Duration(milliseconds: 50),
      );

      source.emit('first');
      await Future.delayed(Duration(milliseconds: 60));

      expect(signal.val, 'first');

      source.emit('second');
      await Future.delayed(Duration(milliseconds: 60));

      expect(signal.val, 'second');
    });
  });

  group('ThrottledSignal', () {
    test('should throttle emissions', () async {
      final source = Signal<int>(0);
      final signal = ThrottledSignal<int>(
        source,
        Duration(milliseconds: 100),
      );

      var emitCount = 0;
      signal.addListener(() {
        emitCount++;
      });

      // First emission should go through immediately
      source.emit(1);
      await Future.delayed(Duration(milliseconds: 10));
      expect(emitCount, 1);

      // Subsequent emissions should be throttled
      source.emit(2);
      source.emit(3);
      expect(emitCount, 1); // Still 1

      // Wait for throttle duration
      await Future.delayed(Duration(milliseconds: 110));

      // Next emission should go through
      source.emit(4);
      await Future.delayed(Duration(milliseconds: 10));
      expect(emitCount, 2);
    });
  });

  group('DistinctSignal', () {
    test('should filter duplicate consecutive values', () async {
      final source = Signal<int>(0);
      final signal = DistinctSignal<int>(source);

      var emitCount = 0;
      signal.addListener(() {
        emitCount++;
      });

      // First emit to 1 should notify (0 -> 1)
      source.emit(1);
      await Future.delayed(Duration.zero); // Allow async stream to process
      expect(emitCount, 1);
      expect(signal.val, 1);

      // Same value should be filtered
      source.emit(1);
      await Future.delayed(Duration.zero);
      expect(emitCount, 1);

      // Different value should emit
      source.emit(2);
      await Future.delayed(Duration.zero);
      expect(emitCount, 2);

      // Same as current should be filtered
      source.emit(2);
      await Future.delayed(Duration.zero);
      expect(emitCount, 2);
    });
  });
}
