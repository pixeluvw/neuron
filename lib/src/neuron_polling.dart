// neuron_polling.dart
//
// ═══════════════════════════════════════════════════════════════════════════════
// NEURON POLLING SIGNAL - Periodic Async Data Refresh
// ═══════════════════════════════════════════════════════════════════════════════
//
// Provides a signal that periodically executes an async operation,
// combining AsyncSignal's state machine with Timer.periodic for
// automatic data refresh.
//
// See also:
// - neuron_signals.dart : AsyncSignal base class
// - neuron_core.dart    : NeuronController lifecycle
//
// ═══════════════════════════════════════════════════════════════════════════════

part of 'neuron_extensions.dart';

/// A signal that periodically executes an async operation and emits the result.
///
/// [PollingSignal] extends [AsyncSignal] with automatic periodic re-execution,
/// eliminating manual [Timer] management and cleanup boilerplate.
///
/// ## Basic Usage
///
/// ```dart
/// class DashboardController extends NeuronController {
///   late final stats = pollingSignal<Stats>(
///     interval: Duration(seconds: 30),
///     operation: () => api.fetchStats(),
///   );
///   // No Timer to manage, no onClose() cleanup needed
/// }
/// ```
///
/// ## Runtime Control
///
/// ```dart
/// controller.stats.pause();                         // Skip ticks
/// controller.stats.resume();                        // Resume ticks
/// controller.stats.setInterval(Duration(seconds: 5)); // Change frequency
/// controller.stats.stop();                          // Cancel timer entirely
/// controller.stats.start();                         // Restart
/// ```
///
/// ## Lifecycle
///
/// The polling timer is automatically cancelled when the signal is disposed
/// (e.g., when the parent controller is uninstalled). No manual cleanup needed.
///
/// See also:
/// - [AsyncSignal] - Base async state machine
/// - [AsyncSlot] - Widget for binding async signals to UI
class PollingSignal<T> extends AsyncSignal<T> {
  Duration _interval;
  final Future<T> Function() _operation;
  Timer? _timer;
  bool _isPaused = false;

  /// Creates a polling signal.
  ///
  /// - [interval]: Time between polls.
  /// - [operation]: The async function to execute on each tick.
  /// - [initial]: Optional initial data (skips initial loading state).
  /// - [autoStart]: Whether to start polling immediately (default: true).
  PollingSignal({
    required Duration interval,
    required Future<T> Function() operation,
    T? initial,
    bool autoStart = true,
    String? debugLabel,
  })  : _interval = interval,
        _operation = operation,
        super(initial, debugLabel: debugLabel) {
    if (autoStart) start();
  }

  /// Starts polling. Executes immediately, then repeats on [interval].
  ///
  /// If already started, this is a no-op.
  void start() {
    if (_timer != null) return;
    _isPaused = false;
    _poll();
    _timer = Timer.periodic(_interval, (_) {
      if (!_isPaused) _poll();
    });
  }

  void _poll() {
    execute(() => _operation());
  }

  /// Stops polling and cancels the timer.
  ///
  /// Call [start] to resume polling from scratch.
  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  /// Pauses polling without cancelling the timer.
  ///
  /// The timer continues to tick but polls are skipped.
  /// Use [resume] to start executing again.
  void pause() {
    _isPaused = true;
  }

  /// Resumes polling after a [pause].
  void resume() {
    _isPaused = false;
  }

  /// Changes the polling interval.
  ///
  /// If the timer is currently running, it is restarted with the new interval.
  void setInterval(Duration newInterval) {
    _interval = newInterval;
    if (_timer != null) {
      stop();
      start();
    }
  }

  /// Whether the signal is actively polling (timer running and not paused).
  bool get isPolling => _timer != null && _timer!.isActive && !_isPaused;

  /// Whether polling is paused.
  bool get isPaused => _isPaused;

  /// The current polling interval.
  Duration get interval => _interval;

  @override
  void dispose() {
    _timer?.cancel();
    _timer = null;
    super.dispose();
  }
}

/// Extension providing [pollingSignal] factory on [NeuronController].
///
/// ```dart
/// class MyController extends NeuronController {
///   late final data = pollingSignal<List<Item>>(
///     interval: Duration(seconds: 30),
///     operation: () => api.fetchItems(),
///   );
/// }
/// ```
extension NeuronControllerPolling on NeuronController {
  /// Creates a [PollingSignal] and automatically binds it to this controller.
  PollingSignal<T> pollingSignal<T>({
    required Duration interval,
    required Future<T> Function() operation,
    T? initial,
    bool autoStart = true,
    String? debugLabel,
  }) {
    return PollingSignal<T>(
      interval: interval,
      operation: operation,
      initial: initial,
      autoStart: autoStart,
      debugLabel: debugLabel,
    ).bind(this);
  }
}
