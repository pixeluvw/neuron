import 'dart:io';

import 'package:mason_logger/mason_logger.dart';
import 'package:path/path.dart' as path;

import '../templates/templates.dart';
import '../utils/project_utils.dart';
import 'di_generator.dart';
import 'route_generator.dart';

/// Generator for creating a new Neuron project
class ProjectGenerator {
  ProjectGenerator({
    required this.projectName,
    required this.projectPath,
    required this.organization,
    required this.isEmpty,
    required this.logger,
  });

  final String projectName;
  final String projectPath;
  final String organization;
  final bool isEmpty;
  final Logger logger;

  Future<void> generate() async {
    // First, run flutter create
    final result = await Process.run(
      'flutter',
      [
        'create',
        '--org',
        organization,
        '--project-name',
        projectName,
        projectPath,
      ],
      runInShell: true,
    );

    if (result.exitCode != 0) {
      throw Exception('Failed to create Flutter project: ${result.stderr}');
    }

    // Replace pubspec.yaml with clean version including neuron
    await _generateCleanPubspec();

    // Create Neuron project structure (modular)
    await _createProjectStructure();

    // Generate initial files
    await _generateInitialFiles();

    // Overwrite default widget_test.dart with Neuron-compatible test
    await _generateWidgetTest();
  }

  Future<void> _generateCleanPubspec() async {
    final neuronVersion = await ProjectUtils.getLatestNeuronVersion();
    final pubspecFile = File(path.join(projectPath, 'pubspec.yaml'));
    final content = '''name: $projectName
description: "A new Flutter/Neuron project."
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: ^3.0.0

dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  neuron: ^$neuronVersion

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0

flutter:
  uses-material-design: true
''';
    await pubspecFile.writeAsString(content);
  }

  Future<void> _createProjectStructure() async {
    // Modular structure: each screen is a self-contained module
    final directories = [
      'lib/modules', // Self-contained screen modules
      'lib/shared/models', // Shared data models
      'lib/shared/widgets', // Shared widgets
      'lib/shared/services', // Shared services (API, storage, etc.)
      'lib/shared/utils', // Shared utilities
      'lib/routes', // Central route registry
      'lib/di', // Dependency injection
    ];

    if (!isEmpty) {
      directories.add('lib/modules/home');
    }

    for (final dir in directories) {
      await Directory(path.join(projectPath, dir)).create(recursive: true);
    }
  }

  Future<void> _generateInitialFiles() async {
    // Generate main.dart with NeuronApp
    await File(path.join(projectPath, 'lib', 'main.dart'))
        .writeAsString(ProjectTemplates.mainDart(projectName, isEmpty));

    if (!isEmpty) {
      // Generate home module (self-contained: controller + view)
      await File(path.join(
              projectPath, 'lib', 'modules', 'home', 'home_controller.dart'))
          .writeAsString(ProjectTemplates.homeControllerDart());

      await File(path.join(
              projectPath, 'lib', 'modules', 'home', 'home_view.dart'))
          .writeAsString(ProjectTemplates.homeViewDart());

      // Generate initial routes with home
      final savedDir = Directory.current;
      Directory.current = Directory(projectPath);
      try {
        final routeGen = RouteGenerator(logger: logger);
        await routeGen.generateInitial(projectName, [
          const RouteEntry(
            name: 'home',
            path: '/',
            module: 'home',
            view: 'HomeView',
          ),
        ]);

        // Generate initial DI with home controller
        final diGen = DiGenerator(logger: logger);
        await diGen.generateInitial([
          const ControllerEntry(
            name: 'home',
            className: 'HomeController',
            importPath: '../modules/home/home_controller.dart',
            isShared: false,
          ),
        ]);
      } finally {
        Directory.current = savedDir;
      }
    } else {
      // Generate empty routes and DI
      final savedDir = Directory.current;
      Directory.current = Directory(projectPath);
      try {
        final routeGen = RouteGenerator(logger: logger);
        await routeGen.generateInitial(projectName, []);

        final diGen = DiGenerator(logger: logger);
        await diGen.generateInitial([]);
      } finally {
        Directory.current = savedDir;
      }
    }
  }

  Future<void> _generateWidgetTest() async {
    final testDir = path.join(projectPath, 'test');
    await Directory(testDir).create(recursive: true);

    final testFile = File(path.join(testDir, 'widget_test.dart'));
    await testFile.writeAsString(
      isEmpty
          ? ProjectTemplates.widgetTestDartEmpty(projectName)
          : ProjectTemplates.widgetTestDart(projectName),
    );
  }
}
