import 'dart:io';

import 'package:mason_logger/mason_logger.dart';
import 'package:path/path.dart' as path;
import 'package:recase/recase.dart';

import '../templates/templates.dart';

/// Generator for managing the central route registry.
///
/// Uses `lib/routes/app_routes.dart` as the single source of truth.
/// Parses the Dart file to read entries and regenerates it after mutations.
class RouteGenerator {
  RouteGenerator({required this.logger});

  final Logger logger;

  String get _routesDir => path.join(Directory.current.path, 'lib', 'routes');
  String get _appRoutesPath => path.join(_routesDir, 'app_routes.dart');

  /// Read the current route entries by parsing the generated Dart file.
  Future<List<RouteEntry>> _readEntries() async {
    final file = File(_appRoutesPath);
    if (!await file.exists()) return [];

    try {
      final content = await file.readAsString();
      return RouteTemplates.parseAppRoutesDart(content);
    } catch (_) {
      return [];
    }
  }

  /// Write entries by regenerating app_routes.dart.
  Future<void> _writeEntries(
      String projectName, List<RouteEntry> routes) async {
    await Directory(_routesDir).create(recursive: true);
    await File(_appRoutesPath)
        .writeAsString(RouteTemplates.appRoutesDart(projectName, routes));
  }

  /// Add a route and regenerate.
  Future<void> addRoute({
    required String screenName,
    String? customRoutePath,
  }) async {
    final rc = ReCase(screenName);
    final routes = await _readEntries();
    final routeName = rc.camelCase;

    // Skip if already registered
    if (routes.any((r) => r.name == routeName)) return;

    routes.add(RouteEntry(
      name: routeName,
      path: customRoutePath ?? '/${rc.paramCase}',
      module: rc.snakeCase,
      view: '${rc.pascalCase}View',
    ));

    final projectName = await _getProjectName();
    await _writeEntries(projectName, routes);
  }

  /// Remove a route and regenerate.
  Future<void> removeRoute(String screenName) async {
    final rc = ReCase(screenName);
    final routes = await _readEntries();
    final before = routes.length;
    routes.removeWhere((r) => r.module == rc.snakeCase);

    if (routes.length < before) {
      final projectName = await _getProjectName();
      await _writeEntries(projectName, routes);
    }
  }

  /// Generate the initial routes from a list of entries (used by create/init).
  Future<void> generateInitial(
      String projectName, List<RouteEntry> routes) async {
    await _writeEntries(projectName, routes);
  }

  /// Regenerate app_routes.dart from its current content (used by upgrade --regen).
  ///
  /// Useful when the template format changes after a CLI upgrade.
  Future<void> regenerate() async {
    final routes = await _readEntries();
    final projectName = await _getProjectName();
    await _writeEntries(projectName, routes);
  }

  /// Get project name from pubspec.yaml
  Future<String> _getProjectName() async {
    final pubspec =
        File(path.join(Directory.current.path, 'pubspec.yaml'));
    if (await pubspec.exists()) {
      final content = await pubspec.readAsString();
      final match = RegExp(r'^name:\s*(\S+)', multiLine: true).firstMatch(content);
      if (match != null) return match.group(1)!;
    }
    return 'app';
  }
}
