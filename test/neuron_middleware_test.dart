import 'package:flutter_test/flutter_test.dart';
import 'package:neuron/neuron.dart';

void main() {
  group('MiddlewareSignal', () {
    test('should apply logging middleware', () {
      final logs = <String>[];
      final signal = MiddlewareSignal<int>(
        0,
        middlewares: [
          LoggingMiddleware<int>(
            label: 'count',
            logger: (msg) => logs.add(msg),
          ),
        ],
      );

      signal.emit(5);
      signal.emit(10);

      expect(logs.length, 2);
      expect(logs[0], contains('count: 0 → 5'));
      expect(logs[1], contains('count: 5 → 10'));
    });

    test('should apply validation middleware', () {
      final signal = MiddlewareSignal<int>(
        0,
        middlewares: [
          ValidationMiddleware<int>(
            validator: (value) => value >= 0,
            fallback: (invalid) => 0,
          ),
        ],
      );

      signal.emit(5);
      expect(signal.val, 5);

      signal.emit(-10); // Invalid
      expect(signal.val, 0); // Fallback
    });

    test('should apply clamp middleware', () {
      final middleware = ClampMiddleware(min: 0, max: 100);
      final signal = MiddlewareSignal<num>(
        50,
        middlewares: [middleware],
      );

      signal.emit(150);
      expect(signal.val, 100);

      signal.emit(-50);
      expect(signal.val, 0);

      signal.emit(75);
      expect(signal.val, 75);
    });

    test('should apply transform middleware', () {
      final signal = MiddlewareSignal<String>(
        '',
        middlewares: [
          TransformMiddleware<String>((value) => value.toUpperCase()),
        ],
      );

      signal.emit('hello');
      expect(signal.val, 'HELLO');

      signal.emit('world');
      expect(signal.val, 'WORLD');
    });

    test('should apply sanitization middleware', () {
      final signal = MiddlewareSignal<String>(
        '',
        middlewares: [
          SanitizationMiddleware(
            trimWhitespace: true,
            maxLength: 10,
          ),
        ],
      );

      signal.emit('  hello world  ');
      expect(signal.val, 'hello worl'); // Trimmed and truncated
    });

    test('should apply rate limit middleware', () async {
      final signal = MiddlewareSignal<int>(
        0,
        middlewares: [
          RateLimitMiddleware<int>(
              minInterval: const Duration(milliseconds: 100)),
        ],
      );

      signal.emit(1);
      expect(signal.val, 1);

      signal.emit(2); // Too fast, should be rejected
      expect(signal.val, 1);

      await Future.delayed(const Duration(milliseconds: 110));

      signal.emit(3); // Enough time passed
      expect(signal.val, 3);
    });

    test('should apply conditional middleware', () {
      final signal = MiddlewareSignal<int>(
        0,
        middlewares: [
          ConditionalMiddleware<int>((old, newVal) => newVal > old),
        ],
      );

      signal.emit(5);
      expect(signal.val, 5);

      signal.emit(3); // Rejected (not greater)
      expect(signal.val, 5);

      signal.emit(10); // Accepted
      expect(signal.val, 10);
    });

    test('should apply history middleware', () {
      final historyMw = HistoryMiddleware<int>(maxHistory: 5);
      final signal = MiddlewareSignal<int>(
        0,
        middlewares: [historyMw],
      );

      signal.emit(1);
      signal.emit(2);
      signal.emit(3);

      expect(historyMw.history, [0, 1, 2]);
      expect(historyMw.previous, 2);
    });

    test('should apply coalesce middleware', () {
      final signal = MiddlewareSignal<int?>(
        10,
        middlewares: [
          CoalesceMiddleware<int>(0),
        ],
      );

      signal.emit(5);
      expect(signal.val, 5);

      signal.emit(null);
      expect(signal.val, 0); // Coalesced to default
    });

    test('should chain multiple middlewares', () {
      final logs = <String>[];
      final clamp = ClampMiddleware(min: 0, max: 100);
      final signal = MiddlewareSignal<num>(
        0,
        middlewares: [
          ValidationMiddleware<num>(
            validator: (value) => value >= 0,
            fallback: (invalid) => 0,
          ),
          clamp,
          LoggingMiddleware<num>(
            label: 'value',
            logger: (msg) => logs.add(msg),
          ),
        ],
      );

      signal.emit(150); // Validated, then clamped to 100
      expect(signal.val, 100);
      expect(logs.last, contains('→ 100'));

      signal.emit(-50); // Validated to 0, clamped (no change)
      expect(signal.val, 0);
    });
  });
}
