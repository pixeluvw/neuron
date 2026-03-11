import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:path/path.dart' as path;

import '../generators/generators.dart';
import '../utils/utils.dart';

/// Command to upgrade the neuron dependency and optionally regenerate files
class UpgradeCommand extends Command<int> {
  UpgradeCommand({required Logger logger}) : _logger = logger {
    argParser.addFlag(
      'regen',
      help: 'Regenerate route and DI files after upgrading',
      negatable: false,
    );
  }

  final Logger _logger;

  @override
  String get name => 'upgrade';

  @override
  String get description =>
      'Upgrade neuron dependency to latest version';

  @override
  Future<int> run() async {
    final regen = argResults!['regen'] as bool;

    if (!await ProjectUtils.isNeuronProject()) {
      _logger.err('Not in a Neuron/Flutter project directory.');
      return ExitCode.usage.code;
    }

    final progress = _logger.progress('Checking latest neuron version');

    try {
      final latestVersion = await ProjectUtils.getLatestNeuronVersion();
      progress.complete('Latest version: $latestVersion');

      // Update pubspec.yaml
      final pubspecFile =
          File(path.join(Directory.current.path, 'pubspec.yaml'));
      var content = await pubspecFile.readAsString();

      // Replace existing neuron version
      final neuronRegex = RegExp(r'neuron:\s*\^?[\d.]+');
      if (neuronRegex.hasMatch(content)) {
        content = content.replaceFirst(
            neuronRegex, 'neuron: ^$latestVersion');
        await pubspecFile.writeAsString(content);
        _logger.success('✓ Updated neuron to ^$latestVersion in pubspec.yaml');
      } else if (content.contains('neuron:')) {
        _logger.warn(
            'Neuron dependency found but uses non-standard format. Please update manually.');
      } else {
        _logger.err('Neuron dependency not found in pubspec.yaml.');
        _logger.info('Run: neuron init');
        return ExitCode.usage.code;
      }

      // Run flutter pub get
      final pubGetProgress = _logger.progress('Running flutter pub get');
      final result = await Process.run(
        'flutter',
        ['pub', 'get'],
        workingDirectory: Directory.current.path,
        runInShell: true,
      );

      if (result.exitCode == 0) {
        pubGetProgress.complete('Dependencies updated!');
      } else {
        pubGetProgress.fail('flutter pub get failed');
        _logger.err(result.stderr.toString());
        return ExitCode.software.code;
      }

      // Regenerate files if requested
      if (regen) {
        final regenProgress =
            _logger.progress('Regenerating routes and DI files');

        final routeGen = RouteGenerator(logger: _logger);
        await routeGen.regenerate();

        final diGen = DiGenerator(logger: _logger);
        await diGen.regenerate();

        regenProgress.complete('Files regenerated!');
      }

      _logger.info('');
      _logger.success('✓ Neuron upgraded to ^$latestVersion');
      if (regen) {
        _logger.success('✓ Routes and DI files regenerated');
      }
      _logger.info('');

      return ExitCode.success.code;
    } catch (e) {
      progress.fail('Upgrade failed');
      _logger.err('$e');
      return ExitCode.software.code;
    }
  }
}
