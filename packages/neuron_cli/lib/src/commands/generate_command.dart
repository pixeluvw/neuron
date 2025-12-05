import 'package:args/command_runner.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:recase/recase.dart';

import '../generators/generators.dart';
import '../utils/utils.dart';

/// Command to generate Neuron components (screens, controllers, models)
class GenerateCommand extends Command<int> {
  GenerateCommand({required Logger logger}) : _logger = logger {
    addSubcommand(GenerateScreenCommand(logger: _logger));
    addSubcommand(GenerateControllerCommand(logger: _logger));
    addSubcommand(GenerateModelCommand(logger: _logger));
  }

  final Logger _logger;

  @override
  String get name => 'generate';

  @override
  List<String> get aliases => ['g'];

  @override
  String get description =>
      'Generate Neuron components (screen, controller, model)';
}

/// Generate a complete screen with controller, view, and route registration
class GenerateScreenCommand extends Command<int> {
  GenerateScreenCommand({required Logger logger}) : _logger = logger {
    argParser
      ..addFlag(
        'no-route',
        help: 'Skip route registration',
        negatable: false,
      )
      ..addOption(
        'path',
        abbr: 'p',
        help: 'Custom route path (default: /<screen_name>)',
      );
  }

  final Logger _logger;

  @override
  String get name => 'screen';

  @override
  List<String> get aliases => ['s'];

  @override
  String get description =>
      'Generate a screen with controller, view, and route';

  @override
  String get invocation => 'neuron generate screen <name>';

  @override
  Future<int> run() async {
    if (argResults?.rest.isEmpty ?? true) {
      _logger.err('Please provide a screen name.');
      _logger.info('Usage: neuron generate screen <name>');
      return ExitCode.usage.code;
    }

    final screenName = argResults!.rest.first;
    final noRoute = argResults!['no-route'] as bool;
    final customPath = argResults!['path'] as String?;

    // Validate we're in a Flutter project
    if (!await ProjectUtils.isNeuronProject()) {
      _logger.err('Not in a Neuron/Flutter project directory.');
      _logger.info(
          'Make sure you are in the root of a Flutter project with Neuron dependency.');
      return ExitCode.usage.code;
    }

    final progress = _logger.progress('Generating module "$screenName"');

    try {
      final generator = ScreenGenerator(
        screenName: screenName,
        registerRoute: !noRoute,
        customRoutePath: customPath,
        logger: _logger,
      );

      await generator.generate();

      progress.complete('Module generated successfully!');

      final rc = ReCase(screenName);

      _logger.info('');
      _logger.success('✓ Generated module: ${rc.pascalCase}');
      _logger.info('');
      _logger.info('Created files:');
      _logger.info(
          '  lib/modules/${rc.snakeCase}/${rc.snakeCase}_controller.dart');
      _logger.info('  lib/modules/${rc.snakeCase}/${rc.snakeCase}_view.dart');
      _logger.info('');
      _logger.info('Usage in view:');
      _logger.info('  final c = ${rc.pascalCase}Controller.init;');
      _logger.info('');
      _logger.info('Navigate using:');
      _logger.info('  Neuron.to(const ${rc.pascalCase}View());');
      _logger.info('  Neuron.off(const ${rc.pascalCase}View());  // replace');
      _logger.info('  Neuron.back();  // pop');

      _logger.info('');

      return ExitCode.success.code;
    } catch (e) {
      progress.fail('Failed to generate module');
      _logger.err('$e');
      return ExitCode.software.code;
    }
  }
}

/// Generate a standalone controller
class GenerateControllerCommand extends Command<int> {
  GenerateControllerCommand({required Logger logger}) : _logger = logger;

  final Logger _logger;

  @override
  String get name => 'controller';

  @override
  List<String> get aliases => ['c'];

  @override
  String get description => 'Generate a NeuronController';

  @override
  String get invocation => 'neuron generate controller <name>';

  @override
  Future<int> run() async {
    if (argResults?.rest.isEmpty ?? true) {
      _logger.err('Please provide a controller name.');
      _logger.info('Usage: neuron generate controller <name>');
      return ExitCode.usage.code;
    }

    final controllerName = argResults!.rest.first;

    if (!await ProjectUtils.isNeuronProject()) {
      _logger.err('Not in a Neuron/Flutter project directory.');
      return ExitCode.usage.code;
    }

    final progress =
        _logger.progress('Generating controller "$controllerName"');

    try {
      final generator = ControllerGenerator(
        controllerName: controllerName,
        logger: _logger,
      );

      await generator.generate();

      progress.complete('Controller generated successfully!');

      final rc = ReCase(controllerName);

      _logger.info('');
      _logger.success('✓ Generated controller: ${rc.pascalCase}Controller');
      _logger.info('');
      _logger.info('Created file:');
      _logger.info('  lib/shared/controllers/${rc.snakeCase}_controller.dart');
      _logger.info('');
      _logger.info('Usage:');
      _logger.info('  final c = ${rc.pascalCase}Controller.init;');
      _logger.info('');

      return ExitCode.success.code;
    } catch (e) {
      progress.fail('Failed to generate controller');
      _logger.err('$e');
      return ExitCode.software.code;
    }
  }
}

/// Generate a model class
class GenerateModelCommand extends Command<int> {
  GenerateModelCommand({required Logger logger}) : _logger = logger {
    argParser.addMultiOption(
      'fields',
      abbr: 'f',
      help:
          'Model fields in format: name:type (e.g., -f id:int -f name:String)',
    );
  }

  final Logger _logger;

  @override
  String get name => 'model';

  @override
  List<String> get aliases => ['m'];

  @override
  String get description => 'Generate a model class';

  @override
  String get invocation => 'neuron generate model <name> [-f field:type]';

  @override
  Future<int> run() async {
    if (argResults?.rest.isEmpty ?? true) {
      _logger.err('Please provide a model name.');
      _logger.info('Usage: neuron generate model <name> [-f field:type]');
      return ExitCode.usage.code;
    }

    final modelName = argResults!.rest.first;
    final fields = argResults!['fields'] as List<String>;

    if (!await ProjectUtils.isNeuronProject()) {
      _logger.err('Not in a Neuron/Flutter project directory.');
      return ExitCode.usage.code;
    }

    final progress = _logger.progress('Generating model "$modelName"');

    try {
      final generator = ModelGenerator(
        modelName: modelName,
        fields: fields,
        logger: _logger,
      );

      await generator.generate();

      progress.complete('Model generated successfully!');

      final rc = ReCase(modelName);

      _logger.info('');
      _logger.success('✓ Generated model: ${rc.pascalCase}');
      _logger.info('');
      _logger.info('Created file:');
      _logger.info('  lib/shared/models/${rc.snakeCase}.dart');
      _logger.info('');

      return ExitCode.success.code;
    } catch (e) {
      progress.fail('Failed to generate model');
      _logger.err('$e');
      return ExitCode.software.code;
    }
  }
}
