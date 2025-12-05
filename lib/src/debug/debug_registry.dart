import 'dart:ui';
import 'package:flutter/foundation.dart';
import '../neuron_atom.dart';

import '../debug/debug_snapshot.dart';
import 'debug_encoder.dart';
import 'debug_event.dart';
import 'debug_stream.dart';

class NeuronDebugRegistry {
  NeuronDebugRegistry._();

  static final NeuronDebugRegistry instance = NeuronDebugRegistry._();

  bool _enabled = false;
  int historyLimit = 500;

  final Map<Object, _ControllerRecord> _controllers = {};
  final Map<String, _NotifierRecord> _notifiers = {};
  final Map<NeuronAtom, String> _reverseLookup = {};
  final Map<NeuronAtom, VoidCallback> _listeners = {};
  final List<NeuronDebugEvent> _history = [];
  final Map<String, List<NeuronDebugEvent>> _perSignalHistory = {};
  final Map<String, int> _perSignalHistoryLimit = {};
  final List<Map<String, dynamic>> _middlewares = [];
  final NeuronDebugStream _stream = NeuronDebugStream.instance;
  Map<String, dynamic> Function()? metricsProvider;

  bool get isEnabled => _enabled;

  Map<String, NeuronAtom> get notifiers => {
        for (final entry in _notifiers.entries) entry.key: entry.value.notifier,
      };

  List<NeuronDebugEvent> get history =>
      List<NeuronDebugEvent>.unmodifiable(_history);

  Map<String, List<NeuronDebugEvent>> get perSignalHistory =>
      Map<String, List<NeuronDebugEvent>>.fromEntries(
        _perSignalHistory.entries.map(
          (e) => MapEntry(e.key, List<NeuronDebugEvent>.unmodifiable(e.value)),
        ),
      );

  void enable() {
    if (_enabled) return;
    _enabled = true;
    // Attach listeners and emit register events for any notifiers that were bound
    // before devtools was enabled.
    for (final entry in _notifiers.values) {
      _attachListener(entry);
      _pushEvent(
        NeuronDebugEvent.register(
          entry.id,
          entry.snapshotValue,
          meta: {
            'controller': entry.controllerName,
            'kind': entry.kind,
            if (entry.label != null) 'label': entry.label,
          },
        ),
      );
    }
  }

  void disable() {
    _enabled = false;
  }

  void registerController(Object controller) {
    final record = _controllers.putIfAbsent(
      controller,
      () => _ControllerRecord(controller),
    );
    _pushEvent(
      NeuronDebugEvent.controller(record.name, false).copyWith(
        meta: {'controller': record.name},
      ),
    );
  }

  void unregisterController(Object controller) {
    final record = _controllers.remove(controller);
    if (record == null) return;

    for (final id in record.notifierIds.toList()) {
      _detachNotifier(id);
    }

    _pushEvent(
      NeuronDebugEvent.controller(record.name, true).copyWith(
        meta: {'controller': record.name},
      ),
    );
  }

  String registerNotifier({
    required Object controller,
    required NeuronAtom notifier,
    String? debugLabel,
    String kind = 'signal',
  }) {
    final controllerRecord = _controllers.putIfAbsent(
      controller,
      () => _ControllerRecord(controller),
    );

    final id = _buildId(controllerRecord, debugLabel, kind);
    final existing = _notifiers[id];
    if (existing != null) {
      _reverseLookup[notifier] = id;
      return id;
    }

    controllerRecord.notifierIds.add(id);

    final entry = _NotifierRecord(
      id: id,
      notifier: notifier,
      kind: kind,
      controllerName: controllerRecord.name,
      label: debugLabel,
    );

    _notifiers[id] = entry;
    _reverseLookup[notifier] = id;

    if (_enabled) {
      _attachListener(entry);
      _pushEvent(
        NeuronDebugEvent.register(
          id,
          entry.snapshotValue,
          meta: {
            'controller': controllerRecord.name,
            'kind': kind,
            if (debugLabel != null) 'label': debugLabel,
          },
        ),
      );
    }

    return id;
  }

  void recordMiddlewareEvent(String name, Map<String, dynamic> payload) {
    if (!_enabled) return;
    final event = NeuronDebugEvent(
      kind: NeuronDebugEventKind.middlewareEvent,
      id: name,
      value: payload,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );
    _middlewares.add({
      'name': name,
      'payload': payload,
      'timestamp': event.timestamp,
    });
    _pushEvent(event);
  }

  NeuronDebugSnapshot snapshot() {
    final signals = <String, dynamic>{};
    final computed = <String, dynamic>{};

    for (final entry in _notifiers.values) {
      final data = entry.toJson();
      if (entry.kind == 'computed') {
        computed[entry.id] = data;
      } else {
        signals[entry.id] = data;
      }
    }

    return NeuronDebugSnapshot(
      signals: signals,
      computed: computed,
      controllers: _controllers.values.map((c) => c.toJson()).toList(),
      middlewares: List<Map<String, dynamic>>.from(_middlewares),
      history: _history.map((e) => e.toJson()).toList(),
      perSignalHistory: {
        for (final entry in _perSignalHistory.entries)
          entry.key: entry.value.map((e) => e.toJson()).toList(),
      },
      metrics: metricsProvider?.call() ?? const {},
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );
  }

  void _attachListener(_NotifierRecord entry) {
    if (_listeners.containsKey(entry.notifier)) return;
    final listener = () {
      entry.lastUpdated = DateTime.now();
      final event = NeuronDebugEvent(
        kind: entry.kind == 'computed'
            ? NeuronDebugEventKind.computedUpdate
            : NeuronDebugEventKind.signalEmit,
        id: entry.id,
        value: entry.snapshotValue,
        timestamp: DateTime.now().millisecondsSinceEpoch,
        meta: {
          'controller': entry.controllerName,
          'kind': entry.kind,
          if (entry.label != null) 'label': entry.label,
        },
      );
      _pushEvent(event);
    };

    _listeners[entry.notifier] = listener;
    entry.notifier.addListener(listener);
  }

  void _detachNotifier(String id) {
    final entry = _notifiers.remove(id);
    if (entry == null) return;

    final listener = _listeners.remove(entry.notifier);
    if (listener != null) {
      entry.notifier.removeListener(listener);
    }

    _reverseLookup.remove(entry.notifier);
  }

  void _pushEvent(NeuronDebugEvent event) {
    _history.add(event);
    if (_history.length > historyLimit) {
      _history.removeAt(0);
    }
    if (event.id.isNotEmpty) {
      final bucket =
          _perSignalHistory.putIfAbsent(event.id, () => <NeuronDebugEvent>[]);
      bucket.add(event);
      final limit = _perSignalHistoryLimit[event.id] ?? historyLimit;
      while (bucket.length > limit) {
        bucket.removeAt(0);
      }
    }
    _stream.add(event);
  }

  /// Lookup the registered id for a notifier, if any.
  String? idForNotifier(NeuronAtom notifier) => _reverseLookup[notifier];

  void setSignalHistoryLimit(String id, int limit) {
    if (limit <= 0) return;
    _perSignalHistoryLimit[id] = limit;
    final bucket = _perSignalHistory[id];
    if (bucket != null) {
      while (bucket.length > limit) {
        bucket.removeAt(0);
      }
    }
  }

  void clearHistory() {
    _history.clear();
    _perSignalHistory.clear();
  }

  String _buildId(
    _ControllerRecord controller,
    String? debugLabel,
    String kind,
  ) {
    if (debugLabel != null && debugLabel.isNotEmpty) {
      if (debugLabel.contains('.')) return debugLabel;
      return '${controller.name}.$debugLabel';
    }

    final prefix = kind == 'computed' ? 'computed' : 'signal';
    final id = '${controller.name}.${prefix}_${controller.counter}';
    controller.counter += 1;
    return id;
  }
}

class _ControllerRecord {
  _ControllerRecord(this.ref)
      : name = ref.runtimeType.toString(),
        createdAt = DateTime.now().millisecondsSinceEpoch;

  final Object ref;
  final String name;
  final int createdAt;
  int counter = 0;
  final Set<String> notifierIds = {};

  Map<String, dynamic> toJson() {
    return {
      'id': name,
      'createdAt': createdAt,
      'signals': notifierIds.length,
    };
  }
}

class _NotifierRecord {
  _NotifierRecord({
    required this.id,
    required this.notifier,
    required this.kind,
    required this.controllerName,
    required this.label,
  }) : lastUpdated = DateTime.now();

  final String id;
  final NeuronAtom notifier;
  final String kind;
  final String controllerName;
  final String? label;
  DateTime lastUpdated;

  dynamic get snapshotValue => NeuronDebugEncoder.encodeValue(notifier.value);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'controller': controllerName,
      'kind': kind,
      'label': label,
      'value': snapshotValue,
      'type': notifier.value.runtimeType.toString(),
      'lastUpdated': lastUpdated.millisecondsSinceEpoch,
    };
  }
}
