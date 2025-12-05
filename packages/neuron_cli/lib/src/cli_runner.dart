import 'package:args/command_runner.dart';
import 'package:mason_logger/mason_logger.dart';

import 'commands/commands.dart';

/// The main CLI runner for Neuron
class NeuronCliRunner {
  NeuronCliRunner({Logger? logger}) : _logger = logger ?? Logger();

  final Logger _logger;

  /// Runs the CLI with the given arguments
  Future<int> run(List<String> arguments) async {
    final runner = CommandRunner<int>(
      'neuron',
      'Neuron CLI - Generate projects, screens, controllers, and models',
    )
      ..addCommand(CreateCommand(logger: _logger))
      ..addCommand(GenerateCommand(logger: _logger))
      ..argParser.addFlag(
        'version',
        abbr: 'v',
        negatable: false,
        help: 'Print the current version.',
      );

    try {
      final results = runner.parse(arguments);

      if (results['version'] == true) {
        _logger.info('neuron_cli version: 1.0.0');
        return ExitCode.success.code;
      }

      final exitCode = await runner.run(arguments);
      return exitCode ?? ExitCode.success.code;
    } on FormatException catch (e) {
      _logger
        ..err(e.message)
        ..info('')
        ..info(runner.usage);
      return ExitCode.usage.code;
    } on UsageException catch (e) {
      _logger
        ..err(e.message)
        ..info('')
        ..info(e.usage);
      return ExitCode.usage.code;
    } catch (e) {
      _logger.err('$e');
      return ExitCode.software.code;
    }
  }
}
