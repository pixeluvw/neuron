import 'package:recase/recase.dart';

/// Route entry for tracking registered routes.
class RouteEntry {
  const RouteEntry({
    required this.name,
    required this.path,
    required this.module,
    required this.view,
  });

  final String name;
  final String path;
  final String module;
  final String view;
}

/// Templates for route generation
class RouteTemplates {
  static final _namePattern = RegExp(r"name:\s*'([^']+)'");
  static final _pathPattern = RegExp(r"path:\s*'([^']+)'");
  static final _viewPattern = RegExp(r'const\s+(\w+View)\(\)');


  /// Parse a generated `app_routes.dart` file back into [RouteEntry] list.
  ///
  /// This makes the Dart file the single source of truth — no JSON needed.
  static List<RouteEntry> parseAppRoutesDart(String content) {
    final entries = <RouteEntry>[];

    // Split on NeuronRoute blocks
    final routeBlocks = content.split('NeuronRoute(');

    // Skip the first chunk (everything before the first NeuronRoute)
    for (var i = 1; i < routeBlocks.length; i++) {
      final block = routeBlocks[i];

      final nameMatch = _namePattern.firstMatch(block);
      final pathMatch = _pathPattern.firstMatch(block);
      final viewMatch = _viewPattern.firstMatch(block);

      if (nameMatch != null && pathMatch != null && viewMatch != null) {
        final name = nameMatch.group(1)!;
        final routePath = pathMatch.group(1)!;
        final view = viewMatch.group(1)!;

        // Derive module from the view name: HomeView → home
        final module = view
            .replaceAll('View', '')
            .replaceAllMapped(
                RegExp(r'[A-Z]'), (m) => '_${m.group(0)!.toLowerCase()}')
            .replaceAll(RegExp(r'^_'), '');

        entries.add(RouteEntry(
          name: name,
          path: routePath,
          module: module,
          view: view,
        ));
      }
    }

    return entries;
  }

  /// Generate the full app_routes.dart file from a list of route entries
  static String appRoutesDart(String projectName, List<RouteEntry> routes) {
    final buffer = StringBuffer();

    // Imports
    buffer.writeln("import 'package:neuron/neuron.dart';");
    buffer.writeln();

    for (final route in routes) {
      final rc = ReCase(route.module);
      buffer.writeln(
          "import '../modules/${rc.snakeCase}/${rc.snakeCase}_view.dart';");
    }

    buffer.writeln();
    buffer.writeln('/// Auto-generated route definitions.');
    buffer.writeln('/// DO NOT EDIT — maintained by neuron CLI.');
    buffer.writeln('final List<NeuronRoute> appRoutes = [');

    for (final route in routes) {
      final rc = ReCase(route.module);
      buffer.writeln('  NeuronRoute(');
      buffer.writeln("    name: '${route.name}',");
      buffer.writeln("    path: '${route.path}',");
      buffer.writeln(
          '    builder: (context, params) => const ${rc.pascalCase}View(),');
      buffer.writeln('  ),');
    }

    buffer.writeln('];');

    return buffer.toString();
  }
}
