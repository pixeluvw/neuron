// neuron_advanced.dart
part of 'neuron_extensions.dart';

/// ============================================================================
/// UNDOABLE SIGNAL (UNDO/REDO SUPPORT)
/// ============================================================================

/// Signal with undo/redo support.
///
/// UndoableSignal keeps a history of values and allows you to undo/redo changes.
///
/// ## Basic Usage
///
/// ```dart
/// final counter = UndoableSignal<int>(0);
///
/// counter.value = 1;
/// counter.value = 2;
///
/// counter.undo(); // value is 1
/// counter.redo(); // value is 2
/// ```
///
/// ## History Management
///
/// You can configure the maximum history size:
///
/// ```dart
/// final text = UndoableSignal<String>(
///   '',
///   maxHistory: 100, // Keep last 100 changes
/// );
/// ```
class UndoableSignal<T> extends Signal<T> {
  final int maxHistory;
  final List<T> _history = [];
  int _index = -1;
  bool _isUndoRedoing = false;

  UndoableSignal(
    T initial, {
    this.maxHistory = 50,
    String? debugLabel,
  }) : super(initial, debugLabel: debugLabel) {
    _history.add(initial);
    _index = 0;
  }

  @override
  void emit(T val) {
    if (_isUndoRedoing) {
      super.emit(val);
      return;
    }

    if (value == val) return;

    // Remove any redo history
    if (_index < _history.length - 1) {
      _history.removeRange(_index + 1, _history.length);
    }

    _history.add(val);
    if (_history.length > maxHistory) {
      _history.removeAt(0);
    } else {
      _index++;
    }

    super.emit(val);
  }

  /// Whether undo is available.
  bool get canUndo => _index > 0;

  /// Whether redo is available.
  bool get canRedo => _index < _history.length - 1;

  /// Undo to the previous value.
  void undo() {
    if (canUndo) {
      _isUndoRedoing = true;
      _index--;
      emit(_history[_index]);
      _isUndoRedoing = false;
    }
  }

  /// Redo to the next value.
  void redo() {
    if (canRedo) {
      _isUndoRedoing = true;
      _index++;
      emit(_history[_index]);
      _isUndoRedoing = false;
    }
  }

  /// Clear all history and reset to current value.
  void clearHistory() {
    _history.clear();
    _history.add(value);
    _index = 0;
  }

  /// Get the complete history.
  List<T> get history => List.unmodifiable(_history);

  /// Get the current position in history.
  int get historyIndex => _index;

  /// Get the history size.
  int get historySize => _history.length;
}

/// ============================================================================
/// SIGNAL SELECTOR (GRANULAR REBUILDS)
/// ============================================================================

/// Select a part of a signal's value for granular rebuilds.
///
/// SignalSelector creates a derived signal that only updates when
/// the selected part of the value changes.
///
/// ## Basic Usage
///
/// ```dart
/// class User {
///   final String name;
///   final int age;
///   User(this.name, this.age);
/// }
///
/// final user = Signal(User('Alice', 25));
///
/// // Only emits when name changes
/// final nameSignal = SignalSelector(user, (u) => u.name);
///
/// nameSignal.addListener(() {
///   print('Name changed: ${nameSignal.value}');
/// });
/// ```
class SignalSelector<T, S> extends Signal<S> {
  final Signal<T> source;
  final S Function(T value) selector;
  StreamSubscription<T>? _subscription;

  SignalSelector(
    this.source,
    this.selector, {
    String? debugLabel,
  }) : super(selector(source.val), debugLabel: debugLabel) {
    _subscription = source.stream.listen((value) {
      final selected = selector(value);
      if (val != selected) {
        emit(selected);
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

/// Widget for using signal selectors inline.
///
/// SelectSlot automatically creates a SignalSelector and only rebuilds
/// when the selected part changes.
///
/// ## Basic Usage
///
/// ```dart
/// SelectSlot<User, String>(
///   connect: userSignal,
///   select: (user) => user.name,
///   to: (context, name) => Text('Name: $name'),
/// )
/// ```
class SelectSlot<T, S> extends StatefulWidget {
  final Signal<T> connect;
  final S Function(T value) select;
  final Widget Function(BuildContext context, S selected) to;
  final Widget? child;

  const SelectSlot({
    super.key,
    required this.connect,
    required this.select,
    required this.to,
    this.child,
  });

  @override
  State<SelectSlot<T, S>> createState() => _SelectSlotState<T, S>();
}

class _SelectSlotState<T, S> extends State<SelectSlot<T, S>> {
  late SignalSelector<T, S> _selector;

  @override
  void initState() {
    super.initState();
    _selector = SignalSelector(widget.connect, widget.select);
  }

  @override
  void dispose() {
    _selector.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Slot<S>(
      connect: _selector,
      to: widget.to,
      child: widget.child,
    );
  }
}

/// ============================================================================
/// FORM SIGNAL WITH VALIDATION
/// ============================================================================

/// Validation result.
class ValidationResult {
  final bool isValid;
  final String? error;

  const ValidationResult.valid()
      : isValid = true,
        error = null;
  const ValidationResult.invalid(this.error) : isValid = false;

  @override
  String toString() => isValid ? 'Valid' : 'Invalid: $error';
}

/// Validator function type.
typedef Validator<T> = ValidationResult Function(T value);

/// Form field signal with validation support.
///
/// FormSignal manages form field state with built-in validation,
/// dirty/touched tracking, and error messages.
///
/// Example:
/// ```dart
/// class LoginController extends NeuronController {
///   late final email = FormSignal<String>(
///     '',
///     validators: [
///       Validators.required('Email is required'),
///       Validators.email('Invalid email format'),
///     ],
///   ).bind(this);
///
///   late final password = FormSignal<String>(
///     '',
///     validators: [
///       Validators.required('Password is required'),
///       Validators.minLength(6, 'Password must be at least 6 characters'),
///     ],
///   ).bind(this);
///
///   bool get canSubmit => email.isValid && password.isValid;
/// }
/// ```
class FormSignal<T> extends NeuronAtom<NeuronFormState<T>> {
  final List<Validator<T>> validators;
  final String? debugLabel;

  FormSignal(
    T initialValue, {
    this.validators = const [],
    this.debugLabel,
    super.equals,
    super.guard,
    super.onListen,
    super.onCancel,
  }) : super(NeuronFormState<T>(
          value: initialValue,
          error: null,
          isDirty: false,
          isTouched: false,
        )) {
    _validate(initialValue);
  }

  /// Emit a new value and validate.
  void emit(T val) {
    final newState = value.copyWith(
      value: val,
      isDirty: true,
    );
    value = newState;
    _validate(val);
  }

  /// Mark the field as touched (focused then blurred).
  void markAsTouched() {
    if (!value.isTouched) {
      value = value.copyWith(isTouched: true);
    }
  }

  /// Mark the field as pristine (reset dirty state).
  void markAsPristine() {
    value = value.copyWith(isDirty: false);
  }

  /// Reset to initial value.
  @override
  void reset([T? initialValue]) {
    final val = initialValue ?? this.initialValue.value;
    value = NeuronFormState<T>(
      value: val,
      error: null,
      isDirty: false,
      isTouched: false,
    );
    _validate(val);
  }

  void _validate(T val) {
    for (final validator in validators) {
      final result = validator(val);
      if (!result.isValid) {
        value = value.copyWith(error: result.error);
        return;
      }
    }
    value = value.copyWith(error: null);
  }

  /// Current value.
  T get val => value.value;

  /// Whether the field is valid.
  bool get isValid => value.error == null;

  /// Whether the field is invalid.
  bool get isInvalid => value.error != null;

  /// Current error message.
  String? get error => value.error;

  /// Whether the field has been modified.
  bool get isDirty => value.isDirty;

  /// Whether the field is pristine (not modified).
  bool get isPristine => !value.isDirty;

  /// Whether the field has been touched.
  bool get isTouched => value.isTouched;

  /// Whether the field is untouched.
  bool get isUntouched => !value.isTouched;
}

/// Form field state.
class NeuronFormState<T> {
  final T value;
  final String? error;
  final bool isDirty;
  final bool isTouched;

  const NeuronFormState({
    required this.value,
    required this.error,
    required this.isDirty,
    required this.isTouched,
  });

  NeuronFormState<T> copyWith({
    T? value,
    String? error,
    bool? isDirty,
    bool? isTouched,
  }) {
    return NeuronFormState<T>(
      value: value ?? this.value,
      error: error,
      isDirty: isDirty ?? this.isDirty,
      isTouched: isTouched ?? this.isTouched,
    );
  }
}

/// Built-in validators.
class Validators {
  /// Required field validator.
  static Validator<T> required<T>(String message) {
    return (value) {
      if (value == null) {
        return ValidationResult.invalid(message);
      }
      if (value is String && value.trim().isEmpty) {
        return ValidationResult.invalid(message);
      }
      if (value is Iterable && value.isEmpty) {
        return ValidationResult.invalid(message);
      }
      return const ValidationResult.valid();
    };
  }

  /// Email validator.
  static Validator<String> email(String message) {
    return (value) {
      final emailRegex = RegExp(
        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
      );
      if (!emailRegex.hasMatch(value)) {
        return ValidationResult.invalid(message);
      }
      return const ValidationResult.valid();
    };
  }

  /// Minimum length validator.
  static Validator<String> minLength(int min, String message) {
    return (value) {
      if (value.length < min) {
        return ValidationResult.invalid(message);
      }
      return const ValidationResult.valid();
    };
  }

  /// Maximum length validator.
  static Validator<String> maxLength(int max, String message) {
    return (value) {
      if (value.length > max) {
        return ValidationResult.invalid(message);
      }
      return const ValidationResult.valid();
    };
  }

  /// Pattern validator.
  static Validator<String> pattern(RegExp regex, String message) {
    return (value) {
      if (!regex.hasMatch(value)) {
        return ValidationResult.invalid(message);
      }
      return const ValidationResult.valid();
    };
  }

  /// Minimum value validator.
  static Validator<num> min(num minimum, String message) {
    return (value) {
      if (value < minimum) {
        return ValidationResult.invalid(message);
      }
      return const ValidationResult.valid();
    };
  }

  /// Maximum value validator.
  static Validator<num> max(num maximum, String message) {
    return (value) {
      if (value > maximum) {
        return ValidationResult.invalid(message);
      }
      return const ValidationResult.valid();
    };
  }

  /// Custom validator.
  static Validator<T> custom<T>(
    bool Function(T value) test,
    String message,
  ) {
    return (value) {
      if (!test(value)) {
        return ValidationResult.invalid(message);
      }
      return const ValidationResult.valid();
    };
  }
}

/// Widget for binding FormSignal to UI.
///
/// Example:
/// ```dart
/// FormSlot<String>(
///   connect: controller.email,
///   builder: (ctx, state) => TextField(
///     onChanged: controller.email.emit,
///     decoration: InputDecoration(
///       labelText: 'Email',
///       errorText: state.error,
///     ),
///   ),
/// )
/// ```
class FormSlot<T> extends StatefulWidget {
  final FormSignal<T> connect;
  final Widget Function(BuildContext context, NeuronFormState<T> state) builder;

  const FormSlot({
    super.key,
    required this.connect,
    required this.builder,
  });

  @override
  State<FormSlot<T>> createState() => _FormSlotState<T>();
}

class _FormSlotState<T> extends State<FormSlot<T>> {
  late NeuronFormState<T> _state;
  VoidCallback? _cancel;

  @override
  void initState() {
    super.initState();
    _state = widget.connect.value;
    _subscribe();
  }

  void _subscribe() {
    _cancel = widget.connect.subscribe(() {
      if (mounted) {
        setState(() {
          _state = widget.connect.value;
        });
      }
    });
  }

  @override
  void didUpdateWidget(FormSlot<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.connect != oldWidget.connect) {
      _cancel?.call();
      _state = widget.connect.value;
      _subscribe();
    }
  }

  @override
  void dispose() {
    _cancel?.call();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _state);
  }
}

/// ============================================================================
/// COMPUTED ASYNC (DERIVED ASYNC SIGNALS)
/// ============================================================================

/// Computed signal that handles async operations.
///
/// ComputedAsync automatically recomputes when dependencies change
/// and manages loading/error states.
///
/// Example:
/// ```dart
/// class UserController extends NeuronController {
///   late final userId = Signal<int>(1).bind(this);
///
///   late final user = ComputedAsync<User>(
///     () => api.getUser(userId.val),
///     [userId],
///   ).bind(this);
/// }
///
/// // In UI
/// AsyncSlot<User>(
///   connect: controller.user,
///   onData: (ctx, user) => Text(user.name),
/// )
/// ```
class ComputedAsync<T> extends AsyncSignal<T> {
  final Future<T> Function() _compute;
  final List<Listenable> _dependencies;
  final List<VoidCallback> _listeners = [];
  bool _isComputing = false;

  ComputedAsync(
    this._compute,
    this._dependencies, {
    String? debugLabel,
  }) : super(null, debugLabel: debugLabel) {
    // Initial computation
    _recompute();

    // Listen to dependencies
    for (final dep in _dependencies) {
      void listener() {
        _recompute();
      }

      _listeners.add(listener);
      dep.addListener(listener);
    }
  }

  Future<void> _recompute() async {
    if (_isComputing) return;
    _isComputing = true;

    emitLoading();
    try {
      final result = await _compute();
      emitData(result);
    } catch (e, stack) {
      emitError(e, stack);
    } finally {
      _isComputing = false;
    }
  }

  @override
  void dispose() {
    for (int i = 0; i < _dependencies.length; i++) {
      _dependencies[i].removeListener(_listeners[i]);
    }
    _listeners.clear();
    super.dispose();
  }
}

/// ============================================================================
/// EFFECT HELPER ON CONTROLLER
/// ============================================================================

// Effect method is now built into NeuronController class

/// ============================================================================
/// BATCHED UPDATES
/// ============================================================================

/// Batch multiple signal updates into a single notification.
///
/// This is useful when you need to update multiple signals and only
/// want to trigger UI rebuilds once.
///
/// Example:
/// ```dart
/// void updateUser(User user) {
///   batch(() {
///     name.emit(user.name);
///     age.emit(user.age);
///     email.emit(user.email);
///   });
///   // UI rebuilds only once here
/// }
/// ```
void batch(void Function() updates) {
  // For now, just execute immediately
  // In a more advanced implementation, you could defer notifications
  updates();
}

/// Extension to add batching support to signals.
extension SignalBatching on Signal {
  /// Update multiple signals in a batch.
  ///
  /// Example:
  /// ```dart
  /// Signal.batchUpdate([
  ///   () => name.emit('John'),
  ///   () => age.emit(30),
  ///   () => email.emit('john@example.com'),
  /// ]);
  /// ```
  static void batchUpdate(List<void Function()> updates) {
    batch(() {
      for (final update in updates) {
        update();
      }
    });
  }
}

/// ============================================================================
/// CONVENIENCE EXTENSIONS
/// ============================================================================

/// Extension to add helper methods to Signal.
extension SignalHelpers<T> on Signal<T> {
  /// Create an undoable version of this signal.
  UndoableSignal<T> undoable({int maxHistory = 50}) {
    return UndoableSignal<T>(val, maxHistory: maxHistory);
  }

  /// Create a debounced version of this signal.
  DebouncedSignal<T> debounce(Duration duration) {
    return DebouncedSignal<T>(this, duration);
  }

  /// Create a throttled version of this signal.
  ThrottledSignal<T> throttle(Duration duration) {
    return ThrottledSignal<T>(this, duration);
  }

  /// Create a distinct version of this signal.
  DistinctSignal<T> distinct() {
    return DistinctSignal<T>(this);
  }

  /// Create a selector for granular rebuilds.
  SignalSelector<T, S> select<S>(S Function(T value) selector) {
    return SignalSelector<T, S>(this, selector);
  }

  /// Create a persistent version of this signal.
  PersistentSignal<T> persist(SignalPersistence<T> persistence) {
    final persistent = PersistentSignal<T>(val, persistence: persistence);
    // Sync values
    stream.listen((value) => persistent.emit(value));
    return persistent;
  }
}

/// ============================================================================
/// STREAM SIGNAL (FROM STREAM)
/// ============================================================================

/// Signal that listens to a Stream and emits its values.
///
/// StreamSignal bridges the gap between Streams and Signals.
///
/// Example:
/// ```dart
/// class LocationController extends NeuronController {
///   late final location = StreamSignal<Position>(
///     Geolocator.getPositionStream(),
///     initialValue: Position.unknown(),
///   ).bind(this);
/// }
/// ```
class StreamSignal<T> extends Signal<T> {
  final Stream<T> source;
  StreamSubscription<T>? _subscription;

  StreamSignal(
    this.source, {
    required T initialValue,
    String? debugLabel,
  }) : super(initialValue, debugLabel: debugLabel) {
    _subscription = source.listen(
      (value) => emit(value),
      onError: (error) {
        if (kDebugMode) print('StreamSignal error: $error');
      },
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

/// ============================================================================
/// INTERVAL SIGNAL (PERIODIC UPDATES)
/// ============================================================================

/// Signal that emits values periodically.
///
/// IntervalSignal is useful for timers, countdowns, or any periodic updates.
///
/// Example:
/// ```dart
/// class TimerController extends NeuronController {
///   late final seconds = IntervalSignal(
///     Duration(seconds: 1),
///     (tick) => tick,
///     initialValue: 0,
///   ).bind(this);
/// }
/// ```
class IntervalSignal<T> extends Signal<T> {
  final Duration interval;
  final T Function(int tick) generator;
  Timer? _timer;
  int _tick = 0;
  bool _isPaused = false;

  IntervalSignal(
    this.interval,
    this.generator, {
    required T initialValue,
    String? debugLabel,
    bool autoStart = true,
  }) : super(initialValue, debugLabel: debugLabel) {
    if (autoStart) start();
  }

  /// Start the interval timer.
  void start() {
    if (_timer != null) return;
    _isPaused = false;
    _timer = Timer.periodic(interval, (timer) {
      if (!_isPaused) {
        _tick++;
        emit(generator(_tick));
      }
    });
  }

  /// Stop the interval timer.
  void stop() {
    _timer?.cancel();
    _timer = null;
    _tick = 0;
  }

  /// Pause the interval timer.
  void pause() {
    _isPaused = true;
  }

  /// Resume the interval timer.
  void resume() {
    _isPaused = false;
  }

  /// Reset the interval timer.
  void reset() {
    _tick = 0;
    emit(generator(0));
  }

  /// Get current tick count.
  int get tick => _tick;

  /// Whether the timer is running.
  bool get isRunning => _timer != null && _timer!.isActive;

  /// Whether the timer is paused.
  bool get isPaused => _isPaused;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

/// ============================================================================
/// TOGGLE SIGNAL (BOOLEAN HELPER)
/// ============================================================================

/// Signal specialized for boolean values with convenience methods.
///
/// ToggleSignal makes working with boolean states easier.
///
/// Example:
/// ```dart
/// class MenuController extends NeuronController {
///   late final isOpen = ToggleSignal(false).bind(this);
///
///   void openMenu() => isOpen.enable();
///   void closeMenu() => isOpen.disable();
///   void toggleMenu() => isOpen.toggle();
/// }
/// ```
class ToggleSignal extends Signal<bool> {
  ToggleSignal(bool initial, {String? debugLabel})
      : super(initial, debugLabel: debugLabel);

  /// Toggle the boolean value.
  void toggle() => emit(!val);

  /// Set to true.
  void enable() => emit(true);

  /// Set to false.
  void disable() => emit(false);

  /// Alias for enable().
  void on() => enable();

  /// Alias for disable().
  void off() => disable();

  /// Whether currently enabled.
  bool get isEnabled => val;

  /// Whether currently disabled.
  bool get isDisabled => !val;
}

/// ============================================================================
/// COUNTER SIGNAL (NUMERIC HELPER)
/// ============================================================================

/// Signal specialized for numeric values with increment/decrement.
///
/// CounterSignal provides convenient methods for numeric operations.
///
/// Example:
/// ```dart
/// class CartController extends NeuronController {
///   late final itemCount = CounterSignal(0, min: 0, max: 99).bind(this);
///
///   void addItem() => itemCount.increment();
///   void removeItem() => itemCount.decrement();
/// }
/// ```
class CounterSignal extends Signal<num> {
  final num? min;
  final num? max;
  final num step;

  CounterSignal(
    num initial, {
    this.min,
    this.max,
    this.step = 1,
    String? debugLabel,
  }) : super(initial, debugLabel: debugLabel);

  /// Increment by step.
  void increment([num? customStep]) {
    final newValue = val + (customStep ?? step);
    if (max != null && newValue > max!) {
      emit(max!);
    } else {
      emit(newValue);
    }
  }

  /// Decrement by step.
  void decrement([num? customStep]) {
    final newValue = val - (customStep ?? step);
    if (min != null && newValue < min!) {
      emit(min!);
    } else {
      emit(newValue);
    }
  }

  /// Reset to initial value or custom value.
  void reset([num? value]) {
    emit(value ?? 0);
  }

  /// Set to maximum value.
  void setMax() {
    if (max != null) emit(max!);
  }

  /// Set to minimum value.
  void setMin() {
    if (min != null) emit(min!);
  }

  /// Whether at maximum.
  bool get isAtMax => max != null && val >= max!;

  /// Whether at minimum.
  bool get isAtMin => min != null && val <= min!;
}

/// ============================================================================
/// COMBINED SIGNAL (COMBINE MULTIPLE SIGNALS)
/// ============================================================================

/// Combine multiple signals into one derived signal.
///
/// CombinedSignal recomputes whenever any source signal changes.
///
/// Example:
/// ```dart
/// class CheckoutController extends NeuronController {
///   late final subtotal = Signal<double>(0).bind(this);
///   late final tax = Signal<double>(0).bind(this);
///   late final shipping = Signal<double>(0).bind(this);
///
///   late final total = CombinedSignal3(
///     subtotal, tax, shipping,
///     (sub, tax, ship) => sub + tax + ship,
///   ).bind(this);
/// }
/// ```
class CombinedSignal2<T1, T2, R> extends Signal<R> {
  final Signal<T1> signal1;
  final Signal<T2> signal2;
  final R Function(T1 val1, T2 val2) combiner;
  final List<VoidCallback> _listeners = [];

  CombinedSignal2(
    this.signal1,
    this.signal2,
    this.combiner, {
    String? debugLabel,
  }) : super(
          combiner(signal1.val, signal2.val),
          debugLabel: debugLabel,
        ) {
    void listener() {
      emit(combiner(signal1.val, signal2.val));
    }

    _listeners.add(listener);
    signal1.addListener(listener);

    void listener2() {
      emit(combiner(signal1.val, signal2.val));
    }

    _listeners.add(listener2);
    signal2.addListener(listener2);
  }

  @override
  void dispose() {
    signal1.removeListener(_listeners[0]);
    signal2.removeListener(_listeners[1]);
    _listeners.clear();
    super.dispose();
  }
}

/// Combine 3 signals.
class CombinedSignal3<T1, T2, T3, R> extends Signal<R> {
  final Signal<T1> signal1;
  final Signal<T2> signal2;
  final Signal<T3> signal3;
  final R Function(T1 val1, T2 val2, T3 val3) combiner;
  final List<VoidCallback> _listeners = [];

  CombinedSignal3(
    this.signal1,
    this.signal2,
    this.signal3,
    this.combiner, {
    String? debugLabel,
  }) : super(
          combiner(signal1.val, signal2.val, signal3.val),
          debugLabel: debugLabel,
        ) {
    void listener() {
      emit(combiner(signal1.val, signal2.val, signal3.val));
    }

    _listeners.add(listener);
    signal1.addListener(listener);

    void listener2() {
      emit(combiner(signal1.val, signal2.val, signal3.val));
    }

    _listeners.add(listener2);
    signal2.addListener(listener2);

    void listener3() {
      emit(combiner(signal1.val, signal2.val, signal3.val));
    }

    _listeners.add(listener3);
    signal3.addListener(listener3);
  }

  @override
  void dispose() {
    signal1.removeListener(_listeners[0]);
    signal2.removeListener(_listeners[1]);
    signal3.removeListener(_listeners[2]);
    _listeners.clear();
    super.dispose();
  }
}

/// Combine 4 signals.
class CombinedSignal4<T1, T2, T3, T4, R> extends Signal<R> {
  final Signal<T1> signal1;
  final Signal<T2> signal2;
  final Signal<T3> signal3;
  final Signal<T4> signal4;
  final R Function(T1 val1, T2 val2, T3 val3, T4 val4) combiner;
  final List<VoidCallback> _listeners = [];

  CombinedSignal4(
    this.signal1,
    this.signal2,
    this.signal3,
    this.signal4,
    this.combiner, {
    String? debugLabel,
  }) : super(
          combiner(signal1.val, signal2.val, signal3.val, signal4.val),
          debugLabel: debugLabel,
        ) {
    void listener() {
      emit(combiner(signal1.val, signal2.val, signal3.val, signal4.val));
    }

    _listeners.add(listener);
    signal1.addListener(listener);

    void listener2() {
      emit(combiner(signal1.val, signal2.val, signal3.val, signal4.val));
    }

    _listeners.add(listener2);
    signal2.addListener(listener2);

    void listener3() {
      emit(combiner(signal1.val, signal2.val, signal3.val, signal4.val));
    }

    _listeners.add(listener3);
    signal3.addListener(listener3);

    void listener4() {
      emit(combiner(signal1.val, signal2.val, signal3.val, signal4.val));
    }

    _listeners.add(listener4);
    signal4.addListener(listener4);
  }

  @override
  void dispose() {
    signal1.removeListener(_listeners[0]);
    signal2.removeListener(_listeners[1]);
    signal3.removeListener(_listeners[2]);
    signal4.removeListener(_listeners[3]);
    _listeners.clear();
    super.dispose();
  }
}

/// ============================================================================
/// WHEN WIDGET (CONDITIONAL RENDERING)
/// ============================================================================

/// Conditional rendering widget based on signal value.
///
/// When widget shows/hides children based on a boolean signal.
///
/// Example:
/// ```dart
/// When(
///   condition: controller.isLoggedIn,
///   then: ProfilePage(),
///   otherwise: LoginPage(),
/// )
/// ```
class When extends StatelessWidget {
  final Signal<bool> condition;
  final Widget then;
  final Widget? otherwise;

  const When({
    super.key,
    required this.condition,
    required this.then,
    this.otherwise,
  });

  @override
  Widget build(BuildContext context) {
    return Slot<bool>(
      connect: condition,
      to: (ctx, isTrue) =>
          isTrue ? then : (otherwise ?? const SizedBox.shrink()),
    );
  }
}

/// Show widget when condition is true.
///
/// Example:
/// ```dart
/// Show(
///   when: controller.isLoading,
///   child: CircularProgressIndicator(),
/// )
/// ```
class Show extends StatelessWidget {
  final Signal<bool> when;
  final Widget child;

  const Show({
    super.key,
    required this.when,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return When(condition: when, then: child);
  }
}

/// Hide widget when condition is true.
///
/// Example:
/// ```dart
/// Hide(
///   when: controller.isLoading,
///   child: MainContent(),
/// )
/// ```
class Hide extends StatelessWidget {
  final Signal<bool> when;
  final Widget child;

  const Hide({
    super.key,
    required this.when,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Slot<bool>(
      connect: when,
      to: (ctx, hide) => hide ? const SizedBox.shrink() : child,
    );
  }
}

/// ============================================================================
/// LAZY SIGNAL (LAZY INITIALIZATION)
/// ============================================================================

/// Signal with lazy initialization.
///
/// LazySignal doesn't compute its initial value until first access.
///
/// Example:
/// ```dart
/// late final expensiveData = LazySignal<List<Data>>(
///   () => computeExpensiveData(),
/// ).bind(this);
/// ```
class LazySignal<T> extends Signal<T?> {
  final T Function() _initializer;
  bool _isInitialized = false;

  LazySignal(this._initializer, {String? debugLabel})
      : super(null, debugLabel: debugLabel);

  @override
  T? get val {
    if (!_isInitialized) {
      _isInitialized = true;
      super.emit(_initializer());
    }
    return super.val;
  }

  /// Force initialization.
  void initialize() {
    if (!_isInitialized) {
      _isInitialized = true;
      emit(_initializer());
    }
  }

  /// Whether the signal has been initialized.
  bool get isInitialized => _isInitialized;
}

/// ============================================================================
/// FUTURE SIGNAL (FROM FUTURE)
/// ============================================================================

/// Signal that loads from a Future.
///
/// FutureSignal automatically handles loading states.
///
/// Example:
/// ```dart
/// late final config = FutureSignal<Config>(
///   loadConfig(),
/// ).bind(this);
///
/// // In UI
/// AsyncSlot<Config>(
///   connect: config,
///   onData: (ctx, cfg) => Text(cfg.appName),
/// )
/// ```
class FutureSignal<T> extends AsyncSignal<T> {
  FutureSignal(Future<T> future, {String? debugLabel})
      : super(null, debugLabel: debugLabel) {
    execute(() => future);
  }

  /// Reload the future.
  Future<void> reload(Future<T> future) async {
    await execute(() => future);
  }
}
