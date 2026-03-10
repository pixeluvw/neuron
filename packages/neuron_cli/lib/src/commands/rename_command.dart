import 'package:args/command_runner.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:recase/recase.dart';

import '../generators/generators.dart';
import '../utils/utils.dart';

/// Command to rename components and update all references
class RenameCommand extends Command<int> {
  RenameCommand({required Logger logger}) : _logger = logger {
    addSubcommand(RenameScreenCommand(logger: _logger));
    addSubcommand(RenameControllerCommand(logger: _logger));
    addSubcommand(RenameModelCommand(logger: _logger));
    addSubcommand(RenameServiceCommand(logger: _logger));
  }

  final Logger _logger;

  @override
  String get name => 'rename';

  @override
  List<String> get aliases => ['mv'];

  @override
  String get description =>
      'Rename a component and update all references (screen, controller, model, service)';
}

// ─── Rename Screen ──────────────────────────────────────────────────────────

class RenameScreenCommand extends Command<int> {
  RenameScreenCommand({required Logger logger}) : _logger = logger;
  final Logger _logger;

  @override
  String get name => 'screen';
  @override
  List<String> get aliases => ['s'];
  @override
  String get description => 'Rename a screen module and update all references';
  @override
  String get invocation => 'neuron rename screen <old_name> <new_name>';

  @override
  Future<int> run() async {
    if ((argResults?.rest.length ?? 0) < 2) {
      _logger.err('Please provide both old and new names.');
      _logger.info('Usage: neuron rename screen <old_name> <new_name>');
      return ExitCode.usage.code;
    }

    final oldName = argResults!.rest[0];
    final newName = argResults!.rest[1];

    if (!await ProjectUtils.isNeuronProject()) {
      _logger.err('Not in a Neuron/Flutter project directory.');
      return ExitCode.usage.code;
    }

    final oldRc = ReCase(oldName);
    final newRc = ReCase(newName);

    final progress = _logger.progress(
        'Renaming module "${oldRc.pascalCase}" → "${newRc.pascalCase}"');

    try {
      final generator = RenameGenerator(logger: _logger);
      await generator.renameScreen(oldName, newName);

      progress.complete('Module renamed successfully!');
      _logger.info('');
      _logger.success(
          '✓ Renamed: ${oldRc.pascalCase} → ${newRc.pascalCase}');
      _logger.info('');
      _logger.info('Updated:');
      _logger.info('  ✓ Module directory and files');
      _logger.info('  ✓ Route entry in app_routes.dart');
      _logger.info('  ✓ DI entry in injector.dart');
      _logger.info('  ✓ Import references across project');

      return ExitCode.success.code;
    } catch (e) {
      progress.fail('Failed to rename module');
      _logger.err('$e');
      return ExitCode.software.code;
    }
  }
}

// ─── Rename Controller ──────────────────────────────────────────────────────

class RenameControllerCommand extends Command<int> {
  RenameControllerCommand({required Logger logger}) : _logger = logger;
  final Logger _logger;

  @override
  String get name => 'controller';
  @override
  List<String> get aliases => ['c'];
  @override
  String get description => 'Rename a controller and update all references';
  @override
  String get invocation =>
      'neuron rename controller <old_name> <new_name>';

  @override
  Future<int> run() async {
    if ((argResults?.rest.length ?? 0) < 2) {
      _logger.err('Please provide both old and new names.');
      _logger.info(
          'Usage: neuron rename controller <old_name> <new_name>');
      return ExitCode.usage.code;
    }

    final oldName = argResults!.rest[0];
    final newName = argResults!.rest[1];

    if (!await ProjectUtils.isNeuronProject()) {
      _logger.err('Not in a Neuron/Flutter project directory.');
      return ExitCode.usage.code;
    }

    final oldRc = ReCase(oldName);
    final newRc = ReCase(newName);
    final progress = _logger.progress(
        'Renaming controller "${oldRc.pascalCase}" → "${newRc.pascalCase}"');

    try {
      final generator = RenameGenerator(logger: _logger);
      await generator.renameController(oldName, newName);

      progress.complete('Controller renamed successfully!');
      _logger.info('');
      _logger.success(
          '✓ Renamed: ${oldRc.pascalCase}Controller → ${newRc.pascalCase}Controller');

      return ExitCode.success.code;
    } catch (e) {
      progress.fail('Failed to rename controller');
      _logger.err('$e');
      return ExitCode.software.code;
    }
  }
}

// ─── Rename Model ───────────────────────────────────────────────────────────

class RenameModelCommand extends Command<int> {
  RenameModelCommand({required Logger logger}) : _logger = logger;
  final Logger _logger;

  @override
  String get name => 'model';
  @override
  List<String> get aliases => ['m'];
  @override
  String get description => 'Rename a model and update all references';
  @override
  String get invocation => 'neuron rename model <old_name> <new_name>';

  @override
  Future<int> run() async {
    if ((argResults?.rest.length ?? 0) < 2) {
      _logger.err('Please provide both old and new names.');
      _logger.info('Usage: neuron rename model <old_name> <new_name>');
      return ExitCode.usage.code;
    }

    final oldName = argResults!.rest[0];
    final newName = argResults!.rest[1];

    if (!await ProjectUtils.isNeuronProject()) {
      _logger.err('Not in a Neuron/Flutter project directory.');
      return ExitCode.usage.code;
    }

    final oldRc = ReCase(oldName);
    final newRc = ReCase(newName);
    final progress = _logger.progress(
        'Renaming model "${oldRc.pascalCase}" → "${newRc.pascalCase}"');

    try {
      final generator = RenameGenerator(logger: _logger);
      await generator.renameModel(oldName, newName);

      progress.complete('Model renamed successfully!');
      _logger.info('');
      _logger.success(
          '✓ Renamed: ${oldRc.pascalCase} → ${newRc.pascalCase}');

      return ExitCode.success.code;
    } catch (e) {
      progress.fail('Failed to rename model');
      _logger.err('$e');
      return ExitCode.software.code;
    }
  }
}

// ─── Rename Service ─────────────────────────────────────────────────────────

class RenameServiceCommand extends Command<int> {
  RenameServiceCommand({required Logger logger}) : _logger = logger;
  final Logger _logger;

  @override
  String get name => 'service';
  @override
  List<String> get aliases => ['svc'];
  @override
  String get description => 'Rename a service and update all references';
  @override
  String get invocation => 'neuron rename service <old_name> <new_name>';

  @override
  Future<int> run() async {
    if ((argResults?.rest.length ?? 0) < 2) {
      _logger.err('Please provide both old and new names.');
      _logger.info('Usage: neuron rename service <old_name> <new_name>');
      return ExitCode.usage.code;
    }

    final oldName = argResults!.rest[0];
    final newName = argResults!.rest[1];

    if (!await ProjectUtils.isNeuronProject()) {
      _logger.err('Not in a Neuron/Flutter project directory.');
      return ExitCode.usage.code;
    }

    final oldRc = ReCase(oldName);
    final newRc = ReCase(newName);
    final progress = _logger.progress(
        'Renaming service "${oldRc.pascalCase}" → "${newRc.pascalCase}"');

    try {
      final generator = RenameGenerator(logger: _logger);
      await generator.renameService(oldName, newName);

      progress.complete('Service renamed successfully!');
      _logger.info('');
      _logger.success(
          '✓ Renamed: ${oldRc.pascalCase}Service → ${newRc.pascalCase}Service');

      return ExitCode.success.code;
    } catch (e) {
      progress.fail('Failed to rename service');
      _logger.err('$e');
      return ExitCode.software.code;
    }
  }
}
