import 'dart:io';

import 'package:mason_logger/mason_logger.dart';
import 'package:path/path.dart' as path;

import '../templates/theme_gen_templates.dart';

/// Generator for creating light/dark theme files
class ThemeGenerator {
  ThemeGenerator({
    required this.seedColor,
    required this.style,
    required this.withController,
    required this.logger,
  });

  final String seedColor;
  final String style;
  final bool withController;
  final Logger logger;

  Future<void> generate() async {
    final projectPath = Directory.current.path;
    final appDir = path.join(projectPath, 'lib', 'app');

    // Create app directory if it doesn't exist
    await Directory(appDir).create(recursive: true);

    final themeFile = File(path.join(appDir, 'theme.dart'));

    // Check if theme already exists
    if (await themeFile.exists()) {
      final overwrite = logger.confirm(
        'lib/app/theme.dart already exists. Overwrite?',
      );
      if (!overwrite) {
        logger.info('Cancelled.');
        return;
      }
    }

    // Write theme file
    await themeFile.writeAsString(
      ThemeGenTemplates.themeDart(seedColor: seedColor, style: style),
    );

    // Optionally generate a ThemeController for runtime switching
    if (withController) {
      final controllersDir =
          path.join(projectPath, 'lib', 'shared', 'controllers');
      await Directory(controllersDir).create(recursive: true);

      final controllerFile =
          File(path.join(controllersDir, 'theme_controller.dart'));

      await controllerFile
          .writeAsString(ThemeGenTemplates.themeControllerDart());
    }
  }
}
