import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'debug_event.dart';
import 'debug_protocol.dart';
import 'debug_snapshot.dart';

/// Lightweight client for consuming the NeuronDebugServer protocol.
///
/// Intended for DevTool UIs or integration tests that need live events
/// and on-demand snapshots.
class NeuronDebugClient {
  NeuronDebugClient({String? uri}) : _uri = uri ?? 'ws://localhost:9090';

  final String _uri;
  WebSocket? _socket;
  Timer? _heartbeat;

  final StreamController<NeuronDebugEvent> _events =
      StreamController<NeuronDebugEvent>.broadcast();
  final StreamController<NeuronDebugSnapshot> _snapshots =
      StreamController<NeuronDebugSnapshot>.broadcast();

  Stream<NeuronDebugEvent> get events => _events.stream;
  Stream<NeuronDebugSnapshot> get snapshots => _snapshots.stream;

  bool get isConnected => _socket != null;

  Future<void> connect() async {
    if (_socket != null) return;
    final socket = await WebSocket.connect(_uri);
    _socket = socket;

    socket.listen(
      _handleMessage,
      onDone: () => _cleanup(),
      onError: (_) => _cleanup(),
      cancelOnError: true,
    );

    _heartbeat = Timer.periodic(
      const Duration(seconds: 20),
      (_) => _send(NeuronDebugProtocol.heartbeat()),
    );
  }

  Future<void> disconnect() async {
    await _socket?.close();
    _cleanup();
  }

  void _cleanup() {
    _heartbeat?.cancel();
    _heartbeat = null;
    _socket = null;
  }

  void _handleMessage(dynamic data) {
    if (data is! String) return;
    final payload = jsonDecode(data) as Map<String, dynamic>;
    final type = payload['type'] as String?;

    switch (type) {
      case 'snapshot':
        final snapData = payload['data'] as Map<String, dynamic>;
        _snapshots.add(_parseSnapshot(snapData));
        break;
      case 'event':
        final eventData = payload['event'] as Map<String, dynamic>;
        _events.add(_parseEvent(eventData));
        break;
      case 'heartbeat':
        break;
      default:
        break;
    }
  }

  NeuronDebugSnapshot _parseSnapshot(Map<String, dynamic> json) {
    return NeuronDebugSnapshot(
      signals: Map<String, dynamic>.from(json['signals'] as Map),
      computed: Map<String, dynamic>.from(json['computed'] as Map),
      controllers:
          List<Map<String, dynamic>>.from(json['controllers'] as List? ?? []),
      middlewares:
          List<Map<String, dynamic>>.from(json['middlewares'] as List? ?? []),
      history: List<Map<String, dynamic>>.from(json['history'] as List? ?? []),
      perSignalHistory: Map<String, List<Map<String, dynamic>>>.from(
        (json['perSignalHistory'] as Map? ?? {}).map((key, value) => MapEntry(
              key as String,
              List<Map<String, dynamic>>.from(value as List? ?? []),
            )),
      ),
      metrics: Map<String, dynamic>.from(json['metrics'] as Map? ?? {}),
      timestamp: json['timestamp'] as int? ?? 0,
    );
  }

  NeuronDebugEvent _parseEvent(Map<String, dynamic> json) {
    final kind = json['type'] as String? ?? 'signal_emit';
    final mapped = NeuronDebugEventKind.values.firstWhere(
      (e) => NeuronDebugEvent.wireType(e) == kind,
      orElse: () => NeuronDebugEventKind.signalEmit,
    );
    return NeuronDebugEvent(
      kind: mapped,
      id: json['id'] as String? ?? '',
      value: json['value'],
      timestamp: json['timestamp'] as int? ?? 0,
      meta: json['meta'] as Map<String, dynamic>?,
    );
  }

  void requestSnapshot() {
    _send({'type': 'get_snapshot'});
  }

  void _send(Map<String, dynamic> body) {
    final socket = _socket;
    if (socket == null) return;
    socket.add(jsonEncode(body));
  }
}
