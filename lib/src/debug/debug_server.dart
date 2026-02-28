// ignore_for_file: avoid_print
import 'dart:async';
import 'dart:convert';
import 'dart:io' if (dart.library.js_interop) 'debug_ws_stub.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;

import 'debug_event.dart';
import 'debug_protocol.dart';
import 'debug_registry.dart';
import 'debug_router.dart';
import 'debug_stream.dart';

class NeuronDebugServer {
  NeuronDebugServer._();

  static final NeuronDebugServer instance = NeuronDebugServer._();

  HttpServer? _server;
  StreamSubscription<NeuronDebugEvent>? _subscription;
  Timer? _heartbeat;
  final List<WebSocket> _clients = [];
  final Map<WebSocket, Set<String>> _clientWatch = {};
  int _port = 9090;
  bool _adbForwardActive = false;

  bool get isRunning => _server != null;
  int get port => _port;
  bool get adbForwardActive => _adbForwardActive;

  Future<int> start({
    int port = 9090,
    String host = '0.0.0.0',
    int maxRetries = 0,
    bool openDashboard = false,
    bool autoAdbForward = true,
  }) async {
    if (_server != null) return _port;

    _port = port;
    NeuronDebugRegistry.instance.enable();

    final router = NeuronDebugRouter(NeuronDebugRegistry.instance);
    final handler = const Pipeline()
        .addMiddleware(logRequests())
        .addMiddleware(_cors())
        .addHandler(router.handler);

    final address = InternetAddress(host);
    for (int attempt = 0; attempt <= maxRetries; attempt++) {
      final candidatePort = port + attempt;
      try {
        _server = await HttpServer.bind(address, candidatePort);
        _port = candidatePort;
        break;
      } on SocketException {
        if (attempt == maxRetries) rethrow;
      }
    }

    _subscription = NeuronDebugStream.instance.stream.listen(_broadcastEvent);
    _heartbeat =
        Timer.periodic(const Duration(seconds: 15), (_) => _sendHeartbeat());

    _server!.listen((HttpRequest request) {
      if (WebSocketTransformer.isUpgradeRequest(request)) {
        _handleWebSocket(request);
        return;
      }
      shelf_io.handleRequest(request, handler);
    });

    // Auto-setup ADB port forwarding for Android development
    if (autoAdbForward) {
      await _setupAdbForward(_port);
    }

    if (openDashboard) {
      _launchDashboard(host, _port);
    }

    return _port;
  }

  Future<void> stop() async {
    await _subscription?.cancel();
    _subscription = null;
    _heartbeat?.cancel();
    _heartbeat = null;

    for (final client in _clients.toList()) {
      try {
        await client.close();
      } catch (_) {}
    }
    _clients.clear();
    _clientWatch.clear();

    await _server?.close(force: true);
    _server = null;
  }

  Future<void> _handleWebSocket(HttpRequest request) async {
    final socket = await WebSocketTransformer.upgrade(request);
    _clients.add(socket);
    _clientWatch[socket] = <String>{};

    socket.done.whenComplete(() {
      _clients.remove(socket);
      _clientWatch.remove(socket);
    });

    socket.add(
      jsonEncode(
        NeuronDebugProtocol.snapshotMessage(
          NeuronDebugRegistry.instance.snapshot(),
        ),
      ),
    );

    socket.listen(
      (data) => _handleWsMessage(socket, data),
      onDone: () {
        _clients.remove(socket);
        _clientWatch.remove(socket);
      },
      onError: (_) {
        _clients.remove(socket);
        _clientWatch.remove(socket);
      },
      cancelOnError: true,
    );
  }

  void _handleWsMessage(WebSocket socket, dynamic data) {
    try {
      if (data is! String) return;
      final decoded = jsonDecode(data) as Map<String, dynamic>;
      final type = decoded['type'] as String?;

      if (type == 'get_snapshot') {
        final snap = NeuronDebugRegistry.instance.snapshot();
        socket.add(jsonEncode(NeuronDebugProtocol.snapshotMessage(snap)));
        return;
      }

      if (type == 'ping') {
        socket.add(jsonEncode(NeuronDebugProtocol.heartbeat()));
        return;
      }

      if (type == 'set_history_limit') {
        final limit = decoded['limit'];
        if (limit is int && limit > 0) {
          NeuronDebugRegistry.instance.historyLimit = limit;
        }
        return;
      }

      if (type == 'set_signal_history_limit') {
        final id = decoded['id'];
        final limit = decoded['limit'];
        if (id is String && limit is int && limit > 0) {
          NeuronDebugRegistry.instance.setSignalHistoryLimit(id, limit);
        }
        return;
      }

      if (type == 'set_watch_list') {
        final ids = decoded['ids'];
        if (ids is List) {
          final set = <String>{};
          for (final v in ids) {
            if (v is String && v.isNotEmpty) set.add(v);
          }
          _clientWatch[socket] = set;
        }
        return;
      }
    } catch (_) {
      socket.add(jsonEncode(NeuronDebugProtocol.error('bad_payload')));
    }
  }

  void _broadcastEvent(NeuronDebugEvent event) {
    if (_clients.isEmpty) return;
    final message = jsonEncode(NeuronDebugProtocol.eventMessage(event));
    for (final client in _clients.toList()) {
      try {
        final watch = _clientWatch[client];
        if (watch != null && watch.isNotEmpty && !watch.contains(event.id)) {
          continue;
        }
        client.add(message);
      } catch (_) {
        _clients.remove(client);
        _clientWatch.remove(client);
      }
    }
  }

  void _sendHeartbeat() {
    if (_clients.isEmpty) return;
    final message = jsonEncode(NeuronDebugProtocol.heartbeat());
    for (final client in _clients.toList()) {
      try {
        client.add(message);
      } catch (_) {
        _clients.remove(client);
      }
    }
  }

  void _launchDashboard(String host, int port) async {
    final url = 'http://${host == '0.0.0.0' ? 'localhost' : host}:$port/ui';
    if (kIsWeb) return;
    try {
      if (Platform.isWindows) {
        await Process.start('cmd', ['/c', 'start', url]);
      } else if (Platform.isMacOS) {
        await Process.start('open', [url]);
      } else if (Platform.isLinux) {
        await Process.start('xdg-open', [url]);
      }
    } catch (_) {
      // ignore browser launch failures
    }
  }

  /// Automatically setup ADB port forwarding for Android debugging.
  ///
  /// When running on Android: prints instructions for the developer.
  /// When running on desktop: attempts to run `adb forward` automatically.
  Future<void> _setupAdbForward(int port) async {
    if (kIsWeb) return;
    if (Platform.isAndroid) {
      // Running on Android device - print instructions
      _adbForwardActive = false;
      print('');
      print('╔════════════════════════════════════════════════════════════╗');
      print('║  🚀 Neuron DevTools Server started on port $port             ║');
      print('╠════════════════════════════════════════════════════════════╣');
      print('║  To connect from your PC, run:                             ║');
      print('║                                                            ║');
      print('║    adb forward tcp:$port tcp:$port                          ║');
      print('║                                                            ║');
      print('║  Then connect dashboard to: ws://127.0.0.1:$port            ║');
      print('╚════════════════════════════════════════════════════════════╝');
      print('');
    } else {
      // Running on desktop - try to setup ADB forward automatically
      _adbForwardActive = await setupAdbPortForward(port: port);
    }
  }

  /// Try to run ADB forward from the host machine.
  /// Call this static method from your development scripts or IDE.
  static Future<bool> setupAdbPortForward({int port = 9090}) async {
    if (kIsWeb) return false;
    final adbPath = await _findAdb();
    if (adbPath == null) {
      print('Neuron: ADB not found in PATH or common locations');
      return false;
    }

    try {
      final result = await Process.run(
        adbPath,
        ['forward', 'tcp:$port', 'tcp:$port'],
      );

      if (result.exitCode == 0) {
        print('');
        print('╔════════════════════════════════════════════════════════════╗');
        print(
            '║  🚀 Neuron DevTools Server started on port $port             ║');
        print('╠════════════════════════════════════════════════════════════╣');
        print('║  ✅ ADB port forward established automatically!            ║');
        print('║                                                            ║');
        print(
            '║  Connect dashboard to: ws://127.0.0.1:$port                 ║');
        print('╚════════════════════════════════════════════════════════════╝');
        print('');
        return true;
      } else {
        print('Neuron: ADB forward failed: ${result.stderr}');
        return false;
      }
    } catch (e) {
      print('Neuron: Failed to run ADB: $e');
      return false;
    }
  }

  /// Find ADB executable in PATH or common installation locations.
  static Future<String?> _findAdb() async {
    if (kIsWeb) return null;
    // First, check if adb is in PATH
    try {
      final result = await Process.run(
        Platform.isWindows ? 'where' : 'which',
        ['adb'],
      );
      if (result.exitCode == 0) {
        final path = (result.stdout as String).trim().split('\n').first;
        if (path.isNotEmpty) return path;
      }
    } catch (_) {}

    // Check common Android SDK locations
    final home = Platform.environment['HOME'] ??
        Platform.environment['USERPROFILE'] ??
        '';

    final commonPaths = [
      // Windows
      if (Platform.isWindows) ...[
        '${Platform.environment['LOCALAPPDATA']}\\Android\\Sdk\\platform-tools\\adb.exe',
        '$home\\AppData\\Local\\Android\\Sdk\\platform-tools\\adb.exe',
        'C:\\Android\\sdk\\platform-tools\\adb.exe',
      ],
      // macOS
      if (Platform.isMacOS) ...[
        '$home/Library/Android/sdk/platform-tools/adb',
        '/usr/local/bin/adb',
      ],
      // Linux
      if (Platform.isLinux) ...[
        '$home/Android/Sdk/platform-tools/adb',
        '/usr/bin/adb',
        '/usr/local/bin/adb',
      ],
    ];

    for (final path in commonPaths) {
      if (await File(path).exists()) {
        return path;
      }
    }

    // Check ANDROID_HOME / ANDROID_SDK_ROOT
    final androidHome = Platform.environment['ANDROID_HOME'] ??
        Platform.environment['ANDROID_SDK_ROOT'];
    if (androidHome != null) {
      final adbPath = Platform.isWindows
          ? '$androidHome\\platform-tools\\adb.exe'
          : '$androidHome/platform-tools/adb';
      if (await File(adbPath).exists()) {
        return adbPath;
      }
    }

    return null;
  }

  /// Remove ADB port forward when stopping the server.
  static Future<void> removeAdbPortForward({int port = 9090}) async {
    if (kIsWeb) return;
    final adbPath = await _findAdb();
    if (adbPath == null) return;

    try {
      await Process.run(adbPath, ['forward', '--remove', 'tcp:$port']);
    } catch (_) {}
  }

  Middleware _cors() {
    return createMiddleware(
      requestHandler: (Request request) {
        if (request.method == 'OPTIONS') {
          return Response.ok(
            '',
            headers: {
              'access-control-allow-origin': '*',
              'access-control-allow-headers': 'origin, content-type',
              'access-control-allow-methods': 'GET, POST, OPTIONS',
            },
          );
        }
        return null;
      },
      responseHandler: (Response response) => response.change(headers: {
        ...response.headers,
        'access-control-allow-origin': '*',
        'access-control-allow-headers': 'origin, content-type',
        'access-control-allow-methods': 'GET, POST, OPTIONS',
      }),
    );
  }
}
