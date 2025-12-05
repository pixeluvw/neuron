// neuron_rate_limiting.dart
part of 'neuron_extensions.dart';

/// ============================================================================
/// RATE LIMITING SIGNALS
/// ============================================================================

/// Debounced signal - delays emissions until quiet period.
///
/// DebouncedSignal waits for a specified duration after the last change
/// before emitting the value. Useful for search inputs, form validation, etc.
///
/// ## Basic Usage
///
/// ```dart
/// final searchQuery = Signal<String>('');
///
/// // Only emits after user stops typing for 500ms
/// final debouncedSearch = DebouncedSignal(
///   searchQuery,
///   Duration(milliseconds: 500),
/// );
///
/// // Listen to the debounced signal
/// debouncedSearch.addListener(() {
///   print('Searching for: ${debouncedSearch.value}');
/// });
/// ```
class DebouncedSignal<T> extends Signal<T> {
  final Signal<T> source;
  final Duration duration;
  Timer? _debounceTimer;
  StreamSubscription<T>? _subscription;

  DebouncedSignal(
    this.source,
    this.duration, {
    String? debugLabel,
    super.equals,
    super.guard,
    super.onListen,
    super.onCancel,
  }) : super(source.val, debugLabel: debugLabel) {
    _subscription = source.stream.listen((value) {
      _debounceTimer?.cancel();
      _debounceTimer = Timer(duration, () {
        emit(value);
      });
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _subscription?.cancel();
    super.dispose();
  }
}

/// Throttled signal - limits emission frequency.
///
/// ThrottledSignal emits the first value immediately, then ignores subsequent
/// changes for the specified duration. Useful for limiting API calls, button clicks, etc.
///
/// ## Basic Usage
///
/// ```dart
/// final buttonClicks = Signal<int>(0);
///
/// // Only allows one click every second
/// final throttledClicks = ThrottledSignal(
///   buttonClicks,
///   Duration(seconds: 1),
/// );
///
/// throttledClicks.addListener(() {
///   print('Button clicked!');
/// });
/// ```
class ThrottledSignal<T> extends Signal<T> {
  final Signal<T> source;
  final Duration duration;
  Timer? _throttleTimer;
  bool _isThrottled = false;
  StreamSubscription<T>? _subscription;

  ThrottledSignal(
    this.source,
    this.duration, {
    String? debugLabel,
    super.equals,
    super.guard,
    super.onListen,
    super.onCancel,
  }) : super(source.val, debugLabel: debugLabel) {
    _subscription = source.stream.listen((value) {
      if (!_isThrottled) {
        emit(value);
        _isThrottled = true;
        _throttleTimer = Timer(duration, () {
          _isThrottled = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _throttleTimer?.cancel();
    _subscription?.cancel();
    super.dispose();
  }
}

/// Distinct signal - filters out duplicate consecutive values.
///
/// DistinctSignal only emits when the value actually changes.
/// Note: Standard [Signal] already does this if `equals` is not null.
/// This class is useful when wrapping another signal that might emit duplicates.
///
/// ## Basic Usage
///
/// ```dart
/// final status = Signal<String>('idle');
///
/// final distinctStatus = DistinctSignal(status);
///
/// distinctStatus.addListener(() {
///   print('Status changed: ${distinctStatus.value}');
/// });
/// ```
class DistinctSignal<T> extends Signal<T> {
  final Signal<T> source;
  StreamSubscription<T>? _subscription;

  DistinctSignal(
    this.source, {
    String? debugLabel,
    super.equals,
    super.guard,
    super.onListen,
    super.onCancel,
  }) : super(source.val, debugLabel: debugLabel) {
    _subscription = source.stream.listen((value) {
      if (val != value) {
        emit(value);
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
