// neuron_devtools.dart
part of 'neuron_extensions.dart';

/// ============================================================================
/// DEVTOOLS AND DEBUGGING
/// ============================================================================

/// Event types for signal lifecycle.
enum SignalEventType {
  registered,
  valueChanged,
  error,
  disposed,
}

/// Event record for debugging.
class SignalEvent {
  final String id;
  final SignalEventType type;
  final dynamic value;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  SignalEvent({
    required this.id,
    required this.type,
    this.value,
    DateTime? timestamp,
    this.metadata,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.toString(),
        'value': value.toString(),
        'timestamp': timestamp.toIso8601String(),
        'metadata': metadata,
      };
}

/// DevTools integration (compat wrapper).
///
/// SignalDevTools now delegates to [NeuronDebugRegistry] so legacy
/// APIs remain callable without duplicating state.
///
/// ## Basic Usage
///
/// ```dart
/// // Enable DevTools
/// SignalDevTools().setEnabled(true);
///
/// // Register a standalone signal
/// final count = Signal(0);
/// SignalDevTools().register('count', count);
/// ```
class SignalDevTools {
  static final SignalDevTools _instance = SignalDevTools._internal();
  factory SignalDevTools() => _instance;
  SignalDevTools._internal();

  bool _enabled = kDebugMode;
  int _maxEvents = 1000; // kept for API compatibility

  int get maxEvents => _maxEvents;
  final _registry = NeuronDebugRegistry.instance;

  // Standalone signals (not bound to a controller) for backward compatibility
  final Map<String, NeuronAtom> _standaloneSignals = {};
  final Map<String, List<dynamic>> _standaloneHistory = {};
  final Map<String, VoidCallback> _standaloneListeners = {};

  bool get isEnabled => _enabled;

  /// Enable or disable devtools.
  void setEnabled(bool enabled) {
    _enabled = enabled;
    if (enabled) {
      _registry.enable();
    } else {
      _registry.disable();
    }
  }

  /// Set maximum number of events to store.
  void setMaxEvents(int max) {
    _maxEvents = max;
    _registry.historyLimit = max;
  }

  /// Register a signal for debugging.
  ///
  /// For backward compatibility with standalone signals (not bound to a controller).
  void register(String id, NeuronAtom signal) {
    if (!_enabled) return;

    _standaloneSignals[id] = signal;
    _standaloneHistory[id] = [signal.value];

    // Track value changes
    void listener() {
      _standaloneHistory[id]?.add(signal.value);
      if (_standaloneHistory[id]!.length > _maxEvents) {
        _standaloneHistory[id]!.removeAt(0);
      }
      // Record event
      _recordStandaloneEvent(id, SignalEventType.valueChanged, signal.value);
    }

    _standaloneListeners[id] = listener;
    signal.addListener(listener);

    // Record registration event
    _recordStandaloneEvent(id, SignalEventType.registered, signal.value);
  }

  /// Unregister a signal.
  void unregister(String id) {
    final signal = _standaloneSignals.remove(id);
    final listener = _standaloneListeners.remove(id);
    if (signal != null && listener != null) {
      signal.removeListener(listener);
    }
    _standaloneHistory.remove(id);
  }

  final List<SignalEvent> _standaloneEvents = [];

  void _recordStandaloneEvent(String id, SignalEventType type, dynamic value) {
    _standaloneEvents.add(SignalEvent(id: id, type: type, value: value));
    if (_standaloneEvents.length > _maxEvents) {
      _standaloneEvents.removeAt(0);
    }
  }

  /// Get all registered signals (id -> notifier) from the registry and standalone.
  Map<String, NeuronAtom> get signals => {
        ..._registry.notifiers,
        ..._standaloneSignals,
      };

  /// Get all events from the registry and standalone.
  List<SignalEvent> get events => [
        ..._registry.history.map(
          (e) => SignalEvent(
            id: e.id,
            type: _mapEventKind(e.kind),
            value: e.value,
            timestamp: DateTime.fromMillisecondsSinceEpoch(e.timestamp),
            metadata: e.meta,
          ),
        ),
        ..._standaloneEvents,
      ];

  /// Get history for a signal (values only).
  List<dynamic>? getHistory(String id) {
    // Check standalone first
    if (_standaloneHistory.containsKey(id)) {
      return List.from(_standaloneHistory[id]!);
    }
    // Fall back to registry
    final list = _registry.perSignalHistory[id];
    if (list == null) return null;
    return list.map((e) => e.value).toList();
  }

  /// Time travel - restore signal to a previous value.
  void timeTravel(String id, int historyIndex) {
    if (!_enabled) return;

    final signal = signals[id];
    final history = getHistory(id);
    if (history == null || signal == null) return;
    if (historyIndex < 0 || historyIndex >= history.length) return;
    final value = history[historyIndex];
    if (signal is Signal) {
      signal.emit(value);
    } else {
      // ignore: invalid_use_of_protected_member
      signal.value = value;
    }
  }

  /// Get snapshot of all signal states.
  Map<String, dynamic> getSnapshot() => {
        for (final entry in _registry.snapshot().signals.entries)
          entry.key: entry.value['value'],
        for (final entry in _standaloneSignals.entries)
          entry.key: entry.value.value,
      };

  /// Export state to JSON.
  String exportState() {
    return jsonEncode(getSnapshot());
  }

  /// Clear all events.
  void clearEvents() {
    _registry.clearHistory();
    _standaloneEvents.clear();
  }

  /// Clear all history.
  void clearHistory() {
    _registry.clearHistory();
    _standaloneHistory.clear();
    _standaloneEvents.clear();
  }

  /// Get events filtered by type.
  List<SignalEvent> getEventsByType(SignalEventType type) {
    return events.where((e) => e.type == type).toList();
  }

  /// Get events for a specific signal.
  List<SignalEvent> getEventsForSignal(String id) {
    return events.where((e) => e.id == id).toList();
  }

  /// Get events within a time range.
  List<SignalEvent> getEventsByTimeRange(DateTime start, DateTime end) {
    return events.where((e) {
      return e.timestamp.isAfter(start) && e.timestamp.isBefore(end);
    }).toList();
  }

  /// Record a custom event.
  void recordCustomEvent(String id, String eventType, dynamic value,
      {Map<String, dynamic>? metadata}) {
    if (!_enabled) return;
    // Record to standalone events for backward compatibility
    _standaloneEvents.add(SignalEvent(
      id: id,
      type: SignalEventType.valueChanged,
      value: value,
      metadata: {'customType': eventType, ...?metadata},
    ));
    _registry.recordMiddlewareEvent(eventType, {
      'id': id,
      'value': value,
      ...?metadata,
    });
  }

  /// Create a checkpoint for state rollback.
  Map<String, dynamic> createCheckpoint() {
    return {
      'timestamp': DateTime.now().toIso8601String(),
      'state': getSnapshot(),
      'eventCount': events.length,
    };
  }

  /// Restore state from a checkpoint.
  void restoreCheckpoint(Map<String, dynamic> checkpoint) {
    if (!_enabled) return;

    final state = checkpoint['state'] as Map<String, dynamic>;
    for (final entry in state.entries) {
      final signal = signals[entry.key];
      if (signal != null) {
        if (signal is Signal) {
          signal.emit(entry.value);
        } else {
          signal.value = entry.value;
        }
      }
    }
  }

  /// Compare two snapshots and return differences.
  Map<String, dynamic> compareSnapshots(
      Map<String, dynamic> snapshot1, Map<String, dynamic> snapshot2) {
    final differences = <String, dynamic>{};

    for (final key in {...snapshot1.keys, ...snapshot2.keys}) {
      final val1 = snapshot1[key];
      final val2 = snapshot2[key];

      if (val1 != val2) {
        differences[key] = {'before': val1, 'after': val2};
      }
    }

    return differences;
  }

  /// Get statistics about signal activity.
  Map<String, dynamic> getStatistics() {
    final eventsList = events;
    final allSignals = signals; // includes standalone
    return {
      'totalSignals': allSignals.length,
      'totalEvents': eventsList.length,
      'eventsByType': {
        for (final type in SignalEventType.values)
          type.toString(): eventsList.where((e) => e.type == type).length,
      },
      'signalChangeFrequency': {
        for (final key in allSignals.keys)
          key: getEventsForSignal(key)
              .where((e) => e.type == SignalEventType.valueChanged)
              .length,
      },
    };
  }

  SignalEventType _mapEventKind(NeuronDebugEventKind kind) {
    switch (kind) {
      case NeuronDebugEventKind.signalRegister:
        return SignalEventType.registered;
      case NeuronDebugEventKind.signalEmit:
      case NeuronDebugEventKind.computedUpdate:
        return SignalEventType.valueChanged;
      case NeuronDebugEventKind.controllerDispose:
        return SignalEventType.disposed;
      case NeuronDebugEventKind.error:
        return SignalEventType.error;
      default:
        return SignalEventType.valueChanged;
    }
  }
}
