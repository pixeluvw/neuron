import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:path/path.dart' as path;

import '../templates/templates.dart';

/// Command to list all registered components in the project
class ListCommand extends Command<int> {
  ListCommand({required Logger logger}) : _logger = logger;

  final Logger _logger;

  static const _validTypes = [
    'screens',
    'controllers',
    'services',
    'models',
    'routes',
  ];

  @override
  String get name => 'list';

  @override
  List<String> get aliases => ['l'];

  @override
  String get description => 'List registered components in the project';

  @override
  String get invocation => 'neuron list [type]';

  @override
  Future<int> run() async {
    final rest = argResults?.rest ?? [];
    final type = rest.isEmpty ? null : rest.first;

    if (type != null && !_validTypes.contains(type)) {
      _logger.err('Unknown type "$type".');
      _logger.info('Valid types: ${_validTypes.join(', ')}');
      return ExitCode.usage.code;
    }

    _logger.info('');

    if (type == null || type == 'screens') await _showScreens();
    if (type == null || type == 'controllers') await _showControllers();
    if (type == null || type == 'services') await _showServices();
    if (type == null || type == 'models') await _showModels();
    if (type == null || type == 'routes') await _showRoutes();

    return ExitCode.success.code;
  }

  Future<void> _showScreens() async {
    final modulesDir =
        path.join(Directory.current.path, 'lib', 'modules');
    final dir = Directory(modulesDir);
    if (!await dir.exists()) {
      _logger.info('📱 Screens: (none)');
      _logger.info('');
      return;
    }

    final modules = dir
        .listSync()
        .whereType<Directory>()
        .map((d) => path.basename(d.path))
        .toList()
      ..sort();

    _logger.info('📱 Screens (${modules.length}):');
    for (final m in modules) {
      _logger.info('   • $m');
    }
    _logger.info('');
  }

  Future<void> _showControllers() async {
    final contDir =
        path.join(Directory.current.path, 'lib', 'shared', 'controllers');
    final dir = Directory(contDir);
    if (!await dir.exists()) {
      _logger.info('🎮 Controllers: (none)');
      _logger.info('');
      return;
    }

    final files = dir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('_controller.dart'))
        .map((f) => path.basenameWithoutExtension(f.path))
        .toList()
      ..sort();

    _logger.info('🎮 Controllers (${files.length}):');
    for (final f in files) {
      _logger.info('   • $f');
    }
    _logger.info('');
  }

  Future<void> _showServices() async {
    // Check shared/services and also module-local services
    final svcDir =
        path.join(Directory.current.path, 'lib', 'shared', 'services');
    final dir = Directory(svcDir);
    final services = <String>[];

    if (await dir.exists()) {
      services.addAll(dir
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('_service.dart'))
          .map((f) => 'shared/${path.basenameWithoutExtension(f.path)}'));
    }

    // Scan modules for local services
    final modulesDir =
        path.join(Directory.current.path, 'lib', 'modules');
    final modDir = Directory(modulesDir);
    if (await modDir.exists()) {
      for (final module in modDir.listSync().whereType<Directory>()) {
        final moduleName = path.basename(module.path);
        for (final file in module.listSync().whereType<File>()) {
          if (file.path.endsWith('_service.dart')) {
            services
                .add('modules/$moduleName/${path.basenameWithoutExtension(file.path)}');
          }
        }
      }
    }

    services.sort();
    _logger.info('⚙️  Services (${services.length}):');
    for (final s in services) {
      _logger.info('   • $s');
    }
    _logger.info('');
  }

  Future<void> _showModels() async {
    final modelsDir =
        path.join(Directory.current.path, 'lib', 'shared', 'models');
    final dir = Directory(modelsDir);
    if (!await dir.exists()) {
      _logger.info('📦 Models: (none)');
      _logger.info('');
      return;
    }

    final files = dir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))
        .map((f) => path.basenameWithoutExtension(f.path))
        .toList()
      ..sort();

    _logger.info('📦 Models (${files.length}):');
    for (final f in files) {
      _logger.info('   • $f');
    }
    _logger.info('');
  }

  Future<void> _showRoutes() async {
    final routesFile =
        File(path.join(Directory.current.path, 'lib', 'routes', 'app_routes.dart'));
    if (!await routesFile.exists()) {
      _logger.info('🔗 Routes: (none)');
      _logger.info('');
      return;
    }

    try {
      final content = await routesFile.readAsString();
      final routes = RouteTemplates.parseAppRoutesDart(content);

      _logger.info('🔗 Routes (${routes.length}):');
      for (final r in routes) {
        _logger.info('   • ${r.name} → ${r.path} (${r.view})');
      }
    } catch (e) {
      _logger.warn('Could not parse app_routes.dart: $e');
    }
    _logger.info('');
  }
}
