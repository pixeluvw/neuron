// neuron_signals.dart
//
// Core signal types for Neuron
// Inspired by Qt's Signals & Slots pattern
//
// Includes:
// - Signal<T> - Core reactive value container
// - AsyncSignal<T> - Async operation handling with loading/error states
// - Computed<T> - Derived signals that auto-update

import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart' show AsyncSnapshot, ConnectionState;
import 'neuron_atom.dart';

// Forward declaration - NeuronController is in neuron_core.dart
// This file is imported by neuron_core.dart

/// ============================================================================
/// SIGNAL<T> - CORE REACTIVE VALUE CONTAINER
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
  void emit(T val) {
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
/// ASYNC SIGNAL<T> - ASYNC STATE MANAGEMENT
/// ============================================================================

/// Async state wrapper for handling loading, data, and error states.
///
/// [AsyncSignal] simplifies async operations by managing three states:
/// - **loading**: Operation in progress ([isLoading] == true)
/// - **data**: Operation completed successfully ([hasData] == true)
/// - **error**: Operation failed ([hasError] == true)
///
/// It wraps Flutter's [AsyncSnapshot] to provide a familiar API.
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
/// - [AsyncSlot] - Widget for binding async signals to UI
/// - [execute] - Helper method to manage async operations
class AsyncSignal<T> extends NeuronAtom<AsyncSnapshot<T>> {
  /// Debug label for identification in DevTools.
  final String? debugLabel;

  /// Creates an async signal with optional initial data.
  AsyncSignal(
    T? initial, {
    this.debugLabel,
    super.equals,
    super.guard,
    super.onListen,
    super.onCancel,
  }) : super(
          initial != null
              ? AsyncSnapshot.withData(ConnectionState.none, initial)
              : const AsyncSnapshot.waiting(),
        );

  /// Set loading state.
  void emitLoading() {
    value = const AsyncSnapshot.waiting();
  }

  /// Set error state.
  void emitError(Object err, [StackTrace? stackTrace]) {
    value = stackTrace != null
        ? AsyncSnapshot.withError(ConnectionState.done, err, stackTrace)
        : AsyncSnapshot.withError(ConnectionState.done, err);
  }

  /// Set data state.
  void emitData(T data) {
    value = AsyncSnapshot.withData(ConnectionState.done, data);
  }

  /// Execute an async operation and handle states automatically.
  Future<void> execute(Future<T> Function() operation) async {
    emitLoading();
    try {
      final data = await operation();
      emitData(data);
    } catch (e, stack) {
      emitError(e, stack);
    }
  }

  /// Current data (null if loading or error).
  T? get data => value.data;

  /// Current error (null if loading or has data).
  Object? get error => value.error;

  /// Whether currently loading.
  bool get isLoading => value.connectionState == ConnectionState.waiting;

  /// Whether has data.
  bool get hasData => value.hasData;

  /// Whether has error.
  bool get hasError => value.hasError;
}

/// ============================================================================
/// COMPUTED<T> - DERIVED REACTIVE VALUES
/// ============================================================================

/// A derived signal that automatically recalculates when dependencies change.
///
/// [Computed] creates a read-only signal whose value is computed from other
/// signals. It listens to all dependencies and recalculates whenever any
/// dependency changes.
///
/// ## Basic Usage
///
/// ```dart
/// class CalculatorController extends NeuronController {
///   late final width = Signal<double>(10).bind(this);
///   late final height = Signal<double>(20).bind(this);
///
///   // Area updates automatically when width or height changes
///   late final area = Computed<double>(
///     () => width.val * height.val,
///     [width, height],
///   ).bind(this);
/// }
/// ```
///
/// ## Multiple Dependencies
///
/// Computed signals can depend on any number of signals:
///
/// ```dart
/// late final total = Computed<int>(
///   () => price.val * quantity.val + tax.val,
///   [price, quantity, tax],
/// ).bind(this);
/// ```
///
/// ## Chaining
///
/// Computed signals can depend on other computed signals, creating a
/// reactive dependency graph:
///
/// ```dart
/// late final doubled = Computed<int>(() => count.val * 2, [count]).bind(this);
/// late final quadrupled = Computed<int>(() => doubled.val * 2, [doubled]).bind(this);
/// ```
///
/// **Note**: Computed signals are read-only. You cannot call `emit()` on them.
/// To change their value, modify their dependencies.
///
/// See also:
/// - [Signal] - Basic reactive value
/// - [Slot] - Widget for binding to UI
class Computed<T> extends NeuronAtom<T> {
  final T Function() _calc;
  final List<NeuronAtom> _dependencies;
  final List<VoidCallback> _listeners = [];

  /// Creates a computed signal from a calculation and its dependencies.
  Computed(
    this._calc,
    this._dependencies, {
    super.equals,
    super.guard,
    super.onListen,
    super.onCancel,
  }) : super(_calc()) {
    for (final dep in _dependencies) {
      void listener() {
        value = _calc();
      }

      _listeners.add(listener);
      dep.addListener(listener);
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
