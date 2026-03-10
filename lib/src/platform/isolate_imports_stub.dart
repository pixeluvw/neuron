// isolate_imports_stub.dart
// Web/WASM stub — provides no-op implementations of Isolate, ReceivePort,
// and SendPort so that IsolateSignal compiles but throws at runtime.

import 'dart:async';

/// Stub [SendPort] for web/WASM — methods throw [UnsupportedError].
class SendPort {
  void send(Object? message) {
    throw UnsupportedError('Isolates are not supported on web/WASM.');
  }
}

/// Stub [ReceivePort] for web/WASM — returns an empty stream.
class ReceivePort {
  final StreamController<dynamic> _controller = StreamController<dynamic>();

  SendPort get sendPort => SendPort();

  StreamSubscription<dynamic> listen(
    void Function(dynamic message)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return _controller.stream.listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  void close() {
    _controller.close();
  }
}

/// Stub [Isolate] for web/WASM — [spawn] always throws.
class Isolate {
  static const int immediate = 0;

  static Future<Isolate> spawn<T>(
    void Function(T message) entryPoint,
    T message, {
    String? debugName,
  }) {
    throw UnsupportedError(
      'Isolate.spawn() is not supported on web/WASM. '
      'Use compute() or Web Workers instead.',
    );
  }

  void kill({int priority = 0}) {}
}
