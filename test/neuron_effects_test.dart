import 'package:flutter_test/flutter_test.dart';
import 'package:neuron/neuron.dart';

void main() {
  group('SignalReaction', () {
    test('should trigger reaction on signal change', () async {
      final count = Signal<int>(0);
      var reactionCount = 0;

      SignalReaction(
        count,
        (value) {
          reactionCount++;
        },
      );

      count.emit(1);
      await Future.delayed(Duration.zero);
      count.emit(2);
      await Future.delayed(Duration.zero);

      expect(reactionCount, 2);
    });

    test('should dispose reaction', () async {
      final count = Signal<int>(0);
      var reactionCount = 0;

      final reaction = SignalReaction(
        count,
        (value) {
          reactionCount++;
        },
      );

      count.emit(1);
      await Future.delayed(Duration.zero);
      expect(reactionCount, 1);

      reaction.dispose();

      count.emit(2);
      await Future.delayed(Duration.zero);
      expect(reactionCount, 1); // Should not increase
    });
  });

  group('SignalTransaction', () {
    test('should batch signal updates', () {
      final count1 = Signal<int>(0);
      final count2 = Signal<int>(0);
      var notifyCount = 0;

      count1.addListener(() => notifyCount++);
      count2.addListener(() => notifyCount++);

      SignalTransaction()
        ..update(count1, 1)
        ..update(count2, 2)
        ..commit();

      expect(count1.val, 1);
      expect(count2.val, 2);
      // Both should have notified
      expect(notifyCount, 2);
    });

    test('should rollback transaction', () {
      final count = Signal<int>(0);

      SignalTransaction()
        ..update(count, 5)
        ..rollback();

      expect(count.val, 0); // Not committed
    });
  });

  group('SignalAction', () {
    test('should track async action state', () async {
      final action = SignalAction<String>(
        name: 'test',
        execute: () async {
          await Future.delayed(Duration(milliseconds: 10));
          return 'result';
        },
      );

      expect(action.isExecuting.val, false);
      expect(action.result.val, null);

      final future = action.run();

      expect(action.isExecuting.val, true);

      final result = await future;

      expect(action.isExecuting.val, false);
      expect(action.result.val, 'result');
      expect(result, 'result');
    });

    test('should handle action errors', () async {
      var errorCaught = false;
      final action = SignalAction<int>(
        name: 'test',
        execute: () async {
          throw Exception('test error');
        },
        onError: (error, stack) {
          errorCaught = true;
        },
      );

      final result = await action.run();

      expect(result, null);
      expect(action.isExecuting.val, false);
      expect(action.error.val, isNotNull);
      expect(errorCaught, true);
    });

    test('should call after callback', () async {
      var afterCalled = false;
      final action = SignalAction<int>(
        name: 'test',
        execute: () async => 42,
        after: (result) {
          afterCalled = true;
        },
      );

      await action.run();

      expect(afterCalled, true);
      expect(action.result.val, 42);
    });

    test('should not run while already executing', () async {
      var executionCount = 0;
      final action = SignalAction<int>(
        name: 'test',
        execute: () async {
          executionCount++;
          await Future.delayed(Duration(milliseconds: 50));
          return 1;
        },
      );

      final future1 = action.run();
      final future2 = action.run(); // Should return null

      await future1;
      final result2 = await future2;

      expect(executionCount, 1);
      expect(result2, null);
    });
  });
}
