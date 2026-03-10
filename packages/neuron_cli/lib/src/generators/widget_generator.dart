import 'dart:io';

import 'package:mason_logger/mason_logger.dart';
import 'package:path/path.dart' as path;
import 'package:recase/recase.dart';

import '../templates/widget_templates.dart';

/// Generator for reusable widgets
class WidgetGenerator {
  WidgetGenerator({
    required this.widgetName,
    required this.logger,
    this.isSignal = false,
  });

  final String widgetName;
  final Logger logger;
  final bool isSignal;

  Future<void> generate() async {
    final rc = ReCase(widgetName);
    final widgetsDir =
        path.join(Directory.current.path, 'lib', 'shared', 'widgets');

    await Directory(widgetsDir).create(recursive: true);

    final filePath = path.join(widgetsDir, '${rc.snakeCase}.dart');

    if (await File(filePath).exists()) {
      throw Exception(
        'Widget "${rc.snakeCase}.dart" already exists at $filePath',
      );
    }

    final content = isSignal
        ? WidgetTemplates.signalWidgetDart(widgetName)
        : WidgetTemplates.widgetDart(widgetName);

    await File(filePath).writeAsString(content);
  }
}
