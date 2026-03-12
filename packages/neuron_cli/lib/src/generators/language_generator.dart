import 'dart:io';

import 'package:mason_logger/mason_logger.dart';
import 'package:path/path.dart' as path;

import '../templates/language_templates.dart';
import '../utils/utils.dart';

/// Generator for installing/removing languages (i18n/l10n).
///
/// When a language is installed the generator sets up:
///
/// 1. ARB files with **comprehensive translations** (40+ keys per locale)
///    covering navigation, actions, auth, feedback, settings — the whole UI.
/// 2. A **LocaleController** (`lib/shared/services/locale_controller.dart`)
///    that holds a reactive `Signal<Locale>` persisted with
///    `shared_preferences`. Changing it rebuilds the entire app in the new
///    language — exactly like switching the system language on Linux / Windows.
/// 3. A **Language picker screen** (`lib/modules/language/`) so the user can
///    switch languages from the UI.
/// 4. A **locale-aware main.dart** wrapped in a `Slot<Locale>` that drives
///    the MaterialApp's `locale` property.
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

    // 5. Ensure shared_preferences is in pubspec.yaml
    await _ensureSharedPreferencesDependency(projectPath);

    // 6. Ensure generate: true in pubspec.yaml flutter section
    await _ensureGenerateFlag(projectPath);

    // 7. Generate / update LocaleController
    await _generateLocaleController(projectPath);

    // 8. Generate language picker screen
    await _generateLanguageScreen(projectPath);

    // 9. Rewrite main.dart to be locale-aware
    await _rewriteMainDart(projectPath, appName);
  }

  /// Remove a language from the application
  Future<void> remove(String locale) async {
    final projectPath = Directory.current.path;
    final appName = await ProjectUtils.getProjectName() ?? 'My App';

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

    // Re-generate locale controller & main.dart with updated locale list
    await _generateLocaleController(projectPath);
    await _rewriteMainDart(projectPath, appName);
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

  // ─────────────────────────────────────────────────────────────────────
  //  Private helpers
  // ─────────────────────────────────────────────────────────────────────

  Future<List<String>> _readArbKeys(File arbFile) async {
    if (!await arbFile.exists()) return [];

    try {
      final content = await arbFile.readAsString();
      // Simple key extraction from JSON
      final keys = <String>[];
      final pattern = RegExp(r'"(\w+)"\s*:');
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

    // Add flutter_localizations dependency
    final updated = content.replaceFirst(
      RegExp(r'^(dependencies:\s*\n)', multiLine: true),
      'dependencies:\n  flutter_localizations:\n    sdk: flutter\n',
    );

    if (updated != content) {
      await pubspecFile.writeAsString(updated);
      logger.info('  Added flutter_localizations to pubspec.yaml');
    }
  }

  Future<void> _ensureSharedPreferencesDependency(String projectPath) async {
    final pubspecFile = File(path.join(projectPath, 'pubspec.yaml'));
    if (!await pubspecFile.exists()) return;

    final content = await pubspecFile.readAsString();

    if (content.contains('shared_preferences:')) return;

    // Add shared_preferences dependency
    final updated = content.replaceFirst(
      RegExp(r'^(dependencies:\s*\n)', multiLine: true),
      'dependencies:\n  shared_preferences: ^2.2.0\n',
    );

    if (updated != content) {
      await pubspecFile.writeAsString(updated);
      logger.info('  Added shared_preferences to pubspec.yaml');
    }
  }

  Future<void> _ensureGenerateFlag(String projectPath) async {
    final pubspecFile = File(path.join(projectPath, 'pubspec.yaml'));
    if (!await pubspecFile.exists()) return;

    final content = await pubspecFile.readAsString();

    if (content.contains('generate: true')) return;

    // Add generate: true under flutter section
    final updated = content.replaceFirst(
      RegExp(r'^(flutter:\s*\n)', multiLine: true),
      'flutter:\n  generate: true\n',
    );

    if (updated != content) {
      await pubspecFile.writeAsString(updated);
      logger.info('  Added generate: true to pubspec.yaml');
    }
  }

  /// Generate (or overwrite) the LocaleController.
  Future<void> _generateLocaleController(String projectPath) async {
    final locales = await listInstalled();
    if (locales.isEmpty) return;

    final dir = path.join(projectPath, 'lib', 'shared', 'services');
    await Directory(dir).create(recursive: true);

    final file = File(path.join(dir, 'locale_controller.dart'));
    await file.writeAsString(
        LanguageTemplates.localeControllerDart(locales));
    logger.info('  Generated lib/shared/services/locale_controller.dart');
  }

  /// Generate the language picker screen module.
  Future<void> _generateLanguageScreen(String projectPath) async {
    final langDir = path.join(projectPath, 'lib', 'modules', 'language');
    await Directory(langDir).create(recursive: true);

    final viewFile = File(path.join(langDir, 'language_view.dart'));
    if (!await viewFile.exists()) {
      await viewFile.writeAsString(LanguageTemplates.languageViewDart());
      logger.info('  Created lib/modules/language/language_view.dart');
    }

    final ctrlFile = File(path.join(langDir, 'language_controller.dart'));
    if (!await ctrlFile.exists()) {
      await ctrlFile.writeAsString(
          LanguageTemplates.languageControllerDart());
      logger.info('  Created lib/modules/language/language_controller.dart');
    }
  }

  /// Rewrite main.dart with locale-aware NeuronApp.
  Future<void> _rewriteMainDart(
      String projectPath, String appName) async {
    final locales = await listInstalled();
    if (locales.isEmpty) return;

    final mainFile = File(path.join(projectPath, 'lib', 'main.dart'));
    if (!await mainFile.exists()) return;

    await mainFile.writeAsString(
        LanguageTemplates.localeAwareMainDart(appName, locales));
    logger.info('  Rewrote lib/main.dart with locale-aware setup');
  }
}
