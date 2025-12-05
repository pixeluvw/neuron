import 'debug_encoder.dart';

class NeuronDebugSnapshot {
  final Map<String, dynamic> signals;
  final Map<String, dynamic> computed;
  final List<Map<String, dynamic>> controllers;
  final List<Map<String, dynamic>> middlewares;
  final List<Map<String, dynamic>> history;
  final Map<String, List<Map<String, dynamic>>> perSignalHistory;
  final Map<String, dynamic> metrics;
  final int timestamp;

  NeuronDebugSnapshot({
    required this.signals,
    required this.computed,
    required this.controllers,
    required this.middlewares,
    required this.history,
    required this.perSignalHistory,
    required this.metrics,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'signals': signals,
      'computed': computed,
      'controllers': controllers,
      'middlewares': middlewares,
      'history': history,
      'perSignalHistory': perSignalHistory,
      'metrics': metrics,
      'timestamp': timestamp,
    };
  }

  static Map<String, dynamic> encodeEntry(MapEntry<String, dynamic> entry) {
    return {
      'id': entry.key,
      'value': NeuronDebugEncoder.encodeValue(entry.value),
      'type': entry.value.runtimeType.toString(),
    };
  }
}
