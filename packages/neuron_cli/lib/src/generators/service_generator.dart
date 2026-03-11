import 'dart:io';

import 'package:mason_logger/mason_logger.dart';
import 'package:path/path.dart' as path;
import 'package:recase/recase.dart';

import '../templates/di_templates.dart';
import '../templates/service_templates.dart';
import 'di_generator.dart';

/// Generator for service classes
class ServiceGenerator {
  ServiceGenerator({
    required this.serviceName,
    required this.logger,
    this.isCrud = false,
    this.isHttp = false,
  });

  final String serviceName;
  final Logger logger;
  final bool isCrud;
  final bool isHttp;

  Future<void> generate() async {
    final rc = ReCase(serviceName);
    final servicesDir =
        path.join(Directory.current.path, 'lib', 'shared', 'services');

    // Ensure directory exists
    await Directory(servicesDir).create(recursive: true);

    final filePath = path.join(servicesDir, '${rc.snakeCase}_service.dart');

    // Check if already exists
    if (await File(filePath).exists()) {
      throw Exception(
        'Service "${rc.snakeCase}_service.dart" already exists at $filePath',
      );
    }

    // Generate the appropriate template
    String content;
    if (isHttp) {
      content = ServiceTemplates.httpServiceDart(serviceName);
    } else if (isCrud) {
      content = ServiceTemplates.crudServiceDart(serviceName);
    } else {
      content = ServiceTemplates.serviceDart(serviceName);
    }

    await File(filePath).writeAsString(content);

    // Register in DI
    final diGen = DiGenerator(logger: logger);
    await diGen.addController(
      name: serviceName,
      className: '${rc.pascalCase}Service',
      importPath: '../shared/services/${rc.snakeCase}_service.dart',
      isShared: true,
      type: EntryType.service,
    );
  }
}
