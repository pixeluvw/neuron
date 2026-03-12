import 'dart:io';

import 'package:mason_logger/mason_logger.dart';
import 'package:path/path.dart' as path;
import 'package:yaml/yaml.dart';

import '../templates/templates.dart';
import '../utils/project_utils.dart';
import 'di_generator.dart';
import 'route_generator.dart';

/// Generator for initializing Neuron in an existing Flutter project
class InitGenerator {
  InitGenerator({
    required this.projectName,
    required this.projectPath,
    required this.isEmpty,
    required this.logger,
  });

  final String projectName;
  final String projectPath;
  final bool isEmpty;
  final Logger logger;

  Future<void> generate() async {
    // 1. Rewrite pubspec.yaml to add neuron dependency
    await _rewritePubspec();

    // 2. Create Neuron directory structure
    await _createProjectStructure();

    // 3. Overwrite main.dart with NeuronApp
    await _generateMainDart();

    // 4. Generate home module (unless --empty)
    if (!isEmpty) {
      await _generateHomeModule();
    }

    // 5. Generate initial routes and DI
    await _generateRoutesAndDi();

    // 6. Overwrite default widget_test.dart with Neuron-compatible test
    await _generateWidgetTest();
  }

  /// Parse existing pubspec.yaml and rewrite it with neuron dependency added
  Future<void> _rewritePubspec() async {
    final pubspecFile = File(path.join(projectPath, 'pubspec.yaml'));
    final content = await pubspecFile.readAsString();
    final yaml = loadYaml(content) as YamlMap;

    // Extract existing values
    final name = yaml['name'] as String? ?? projectName;
    final description =
        yaml['description'] as String? ?? 'A Flutter/Neuron project.';
    final publishTo = yaml['publish_to'];
    final version = yaml['version'] as String? ?? '1.0.0+1';

    // Environment
    final environment = yaml['environment'] as YamlMap?;
    final sdkConstraint = environment?['sdk'] as String? ?? '^3.0.0';

    // Dependencies — preserve existing ones and add neuron
    final deps = yaml['dependencies'] as YamlMap?;
    final devDeps = yaml['dev_dependencies'] as YamlMap?;

    // Build dependencies section
    final depsBuffer = StringBuffer();
    if (deps != null) {
      for (final key in deps.keys) {
        final value = deps[key];
        if (key == 'neuron') continue; // We'll add our own
        _writeDependency(depsBuffer, key as String, value);
      }
    }

    // Add neuron dependency (published — fetched from pub.dev)
    final neuronVersion = await ProjectUtils.getLatestNeuronVersion();
    depsBuffer.writeln('  neuron: ^$neuronVersion');

    // Build dev_dependencies section
    final devDepsBuffer = StringBuffer();
    if (devDeps != null) {
      for (final key in devDeps.keys) {
        final value = devDeps[key];
        _writeDependency(devDepsBuffer, key as String, value);
      }
    }

    // Build flutter section
    final flutterSection = yaml['flutter'] as YamlMap?;
    final flutterBuffer = StringBuffer();
    if (flutterSection != null) {
      _writeYamlMap(flutterBuffer, flutterSection, indent: 2);
    } else {
      flutterBuffer.writeln('  uses-material-design: true');
    }

    // Reconstruct pubspec.yaml
    final output = StringBuffer();
    output.writeln('name: $name');
    output.writeln('description: "$description"');
    if (publishTo != null) {
      output.writeln("publish_to: '$publishTo'");
    }
    output.writeln('version: $version');
    output.writeln('');
    output.writeln('environment:');
    output.writeln('  sdk: $sdkConstraint');
    output.writeln('');
    output.writeln('dependencies:');
    output.write(depsBuffer);
    output.writeln('');
    output.writeln('dev_dependencies:');
    output.write(devDepsBuffer);
    output.writeln('');
    output.writeln('flutter:');
    output.write(flutterBuffer);

    await pubspecFile.writeAsString(output.toString());
  }

  /// Write a single dependency entry
  void _writeDependency(StringBuffer buffer, String name, dynamic value) {
    if (value is String) {
      buffer.writeln('  $name: $value');
    } else if (value is YamlMap) {
      buffer.writeln('  $name:');
      _writeYamlMap(buffer, value, indent: 4);
    } else if (value == null) {
      buffer.writeln('  $name:');
    } else {
      buffer.writeln('  $name: $value');
    }
  }

  /// Write a YamlMap with proper indentation
  void _writeYamlMap(StringBuffer buffer, YamlMap map, {int indent = 2}) {
    final prefix = ' ' * indent;
    for (final key in map.keys) {
      final value = map[key];
      if (value is YamlMap) {
        buffer.writeln('$prefix$key:');
        _writeYamlMap(buffer, value, indent: indent + 2);
      } else if (value is YamlList) {
        buffer.writeln('$prefix$key:');
        for (final item in value) {
          buffer.writeln('$prefix  - $item');
        }
      } else if (value is bool) {
        buffer.writeln('$prefix$key: $value');
      } else if (value is String) {
        buffer.writeln('$prefix$key: $value');
      } else if (value == null) {
        buffer.writeln('$prefix$key:');
      } else {
        buffer.writeln('$prefix$key: $value');
      }
    }
  }

  /// Create the Neuron modular directory structure
  Future<void> _createProjectStructure() async {
    final directories = [
      'lib/modules',
      'lib/shared/models',
      'lib/shared/widgets',
      'lib/shared/services',
      'lib/shared/utils',
      'lib/routes',
      'lib/di',
    ];

    if (!isEmpty) {
      directories.add('lib/modules/home');
    }

    for (final dir in directories) {
      await Directory(path.join(projectPath, dir)).create(recursive: true);
    }
  }

  /// Overwrite lib/main.dart with NeuronApp template
  Future<void> _generateMainDart() async {
    final mainFile = File(path.join(projectPath, 'lib', 'main.dart'));
    await mainFile.writeAsString(
        ProjectTemplates.mainDart(projectName, isEmpty));
  }

  /// Generate the starter home module (controller + view)
  Future<void> _generateHomeModule() async {
    await File(path.join(
            projectPath, 'lib', 'modules', 'home', 'home_controller.dart'))
        .writeAsString(ProjectTemplates.homeControllerDart());

    await File(
            path.join(projectPath, 'lib', 'modules', 'home', 'home_view.dart'))
        .writeAsString(ProjectTemplates.homeViewDart());
  }

  /// Generate initial routes and DI files
  Future<void> _generateRoutesAndDi() async {
    final savedDir = Directory.current;
    Directory.current = Directory(projectPath);
    try {
      if (!isEmpty) {
        final routeGen = RouteGenerator(logger: logger);
        await routeGen.generateInitial(projectName, [
          const RouteEntry(
            name: 'home',
            path: '/',
            module: 'home',
            view: 'HomeView',
          ),
        ]);

        final diGen = DiGenerator(logger: logger);
        await diGen.generateInitial([
          const ControllerEntry(
            name: 'home',
            className: 'HomeController',
            importPath: '../modules/home/home_controller.dart',
            isShared: false,
          ),
        ]);
      } else {
        final routeGen = RouteGenerator(logger: logger);
        await routeGen.generateInitial(projectName, []);

        final diGen = DiGenerator(logger: logger);
        await diGen.generateInitial([]);
      }
    } finally {
      Directory.current = savedDir;
    }
  }

  /// Overwrite the default widget_test.dart with Neuron-compatible test
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
