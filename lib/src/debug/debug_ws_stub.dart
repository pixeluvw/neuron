// debug_ws_stub.dart

class HttpServer {
  static Future<HttpServer> bind(dynamic host, int port) async {
    throw UnimplementedError('HttpServer is not available on the Web.');
  }

  void listen(void Function(HttpRequest request) onData) {}
  Future<void> close({bool force = false}) async {}
}

class HttpRequest {
  String get method => '';
}

class WebSocket {
  static Future<WebSocket> connect(String url) async {
    throw UnimplementedError('WebSocket native is not available on the Web.');
  }

  void add(dynamic data) {}
  void listen(
    void Function(dynamic data) onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {}

  Future<void> close() async {}
  Future<void> get done async {}
}

class WebSocketTransformer {
  static bool isUpgradeRequest(HttpRequest request) => false;
  static Future<WebSocket> upgrade(HttpRequest request) async {
    throw UnimplementedError();
  }
}

class SocketException implements Exception {}

class InternetAddress {
  InternetAddress(String address);
}

class Platform {
  static const bool isWindows = false;
  static const bool isMacOS = false;
  static const bool isLinux = false;
  static const bool isAndroid = false;
  static const Map<String, String> environment = {};
}

class ProcessResult {
  final int exitCode;
  final dynamic stdout;
  final dynamic stderr;
  ProcessResult(this.exitCode, this.stdout, this.stderr);
}

class Process {
  static Future<ProcessResult> start(
      String executable, List<String> arguments) async {
    throw UnimplementedError();
  }

  static Future<ProcessResult> run(
      String executable, List<String> arguments) async {
    throw UnimplementedError();
  }
}

class File {
  File(String path);
  Future<bool> exists() async => false;
}
