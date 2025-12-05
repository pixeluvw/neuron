import 'dart:io';

import 'package:mason_logger/mason_logger.dart';
import 'package:path/path.dart' as path;
import 'package:recase/recase.dart';

import '../templates/templates.dart';

/// Generator for creating a standalone (shared) controller
class ControllerGenerator {
  ControllerGenerator({
    required this.controllerName,
    required this.logger,
  });

  final String controllerName;
  final Logger logger;

  Future<void> generate() async {
    final rc = ReCase(controllerName);
    // Shared controllers go in lib/shared/controllers/
    final controllersDir =
        path.join(Directory.current.path, 'lib', 'shared', 'controllers');

    // Create controllers directory if it doesn't exist
    await Directory(controllersDir).create(recursive: true);

    // Generate controller
    await File(path.join(controllersDir, '${rc.snakeCase}_controller.dart'))
        .writeAsString(ControllerTemplates.controllerDart(controllerName));
  }
}
