import 'dart:io';

import 'package:mason_logger/mason_logger.dart';
import 'package:path/path.dart' as path;

import '../templates/language_templates.dart';
import '../utils/utils.dart';

/// Generator for installing/removing languages (i18n/l10n)
class LanguageGenerator {
  LanguageGenerator({
    required this.logger,
  });

  final Logger logger;

  /// Install a language for the entire application
  Future<void> install(String locale) async {
    final projectPath = Directory.current.path;
    final appName = await ProjectUtils.getProjectName() ?? 'My App';
    final l10nDir = path.join(projectPath, 'lib', 'l10n');

    // Create l10n directory
    await Directory(l10nDir).create(recursive: true);

    // 1. Ensure l10n.yaml exists at project root
    final l10nYamlFile = File(path.join(projectPath, 'l10n.yaml'));
    if (!await l10nYamlFile.exists()) {
      await l10nYamlFile.writeAsString(LanguageTemplates.l10nYaml());
      logger.info('  Created l10n.yaml');
    }

    // 2. Ensure English (template) ARB exists
    final enArbFile = File(path.join(l10nDir, 'app_en.arb'));
    if (!await enArbFile.exists()) {
      await enArbFile.writeAsString(LanguageTemplates.defaultEnArb(appName));
      logger.info('  Created lib/l10n/app_en.arb (template)');
    }

    // 3. Create ARB file for the requested locale
    final arbFile = File(path.join(l10nDir, 'app_$locale.arb'));
    if (await arbFile.exists()) {
      logger.warn('  lib/l10n/app_$locale.arb already exists, skipping.');
    } else {
      // Read existing keys from template ARB to match structure
      final templateKeys = await _readArbKeys(enArbFile);
      final translations = LanguageTemplates.translationsForLocale(
        locale,
        appName,
      );

      // Merge: use known translations, keep template value for unknown keys
      final merged = <String, String>{};
      for (final key in templateKeys) {
        if (key.startsWith('@')) continue;
        merged[key] = translations[key] ?? 'TODO: translate';
      }

      await arbFile.writeAsString(
        LanguageTemplates.arbFile(locale: locale, translations: merged),
      );
      logger.info('  Created lib/l10n/app_$locale.arb');
    }

    // 4. Ensure flutter_localizations is in pubspec.yaml
    await _ensureLocalizationDependency(projectPath);

    // 5. Ensure generate: true in pubspec.yaml flutter section
    await _ensureGenerateFlag(projectPath);

    // 6. Update supportedLocales in main.dart
    await _updateSupportedLocales(projectPath);
  }

  /// Remove a language from the application
  Future<void> remove(String locale) async {
    final projectPath = Directory.current.path;

    if (locale == 'en') {
      logger.err('Cannot remove English (en) - it is the template locale.');
      return;
    }

    final l10nDir = path.join(projectPath, 'lib', 'l10n');
    final arbFile = File(path.join(l10nDir, 'app_$locale.arb'));

    if (!await arbFile.exists()) {
      logger.err('Language file lib/l10n/app_$locale.arb not found.');
      return;
    }

    await arbFile.delete();
    logger.info('  Deleted lib/l10n/app_$locale.arb');

    // Update supportedLocales in main.dart
    await _updateSupportedLocales(projectPath);
  }

  /// List all currently installed languages
  Future<List<String>> listInstalled() async {
    final projectPath = Directory.current.path;
    final l10nDir = Directory(path.join(projectPath, 'lib', 'l10n'));

    if (!await l10nDir.exists()) return [];

    final locales = <String>[];
    await for (final entity in l10nDir.list()) {
      if (entity is File) {
        final name = path.basename(entity.path);
        final match = RegExp(r'^app_(\w+)\.arb$').firstMatch(name);
        if (match != null) {
          locales.add(match.group(1)!);
        }
      }
    }

    locales.sort();
    return locales;
  }

  Future<List<String>> _readArbKeys(File arbFile) async {
    if (!await arbFile.exists()) return [];

    try {
      final content = await arbFile.readAsString();
      // Simple key extraction from JSON
      final keys = <String>[];
      final pattern = RegExp(r'(\w+)"\s*:');
      for (final match in pattern.allMatches(content)) {
        final key = match.group(1)!;
        if (key != '@@locale') keys.add(key);
      }
      return keys;
    } catch (_) {
      return [];
    }
  }

  Future<void> _ensureLocalizationDependency(String projectPath) async {
    final pubspecFile = File(path.join(projectPath, 'pubspec.yaml'));
    if (!await pubspecFile.exists()) return;

    final content = await pubspecFile.readAsString();

    if (content.contains('flutter_localizations:')) return;

    // Add flutter_localizations dependency (match root-level dependencies: only)
    final updated = content.replaceFirst(
      RegExp(r'^(dependencies:\s*\n)', multiLine: true),
      'dependencies:\n  flutter_localizations:\n    sdk: flutter\n',
    );

    if (updated != content) {
      await pubspecFile.writeAsString(updated);
      logger.info('  Added flutter_localizations to pubspec.yaml');
    }
  }

  Future<void> _ensureGenerateFlag(String projectPath) async {
    final pubspecFile = File(path.join(projectPath, 'pubspec.yaml'));
    if (!await pubspecFile.exists()) return;

    final content = await pubspecFile.readAsString();

    if (content.contains('generate: true')) return;

    // Add generate: true under flutter section (match root-level flutter: only)
    final updated = content.replaceFirst(
      RegExp(r'^(flutter:\s*\n)', multiLine: true),
      'flutter:\n  generate: true\n',
    );

    if (updated != content) {
      await pubspecFile.writeAsString(updated);
      logger.info('  Added generate: true to pubspec.yaml');
    }
  }

  Future<void> _updateSupportedLocales(String projectPath) async {
    final locales = await listInstalled();
    if (locales.isEmpty) return;

    final mainFile = File(path.join(projectPath, 'lib', 'main.dart'));
    if (!await mainFile.exists()) return;

    var content = await mainFile.readAsString();

    // Build supportedLocales list
    final localeEntries =
        locales.map((l) => "        const Locale('$l'),").join('\n');
    final supportedLocalesBlock = '''
      supportedLocales: const [
$localeEntries
      ],''';

    // Check if localization imports already exist
    if (!content.contains('flutter_localizations')) {
      // Add imports after existing imports
      final lastImportMatch =
          RegExp(r'^import [^\n]+;$', multiLine: true).allMatches(content);
      if (lastImportMatch.isNotEmpty) {
        final lastImport = lastImportMatch.last;
        content = '${content.substring(0, lastImport.end)}'
            '\n${LanguageTemplates.localizationImports()}'
            '${content.substring(lastImport.end)}';
      }
    }

    // Add or update localizationsDelegates
    if (!content.contains('localizationsDelegates')) {
      // Insert before the closing ); of NeuronApp or MaterialApp
      final appPattern =
          RegExp(r'(NeuronApp|MaterialApp)\s*\(', multiLine: true);
      final appMatch = appPattern.firstMatch(content);
      if (appMatch != null) {
        // Find the first property inside the app widget and insert before it
        final afterParen = appMatch.end;
        content = '${content.substring(0, afterParen)}'
            '\n${LanguageTemplates.localizationDelegates()}\n$supportedLocalesBlock'
            '${content.substring(afterParen)}';
      }
    } else {
      // Update existing supportedLocales
      content = content.replaceFirst(
        RegExp(
            r'supportedLocales:\s*const\s*\[[\s\S]*?\],', multiLine: true),
        supportedLocalesBlock.trim(),
      );
    }

    await mainFile.writeAsString(content);
    logger.info('  Updated lib/main.dart with locale configuration');
  }
}
