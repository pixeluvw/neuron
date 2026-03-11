import 'package:args/command_runner.dart';
import 'package:mason_logger/mason_logger.dart';

import '../generators/language_generator.dart';
import '../templates/language_templates.dart';
import '../utils/utils.dart';

/// Command to install/remove languages for the whole application
class LanguageCommand extends Command<int> {
  LanguageCommand({required Logger logger}) : _logger = logger {
    addSubcommand(LanguageInstallCommand(logger: _logger));
    addSubcommand(LanguageRemoveCommand(logger: _logger));
    addSubcommand(LanguageListCommand(logger: _logger));
  }

  final Logger _logger;

  @override
  String get name => 'language';

  @override
  List<String> get aliases => ['lang', 'l10n'];

  @override
  String get description =>
      'Manage languages/localization for the application';
}

/// Install a new language
class LanguageInstallCommand extends Command<int> {
  LanguageInstallCommand({required Logger logger}) : _logger = logger;

  final Logger _logger;

  @override
  String get name => 'install';

  @override
  List<String> get aliases => ['add'];

  @override
  String get description => 'Install a language for the application';

  @override
  String get invocation => 'neuron language install <locale>';

  @override
  Future<int> run() async {
    if (argResults?.rest.isEmpty ?? true) {
      _logger.err('Please provide a locale code.');
      _logger.info('Usage: neuron language install <locale>');
      _logger.info('');
      _logger.info('Examples:');
      _logger.info('  neuron language install es    # Spanish');
      _logger.info('  neuron language install fr    # French');
      _logger.info('  neuron language install de    # German');
      _logger.info('  neuron language install ja    # Japanese');
      _logger.info('  neuron language install zh    # Chinese');
      return ExitCode.usage.code;
    }

    if (!await ProjectUtils.isNeuronProject()) {
      _logger.err('Not in a Neuron/Flutter project directory.');
      return ExitCode.usage.code;
    }

    final locale = argResults!.rest.first.toLowerCase();

    // Validate locale format (2 or 2+2 letter code)
    if (!RegExp(r'^[a-z]{2}(_[A-Za-z]{2})?$').hasMatch(locale)) {
      _logger.err('Invalid locale code: $locale');
      _logger.info('Use a valid ISO 639-1 code (e.g., en, es, fr, de, ja).');
      return ExitCode.usage.code;
    }

    final langName = LanguageTemplates.languageName(locale);
    final progress =
        _logger.progress('Installing language: $langName ($locale)');

    try {
      final generator = LanguageGenerator(logger: _logger);
      await generator.install(locale);

      progress.complete('Language installed successfully!');

      _logger.info('');
      _logger.success('✓ Installed $langName ($locale)');
      _logger.info('');
      _logger.info('Created/updated:');
      _logger.info('  lib/l10n/app_$locale.arb');
      _logger.info('');
      _logger.info('Next steps:');
      _logger
          .info('  1. Edit lib/l10n/app_$locale.arb with your translations');
      _logger.info('  2. Run "flutter gen-l10n" to generate Dart code');
      _logger.info(
          '  3. Use AppLocalizations.of(context)!.key in your widgets');
      _logger.info('');

      return ExitCode.success.code;
    } catch (e) {
      progress.fail('Failed to install language');
      _logger.err('$e');
      return ExitCode.software.code;
    }
  }
}

/// Remove a language
class LanguageRemoveCommand extends Command<int> {
  LanguageRemoveCommand({required Logger logger}) : _logger = logger {
    argParser.addFlag(
      'force',
      abbr: 'f',
      help: 'Force removal without confirmation',
      negatable: false,
    );
  }

  final Logger _logger;

  @override
  String get name => 'remove';

  @override
  List<String> get aliases => ['rm'];

  @override
  String get description => 'Remove a language from the application';

  @override
  String get invocation => 'neuron language remove <locale>';

  @override
  Future<int> run() async {
    if (argResults?.rest.isEmpty ?? true) {
      _logger.err('Please provide a locale code to remove.');
      _logger.info('Usage: neuron language remove <locale>');
      return ExitCode.usage.code;
    }

    if (!await ProjectUtils.isNeuronProject()) {
      _logger.err('Not in a Neuron/Flutter project directory.');
      return ExitCode.usage.code;
    }

    final locale = argResults!.rest.first.toLowerCase();
    final force = argResults!['force'] as bool;
    final langName = LanguageTemplates.languageName(locale);

    if (!force) {
      final confirmed = _logger.confirm(
        'Remove $langName ($locale) translations?',
      );
      if (!confirmed) {
        _logger.info('Cancelled.');
        return ExitCode.success.code;
      }
    }

    final progress =
        _logger.progress('Removing language: $langName ($locale)');

    try {
      final generator = LanguageGenerator(logger: _logger);
      await generator.remove(locale);

      progress.complete('Language removed successfully!');

      _logger.info('');
      _logger.success('✓ Removed $langName ($locale)');
      _logger.info('');
      _logger
          .info('Run "flutter gen-l10n" to regenerate localization code.');
      _logger.info('');

      return ExitCode.success.code;
    } catch (e) {
      progress.fail('Failed to remove language');
      _logger.err('$e');
      return ExitCode.software.code;
    }
  }
}

/// List installed languages
class LanguageListCommand extends Command<int> {
  LanguageListCommand({required Logger logger}) : _logger = logger;

  final Logger _logger;

  @override
  String get name => 'list';

  @override
  List<String> get aliases => ['ls'];

  @override
  String get description => 'List installed languages';

  @override
  Future<int> run() async {
    if (!await ProjectUtils.isNeuronProject()) {
      _logger.err('Not in a Neuron/Flutter project directory.');
      return ExitCode.usage.code;
    }

    final generator = LanguageGenerator(logger: _logger);
    final locales = await generator.listInstalled();

    if (locales.isEmpty) {
      _logger.info('No languages installed yet.');
      _logger.info('');
      _logger.info('Get started:');
      _logger.info('  neuron language install en    # English (template)');
      _logger.info('  neuron language install es    # Spanish');
      return ExitCode.success.code;
    }

    _logger.info('');
    _logger.info('${lightCyan.wrap('Installed Languages')}');
    _logger.info('');
    for (final locale in locales) {
      final name = LanguageTemplates.languageName(locale);
      final marker = locale == 'en' ? ' (template)' : '';
      _logger.info('  $locale - $name$marker');
    }
    _logger.info('');

    return ExitCode.success.code;
  }
}
