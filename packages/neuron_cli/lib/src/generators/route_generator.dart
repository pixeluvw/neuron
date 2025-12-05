import 'dart:io';

import 'package:mason_logger/mason_logger.dart';
import 'package:path/path.dart' as path;
import 'package:recase/recase.dart';

/// Generator for auto-registering routes
class RouteGenerator {
  RouteGenerator({
    required this.screenName,
    this.customRoutePath,
    required this.logger,
  });

  final String screenName;
  final String? customRoutePath;
  final Logger logger;

  String get routePath => customRoutePath ?? '/${ReCase(screenName).paramCase}';

  Future<void> registerRoute() async {
    final rc = ReCase(screenName);
    final routesFile = File(
        path.join(Directory.current.path, 'lib', 'routes', 'app_routes.dart'));
    final routerFile = File(path.join(
        Directory.current.path, 'lib', 'routes', 'neuron_router.dart'));

    // Update app_routes.dart
    if (await routesFile.exists()) {
      await _updateAppRoutes(routesFile, rc);
    } else {
      logger.warn('app_routes.dart not found. Skipping route registration.');
    }

    // Update neuron_router.dart
    if (await routerFile.exists()) {
      await _updateNeuronRouter(routerFile, rc);
    } else {
      logger.warn('neuron_router.dart not found. Skipping router helper.');
    }
  }

  Future<void> _updateAppRoutes(File file, ReCase rc) async {
    var content = await file.readAsString();

    // Add import
    final snakeCase = rc.snakeCase;
    final importStatement =
        "import '../modules/$snakeCase/${snakeCase}_view.dart';";
    if (!content.contains(importStatement)) {
      // Find the last import line and add after it
      final importPattern = RegExp(r'''import\s+['"].*['"]\s*;''');
      final matches = importPattern.allMatches(content).toList();
      if (matches.isNotEmpty) {
        final lastImport = matches.last;
        content =
            '${content.substring(0, lastImport.end)}\n$importStatement${content.substring(lastImport.end)}';
      } else {
        // No imports found, add at the beginning
        content = '$importStatement\n\n$content';
      }
    }

    // Add route constant
    final camelCase = rc.camelCase;
    final pascalCase = rc.pascalCase;
    final routeConstant = "  static const $camelCase = '$routePath';";
    final constCheck = 'static const $camelCase =';
    if (!content.contains(constCheck)) {
      final routesClassPattern =
          RegExp(r'class\s+AppRoutes\s*\{([^}]*)\}', dotAll: true);
      final match = routesClassPattern.firstMatch(content);
      if (match != null) {
        final classContent = match.group(1)!;
        final newClassContent = '$classContent\n$routeConstant\n';
        content = content.replaceFirst(
          'class AppRoutes {$classContent}',
          'class AppRoutes {$newClassContent}',
        );
      }
    }

    // Add route case in generateRoute
    final routeCase = '''
      case AppRoutes.$camelCase:
        return MaterialPageRoute(
          builder: (_) => const ${pascalCase}View(),
          settings: settings,
        );''';

    final caseCheck = 'case AppRoutes.$camelCase:';
    if (!content.contains(caseCheck)) {
      // Find the switch statement and add before default case
      final defaultPattern = RegExp(r'(\s*default\s*:)');
      final match = defaultPattern.firstMatch(content);
      if (match != null) {
        content =
            '${content.substring(0, match.start)}\n$routeCase\n${content.substring(match.start)}';
      }
    }

    await file.writeAsString(content);
  }

  Future<void> _updateNeuronRouter(File file, ReCase rc) async {
    var content = await file.readAsString();

    final pascalCase = rc.pascalCase;
    final camelCase = rc.camelCase;

    // Add navigation helper method
    final helperMethod = '''
  /// Navigate to $pascalCase screen
  static Future<T?> to$pascalCase<T>(BuildContext context, {Object? arguments}) {
    return Navigator.pushNamed<T>(context, AppRoutes.$camelCase, arguments: arguments);
  }
''';

    final methodCheck = 'static Future<T?> to$pascalCase<T>';
    if (!content.contains(methodCheck)) {
      // Find the class closing brace and add before it
      final classPattern = RegExp(r'(class\s+NeuronRouter\s*\{[^}]*)(})');
      final match = classPattern.firstMatch(content);
      if (match != null) {
        content = '${match.group(1)}\n$helperMethod${match.group(2)}';
      }
    }

    await file.writeAsString(content);
  }
}
