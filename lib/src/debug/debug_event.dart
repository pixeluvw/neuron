import 'debug_encoder.dart';

enum NeuronDebugEventKind {
  signalRegister,
  signalEmit,
  slotTrigger,
  computedUpdate,
  controllerInit,
  controllerDispose,
  middlewareEvent,
  error,
}

class NeuronDebugEvent {
  final NeuronDebugEventKind kind;
  final String id;
  final dynamic value;
  final int timestamp;
  final Map<String, dynamic>? meta;

  const NeuronDebugEvent({
    required this.kind,
    required this.id,
    required this.value,
    required this.timestamp,
    this.meta,
  });

  factory NeuronDebugEvent.register(String id, dynamic value,
      {Map<String, dynamic>? meta}) {
    return NeuronDebugEvent(
      kind: NeuronDebugEventKind.signalRegister,
      id: id,
      value: value,
      timestamp: DateTime.now().millisecondsSinceEpoch,
      meta: meta,
    );
  }

  factory NeuronDebugEvent.controller(String id, bool disposed) {
    return NeuronDebugEvent(
      kind: disposed
          ? NeuronDebugEventKind.controllerDispose
          : NeuronDebugEventKind.controllerInit,
      id: id,
      value: null,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );
  }

  NeuronDebugEvent copyWith({
    NeuronDebugEventKind? kind,
    dynamic value,
    Map<String, dynamic>? meta,
  }) {
    return NeuronDebugEvent(
      kind: kind ?? this.kind,
      id: id,
      value: value ?? this.value,
      timestamp: DateTime.now().millisecondsSinceEpoch,
      meta: meta ?? this.meta,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': wireType(kind),
      'id': id,
      'value': NeuronDebugEncoder.encodeValue(value),
      'timestamp': timestamp,
      if (meta != null) 'meta': meta,
    };
  }

  static String wireType(NeuronDebugEventKind kind) {
    switch (kind) {
      case NeuronDebugEventKind.signalRegister:
        return 'signal_register';
      case NeuronDebugEventKind.signalEmit:
        return 'signal_emit';
      case NeuronDebugEventKind.slotTrigger:
        return 'slot_trigger';
      case NeuronDebugEventKind.computedUpdate:
        return 'computed_update';
      case NeuronDebugEventKind.controllerInit:
        return 'controller_init';
      case NeuronDebugEventKind.controllerDispose:
        return 'controller_dispose';
      case NeuronDebugEventKind.middlewareEvent:
        return 'middleware_event';
      case NeuronDebugEventKind.error:
        return 'error';
    }
  }
}
