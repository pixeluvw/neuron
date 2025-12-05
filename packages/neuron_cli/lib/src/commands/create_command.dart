import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:path/path.dart' as path;

import '../generators/generators.dart';

/// Command to create a new Neuron project
class CreateCommand extends Command<int> {
  CreateCommand({required Logger logger}) : _logger = logger {
    argParser
      ..addOption(
        'org',
        abbr: 'o',
        help: 'The organization identifier (e.g., com.example)',
        defaultsTo: 'com.example',
      )
      ..addFlag(
        'empty',
        help: 'Create an empty project without example code',
        negatable: false,
      );
  }

  final Logger _logger;

  @override
  String get name => 'create';

  @override
  String get description => 'Create a new Neuron project';

  @override
  String get invocation => 'neuron create <project_name>';

  @override
  Future<int> run() async {
    if (argResults?.rest.isEmpty ?? true) {
      _logger.err('Please provide a project name.');
      _logger.info('Usage: neuron create <project_name>');
      return ExitCode.usage.code;
    }

    final projectName = argResults!.rest.first;
    final org = argResults!['org'] as String;
    final empty = argResults!['empty'] as bool;

    // Validate project name
    if (!_isValidProjectName(projectName)) {
      _logger.err('Invalid project name: $projectName');
      _logger.info(
          'Project name must be a valid Dart package name (lowercase with underscores).');
      return ExitCode.usage.code;
    }

    final projectPath = path.join(Directory.current.path, projectName);

    if (Directory(projectPath).existsSync()) {
      _logger.err('Directory "$projectName" already exists.');
      return ExitCode.cantCreate.code;
    }

    final progress = _logger.progress('Creating Neuron project "$projectName"');

    try {
      final generator = ProjectGenerator(
        projectName: projectName,
        projectPath: projectPath,
        organization: org,
        isEmpty: empty,
        logger: _logger,
      );

      await generator.generate();

      progress.complete('Project created successfully!');

      _logger.info('');
      _logger.success('✓ Created Neuron project: $projectName');
      _logger.info('');
      _logger.info('Next steps:');
      _logger.info('  cd $projectName');
      _logger.info('  flutter pub get');
      _logger.info('  flutter run');
      _logger.info('');
      _logger.info('Generate screens:');
      _logger.info('  neuron generate screen home');
      _logger.info('  neuron generate screen settings');
      _logger.info('');

      return ExitCode.success.code;
    } catch (e) {
      progress.fail('Failed to create project');
      _logger.err('$e');
      return ExitCode.software.code;
    }
  }

  bool _isValidProjectName(String name) {
    final regex = RegExp(r'^[a-z][a-z0-9_]*$');
    return regex.hasMatch(name) && !_dartReservedWords.contains(name);
  }

  static const _dartReservedWords = [
    'abstract',
    'as',
    'assert',
    'async',
    'await',
    'break',
    'case',
    'catch',
    'class',
    'const',
    'continue',
    'covariant',
    'default',
    'deferred',
    'do',
    'dynamic',
    'else',
    'enum',
    'export',
    'extends',
    'extension',
    'external',
    'factory',
    'false',
    'final',
    'finally',
    'for',
    'Function',
    'get',
    'hide',
    'if',
    'implements',
    'import',
    'in',
    'interface',
    'is',
    'late',
    'library',
    'mixin',
    'new',
    'null',
    'on',
    'operator',
    'part',
    'required',
    'rethrow',
    'return',
    'set',
    'show',
    'static',
    'super',
    'switch',
    'sync',
    'this',
    'throw',
    'true',
    'try',
    'typedef',
    'var',
    'void',
    'while',
    'with',
    'yield',
  ];
}
