import 'dart:convert';

import 'package:shelf/shelf.dart';

import 'debug_dashboard.dart';
import 'debug_protocol.dart';
import 'debug_registry.dart';

class NeuronDebugRouter {
  NeuronDebugRouter(this.registry);

  final NeuronDebugRegistry registry;

  Handler get handler => (Request request) async {
        switch (request.url.path) {
          case '':
          case '/':
          case 'health':
            return _json({
              'status': 'ok',
              'protocol': NeuronDebugProtocol.version,
              'timestamp': DateTime.now().millisecondsSinceEpoch,
            });
          case 'snapshot':
            final snap = registry.snapshot();
            return _json(NeuronDebugProtocol.snapshotMessage(snap));
          case 'events':
            final snap = registry.snapshot();
            return _json({
              'type': 'events',
              'protocol': NeuronDebugProtocol.version,
              'history': snap.history,
              'timestamp': snap.timestamp,
            });
          case 'registry':
            final snap = registry.snapshot();
            return _json({
              'type': 'registry',
              'protocol': NeuronDebugProtocol.version,
              'counts': {
                'signals': snap.signals.length,
                'computed': snap.computed.length,
                'controllers': snap.controllers.length,
                'middlewares': snap.middlewares.length,
              },
              'controllers': snap.controllers,
              'timestamp': snap.timestamp,
            });
          case 'protocol':
            return _json(NeuronDebugProtocol.info());
          case 'ui':
            return _html(neuronDebugDashboardHtml);
          default:
            return _json(NeuronDebugProtocol.error('not_found'),
                statusCode: 404);
        }
      };

  Response _json(Map<String, dynamic> body, {int statusCode = 200}) {
    return Response(
      statusCode,
      body: jsonEncode(body),
      headers: {'content-type': 'application/json'},
    );
  }

  Response _html(String body) {
    return Response(
      200,
      body: body,
      headers: {'content-type': 'text/html; charset=utf-8'},
    );
  }
}
