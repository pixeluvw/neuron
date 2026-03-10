import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:path/path.dart' as path;
import 'package:recase/recase.dart';

import '../generators/generators.dart';
import '../utils/utils.dart';

/// Command to remove Neuron components (screens, controllers, models)
class RemoveCommand extends Command<int> {
  RemoveCommand({required Logger logger}) : _logger = logger {
    addSubcommand(RemoveScreenCommand(logger: _logger));
    addSubcommand(RemoveControllerCommand(logger: _logger));
    addSubcommand(RemoveModelCommand(logger: _logger));
  }

  final Logger _logger;

  @override
  String get name => 'remove';

  @override
  List<String> get aliases => ['r'];

  @override
  String get description =>
      'Remove Neuron components (screen, controller, model)';
}

/// Remove a screen module (controller + view + route + DI entry)
class RemoveScreenCommand extends Command<int> {
  RemoveScreenCommand({required Logger logger}) : _logger = logger;

  final Logger _logger;

  @override
  String get name => 'screen';

  @override
  List<String> get aliases => ['s'];

  @override
  String get description =>
      'Remove a screen module and clean up routes/DI';

  @override
  String get invocation => 'neuron remove screen <name>';

  @override
  Future<int> run() async {
    if (argResults?.rest.isEmpty ?? true) {
      _logger.err('Please provide a screen name.');
      _logger.info('Usage: neuron remove screen <name>');
      return ExitCode.usage.code;
    }

    final screenName = argResults!.rest.first;
    final rc = ReCase(screenName);

    if (!await ProjectUtils.isNeuronProject()) {
      _logger.err('Not in a Neuron/Flutter project directory.');
      return ExitCode.usage.code;
    }

    final moduleDir =
        path.join(Directory.current.path, 'lib', 'modules', rc.snakeCase);

    if (!Directory(moduleDir).existsSync()) {
      _logger.err('Module "${rc.snakeCase}" not found.');
      _logger.info('Expected at: lib/modules/${rc.snakeCase}/');
      return ExitCode.usage.code;
    }

    // Confirm deletion
    final confirm = _logger.confirm(
      'Remove module "${rc.pascalCase}" and all its files?',
    );

    if (!confirm) {
      _logger.info('Cancelled.');
      return ExitCode.success.code;
    }

    final progress = _logger.progress('Removing module "${rc.pascalCase}"');

    try {
      // Delete module directory
      await Directory(moduleDir).delete(recursive: true);

      // Remove route
      final routeGen = RouteGenerator(logger: _logger);
      await routeGen.removeRoute(screenName);

      // Remove DI entry
      final diGen = DiGenerator(logger: _logger);
      await diGen.removeController('${rc.pascalCase}Controller');

      progress.complete('Module removed successfully!');

      _logger.info('');
      _logger.success('✓ Removed module: ${rc.pascalCase}');
      _logger.info('');
      _logger.info('Cleaned up:');
      _logger.info('  ✓ lib/modules/${rc.snakeCase}/ (deleted)');
      _logger.info('  ✓ Route entry removed from app_routes.dart');
      _logger.info('  ✓ Controller removed from injector.dart');

      return ExitCode.success.code;
    } catch (e) {
      progress.fail('Failed to remove module');
      _logger.err('$e');
      return ExitCode.software.code;
    }
  }
}

/// Remove a standalone controller
class RemoveControllerCommand extends Command<int> {
  RemoveControllerCommand({required Logger logger}) : _logger = logger;

  final Logger _logger;

  @override
  String get name => 'controller';

  @override
  List<String> get aliases => ['c'];

  @override
  String get description =>
      'Remove a shared controller and clean up DI';

  @override
  String get invocation => 'neuron remove controller <name>';

  @override
  Future<int> run() async {
    if (argResults?.rest.isEmpty ?? true) {
      _logger.err('Please provide a controller name.');
      _logger.info('Usage: neuron remove controller <name>');
      return ExitCode.usage.code;
    }

    final controllerName = argResults!.rest.first;
    final rc = ReCase(controllerName);

    if (!await ProjectUtils.isNeuronProject()) {
      _logger.err('Not in a Neuron/Flutter project directory.');
      return ExitCode.usage.code;
    }

    final controllerFile = File(path.join(
      Directory.current.path,
      'lib',
      'shared',
      'controllers',
      '${rc.snakeCase}_controller.dart',
    ));

    if (!controllerFile.existsSync()) {
      _logger.err('Controller "${rc.snakeCase}_controller.dart" not found.');
      _logger.info(
          'Expected at: lib/shared/controllers/${rc.snakeCase}_controller.dart');
      return ExitCode.usage.code;
    }

    final confirm = _logger.confirm(
      'Remove controller "${rc.pascalCase}Controller"?',
    );

    if (!confirm) {
      _logger.info('Cancelled.');
      return ExitCode.success.code;
    }

    final progress =
        _logger.progress('Removing controller "${rc.pascalCase}Controller"');

    try {
      // Delete controller file
      await controllerFile.delete();

      // Remove DI entry
      final diGen = DiGenerator(logger: _logger);
      await diGen.removeController('${rc.pascalCase}Controller');

      progress.complete('Controller removed successfully!');

      _logger.info('');
      _logger.success('✓ Removed controller: ${rc.pascalCase}Controller');
      _logger.info('');
      _logger.info('Cleaned up:');
      _logger.info(
          '  ✓ lib/shared/controllers/${rc.snakeCase}_controller.dart (deleted)');
      _logger.info('  ✓ Controller removed from injector.dart');

      return ExitCode.success.code;
    } catch (e) {
      progress.fail('Failed to remove controller');
      _logger.err('$e');
      return ExitCode.software.code;
    }
  }
}

/// Remove a model class
class RemoveModelCommand extends Command<int> {
  RemoveModelCommand({required Logger logger}) : _logger = logger;

  final Logger _logger;

  @override
  String get name => 'model';

  @override
  List<String> get aliases => ['m'];

  @override
  String get description => 'Remove a model class';

  @override
  String get invocation => 'neuron remove model <name>';

  @override
  Future<int> run() async {
    if (argResults?.rest.isEmpty ?? true) {
      _logger.err('Please provide a model name.');
      _logger.info('Usage: neuron remove model <name>');
      return ExitCode.usage.code;
    }

    final modelName = argResults!.rest.first;
    final rc = ReCase(modelName);

    if (!await ProjectUtils.isNeuronProject()) {
      _logger.err('Not in a Neuron/Flutter project directory.');
      return ExitCode.usage.code;
    }

    final modelFile = File(path.join(
      Directory.current.path,
      'lib',
      'shared',
      'models',
      '${rc.snakeCase}.dart',
    ));

    if (!modelFile.existsSync()) {
      _logger.err('Model "${rc.snakeCase}.dart" not found.');
      _logger.info('Expected at: lib/shared/models/${rc.snakeCase}.dart');
      return ExitCode.usage.code;
    }

    final confirm = _logger.confirm(
      'Remove model "${rc.pascalCase}"?',
    );

    if (!confirm) {
      _logger.info('Cancelled.');
      return ExitCode.success.code;
    }

    final progress = _logger.progress('Removing model "${rc.pascalCase}"');

    try {
      await modelFile.delete();

      progress.complete('Model removed successfully!');

      _logger.info('');
      _logger.success('✓ Removed model: ${rc.pascalCase}');
      _logger.info('');
      _logger.info('Deleted: lib/shared/models/${rc.snakeCase}.dart');

      return ExitCode.success.code;
    } catch (e) {
      progress.fail('Failed to remove model');
      _logger.err('$e');
      return ExitCode.software.code;
    }
  }
}
