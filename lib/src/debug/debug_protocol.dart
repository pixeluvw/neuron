import 'debug_event.dart';
import 'debug_snapshot.dart';

class NeuronDebugProtocol {
  NeuronDebugProtocol._();

  static const version = '1.0.0';

  static Map<String, dynamic> eventMessage(NeuronDebugEvent event) {
    return {
      'type': 'event',
      'protocol': version,
      'event': event.toJson(),
    };
  }

  static Map<String, dynamic> snapshotMessage(NeuronDebugSnapshot snapshot) {
    return {
      'type': 'snapshot',
      'protocol': version,
      'data': snapshot.toJson(),
    };
  }

  static Map<String, dynamic> heartbeat() {
    return {
      'type': 'heartbeat',
      'protocol': version,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
  }

  static Map<String, dynamic> info() {
    return {
      'type': 'info',
      'protocol': version,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'events': NeuronDebugEventKind.values
          .map((e) => NeuronDebugEvent.wireType(e))
          .toList(),
    };
  }

  static Map<String, dynamic> error(String message) {
    return {
      'type': 'error',
      'protocol': version,
      'message': message,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
  }
}
