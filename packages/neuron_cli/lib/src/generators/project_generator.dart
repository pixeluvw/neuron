import 'dart:io';

import 'package:mason_logger/mason_logger.dart';
import 'package:path/path.dart' as path;

import '../templates/templates.dart';

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
  }

  Future<void> _generateCleanPubspec() async {
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
  neuron:
    git:
      url: https://github.com/pixeluvw/Neuron-Framework.git
      path: packages/neuron

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
      'lib/modules/home', // Home module (controller + view)
      'lib/shared/models', // Shared data models
      'lib/shared/widgets', // Shared widgets
      'lib/shared/services', // Shared services (API, storage, etc.)
      'lib/shared/utils', // Shared utilities
    ];

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
    }
  }
}
