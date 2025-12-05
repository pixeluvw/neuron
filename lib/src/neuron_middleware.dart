// neuron_middleware.dart
part of 'neuron_extensions.dart';

/// ============================================================================
/// MIDDLEWARE AND INTERCEPTORS
/// ============================================================================

/// Middleware interface for signal value processing.
///
/// Middleware can transform, validate, or log values before they're emitted.
abstract class SignalMiddleware<T> {
  T process(T oldValue, T newValue);
}

/// Signal with middleware support.
///
/// MiddlewareSignal allows you to intercept and transform values
/// before they're emitted.
///
/// ## Basic Usage
///
/// ```dart
/// final age = MiddlewareSignal<int>(
///   0,
///   middlewares: [
///     // Ensure age is between 0 and 120
///     ClampMiddleware(min: 0, max: 120),
///
///     // Log changes
///     LoggingMiddleware(label: 'Age'),
///   ],
/// );
///
/// age.value = 150; // Clamped to 120, logged
/// ```
class MiddlewareSignal<T> extends Signal<T> {
  final List<SignalMiddleware<T>> middlewares;

  MiddlewareSignal(
    super.initial, {
    required this.middlewares,
    super.debugLabel,
    super.equals,
    super.guard,
    super.onListen,
    super.onCancel,
  });

  @override
  void emit(T val) {
    final registry = NeuronDebugRegistry.instance;
    final bool logMiddleware = registry.isEnabled;
    final List<Map<String, dynamic>> steps = [];

    T processedValue = val;
    for (final middleware in middlewares) {
      final before = processedValue;
      processedValue = middleware.process(super.value, processedValue);
      if (logMiddleware) {
        steps.add({
          'middleware': middleware.runtimeType.toString(),
          'before': before,
          'after': processedValue,
        });
      }
    }

    if (logMiddleware) {
      registry.recordMiddlewareEvent('signal_middleware', {
        'signalId': registry.idForNotifier(this) ??
            debugLabel ??
            runtimeType.toString(),
        'controller': (registry.idForNotifier(this) ?? '').split('.').first,
        'oldValue': NeuronDebugEncoder.encodeValue(super.value),
        'newValue': NeuronDebugEncoder.encodeValue(processedValue),
        'steps': steps,
      });
    }
    super.emit(processedValue);
  }
}

/// Logging middleware - logs value changes.
class LoggingMiddleware<T> extends SignalMiddleware<T> {
  final String? label;
  final void Function(String message)? logger;

  LoggingMiddleware({this.label, this.logger});

  @override
  T process(T oldValue, T newValue) {
    final message = '${label ?? 'Signal'}: $oldValue → $newValue';
    if (logger != null) {
      logger!(message);
    } else {
      if (kDebugMode) print(message);
    }
    return newValue;
  }
}

/// Validation middleware - validates values.
class ValidationMiddleware<T> extends SignalMiddleware<T> {
  final bool Function(T value) validator;
  final T Function(T invalidValue)? fallback;

  ValidationMiddleware({
    required this.validator,
    this.fallback,
  });

  @override
  T process(T oldValue, T newValue) {
    if (validator(newValue)) {
      return newValue;
    }
    return fallback?.call(newValue) ?? oldValue;
  }
}

/// Clamp middleware - clamps numeric values to range.
class ClampMiddleware extends SignalMiddleware<num> {
  final num min;
  final num max;

  ClampMiddleware({required this.min, required this.max});

  @override
  num process(num oldValue, num newValue) {
    return newValue.clamp(min, max);
  }
}

/// Transform middleware - transforms values.
class TransformMiddleware<T> extends SignalMiddleware<T> {
  final T Function(T value) transformer;

  TransformMiddleware(this.transformer);

  @override
  T process(T oldValue, T newValue) {
    return transformer(newValue);
  }
}

/// String sanitization middleware.
class SanitizationMiddleware extends SignalMiddleware<String> {
  final bool trimWhitespace;
  final int? maxLength;
  final bool toLowerCase;
  final bool toUpperCase;

  SanitizationMiddleware({
    this.trimWhitespace = true,
    this.maxLength,
    this.toLowerCase = false,
    this.toUpperCase = false,
  });

  @override
  String process(String oldValue, String newValue) {
    String result = newValue;

    if (trimWhitespace) {
      result = result.trim();
    }

    if (toLowerCase) {
      result = result.toLowerCase();
    }

    if (toUpperCase) {
      result = result.toUpperCase();
    }

    if (maxLength != null && result.length > maxLength!) {
      result = result.substring(0, maxLength);
    }

    return result;
  }
}

/// Rate limit middleware - limits how frequently values can be emitted.
class RateLimitMiddleware<T> extends SignalMiddleware<T> {
  final Duration minInterval;
  DateTime? _lastEmitTime;

  RateLimitMiddleware({required this.minInterval});

  @override
  T process(T oldValue, T newValue) {
    final now = DateTime.now();
    if (_lastEmitTime != null) {
      final elapsed = now.difference(_lastEmitTime!);
      if (elapsed < minInterval) {
        return oldValue; // Reject new value
      }
    }
    _lastEmitTime = now;
    return newValue;
  }
}

/// Conditional middleware - only emit if condition is met.
class ConditionalMiddleware<T> extends SignalMiddleware<T> {
  final bool Function(T oldValue, T newValue) condition;

  ConditionalMiddleware(this.condition);

  @override
  T process(T oldValue, T newValue) {
    return condition(oldValue, newValue) ? newValue : oldValue;
  }
}

/// History middleware - keeps track of previous values.
class HistoryMiddleware<T> extends SignalMiddleware<T> {
  final int maxHistory;
  final List<T> _history = [];

  HistoryMiddleware({this.maxHistory = 10});

  /// Get the history of values.
  List<T> get history => List.unmodifiable(_history);

  /// Get the previous value (if any).
  T? get previous => _history.isNotEmpty ? _history.last : null;

  @override
  T process(T oldValue, T newValue) {
    if (_history.isEmpty || _history.last != oldValue) {
      _history.add(oldValue);
      if (_history.length > maxHistory) {
        _history.removeAt(0);
      }
    }
    return newValue;
  }
}

/// Coalesce middleware - prevents null values.
class CoalesceMiddleware<T> extends SignalMiddleware<T?> {
  final T defaultValue;

  CoalesceMiddleware(this.defaultValue);

  @override
  T? process(T? oldValue, T? newValue) {
    return newValue ?? defaultValue;
  }
}

/// Aggregate middleware - combine multiple middlewares.
///
/// Applies a list of middlewares in sequence.
class AggregateMiddleware<T> extends SignalMiddleware<T> {
  /// The list of middlewares to apply in order.
  final List<SignalMiddleware<T>> middlewares;

  /// Creates an aggregate middleware with the given list of [middlewares].
  AggregateMiddleware(this.middlewares);

  @override
  /// Processes the value through each middleware in the list sequentially.
  T process(T oldValue, T newValue) {
    T result = newValue;
    for (final middleware in middlewares) {
      result = middleware.process(oldValue, result);
    }
    return result;
  }
}
