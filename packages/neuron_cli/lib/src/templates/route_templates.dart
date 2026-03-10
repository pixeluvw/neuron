import 'package:recase/recase.dart';

/// Route entry for manifest tracking
class RouteEntry {
  const RouteEntry({
    required this.name,
    required this.path,
    required this.module,
    required this.view,
  });

  factory RouteEntry.fromJson(Map<String, dynamic> json) => RouteEntry(
        name: json['name'] as String,
        path: json['path'] as String,
        module: json['module'] as String,
        view: json['view'] as String,
      );

  final String name;
  final String path;
  final String module;
  final String view;

  Map<String, dynamic> toJson() => {
        'name': name,
        'path': path,
        'module': module,
        'view': view,
      };
}

/// Templates for route generation
class RouteTemplates {
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
