import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:path/path.dart' as path;
import 'package:yaml/yaml.dart';

import '../generators/generators.dart';

/// Command to initialize Neuron in an existing Flutter project
class InitCommand extends Command<int> {
  InitCommand({required Logger logger}) : _logger = logger {
    argParser
      ..addFlag(
        'empty',
        help: 'Initialize without generating a starter home module',
        negatable: false,
      )
      ..addFlag(
        'force',
        abbr: 'f',
        help: 'Force re-initialization even if already a Neuron project',
        negatable: false,
      );
  }

  final Logger _logger;

  @override
  String get name => 'init';

  @override
  String get description =>
      'Initialize Neuron in an existing Flutter project';

  @override
  String get invocation => 'neuron init';

  @override
  Future<int> run() async {
    final projectPath = Directory.current.path;
    final force = argResults!['force'] as bool;
    final empty = argResults!['empty'] as bool;

    // Check pubspec.yaml exists
    final pubspecFile = File(path.join(projectPath, 'pubspec.yaml'));
    if (!pubspecFile.existsSync()) {
      _logger.err('No pubspec.yaml found in the current directory.');
      _logger.info('Make sure you are in the root of a Flutter project.');
      return ExitCode.usage.code;
    }

    // Parse pubspec to validate it's a Flutter project and get name
    final String projectName;
    final bool hasNeuron;
    try {
      final content = await pubspecFile.readAsString();
      final yaml = loadYaml(content) as YamlMap;

      projectName = yaml['name'] as String? ?? 'my_app';

      final dependencies = yaml['dependencies'] as YamlMap?;
      if (dependencies == null || !dependencies.containsKey('flutter')) {
        _logger.err('This does not appear to be a Flutter project.');
        _logger.info(
            'pubspec.yaml must have a "flutter" dependency. Run "flutter create" first.');
        return ExitCode.usage.code;
      }

      hasNeuron = dependencies.containsKey('neuron');
    } catch (e) {
      _logger.err('Failed to parse pubspec.yaml: $e');
      return ExitCode.software.code;
    }

    // Check if already initialized
    final modulesDir = Directory(path.join(projectPath, 'lib', 'modules'));
    if (!force && (hasNeuron || modulesDir.existsSync())) {
      _logger.err('This project appears to already be a Neuron project.');
      _logger.info('Use --force to re-initialize.');
      return ExitCode.usage.code;
    }

    final progress = _logger.progress('Initializing Neuron in "$projectName"');

    try {
      final generator = InitGenerator(
        projectName: projectName,
        projectPath: projectPath,
        isEmpty: empty,
        logger: _logger,
      );

      await generator.generate();

      progress.complete('Neuron initialized successfully!');

      _logger.info('');
      _logger.success('✓ Initialized Neuron in: $projectName');
      _logger.info('');
      _logger.info('Next steps:');
      _logger.info('  flutter pub get');
      _logger.info('  flutter run');
      _logger.info('');
      _logger.info('Generate more screens:');
      _logger.info('  neuron generate screen settings');
      _logger.info('  neuron generate screen profile');
      _logger.info('');

      return ExitCode.success.code;
    } catch (e) {
      progress.fail('Failed to initialize Neuron');
      _logger.err('$e');
      return ExitCode.software.code;
    }
  }
}
