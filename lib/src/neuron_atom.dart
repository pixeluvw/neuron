// neuron_atom.dart
//
// ═══════════════════════════════════════════════════════════════════════════════
// NEURON ATOM - Foundation Reactive Container
// ═══════════════════════════════════════════════════════════════════════════════
//
// NeuronAtom<T> is the foundational building block of the Neuron reactive
// system. It provides a lightweight, observable value container that serves
// as the base class for Signal<T>, AsyncSignal<T>, and Computed<T>.
//
// KEY FEATURES:
// - 🔔 Listener Management  : Add/remove/subscribe to value changes
// - 🛡️ Value Guards        : Intercept and transform values before emission
// - ⚖️  Custom Equality     : Control when listeners are notified
// - 🔄 Reset Support       : Return to initial value
// - 🧹 Auto-disposal       : Clean up resources when done
// - 🎯 Selective Listening : Create derived atoms that watch specific fields
//
// INHERITANCE HIERARCHY:
//   NeuronAtom<T>
//      ├── Signal<T>       : Synchronous reactive value
//      ├── AsyncSignal<T>  : Async state (loading/data/error)
//      └── Computed<T>     : Derived value with auto-tracking
//
// LIFECYCLE HOOKS:
//   onActive()   - Called when first listener subscribes
//   onInactive() - Called when last listener unsubscribes
//
// These hooks enable lazy resource management (e.g., WebSocket connections,
// stream subscriptions) that only activate when the atom is being observed.
//
// EXAMPLE:
// ```dart
// final counter = NeuronAtom<int>(0);
//
// // Subscribe and auto-unsubscribe
// final cancel = counter.subscribe(() {
//   print('Counter: ${counter.value}');
// });
//
// counter.value = 1; // Prints: Counter: 1
// counter.value = 2; // Prints: Counter: 2
// cancel();          // Unsubscribes
// ```
//
// See also:
// - neuron_signals.dart : Signal, AsyncSignal, Computed definitions
// - neuron_core.dart    : NeuronController and binding utilities
//
// ═══════════════════════════════════════════════════════════════════════════════

// ═══════════════════════════════════════════════════════════════════════════════

import 'dart:ui';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:meta/meta.dart';

/// A zero-cost abstraction for a listener handle.
///
/// In Dart 3, this `extension type` completely disappears at runtime.
/// It wraps a standard `VoidCallback` but adds a generic `.cancel()` wrapper
/// method, avoiding the creation of an explicit closure allocation in `subscribe`.
extension type AtomListener(VoidCallback _call) {
  /// Invokes the underlying listener.
  void invoke() => _call();
}

/// Interface for objects that need cleanup when no longer used.
///
/// Classes implementing [Disposable] should release resources, cancel
/// subscriptions, and perform cleanup in their [dispose] method.
///
/// ## Usage
///
/// ```dart
/// class MyResource implements Disposable {
///   StreamSubscription? _subscription;
///
///   void start() {
///     _subscription = someStream.listen(...);
///   }
///
///   @override
///   void dispose() {
///     _subscription?.cancel();
///     _subscription = null;
///   }
/// }
/// ```
///
/// **Important**: Always call [dispose] when the object is no longer needed
/// to prevent memory leaks.
abstract class Disposable {
  /// Releases resources held by this object.
  ///
  /// After calling [dispose], the object should not be used.
  void dispose();
}

/// Global error handler for Neuron framework errors.
///
/// This handler is called when errors occur in listeners or other Neuron
/// operations. Override this to customize error reporting, logging,
/// or crash analytics integration.
///
/// ## Default Behavior
///
/// By default, errors are printed only in debug mode to avoid cluttering
/// release builds. Override for custom behavior:
///
/// ## Customization
///
/// ```dart
/// void main() {
///   // Send errors to crash reporting service
///   neuronErrorHandler = (message, error, stackTrace) {
///     FirebaseCrashlytics.instance.recordError(error, stackTrace);
///   };
///
///   runApp(MyApp());
/// }
/// ```
///
/// ## Parameters
///
/// - `message`: Context about where the error occurred
/// - `error`: The actual error/exception object
/// - `stackTrace`: Stack trace if available (may be null)
void Function(String message, Object error, StackTrace? stackTrace)
    neuronErrorHandler = _defaultErrorHandler;

void _defaultErrorHandler(
    String message, Object error, StackTrace? stackTrace) {
  if (kDebugMode) {
    // ignore: avoid_print
    print('$message: $error');
    if (stackTrace != null) {
      // ignore: avoid_print
      print(stackTrace);
    }
  }
}

/// ═══════════════════════════════════════════════════════════════════════════════
/// ATOM POOLING / ARENA ALLOCATION
/// ═══════════════════════════════════════════════════════════════════════════════
///
/// An object pool for recycling standard [NeuronAtom] instances to avoid GC thrashing
/// and constructor allocation penalties when rapid instantiations occur (e.g., inside Lists).
class NeuronAtomPool {
  static final List<NeuronAtom<dynamic>> _freeList = [];
  static const int _maxPoolSize = 1000;

  /// Retrieves an atom from the pool, or creates a new one if the pool is empty.
  static NeuronAtom<T> obtain<T>(T initialValue) {
    for (int i = 0; i < _freeList.length; i++) {
      if (_freeList[i] is NeuronAtom<T>) {
        final atom = _freeList.removeAt(i) as NeuronAtom<T>;
        // Reset the pooled atom
        atom._value = initialValue;
        atom._initialValue = initialValue;
        atom._previousValue = null;
        atom._state = 0; // Clear bitmask flags
        atom._listeners.clear();
        return atom;
      }
    }
    return NeuronAtom<T>(initialValue);
  }

  /// Returns an atom to the pool.
  static void release(NeuronAtom<dynamic> atom) {
    if (_freeList.length < _maxPoolSize) {
      _freeList.add(atom);
    }
  }
}

/// A modern, lightweight reactive value container.
///
/// [NeuronAtom] is the foundation of Neuron's reactive system. It holds a
/// value of type [T] and notifies listeners when the value changes. Think of
/// it as a smarter version of Flutter's `ValueNotifier` with additional features.
///
/// ## Core Features
///
/// - **Value observation**: Listeners are notified when value changes
/// - **Equality checking**: Custom equality to control when listeners fire
/// - **Value guards**: Transform or validate values before emission
/// - **Initial value**: Access original value via [initialValue]
/// - **Previous value**: Track changes via [previousValue]
/// - **Lifecycle hooks**: [onActive] and [onInactive] for resource management
/// - **RAII Finalizer**: Automatically calls [dispose] if an atom is garbage collected
///
/// ## Basic Usage
///
/// ```dart
/// final counter = NeuronAtom<int>(0);
///
/// // Listen to changes
/// final cancel = counter.subscribe(() {
///   print('New value: ${counter.value}');
/// });
///
/// counter.value = 1;  // Prints: New value: 1
/// counter.value = 1;  // No print (value unchanged)
/// counter.value = 2;  // Prints: New value: 2
///
/// cancel(); // Stop listening
/// ```
///
/// ## Custom Equality
///
/// Control when listeners are notified:
///
/// ```dart
/// final user = NeuronAtom<User>(
///   User(id: 1),
///   equals: (a, b) => a.id == b.id,  // Only notify if ID changes
/// );
/// ```
///
/// ## Value Guards
///
/// Transform or validate values before emission:
///
/// ```dart
/// final percentage = NeuronAtom<int>(
///   50,
///   guard: (current, next) => next.clamp(0, 100),  // Ensure 0-100 range
/// );
///
/// percentage.value = 150;  // Actually sets to 100
/// ```
///
/// ## Selective Listening
///
/// Create derived atoms that only update for specific changes:
///
/// ```dart
/// final user = NeuronAtom<User>(User(name: 'Alice', age: 30));
/// final nameOnly = user.select((u) => u.name);  // Only fires on name change
/// ```
///
/// **Note**: For most use cases, use [Signal<T>] instead, which extends
/// [NeuronAtom] with stream support and controller binding.
///
/// See also:
/// - [Signal] - Preferred reactive value with stream support
/// - [AsyncSignal] - For async operations
/// - [Computed] - For derived values
class NeuronAtom<T> implements Disposable {
  static final Finalizer<VoidCallback> _finalizer =
      Finalizer<VoidCallback>((callback) => callback());

  static final Type _neuronAtomType = _typeOf<NeuronAtom<dynamic>>();
  static Type _typeOf<X>() => X;

  /// Token for finalizer detachment.
  final Object _finalizerToken = Object();

  /// Current value stored in this atom.
  T _value;

  /// The value this atom was initialized with (for [reset]).
  T _initialValue;

  /// The value before the most recent change (null if never changed).
  T? _previousValue;

  /// List of callbacks to invoke when value changes.
  final List<AtomListener> _listeners = [];

  // ==========================================
  // High-Performance Bitmask State
  // ==========================================
  static const int _flagDisposed = 1 << 0; // 0001

  /// Bitfield packing multiple states into a single integer.
  int _state = 0;

  /// Modifies the internal state bitmask.
  @pragma('vm:prefer-inline')
  void _setFlag(int flag, bool value) {
    if (value) {
      _state |= flag;
    } else {
      _state &= ~flag;
    }
  }

  /// Evaluates a specific state flag.
  @pragma('vm:prefer-inline')
  bool _hasFlag(int flag) => (_state & flag) != 0;

  /// Whether this atom has been disposed.
  @protected
  bool get isDisposed => _hasFlag(_flagDisposed);

  // ─────────────────────────────────────────────────────────────────────────
  // Configuration Options
  // ─────────────────────────────────────────────────────────────────────────

  /// Custom equality function to determine if value has changed.
  ///
  /// If provided, this function is called instead of `==` operator.
  /// Return `true` if values should be considered equal (no notification).
  ///
  /// ```dart
  /// NeuronAtom<User>(
  ///   user,
  ///   equals: (a, b) => a.id == b.id,
  /// )
  /// ```
  final bool Function(T a, T b)? equals;

  /// Value guard/transformer called before setting a new value.
  ///
  /// Use this to validate, clamp, or transform values:
  ///
  /// ```dart
  /// NeuronAtom<int>(
  ///   50,
  ///   guard: (current, next) => next.clamp(0, 100),
  /// )
  /// ```
  final T Function(T current, T next)? guard;

  // ─────────────────────────────────────────────────────────────────────────
  // Lifecycle Callbacks
  // ─────────────────────────────────────────────────────────────────────────

  /// Callback invoked when the first listener subscribes.
  ///
  /// Use this to start expensive resources only when needed.
  final VoidCallback? onListen;

  /// Callback invoked when the last listener unsubscribes.
  ///
  /// Use this to clean up resources when no one is listening.
  final VoidCallback? onCancel;

  /// Creates a [NeuronAtom] with an initial value.
  NeuronAtom(
    T value, {
    this.equals,
    this.guard,
    this.onListen,
    this.onCancel,
  })  : _value = value,
        _initialValue = value {
    _finalizer.attach(this, () {
      if (!_hasFlag(_flagDisposed)) {
        _setFlag(_flagDisposed, true);
        _listeners.clear();
      }
    }, detach: _finalizerToken);
  }

  /// The current value of the atom.
  ///
  /// Setting a new value will notify listeners if the new value is different
  /// from the current value (using [equals] or `!=` operator).
  T get value => _value;

  /// The initial value of the atom.
  T get initialValue => _initialValue;

  /// The previous value of the atom (before the last change).
  T? get previousValue => _previousValue;

  set value(T newValue) {
    if (_hasFlag(_flagDisposed)) return;

    // Apply guard if present
    final guardedValue = guard != null ? guard!(_value, newValue) : newValue;

    // Check equality
    final areEqual =
        equals != null ? equals!(_value, guardedValue) : _value == guardedValue;

    if (!areEqual) {
      _previousValue = _value;
      _value = guardedValue;
      notifyListeners();
    }
  }

  /// Resets the atom to its initial value.
  void reset() {
    value = _initialValue;
  }

  /// Adds a listener to be called when the value changes.
  AtomListener addListener(VoidCallback listener) {
    if (_hasFlag(_flagDisposed)) return AtomListener(() {});

    final handle = AtomListener(listener);
    final wasEmpty = _listeners.isEmpty;
    _listeners.add(handle);

    if (wasEmpty) {
      onActive();
    }
    return handle;
  }

  /// Removes a previously added listener.
  void removeListener(AtomListener listener) {
    if (_hasFlag(_flagDisposed)) return;

    _listeners.remove(listener);

    if (_listeners.isEmpty) {
      onInactive();
    }
  }

  /// Adds a listener and returns a callback that cancels the subscription when called.
  ///
  /// This is a convenience method for easier cleanup.
  /// ```dart
  /// final cancel = atom.subscribe(() => print(atom.value));
  /// // ... later
  /// cancel();
  /// ```
  VoidCallback subscribe(VoidCallback listener) {
    assert(
        !_hasFlag(_flagDisposed), 'Cannot subscribe to a disposed NeuronAtom');
    final handle = addListener(listener);
    return () => removeListener(handle);
  }

  /// Manually notifies all listeners.
  ///
  /// Use this if you need to trigger updates even if the value hasn't changed,
  /// or if the value is mutable and has been modified internally.
  void notifyListeners() {
    assert(!_hasFlag(_flagDisposed),
        'Cannot notify listeners on a disposed NeuronAtom');
    if (_hasFlag(_flagDisposed)) return;
    if (_listeners.isEmpty) return;

    // Track if listeners are modified during notification
    bool listenersModified = false;
    final originalLength = _listeners.length;

    // Iterate with index to avoid allocation when no modification occurs
    for (int i = 0; i < _listeners.length; i++) {
      // Check if listeners were modified (added/removed)
      if (_listeners.length != originalLength) {
        listenersModified = true;
      }

      // If modified, switch to safe copy-based iteration for remaining listeners
      if (listenersModified) {
        final remaining = List<AtomListener>.from(_listeners.skip(i));
        for (final listener in remaining) {
          try {
            if (_listeners.contains(listener)) {
              listener.invoke();
            }
          } catch (e, st) {
            neuronErrorHandler('Error in NeuronAtom listener', e, st);
          }
        }
        break;
      }

      try {
        _listeners[i].invoke();
      } catch (e, st) {
        neuronErrorHandler('Error in NeuronAtom listener', e, st);
      }
    }
  }

  /// Creates a new atom that selects a part of this atom's value.
  ///
  /// The selected atom will only update when the selected value changes.
  /// It manages its subscription to the parent atom automatically (cold observable).
  NeuronAtom<R> select<R>(R Function(T value) selector) {
    return _SelectedAtom<T, R>(this, selector);
  }

  /// Whether this atom has any listeners.
  bool get hasListeners => _listeners.isNotEmpty;

  /// Called when the first listener is added.
  ///
  /// Override this method in subclasses to perform setup when the atom
  /// becomes active (has at least one listener). Call super to invoke
  /// the [onListen] callback.
  @protected
  @mustCallSuper
  void onActive() {
    onListen?.call();
  }

  /// Called when the last listener is removed.
  ///
  /// Override this method in subclasses to perform cleanup when the atom
  /// becomes inactive (has no listeners). Call super to invoke
  /// the [onCancel] callback.
  @protected
  @mustCallSuper
  void onInactive() {
    onCancel?.call();
  }

  /// Disposes the atom, removing all listeners.
  @override
  void dispose() {
    if (_hasFlag(_flagDisposed)) return;
    _finalizer.detach(_finalizerToken);
    _setFlag(_flagDisposed, true);
    _listeners.clear();

    if (runtimeType == _neuronAtomType) {
      NeuronAtomPool.release(this);
    }
  }

  @override
  String toString() => 'NeuronAtom($value)';
}

class _SelectedAtom<T, R> extends NeuronAtom<R> {
  final NeuronAtom<T> parent;
  final R Function(T value) selector;
  VoidCallback? _cleanup;

  _SelectedAtom(this.parent, this.selector) : super(selector(parent.value));

  @override
  R get value {
    // If we aren't listening to parent, we might be stale.
    // Check if we are active. If not, re-calculate on the fly.
    if (!hasListeners) {
      return selector(parent.value);
    }
    return super.value;
  }

  @override
  set value(R newValue) {
    throw UnsupportedError(
        'Cannot set the value of a derived atom. Update the parent atom instead.');
  }

  @override
  void onActive() {
    super.onActive();

    // 1. SYNC: Update value immediately in case parent changed while we were sleeping
    final freshValue = selector(parent.value);
    if (freshValue != _value) {
      _value =
          freshValue; // Update internal value directly to avoid firing listeners yet
    }

    // 2. SUBSCRIBE: Listen for future changes
    _cleanup = parent.subscribe(() {
      final newValue = selector(parent.value);
      super.value = newValue;
    });
  }

  @override
  void onInactive() {
    super.onInactive();
    // Unsubscribe from parent when we have no listeners
    _cleanup?.call();
    _cleanup = null;
  }
}
