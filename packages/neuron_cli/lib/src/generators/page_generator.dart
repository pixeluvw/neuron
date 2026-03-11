import 'dart:io';

import 'package:mason_logger/mason_logger.dart';
import 'package:path/path.dart' as path;
import 'package:recase/recase.dart';

import '../templates/di_templates.dart';
import '../templates/page_templates.dart';
import 'di_generator.dart';
import 'route_generator.dart';

/// Generator for full-stack pages (screen + service + wiring)
class PageGenerator {
  PageGenerator({
    required this.pageName,
    this.customRoutePath,
    required this.logger,
  });

  final String pageName;
  final String? customRoutePath;
  final Logger logger;

  Future<void> generate() async {
    final rc = ReCase(pageName);
    final moduleDir =
        path.join(Directory.current.path, 'lib', 'modules', rc.snakeCase);

    // Create module directory
    await Directory(moduleDir).create(recursive: true);

    // Generate controller (wired to service)
    await File(path.join(moduleDir, '${rc.snakeCase}_controller.dart'))
        .writeAsString(PageTemplates.controllerDart(pageName));

    // Generate view (with AsyncSlot pattern)
    await File(path.join(moduleDir, '${rc.snakeCase}_view.dart'))
        .writeAsString(PageTemplates.viewDart(pageName));

    // Generate service (CRUD stubs)
    await File(path.join(moduleDir, '${rc.snakeCase}_service.dart'))
        .writeAsString(PageTemplates.serviceDart(pageName));

    // Register route
    final routeGen = RouteGenerator(logger: logger);
    await routeGen.addRoute(
      screenName: pageName,
      customRoutePath: customRoutePath,
    );

    // Register controller in DI
    final diGen = DiGenerator(logger: logger);
    await diGen.addController(
      name: pageName,
      className: '${rc.pascalCase}Controller',
      importPath: '../modules/${rc.snakeCase}/${rc.snakeCase}_controller.dart',
      isShared: false,
    );

    // Register service in DI
    await diGen.addController(
      name: '${pageName}_service',
      className: '${rc.pascalCase}Service',
      importPath: '../modules/${rc.snakeCase}/${rc.snakeCase}_service.dart',
      isShared: true,
      type: EntryType.service,
    );
  }
}
