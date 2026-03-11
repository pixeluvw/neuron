/// Templates for internationalization / localization setup
class LanguageTemplates {
  /// l10n.yaml configuration file
  static String l10nYaml() {
    return '''
arb-dir: lib/l10n
template-arb-file: app_en.arb
output-localization-file: app_localizations.dart
''';
  }

  /// ARB file for a given locale
  static String arbFile({
    required String locale,
    required Map<String, String> translations,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('{');
    buffer.writeln('  "@@locale": "$locale",');

    final entries = translations.entries.toList();
    for (var i = 0; i < entries.length; i++) {
      final entry = entries[i];
      final comma = i < entries.length - 1 ? ',' : '';
      buffer.writeln('  "${entry.key}": "${entry.value}"$comma');
    }

    buffer.writeln('}');
    return buffer.toString();
  }

  /// Default English ARB file
  static String defaultEnArb(String appName) {
    return arbFile(
      locale: 'en',
      translations: {
        'appTitle': appName,
        '@appTitle': '',
        'hello': 'Hello',
        '@hello': '',
        'settings': 'Settings',
        '@settings': '',
        'language': 'Language',
        '@language': '',
      },
    );
  }

  /// Well-known translations for supported locales
  static Map<String, String> translationsForLocale(
      String locale, String appName) {
    return switch (locale) {
      'es' => {
          'appTitle': appName,
          'hello': 'Hola',
          'settings': 'Configuración',
          'language': 'Idioma',
        },
      'fr' => {
          'appTitle': appName,
          'hello': 'Bonjour',
          'settings': 'Paramètres',
          'language': 'Langue',
        },
      'de' => {
          'appTitle': appName,
          'hello': 'Hallo',
          'settings': 'Einstellungen',
          'language': 'Sprache',
        },
      'pt' => {
          'appTitle': appName,
          'hello': 'Olá',
          'settings': 'Configurações',
          'language': 'Idioma',
        },
      'it' => {
          'appTitle': appName,
          'hello': 'Ciao',
          'settings': 'Impostazioni',
          'language': 'Lingua',
        },
      'ja' => {
          'appTitle': appName,
          'hello': 'こんにちは',
          'settings': '設定',
          'language': '言語',
        },
      'ko' => {
          'appTitle': appName,
          'hello': '안녕하세요',
          'settings': '설정',
          'language': '언어',
        },
      'zh' => {
          'appTitle': appName,
          'hello': '你好',
          'settings': '设置',
          'language': '语言',
        },
      'ar' => {
          'appTitle': appName,
          'hello': 'مرحبا',
          'settings': 'الإعدادات',
          'language': 'اللغة',
        },
      'ru' => {
          'appTitle': appName,
          'hello': 'Привет',
          'settings': 'Настройки',
          'language': 'Язык',
        },
      'hi' => {
          'appTitle': appName,
          'hello': 'नमस्ते',
          'settings': 'सेटिंग्स',
          'language': 'भाषा',
        },
      'tr' => {
          'appTitle': appName,
          'hello': 'Merhaba',
          'settings': 'Ayarlar',
          'language': 'Dil',
        },
      'nl' => {
          'appTitle': appName,
          'hello': 'Hallo',
          'settings': 'Instellingen',
          'language': 'Taal',
        },
      'pl' => {
          'appTitle': appName,
          'hello': 'Cześć',
          'settings': 'Ustawienia',
          'language': 'Język',
        },
      _ => {
          'appTitle': appName,
          'hello': 'Hello',
          'settings': 'Settings',
          'language': 'Language',
        },
    };
  }

  /// Human-readable language name
  static String languageName(String locale) {
    return switch (locale) {
      'en' => 'English',
      'es' => 'Spanish',
      'fr' => 'French',
      'de' => 'German',
      'pt' => 'Portuguese',
      'it' => 'Italian',
      'ja' => 'Japanese',
      'ko' => 'Korean',
      'zh' => 'Chinese',
      'ar' => 'Arabic',
      'ru' => 'Russian',
      'hi' => 'Hindi',
      'tr' => 'Turkish',
      'nl' => 'Dutch',
      'pl' => 'Polish',
      _ => locale,
    };
  }

  /// Localization helper snippet (to add to main.dart)
  static String localizationImports() {
    return '''
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';''';
  }

  /// Localization delegates snippet
  static String localizationDelegates() {
    return '''
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],''';
  }
}
