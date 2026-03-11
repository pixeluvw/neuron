import 'dart:convert';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:path/path.dart' as path;

/// Command to list all registered components in the project
class ListCommand extends Command<int> {
  ListCommand({required Logger logger}) : _logger = logger {
    addSubcommand(ListScreensCommand(logger: _logger));
    addSubcommand(ListControllersCommand(logger: _logger));
    addSubcommand(ListServicesCommand(logger: _logger));
    addSubcommand(ListModelsCommand(logger: _logger));
    addSubcommand(ListRoutesCommand(logger: _logger));
  }

  final Logger _logger;

  @override
  String get name => 'list';

  @override
  List<String> get aliases => ['l'];

  @override
  String get description => 'List registered components in the project';

  @override
  Future<int> run() async {
    // Default: show everything
    _logger.info('');
    await _showScreens();
    await _showControllers();
    await _showServices();
    await _showModels();
    await _showRoutes();
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
        File(path.join(Directory.current.path, 'lib', 'routes', '.routes.json'));
    if (!await routesFile.exists()) {
      _logger.info('🔗 Routes: (none)');
      _logger.info('');
      return;
    }

    try {
      final content = await routesFile.readAsString();
      final routes = (jsonDecode(content) as List).cast<Map<String, dynamic>>();

      _logger.info('🔗 Routes (${routes.length}):');
      for (final r in routes) {
        final name = r['name'] ?? '?';
        final routePath = r['path'] ?? '?';
        final view = r['view'] ?? '?';
        _logger.info('   • $name → $routePath ($view)');
      }
    } catch (e) {
      _logger.warn('Could not parse .routes.json: $e');
    }
    _logger.info('');
  }
}

// ─── Individual subcommands ─────────────────────────────────────────────────

class ListScreensCommand extends Command<int> {
  ListScreensCommand({required Logger logger});

  @override
  String get name => 'screens';
  @override
  String get description => 'List all screen modules';

  @override
  Future<int> run() async {
    final parent = this.parent as ListCommand;
    await parent._showScreens();
    return ExitCode.success.code;
  }
}

class ListControllersCommand extends Command<int> {
  ListControllersCommand({required Logger logger});

  @override
  String get name => 'controllers';
  @override
  String get description => 'List all standalone controllers';

  @override
  Future<int> run() async {
    final parent = this.parent as ListCommand;
    await parent._showControllers();
    return ExitCode.success.code;
  }
}

class ListServicesCommand extends Command<int> {
  ListServicesCommand({required Logger logger});

  @override
  String get name => 'services';
  @override
  String get description => 'List all services';

  @override
  Future<int> run() async {
    final parent = this.parent as ListCommand;
    await parent._showServices();
    return ExitCode.success.code;
  }
}

class ListModelsCommand extends Command<int> {
  ListModelsCommand({required Logger logger});

  @override
  String get name => 'models';
  @override
  String get description => 'List all models';

  @override
  Future<int> run() async {
    final parent = this.parent as ListCommand;
    await parent._showModels();
    return ExitCode.success.code;
  }
}

class ListRoutesCommand extends Command<int> {
  ListRoutesCommand({required Logger logger});

  @override
  String get name => 'routes';
  @override
  String get description => 'List all registered routes';

  @override
  Future<int> run() async {
    final parent = this.parent as ListCommand;
    await parent._showRoutes();
    return ExitCode.success.code;
  }
}
