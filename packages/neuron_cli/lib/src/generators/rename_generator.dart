import 'dart:io';

import 'package:mason_logger/mason_logger.dart';
import 'package:path/path.dart' as path;
import 'package:recase/recase.dart';

import 'di_generator.dart';
import 'route_generator.dart';

/// Generator for renaming components and updating all references
class RenameGenerator {
  RenameGenerator({required this.logger});

  final Logger logger;

  /// Rename a screen module
  Future<void> renameScreen(String oldName, String newName) async {
    final oldRc = ReCase(oldName);
    final newRc = ReCase(newName);

    final modulesDir = path.join(Directory.current.path, 'lib', 'modules');
    final oldDir = path.join(modulesDir, oldRc.snakeCase);
    final newDir = path.join(modulesDir, newRc.snakeCase);

    if (!await Directory(oldDir).exists()) {
      throw Exception('Module "${oldRc.snakeCase}" not found at $oldDir');
    }

    if (await Directory(newDir).exists()) {
      throw Exception('Module "${newRc.snakeCase}" already exists');
    }

    // 1. Rename files within the old directory first
    final files = Directory(oldDir).listSync();
    for (final entity in files) {
      if (entity is File) {
        var content = await entity.readAsString();
        // Replace class names
        content = content.replaceAll(oldRc.pascalCase, newRc.pascalCase);
        // Replace snake_case references
        content = content.replaceAll(oldRc.snakeCase, newRc.snakeCase);
        // Replace camelCase references
        content = content.replaceAll(oldRc.camelCase, newRc.camelCase);
        await entity.writeAsString(content);

        // Rename file
        final oldFileName = path.basename(entity.path);
        final newFileName =
            oldFileName.replaceAll(oldRc.snakeCase, newRc.snakeCase);
        if (oldFileName != newFileName) {
          await entity.rename(path.join(oldDir, newFileName));
        }
      }
    }

    // 2. Rename the directory
    await Directory(oldDir).rename(newDir);

    // 3. Update route
    final routeGen = RouteGenerator(logger: logger);
    await routeGen.removeRoute(oldName);
    await routeGen.addRoute(screenName: newName);

    // 4. Update DI
    final diGen = DiGenerator(logger: logger);
    await diGen.removeController('${oldRc.pascalCase}Controller');
    await diGen.addController(
      name: newName,
      className: '${newRc.pascalCase}Controller',
      importPath:
          '../modules/${newRc.snakeCase}/${newRc.snakeCase}_controller.dart',
      isShared: false,
    );

    // 5. Update imports in other files
    await _updateImportsInProject(oldRc, newRc);
  }

  /// Rename a standalone controller
  Future<void> renameController(String oldName, String newName) async {
    final oldRc = ReCase(oldName);
    final newRc = ReCase(newName);

    final contDir = path.join(
        Directory.current.path, 'lib', 'shared', 'controllers');
    final oldFile = path.join(contDir, '${oldRc.snakeCase}_controller.dart');
    final newFile = path.join(contDir, '${newRc.snakeCase}_controller.dart');

    if (!await File(oldFile).exists()) {
      throw Exception(
          'Controller "${oldRc.snakeCase}_controller.dart" not found');
    }

    if (await File(newFile).exists()) {
      throw Exception(
          'Controller "${newRc.snakeCase}_controller.dart" already exists');
    }

    // Update content
    var content = await File(oldFile).readAsString();
    content = content.replaceAll(oldRc.pascalCase, newRc.pascalCase);
    content = content.replaceAll(oldRc.snakeCase, newRc.snakeCase);
    content = content.replaceAll(oldRc.camelCase, newRc.camelCase);
    await File(oldFile).writeAsString(content);

    // Rename file
    await File(oldFile).rename(newFile);

    // Update DI
    final diGen = DiGenerator(logger: logger);
    await diGen.removeController('${oldRc.pascalCase}Controller');
    await diGen.addController(
      name: newName,
      className: '${newRc.pascalCase}Controller',
      importPath: '../shared/controllers/${newRc.snakeCase}_controller.dart',
      isShared: true,
    );

    // Update imports
    await _updateImportsInProject(oldRc, newRc);
  }

  /// Rename a model
  Future<void> renameModel(String oldName, String newName) async {
    final oldRc = ReCase(oldName);
    final newRc = ReCase(newName);

    final modelsDir =
        path.join(Directory.current.path, 'lib', 'shared', 'models');
    final oldFile = path.join(modelsDir, '${oldRc.snakeCase}.dart');
    final newFile = path.join(modelsDir, '${newRc.snakeCase}.dart');

    if (!await File(oldFile).exists()) {
      throw Exception('Model "${oldRc.snakeCase}.dart" not found');
    }

    if (await File(newFile).exists()) {
      throw Exception('Model "${newRc.snakeCase}.dart" already exists');
    }

    var content = await File(oldFile).readAsString();
    content = content.replaceAll(oldRc.pascalCase, newRc.pascalCase);
    content = content.replaceAll(oldRc.snakeCase, newRc.snakeCase);
    await File(oldFile).writeAsString(content);
    await File(oldFile).rename(newFile);

    await _updateImportsInProject(oldRc, newRc);
  }

  /// Rename a service
  Future<void> renameService(String oldName, String newName) async {
    final oldRc = ReCase(oldName);
    final newRc = ReCase(newName);

    final svcDir =
        path.join(Directory.current.path, 'lib', 'shared', 'services');
    final oldFile = path.join(svcDir, '${oldRc.snakeCase}_service.dart');
    final newFile = path.join(svcDir, '${newRc.snakeCase}_service.dart');

    if (!await File(oldFile).exists()) {
      throw Exception(
          'Service "${oldRc.snakeCase}_service.dart" not found');
    }

    if (await File(newFile).exists()) {
      throw Exception(
          'Service "${newRc.snakeCase}_service.dart" already exists');
    }

    var content = await File(oldFile).readAsString();
    content = content.replaceAll(oldRc.pascalCase, newRc.pascalCase);
    content = content.replaceAll(oldRc.snakeCase, newRc.snakeCase);
    content = content.replaceAll(oldRc.camelCase, newRc.camelCase);
    await File(oldFile).writeAsString(content);
    await File(oldFile).rename(newFile);

    // Update DI
    final diGen = DiGenerator(logger: logger);
    await diGen.removeController('${oldRc.pascalCase}Service');
    await diGen.addController(
      name: newName,
      className: '${newRc.pascalCase}Service',
      importPath: '../shared/services/${newRc.snakeCase}_service.dart',
      isShared: true,
    );

    await _updateImportsInProject(oldRc, newRc);
  }

  /// Scan the lib/ directory and update any import references
  Future<void> _updateImportsInProject(ReCase oldRc, ReCase newRc) async {
    final libDir = Directory(path.join(Directory.current.path, 'lib'));

    if (!await libDir.exists()) return;

    await for (final entity in libDir.list(recursive: true)) {
      if (entity is File && entity.path.endsWith('.dart')) {
        var content = await entity.readAsString();
        final originalContent = content;

        // Update import paths
        content = content.replaceAll(
          '${oldRc.snakeCase}_controller.dart',
          '${newRc.snakeCase}_controller.dart',
        );
        content = content.replaceAll(
          '${oldRc.snakeCase}_view.dart',
          '${newRc.snakeCase}_view.dart',
        );
        content = content.replaceAll(
          '${oldRc.snakeCase}_service.dart',
          '${newRc.snakeCase}_service.dart',
        );
        content = content.replaceAll(
          '/${oldRc.snakeCase}/',
          '/${newRc.snakeCase}/',
        );

        // Update class references
        content = content.replaceAll(
          '${oldRc.pascalCase}Controller',
          '${newRc.pascalCase}Controller',
        );
        content = content.replaceAll(
          '${oldRc.pascalCase}View',
          '${newRc.pascalCase}View',
        );
        content = content.replaceAll(
          '${oldRc.pascalCase}Service',
          '${newRc.pascalCase}Service',
        );

        // Update route names
        content = content.replaceAll(
          "'${oldRc.camelCase}'",
          "'${newRc.camelCase}'",
        );

        if (content != originalContent) {
          await entity.writeAsString(content);
        }
      }
    }
  }
}
