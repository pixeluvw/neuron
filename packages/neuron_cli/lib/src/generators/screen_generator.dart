import 'dart:io';

import 'package:mason_logger/mason_logger.dart';
import 'package:path/path.dart' as path;
import 'package:recase/recase.dart';

import '../templates/templates.dart';
import '../utils/project_utils.dart';
import 'di_generator.dart';
import 'route_generator.dart';

/// Generator for creating a self-contained screen module (controller + view)
class ScreenGenerator {
  ScreenGenerator({
    required this.screenName,
    required this.registerRoute,
    this.customRoutePath,
    required this.logger,
  });

  final String screenName;
  final bool registerRoute;
  final String? customRoutePath;
  final Logger logger;

  Future<void> generate() async {
    final rc = ReCase(screenName);
    // Modules are self-contained: lib/modules/<screen_name>/
    final moduleDir =
        path.join(Directory.current.path, 'lib', 'modules', rc.snakeCase);

    // Ensure neuron dependency is added to pubspec.yaml
    await _ensureNeuronDependency();

    // Create module directory
    await Directory(moduleDir).create(recursive: true);

    // Generate controller (with static init getter)
    await File(path.join(moduleDir, '${rc.snakeCase}_controller.dart'))
        .writeAsString(ScreenTemplates.controllerDart(screenName));

    // Generate view (StatelessWidget only!)
    await File(path.join(moduleDir, '${rc.snakeCase}_view.dart'))
        .writeAsString(ScreenTemplates.viewDart(screenName));

    // Register route in central route registry
    if (registerRoute) {
      final routeGen = RouteGenerator(logger: logger);
      await routeGen.addRoute(
        screenName: screenName,
        customRoutePath: customRoutePath,
      );
    }

    // Register controller in DI
    final diGen = DiGenerator(logger: logger);
    await diGen.addController(
      name: screenName,
      className: '${rc.pascalCase}Controller',
      importPath: '../modules/${rc.snakeCase}/${rc.snakeCase}_controller.dart',
      isShared: false,
    );

    // Log navigation info
    if (registerRoute) {
      logger.info('');
      logger.info('Navigation:');
      logger.info("  Neuron.toNamed('${rc.camelCase}');");
      logger.info('  Neuron.to(const ${rc.pascalCase}View());');
    }
  }

  /// Ensures neuron dependency is present in pubspec.yaml
  Future<void> _ensureNeuronDependency() async {
    final pubspecFile = File(path.join(Directory.current.path, 'pubspec.yaml'));

    if (!await pubspecFile.exists()) {
      logger.warn(
          'No pubspec.yaml found. Make sure you are in a Flutter project root.');
      return;
    }

    var content = await pubspecFile.readAsString();

    // Check if neuron is already a dependency
    if (content.contains('neuron:')) {
      return; // Already has neuron dependency
    }

    logger.info('Adding neuron dependency to pubspec.yaml...');

    // Find the dependencies section and add neuron after cupertino_icons or after flutter sdk
    final dependenciesRegex = RegExp(
        r'(dependencies:\s*\n(?:.*\n)*?)(cupertino_icons:[^\n]*\n|  flutter:\s*\n\s*sdk:\s*flutter\s*\n)');
    final match = dependenciesRegex.firstMatch(content);
    final neuronVersion = await ProjectUtils.getLatestNeuronVersion();

    if (match != null) {
      final neuronDep = '  neuron: ^$neuronVersion\n';
      final insertPoint = match.end;
      content = content.substring(0, insertPoint) +
          neuronDep +
          content.substring(insertPoint);

      await pubspecFile.writeAsString(content);
      logger.success('Added neuron dependency to pubspec.yaml');
      logger.info('Run "flutter pub get" to install the dependency.');
    } else {
      logger.warn(
          'Could not automatically add neuron dependency. Please add it manually:');
      logger.info('  neuron: ^$neuronVersion');
    }
  }
}
