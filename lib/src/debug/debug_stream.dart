import 'dart:async';

import 'debug_event.dart';

class NeuronDebugStream {
  NeuronDebugStream._();

  static final NeuronDebugStream instance = NeuronDebugStream._();

  final StreamController<NeuronDebugEvent> _controller =
      StreamController<NeuronDebugEvent>.broadcast();

  Stream<NeuronDebugEvent> get stream => _controller.stream;

  void add(NeuronDebugEvent event) {
    if (_controller.isClosed) return;
    _controller.add(event);
  }

  Future<void> dispose() async {
    await _controller.close();
  }
}
