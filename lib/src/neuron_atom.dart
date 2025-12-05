import 'dart:ui';

/// Interface for objects that need to be disposed.
abstract class Disposable {
  void dispose();
}

/// A modern, lightweight reactive value container that replaces Flutter's ValueNotifier.
///
/// [NeuronAtom] holds a value of type [T] and notifies listeners when the value changes.
/// It provides a cleaner API for subscription management and is designed to be
/// the foundation of the Neuron reactive system.
class NeuronAtom<T> implements Disposable {
  T _value;
  final T _initialValue;
  T? _previousValue;

  final List<VoidCallback> _listeners = [];
  bool _disposed = false;

  // Configuration
  final bool Function(T a, T b)? equals;
  final T Function(T current, T next)? guard;

  // Lifecycle hooks
  final VoidCallback? onListen;
  final VoidCallback? onCancel;

  /// Creates a [NeuronAtom] with an initial value.
  NeuronAtom(
    T value, {
    this.equals,
    this.guard,
    this.onListen,
    this.onCancel,
  })  : _value = value,
        _initialValue = value;

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
    if (_disposed) return;

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
  void addListener(VoidCallback listener) {
    if (_disposed) return;

    final wasEmpty = _listeners.isEmpty;
    _listeners.add(listener);

    if (wasEmpty) {
      _onActive();
    }
  }

  /// Removes a previously added listener.
  void removeListener(VoidCallback listener) {
    if (_disposed) return;

    _listeners.remove(listener);

    if (_listeners.isEmpty) {
      _onInactive();
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
    addListener(listener);
    return () => removeListener(listener);
  }

  /// Manually notifies all listeners.
  ///
  /// Use this if you need to trigger updates even if the value hasn't changed,
  /// or if the value is mutable and has been modified internally.
  void notifyListeners() {
    if (_disposed) return;
    if (_listeners.isEmpty) return;

    // Copy the list to allow listeners to be added/removed during notification
    final localListeners = List<VoidCallback>.from(_listeners);

    for (final listener in localListeners) {
      try {
        if (_listeners.contains(listener)) {
          listener();
        }
      } catch (e) {
        print('Error in NeuronAtom listener: $e');
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
  void _onActive() {
    onListen?.call();
  }

  /// Called when the last listener is removed.
  void _onInactive() {
    onCancel?.call();
  }

  /// Disposes the atom, removing all listeners.
  @override
  void dispose() {
    _disposed = true;
    _listeners.clear();
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
  void _onActive() {
    super._onActive();

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
  void _onInactive() {
    super._onInactive();
    // Unsubscribe from parent when we have no listeners
    _cleanup?.call();
    _cleanup = null;
  }
}
