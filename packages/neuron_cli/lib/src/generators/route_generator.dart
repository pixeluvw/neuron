import 'dart:convert';
import 'dart:io';

import 'package:mason_logger/mason_logger.dart';
import 'package:path/path.dart' as path;
import 'package:recase/recase.dart';

import '../templates/templates.dart';

/// Generator for managing the central route registry.
///
/// Uses a JSON manifest (`lib/routes/.routes.json`) as source of truth.
/// Always regenerates `lib/routes/app_routes.dart` from the manifest.
class RouteGenerator {
  RouteGenerator({required this.logger});

  final Logger logger;

  String get _routesDir => path.join(Directory.current.path, 'lib', 'routes');
  String get _manifestPath => path.join(_routesDir, '.routes.json');
  String get _appRoutesPath => path.join(_routesDir, 'app_routes.dart');

  /// Read the current route manifest
  Future<List<RouteEntry>> _readManifest() async {
    final file = File(_manifestPath);
    if (!await file.exists()) return [];

    try {
      final content = await file.readAsString();
      final list = jsonDecode(content) as List;
      return list
          .map((e) => RouteEntry.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Write the manifest and regenerate app_routes.dart
  Future<void> _writeManifest(
      String projectName, List<RouteEntry> routes) async {
    await Directory(_routesDir).create(recursive: true);

    // Write JSON manifest
    final json = const JsonEncoder.withIndent('  ')
        .convert(routes.map((r) => r.toJson()).toList());
    await File(_manifestPath).writeAsString(json);

    // Regenerate app_routes.dart
    await File(_appRoutesPath)
        .writeAsString(RouteTemplates.appRoutesDart(projectName, routes));
  }

  /// Add a route to the manifest and regenerate
  Future<void> addRoute({
    required String screenName,
    String? customRoutePath,
  }) async {
    final rc = ReCase(screenName);
    final routes = await _readManifest();
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
    await _writeManifest(projectName, routes);
  }

  /// Remove a route from the manifest and regenerate
  Future<void> removeRoute(String screenName) async {
    final rc = ReCase(screenName);
    final routes = await _readManifest();
    final before = routes.length;
    routes.removeWhere((r) => r.module == rc.snakeCase);

    if (routes.length < before) {
      final projectName = await _getProjectName();
      await _writeManifest(projectName, routes);
    }
  }

  /// Generate the initial routes from a list of entries (used by create/init)
  Future<void> generateInitial(
      String projectName, List<RouteEntry> routes) async {
    await _writeManifest(projectName, routes);
  }

  /// Regenerate app_routes.dart from the manifest (used by upgrade --regen)
  Future<void> regenerateFromManifest() async {
    final routes = await _readManifest();
    final projectName = await _getProjectName();
    await _writeManifest(projectName, routes);
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
