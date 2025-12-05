import 'dart:io';

import 'package:mason_logger/mason_logger.dart';
import 'package:path/path.dart' as path;
import 'package:recase/recase.dart';

import '../templates/templates.dart';

/// Generator for creating a model class
class ModelGenerator {
  ModelGenerator({
    required this.modelName,
    required this.fields,
    required this.logger,
  });

  final String modelName;
  final List<String> fields;
  final Logger logger;

  Future<void> generate() async {
    final rc = ReCase(modelName);
    // Shared models go in lib/shared/models/
    final modelsDir =
        path.join(Directory.current.path, 'lib', 'shared', 'models');

    // Create models directory if it doesn't exist
    await Directory(modelsDir).create(recursive: true);

    // Parse fields
    final parsedFields = _parseFields();

    // Generate model
    await File(path.join(modelsDir, '${rc.snakeCase}.dart'))
        .writeAsString(ModelTemplates.modelDart(modelName, parsedFields));
  }

  List<ModelField> _parseFields() {
    final result = <ModelField>[];

    for (final field in fields) {
      final parts = field.split(':');
      if (parts.length >= 2) {
        final name = parts[0].trim();
        final type = parts[1].trim();
        final isNullable = type.endsWith('?');
        result.add(ModelField(
          name: name,
          type: isNullable ? type.substring(0, type.length - 1) : type,
          isNullable: isNullable,
        ));
      } else if (parts.length == 1) {
        // Default to String type
        result.add(ModelField(
          name: parts[0].trim(),
          type: 'String',
          isNullable: false,
        ));
      }
    }

    return result;
  }
}

/// Represents a model field
class ModelField {
  const ModelField({
    required this.name,
    required this.type,
    required this.isNullable,
  });

  final String name;
  final String type;
  final bool isNullable;

  String get dartType => isNullable ? '$type?' : type;
}
