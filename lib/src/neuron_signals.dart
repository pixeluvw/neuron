// neuron_signals.dart
//
// ═══════════════════════════════════════════════════════════════════════════════
// NEURON SIGNALS - Core Reactive Primitives
// ═══════════════════════════════════════════════════════════════════════════════
//
// This file contains the fundamental reactive building blocks of Neuron,
// inspired by Qt's Signal/Slot pattern and modern reactive programming.
//
// ┌─────────────────────────────────────────────────────────────────────────────┐
// │ SIGNAL TYPES                                                                │
// ├─────────────────────────────────────────────────────────────────────────────┤
// │ Signal<T>       │ Core reactive value - emits when value changes           │
// │ AsyncSignal<T>  │ Async operations with loading/data/error states          │
// │ Computed<T>     │ Derived values with auto-dependency tracking             │
// └─────────────────────────────────────────────────────────────────────────────┘
//
// ┌─────────────────────────────────────────────────────────────────────────────┐
// │ ASYNC STATE (Pure Dart - No Flutter Dependency)                             │
// ├─────────────────────────────────────────────────────────────────────────────┤
// │ AsyncState<T>   │ Sealed class for async state representation              │
// │ AsyncLoading<T> │ Operation in progress                                    │
// │ AsyncData<T>    │ Operation completed successfully                         │
// │ AsyncError<T>   │ Operation failed with error                              │
// └─────────────────────────────────────────────────────────────────────────────┘
//
// ARCHITECTURE NOTES:
// - All signals extend NeuronAtom<T> for unified lifecycle management
// - Signals support automatic disposal when bound to a NeuronController
// - Computed signals use lazy evaluation with automatic dependency detection
// - AsyncState is framework-agnostic (pure Dart) for testability
//
// USAGE PATTERN:
//   Controller → Signal.emit() → Slot (Widget) rebuilds
//
// See also:
// - neuron_atom.dart      : Base reactive container
// - neuron_core.dart      : Controller, Slot widgets, service locator
// - neuron_collections.dart : ListSignal, MapSignal, SetSignal
//
// ═══════════════════════════════════════════════════════════════════════════════

import 'dart:async';
import 'dart:ui';
import 'neuron_atom.dart';

/// ============================================================================
/// `ASYNC STATE<T>` - PURE DART ASYNC STATE REPRESENTATION
/// ============================================================================

/// A sealed class representing the state of an async operation.
///
/// This is a pure Dart alternative to Flutter's `AsyncSnapshot`, enabling
/// business logic to remain framework-agnostic.
///
/// ## Pattern Matching (Dart 3.0+)
///
/// ```dart
/// final state = asyncSignal.state;
/// switch (state) {
///   case AsyncLoading():
///     return CircularProgressIndicator();
///   case AsyncData(:final value):
///     return Text('Data: $value');
///   case AsyncError(:final error):
///     return Text('Error: $error');
/// }
/// ```
sealed class AsyncState<T> {
  const AsyncState();

  /// Whether this state represents loading.
  bool get isLoading => this is AsyncLoading<T>;

  /// Whether this state has data.
  bool get hasData => this is AsyncData<T>;

  /// Whether this state has an error.
  bool get hasError => this is AsyncError<T>;

  /// The data value, or null if not in data state.
  T? get dataOrNull => switch (this) {
        AsyncData<T>(:final value) => value,
        _ => null,
      };

  /// The error, or null if not in error state.
  Object? get errorOrNull => switch (this) {
        AsyncError<T>(:final error) => error,
        _ => null,
      };

  /// The stack trace, or null if not in error state.
  StackTrace? get stackTraceOrNull => switch (this) {
        AsyncError<T>(:final stackTrace) => stackTrace,
        _ => null,
      };

  /// Maps this state to a value using the provided callbacks.
  ///
  /// ```dart
  /// final widget = state.when(
  ///   loading: () => CircularProgressIndicator(),
  ///   data: (value) => Text('$value'),
  ///   error: (e, st) => Text('Error: $e'),
  /// );
  /// ```
  R when<R>({
    required R Function() loading,
    required R Function(T value) data,
    required R Function(Object error, StackTrace? stackTrace) onError,
  }) {
    return switch (this) {
      AsyncLoading<T>() => loading(),
      AsyncData<T>(:final value) => data(value),
      AsyncError<T>(:final error, :final stackTrace) =>
        onError(error, stackTrace),
    };
  }

  /// Maps this state with optional fallback for unhandled states.
  R maybeWhen<R>({
    R Function()? loading,
    R Function(T value)? data,
    R Function(Object error, StackTrace? stackTrace)? onError,
    required R Function() orElse,
  }) {
    return switch (this) {
      AsyncLoading<T>() => loading?.call() ?? orElse(),
      AsyncData<T>(:final value) => data?.call(value) ?? orElse(),
      AsyncError<T>(:final error, :final stackTrace) =>
        onError?.call(error, stackTrace) ?? orElse(),
    };
  }
}

/// Represents the loading state of an async operation.
final class AsyncLoading<T> extends AsyncState<T> {
  const AsyncLoading();

  @override
  bool operator ==(Object other) => other is AsyncLoading<T>;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'AsyncLoading<$T>()';
}

/// Represents the data state of an async operation.
final class AsyncData<T> extends AsyncState<T> {
  /// The successfully loaded data.
  final T value;

  const AsyncData(this.value);

  @override
  bool operator ==(Object other) =>
      other is AsyncData<T> && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'AsyncData<$T>($value)';
}

/// Represents the error state of an async operation.
final class AsyncError<T> extends AsyncState<T> {
  /// The error that occurred.
  final Object error;

  /// The stack trace of the error.
  final StackTrace? stackTrace;

  const AsyncError(this.error, [this.stackTrace]);

  @override
  bool operator ==(Object other) =>
      other is AsyncError<T> && other.error == error;

  @override
  int get hashCode => error.hashCode;

  @override
  String toString() => 'AsyncError<$T>($error)';
}

// Forward declaration - NeuronController is in neuron_core.dart
// This file is imported by neuron_core.dart

/// ============================================================================
/// `SIGNAL<T>` - CORE REACTIVE VALUE CONTAINER
/// ============================================================================

/// A reactive value that notifies listeners when changed.
///
/// [Signal] is the core reactive primitive in Neuron. It holds a single
/// value and notifies listeners whenever the value changes. It extends [NeuronAtom]
/// to provide stream support and integration with the Neuron ecosystem.
///
/// ## Basic Usage
///
/// ```dart
/// class CounterController extends NeuronController {
///   // Create a signal and bind it to the controller for auto-disposal
///   late final count = Signal<int>(0).bind(this);
///
///   void increment() {
///     // Update value and notify listeners
///     count.emit(count.val + 1);
///   }
/// }
/// ```
///
/// ## Binding to UI
///
/// Use [Slot] to connect signals to widgets. The widget will automatically
/// rebuild when the signal emits a new value.
///
/// ```dart
/// Slot<int>(
///   connect: controller.count,
///   to: (context, value) => Text('Count: $value'),
/// )
/// ```
///
/// ## Reactive Streams
///
/// Signals expose a broadcast [stream] that emits values on change. This allows
/// integration with RxDart or standard Stream builders.
///
/// ```dart
/// controller.count.stream
///   .debounceTime(Duration(milliseconds: 500))
///   .listen((val) => print('Debounced: $val'));
/// ```
///
/// ## Equality & Updates
///
/// [emit] checks if the new value is different from the current value using
/// the `!=` operator (or a custom `equals` callback if provided).
///
/// - `emit(val)`: Updates value and notifies if changed.
/// - `value = val`: Same as emit.
/// - `val`: Getter alias for `value`.
///
/// See also:
/// - [AsyncSignal] - For async operations with loading/error states
/// - [Computed] - For derived values that auto-update
/// - [Slot] - Widget for binding signals to UI
class Signal<T> extends NeuronAtom<T> {
  /// Debug label for identification in DevTools.
  final String? debugLabel;

  final StreamController<T> _streamController = StreamController<T>.broadcast();

  /// Creates a signal with an initial value.
  Signal(
    super.value, {
    this.debugLabel,
    super.equals,
    super.guard,
    super.onListen,
    super.onCancel,
  });

  /// Override value getter to support dependency tracking for Computed.
  @override
  T get value {
    _DependencyTracker.track(this);
    return super.value;
  }

  /// Assigns a new value and notifies listeners if the value changed.
  ///
  /// This method only notifies listeners if the new value is different
  /// from the current [value] (using `!=` operator).
  ///
  /// ```dart
  /// count.emit(5);        // Notifies if count.val != 5
  /// count.emit(count.val + 1); // Increment and notify
  /// ```
  ///
  /// The new value is also published to the [stream].
  ///
  /// Throws an assertion error in debug mode if called on a disposed signal.
  void emit(T val) {
    assert(!isDisposed, 'Cannot emit on a disposed Signal');
    if (value != val) {
      value = val;
      _streamController.add(val);
    }
  }

  /// Short alias for the current [value].
  ///
  /// This provides a more convenient way to read the signal's value:
  /// ```dart
  /// print(count.val);        // Instead of count.value
  /// doubled = count.val * 2; // Cleaner syntax
  /// ```
  T get val => value;

  /// A broadcast stream of value changes.
  ///
  /// The stream emits whenever [emit] is called with a different value.
  /// This is useful for reactive programming patterns:
  ///
  /// ```dart
  /// count.stream
  ///   .where((val) => val > 10)
  ///   .listen((val) => print('Count exceeded 10: $val'));
  /// ```
  Stream<T> get stream => _streamController.stream;

  @override
  void dispose() {
    _streamController.close();
    super.dispose();
  }
}

/// ============================================================================
/// `ASYNC SIGNAL<T>` - ASYNC STATE MANAGEMENT
/// ============================================================================

/// Async state wrapper for handling loading, data, and error states.
///
/// [AsyncSignal] simplifies async operations by managing three states:
/// - **loading**: Operation in progress ([isLoading] == true)
/// - **data**: Operation completed successfully ([hasData] == true)
/// - **error**: Operation failed ([hasError] == true)
///
/// Uses the pure Dart [AsyncState] sealed class, allowing business logic
/// to remain framework-agnostic.
///
/// ## Basic Usage
///
/// ```dart
/// class UserController extends NeuronController {
///   late final user = AsyncSignal<User>(null).bind(this);
///
///   Future<void> loadUser() async {
///     user.emitLoading();
///     try {
///       final data = await api.getUser();
///       user.emitData(data);
///     } catch (e, stack) {
///       user.emitError(e, stack);
///     }
///   }
/// }
/// ```
///
/// ## Automatic Execution
///
/// Use [execute] to handle the try-catch-emit flow automatically:
///
/// ```dart
/// Future<void> loadUser() async {
///   await user.execute(() => api.getUser());
/// }
/// ```
///
/// ## Refresh Capability
///
/// Use [refresh] to re-execute the last operation:
///
/// ```dart
/// user.refresh(); // Re-runs the last operation passed to execute()
/// ```
///
/// ## Pattern Matching
///
/// Use Dart 3's pattern matching for exhaustive state handling:
///
/// ```dart
/// switch (user.state) {
///   case AsyncLoading():
///     return CircularProgressIndicator();
///   case AsyncData(:final value):
///     return Text(value.name);
///   case AsyncError(:final error):
///     return Text('Error: $error');
/// }
/// ```
///
/// ## Binding to UI
///
/// Use [AsyncSlot] to handle all three states declaratively:
///
/// ```dart
/// AsyncSlot<User>(
///   connect: controller.user,
///   onData: (ctx, user) => Text(user.name),
///   onLoading: (ctx) => CircularProgressIndicator(),
///   onError: (ctx, err) => Text('Error: $err'),
/// )
/// ```
///
/// See also:
/// - [AsyncState] - Pure Dart sealed class for async state
/// - [AsyncSlot] - Widget for binding async signals to UI
/// - [execute] - Helper method to manage async operations
class AsyncSignal<T> extends NeuronAtom<AsyncState<T>> {
  /// Debug label for identification in DevTools.
  final String? debugLabel;

  /// Stores the last operation for refresh capability.
  Future<T> Function()? _lastOperation;

  /// Creates an async signal with optional initial data.
  AsyncSignal(
    T? initial, {
    this.debugLabel,
    super.equals,
    super.guard,
    super.onListen,
    super.onCancel,
  }) : super(
          initial != null ? AsyncData<T>(initial) : AsyncLoading<T>(),
        );

  /// The current async state.
  AsyncState<T> get state => value;

  /// Set loading state.
  void emitLoading() {
    value = AsyncLoading<T>();
  }

  /// Set error state.
  void emitError(Object err, [StackTrace? stackTrace]) {
    value = AsyncError<T>(err, stackTrace);
  }

  /// Set data state.
  void emitData(T data) {
    value = AsyncData<T>(data);
  }

  /// Execute an async operation and handle states automatically.
  ///
  /// Stores the operation for later [refresh] calls.
  Future<void> execute(Future<T> Function() operation) async {
    _lastOperation = operation;
    emitLoading();
    try {
      final data = await operation();
      emitData(data);
    } catch (e, stack) {
      emitError(e, stack);
    }
  }

  /// Re-execute the last operation.
  ///
  /// Throws [StateError] if no operation has been executed yet.
  ///
  /// ```dart
  /// // Initial load
  /// await user.execute(() => api.getUser());
  ///
  /// // Later, to refresh:
  /// await user.refresh();
  /// ```
  Future<void> refresh() async {
    if (_lastOperation == null) {
      throw StateError(
        'Cannot refresh: no operation has been executed yet. '
        'Call execute() first.',
      );
    }
    await execute(_lastOperation!);
  }

  /// Whether a refresh operation is possible.
  bool get canRefresh => _lastOperation != null;

  /// Current data (null if loading or error).
  T? get data => state.dataOrNull;

  /// Current error (null if loading or has data).
  Object? get error => state.errorOrNull;

  /// Whether currently loading.
  bool get isLoading => state.isLoading;

  /// Whether has data.
  bool get hasData => state.hasData;

  /// Whether has error.
  bool get hasError => state.hasError;
}

/// ============================================================================
/// `COMPUTED<T>` - DERIVED REACTIVE VALUES
/// ============================================================================

/// Error thrown when a circular dependency is detected in computed signals.
class CircularDependencyError extends Error {
  /// The chain of computed signals forming the cycle.
  final List<String> dependencyChain;

  CircularDependencyError(this.dependencyChain);

  @override
  String toString() {
    return 'CircularDependencyError: Detected circular dependency in computed signals.\n'
        'Dependency chain: ${dependencyChain.join(' -> ')} -> ${dependencyChain.first}';
  }
}

/// Tracking context for automatic dependency detection.
///
/// This class implements the core mechanism for auto-tracking dependencies
/// in [Computed] signals. It uses a thread-local-like pattern where:
///
/// 1. Before computing, [Computed] calls [collectDependencies]
/// 2. This sets [_currentDependencies] to an empty set
/// 3. During computation, any [Signal.value] access calls [track]
/// 4. [track] adds the signal to [_currentDependencies]
/// 5. After computation, the set contains all accessed signals
///
/// ## Circular Dependency Detection
///
/// Uses [_computingStack] to track nested computations. If a [Computed]
/// appears twice in the stack, it means A depends on B which depends on A.
///
/// ## Thread Safety Note
///
/// This implementation assumes single-threaded execution (Dart's event loop).
/// The static variables are safe because Dart is single-threaded and
/// computations run synchronously.
class _DependencyTracker {
  /// Stack of Computed signals currently being evaluated.
  /// Used to detect circular dependencies (A -> B -> A).
  static final Set<Computed> _computingStack = {};

  /// The dependency set being populated by the current computation.
  /// Null when no computation is in progress.
  static Set<NeuronAtom>? _currentDependencies;

  /// Called by Signal.value getter to register an access.
  ///
  /// If a computation is in progress ([_currentDependencies] is non-null),
  /// the accessed atom is added as a dependency.
  static void track(NeuronAtom atom) {
    // Only track if we're inside a Computed evaluation
    _currentDependencies?.add(atom);
  }

  /// Executes [computation] while collecting all signal accesses.
  ///
  /// Returns the set of [NeuronAtom]s that were accessed during the
  /// computation. These become the dependencies of the [Computed].
  ///
  /// Throws [CircularDependencyError] if [computed] is already in the
  /// evaluation stack (circular dependency detected).
  static Set<NeuronAtom> collectDependencies(
    Computed computed,
    void Function() computation,
  ) {
    // ─────────────────────────────────────────────────────────────────────────
    // Step 1: Check for circular dependency
    // ─────────────────────────────────────────────────────────────────────────
    if (_computingStack.contains(computed)) {
      // Build a human-readable chain for the error message
      final chain = _computingStack
          .map((c) => c.debugLabel ?? 'Computed@${c.hashCode}')
          .toList();
      throw CircularDependencyError(chain);
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Step 2: Set up tracking context
    // ─────────────────────────────────────────────────────────────────────────
    _computingStack.add(computed);
    final previousDependencies = _currentDependencies; // Save outer context
    final dependencies = _currentDependencies = <NeuronAtom>{}; // Fresh set

    try {
      // ───────────────────────────────────────────────────────────────────────
      // Step 3: Run computation (Signal accesses will call track())
      // ───────────────────────────────────────────────────────────────────────
      computation();
      return dependencies;
    } finally {
      // ───────────────────────────────────────────────────────────────────────
      // Step 4: Restore previous context (supports nested Computed)
      // ───────────────────────────────────────────────────────────────────────
      _currentDependencies = previousDependencies;
      _computingStack.remove(computed);
    }
  }
}

/// A derived signal that automatically recalculates when dependencies change.
///
/// [Computed] creates a read-only signal whose value is computed from other
/// signals. It automatically detects dependencies and recalculates whenever
/// any dependency changes.
///
/// ## Key Features
///
/// - **Automatic dependency tracking**: No need to manually list dependencies
/// - **Lazy evaluation**: Only computes when accessed and listeners exist
/// - **Error handling**: Captures computation errors gracefully
/// - **Circular dependency detection**: Throws clear error on cycles
///
/// ## Basic Usage
///
/// ```dart
/// class CalculatorController extends NeuronController {
///   late final width = Signal<double>(10).bind(this);
///   late final height = Signal<double>(20).bind(this);
///
///   // Dependencies detected automatically!
///   late final area = Computed<double>(
///     () => width.val * height.val,
///   ).bind(this);
/// }
/// ```
///
/// ## Error Handling
///
/// If the computation throws, the error is captured and can be checked:
///
/// ```dart
/// late final ratio = Computed<double>(() {
///   if (height.val == 0) throw ArgumentError('Cannot divide by zero');
///   return width.val / height.val;
/// }).bind(this);
///
/// // Later:
/// if (ratio.hasError) {
///   print('Error: ${ratio.error}');
/// } else {
///   print('Ratio: ${ratio.val}');
/// }
/// ```
///
/// ## Chaining
///
/// Computed signals can depend on other computed signals:
///
/// ```dart
/// late final doubled = Computed<int>(() => count.val * 2).bind(this);
/// late final quadrupled = Computed<int>(() => doubled.val * 2).bind(this);
/// ```
///
/// ## Initial Value
///
/// Provide an initial value to defer computation:
///
/// ```dart
/// late final expensive = Computed<Data>(
///   () => computeExpensiveValue(),
///   initialValue: Data.empty(),
/// ).bind(this);
/// ```
///
/// **Note**: Computed signals are read-only. You cannot set their value.
/// To change them, modify their dependencies.
///
/// See also:
/// - [Signal] - Basic reactive value
/// - [Slot] - Widget for binding to UI
class Computed<T> extends NeuronAtom<T> {
  final T Function() _compute;

  /// Debug label for identification in DevTools.
  final String? debugLabel;

  // User-provided lifecycle callbacks
  final VoidCallback? _userOnListen;
  final VoidCallback? _userOnCancel;

  // Lazy evaluation state
  bool _isStale = true;
  T? _cachedValue;
  Object? _error;
  StackTrace? _stackTrace;

  // Dependency management
  Set<NeuronAtom> _dependencies = {};
  final Map<NeuronAtom, VoidCallback> _subscriptions = {};

  /// Creates a computed signal with automatic dependency tracking.
  ///
  /// The [compute] function is called lazily when the value is accessed
  /// and there are active listeners. Dependencies are detected automatically.
  ///
  /// Optionally provide [initialValue] to defer the first computation.
  Computed(
    this._compute, {
    T? initialValue,
    this.debugLabel,
    super.equals,
    super.guard,
    VoidCallback? onListen,
    VoidCallback? onCancel,
  })  : _userOnListen = onListen,
        _userOnCancel = onCancel,
        // Use a temporary placeholder that will be immediately overwritten
        super(initialValue ?? _computeInitial(_compute)) {
    _cachedValue = value;
    _isStale = false;
  }

  /// Helper to compute initial value during construction.
  static T _computeInitial<T>(T Function() compute) {
    // Note: Cannot track dependencies here since Computed instance isn't created yet
    // Dependencies will be tracked on first recompute when listeners are added
    return compute();
  }

  /// Called when the first listener is added - sets up dependency subscriptions.
  @override
  void onActive() {
    super.onActive();
    _userOnListen?.call();
    // When first listener added, sync value and subscribe to dependencies
    _recompute();
    _setupSubscriptions();
  }

  /// Called when the last listener is removed - tears down subscriptions.
  @override
  void onInactive() {
    super.onInactive();
    _userOnCancel?.call();
    // When last listener removed, unsubscribe from dependencies (go cold)
    _teardownSubscriptions();
    _isStale = true; // Mark stale so next access recomputes
  }

  /// Legacy constructor for backward compatibility.
  ///
  /// Accepts explicit dependencies list. Prefer the auto-tracking constructor.
  @Deprecated('Use Computed(() => ...) with automatic dependency tracking')
  factory Computed.withDependencies(
    T Function() compute,
    List<NeuronAtom> dependencies, {
    String? debugLabel,
    bool Function(T a, T b)? equals,
    T Function(T current, T next)? guard,
    VoidCallback? onListen,
    VoidCallback? onCancel,
  }) {
    final computed = Computed<T>(
      compute,
      debugLabel: debugLabel,
      equals: equals,
      guard: guard,
      onListen: onListen,
      onCancel: onCancel,
    );
    // Force these as dependencies even if not accessed in first compute
    computed._dependencies = dependencies.toSet();
    computed._setupSubscriptions();
    return computed;
  }

  /// Whether this computed has an error from the last computation.
  bool get hasError => _error != null;

  /// The error from the last computation, if any.
  Object? get error => _error;

  /// The stack trace from the last computation error, if any.
  StackTrace? get stackTrace => _stackTrace;

  @override
  T get value {
    // Register this access for parent Computed tracking
    _DependencyTracker.track(this);

    // If we have listeners, use cached value (updated via subscriptions)
    // If no listeners (cold), always recompute to get fresh value
    if (!hasListeners || _isStale) {
      _recompute();
    }

    if (_error != null) {
      // Return last good value if we have one, otherwise rethrow
      if (_cachedValue != null) {
        return _cachedValue as T;
      }
      Error.throwWithStackTrace(_error!, _stackTrace ?? StackTrace.current);
    }

    return _cachedValue as T;
  }

  /// Short alias for the current [value].
  T get val => value;

  @override
  set value(T newValue) {
    throw UnsupportedError(
      'Cannot set the value of a Computed signal. '
      'Update its dependencies instead.',
    );
  }

  void _recompute() {
    final previousError = _error;
    _error = null;
    _stackTrace = null;

    try {
      final newDependencies = _DependencyTracker.collectDependencies(this, () {
        _cachedValue = _compute();
      });

      // Update dependencies if they changed
      if (!_setEquals(newDependencies, _dependencies)) {
        _dependencies = newDependencies;
        if (hasListeners) {
          _setupSubscriptions();
        }
      }

      _isStale = false;
    } catch (e, st) {
      _error = e;
      _stackTrace = st;
      _isStale = false;

      // Only notify if error state changed and we have listeners
      if (previousError == null && hasListeners) {
        notifyListeners();
      }
    }
  }

  void _setupSubscriptions() {
    // Unsubscribe from old dependencies not in new set
    final toRemove = <NeuronAtom>[];
    for (final dep in _subscriptions.keys) {
      if (!_dependencies.contains(dep)) {
        dep.removeListener(_subscriptions[dep]!);
        toRemove.add(dep);
      }
    }
    for (final dep in toRemove) {
      _subscriptions.remove(dep);
    }

    // Subscribe to new dependencies
    for (final dep in _dependencies) {
      if (!_subscriptions.containsKey(dep)) {
        void listener() {
          _markStale();
        }

        _subscriptions[dep] = listener;
        dep.addListener(listener);
      }
    }
  }

  void _markStale() {
    if (!_isStale) {
      _isStale = true;
      // Recompute immediately and notify if value changed
      final oldValue = _cachedValue;
      final oldError = _error;
      _recompute();

      // Notify if value or error state changed
      final valueChanged = equals != null
          ? !equals!(_cachedValue as T, oldValue as T)
          : _cachedValue != oldValue;
      final errorChanged = (_error != null) != (oldError != null);

      if (valueChanged || errorChanged) {
        notifyListeners();
      }
    }
  }

  void _teardownSubscriptions() {
    for (final entry in _subscriptions.entries) {
      entry.key.removeListener(entry.value);
    }
    _subscriptions.clear();
  }

  @override
  void dispose() {
    _teardownSubscriptions();
    _dependencies.clear();
    super.dispose();
  }

  static bool _setEquals<E>(Set<E> a, Set<E> b) {
    if (a.length != b.length) return false;
    for (final e in a) {
      if (!b.contains(e)) return false;
    }
    return true;
  }
}
