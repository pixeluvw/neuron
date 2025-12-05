// neuron_effects.dart
part of 'neuron_extensions.dart';

/// ============================================================================
/// EFFECTS AND REACTIONS
/// ============================================================================

/// Reaction - Execute side effects when signal changes.
///
/// Reactions run callbacks in response to signal changes.
///
/// ## Basic Usage
///
/// ```dart
/// final count = Signal<int>(0);
///
/// final reaction = SignalReaction(
///   count,
///   (value) {
///     print('Count changed to: $value');
///   },
/// );
///
/// // Don't forget to dispose!
/// reaction.dispose();
/// ```
class SignalReaction<T> {
  final Signal<T> signal;
  final void Function(T value) callback;
  final bool Function(T oldValue, T newValue)? when;
  StreamSubscription<T>? _subscription;
  T? _previousValue;

  SignalReaction(
    this.signal,
    this.callback, {
    this.when,
    bool fireImmediately = false,
  }) {
    _previousValue = signal.val;

    if (fireImmediately) {
      callback(signal.val);
    }

    _subscription = signal.stream.listen((value) {
      final oldValue = _previousValue;
      _previousValue = value;

      if (when != null && oldValue != null) {
        if (when!(oldValue as T, value)) {
          callback(value);
        }
      } else {
        callback(value);
      }
    });
  }

  /// Dispose the reaction.
  void dispose() {
    _subscription?.cancel();
    _subscription = null;
  }
}

/// Transaction - Batch multiple signal updates.
///
/// Transactions allow you to update multiple signals and only notify
/// listeners once all updates are complete.
///
/// ## Basic Usage
///
/// ```dart
/// final name = Signal<String>('Alice');
/// final age = Signal<int>(25);
///
/// SignalTransaction()
///   .update(name, 'Bob')
///   .update(age, 30)
///   .commit();
/// ```
class SignalTransaction {
  final Map<Signal, dynamic> _updates = {};
  bool _committed = false;

  /// Add a signal update to the transaction.
  SignalTransaction update<T>(Signal<T> signal, T value) {
    if (_committed) {
      throw StateError('Transaction already committed');
    }
    _updates[signal] = value;
    return this;
  }

  /// Commit all updates atomically.
  void commit() {
    if (_committed) {
      throw StateError('Transaction already committed');
    }
    _committed = true;

    for (final entry in _updates.entries) {
      final signal = entry.key;
      final value = entry.value;
      signal.emit(value);
    }

    _updates.clear();
  }

  /// Rollback the transaction without applying changes.
  void rollback() {
    _committed = true;
    _updates.clear();
  }
}

/// Action - Encapsulates async mutations with state tracking.
///
/// Actions provide a structured way to handle async operations
/// with loading state and error handling.
///
/// ## Basic Usage
///
/// ```dart
/// final loginAction = SignalAction<User>(
///   name: 'login',
///   execute: () async {
///     return await authService.login();
///   },
///   onError: (error, stack) => print('Login failed: $error'),
/// );
///
/// // In UI:
/// if (loginAction.isExecuting.value) {
///   return CircularProgressIndicator();
/// }
///
/// ElevatedButton(
///   onPressed: () => loginAction.run(),
///   child: Text('Login'),
/// )
/// ```
class SignalAction<T> {
  final String name;
  final Future<T> Function() execute;
  final void Function(T result)? after;
  final void Function(Object error, StackTrace stackTrace)? onError;

  final Signal<bool> isExecuting = Signal<bool>(false);
  final Signal<T?> result = Signal<T?>(null);
  final Signal<Object?> error = Signal<Object?>(null);

  SignalAction({
    required this.name,
    required this.execute,
    this.after,
    this.onError,
  });

  /// Run the action.
  Future<T?> run() async {
    if (isExecuting.val) {
      return null; // Already executing
    }

    isExecuting.emit(true);
    error.emit(null);

    try {
      final value = await execute();
      result.emit(value);
      after?.call(value);
      return value;
    } catch (e, stack) {
      error.emit(e);
      onError?.call(e, stack);
      return null;
    } finally {
      isExecuting.emit(false);
    }
  }

  /// Dispose all signals.
  void dispose() {
    isExecuting.dispose();
    result.dispose();
    error.dispose();
  }
}
