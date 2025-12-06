// neuron_utilities.dart
part of 'neuron_extensions.dart';

/// ============================================================================
/// UTILITIES
/// ============================================================================

/// Utility methods for creating and managing signals.
///
/// ## Basic Usage
///
/// ```dart
/// // From Stream
/// final streamSignal = SignalUtils.fromStream(myStream, initialValue);
///
/// // From Future
/// final futureSignal = SignalUtils.fromFuture(myFuture);
///
/// // Polling
/// final pollSignal = SignalUtils.poll(
///   () => fetchStatus(),
///   Duration(seconds: 5),
///   'initial',
/// );
/// ```
class SignalUtils {
  /// Create a signal from a stream.
  static Signal<T> fromStream<T>(Stream<T> stream, T initialValue) {
    final signal = Signal<T>(initialValue);
    stream.listen((value) => signal.emit(value));
    return signal;
  }

  /// Create a signal from a future.
  static AsyncSignal<T> fromFuture<T>(Future<T> future) {
    final signal = AsyncSignal<T>(null);
    signal.execute(() => future);
    return signal;
  }

  /// Create a polling signal that updates periodically.
  static Signal<T> poll<T>(
    Future<T> Function() getter,
    Duration interval,
    T initialValue,
  ) {
    final signal = Signal<T>(initialValue);

    Timer.periodic(interval, (timer) async {
      try {
        final value = await getter();
        signal.emit(value);
      } catch (e) {
        // Ignore errors in polling
      }
    });

    return signal;
  }

  /// Bind two signals bidirectionally.
  static void bind<T>(Signal<T> signal1, Signal<T> signal2) {
    signal1.stream.listen((value) => signal2.emit(value));
    signal2.stream.listen((value) => signal1.emit(value));
  }

  /// Create a lazy signal that only computes value when accessed.
  static Signal<T> lazy<T>(T Function() initializer) {
    return Signal<T>(initializer());
  }

  /// Create a signal that caches computed values.
  static Computed<T> cached<T>(
    T Function() compute,
    List<NeuronAtom> dependencies, {
    Duration? ttl,
  }) {
    T? cache;
    DateTime? cacheTime;

    return Computed<T>(
      () {
        final now = DateTime.now();
        if (cache != null &&
            cacheTime != null &&
            ttl != null &&
            now.difference(cacheTime!) < ttl) {
          return cache as T;
        }
        cache = compute();
        cacheTime = now;
        return cache as T;
      },
      dependencies,
    );
  }

  /// Wait for a signal to meet a condition.
  static Future<T> waitFor<T>(
    Signal<T> signal,
    bool Function(T value) condition, {
    Duration? timeout,
  }) async {
    if (condition(signal.val)) {
      return signal.val;
    }

    final completer = Completer<T>();
    StreamSubscription<T>? subscription;

    subscription = signal.stream.listen((value) {
      if (condition(value)) {
        subscription?.cancel();
        if (!completer.isCompleted) {
          completer.complete(value);
        }
      }
    });

    if (timeout != null) {
      return completer.future.timeout(timeout, onTimeout: () {
        subscription?.cancel();
        throw TimeoutException('Timeout waiting for signal condition');
      });
    }

    return completer.future;
  }

  /// Create a validated signal with middleware.
  static MiddlewareSignal<T> validated<T>(
    T initialValue,
    bool Function(T value) validator, {
    T Function(T invalidValue)? fallback,
  }) {
    return MiddlewareSignal<T>(
      initialValue,
      middlewares: [
        ValidationMiddleware(validator: validator, fallback: fallback),
      ],
    );
  }

  /// Create a clamped numeric signal.
  static MiddlewareSignal<num> clamped(
    num initialValue, {
    required num min,
    required num max,
  }) {
    return MiddlewareSignal<num>(
      initialValue,
      middlewares: [
        ClampMiddleware(min: min, max: max),
      ],
    );
  }

  /// Create a logged signal.
  static MiddlewareSignal<T> logged<T>(
    T initialValue, {
    String? label,
  }) {
    return MiddlewareSignal<T>(
      initialValue,
      middlewares: [
        LoggingMiddleware<T>(label: label),
      ],
    );
  }

  /// Create a toggle signal (boolean).
  static Signal<bool> toggle(bool initialValue) {
    return Signal<bool>(initialValue);
  }
}

/// Extension methods for signals.
extension SignalExtensions<T> on Signal<T> {
  /// Toggle boolean signal.
  void toggle() {
    if (this is Signal<bool>) {
      final boolSignal = this as Signal<bool>;
      boolSignal.emit(!boolSignal.val);
    }
  }

  /// Increment numeric signal.
  void increment([num by = 1]) {
    if (val is num) {
      emit(((val as num) + by) as T);
    }
  }

  /// Decrement numeric signal.
  void decrement([num by = 1]) {
    if (val is num) {
      emit(((val as num) - by) as T);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Short Aliases for Numeric Signals
  // ─────────────────────────────────────────────────────────────────────────

  /// Short alias for [increment]. Increments numeric signal by [by] (default 1).
  ///
  /// ```dart
  /// count.inc();    // same as count.increment()
  /// count.inc(5);   // same as count.increment(5)
  /// ```
  void inc([num by = 1]) => increment(by);

  /// Short alias for [decrement]. Decrements numeric signal by [by] (default 1).
  ///
  /// ```dart
  /// count.dec();    // same as count.decrement()
  /// count.dec(3);   // same as count.decrement(3)
  /// ```
  void dec([num by = 1]) => decrement(by);

  /// Add [amount] to numeric signal and emit. Alias for [increment].
  ///
  /// ```dart
  /// count.add(10);  // same as count.emit(count.val + 10)
  /// ```
  void add(num amount) => increment(amount);

  /// Subtract [amount] from numeric signal and emit. Alias for [decrement].
  ///
  /// ```dart
  /// count.sub(5);   // same as count.emit(count.val - 5)
  /// ```
  void sub(num amount) => decrement(amount);

  /// Get current snapshot.
  T snapshot() => val;

  /// Pipe values to another signal.
  StreamSubscription<T> pipeTo(Signal<T> target) {
    return stream.listen((value) => target.emit(value));
  }
}

/// Exception for timeout operations.
class TimeoutException implements Exception {
  final String message;
  TimeoutException(this.message);

  @override
  String toString() => 'TimeoutException: $message';
}
