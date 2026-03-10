import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:recase/recase.dart';

import '../generators/generators.dart';
import '../templates/templates.dart';
import '../utils/utils.dart';

/// Command to generate Neuron components (screens, controllers, models)
class GenerateCommand extends Command<int> {
  GenerateCommand({required Logger logger}) : _logger = logger {
    addSubcommand(GenerateScreenCommand(logger: _logger));
    addSubcommand(GenerateControllerCommand(logger: _logger));
    addSubcommand(GenerateModelCommand(logger: _logger));
    addSubcommand(GenerateServiceCommand(logger: _logger));
    addSubcommand(GenerateWidgetCommand(logger: _logger));
    addSubcommand(GenerateMiddlewareCommand(logger: _logger));
    addSubcommand(GeneratePageCommand(logger: _logger));
  }

  final Logger _logger;

  @override
  String get name => 'generate';

  @override
  List<String> get aliases => ['g'];

  @override
  String get description =>
      'Generate Neuron components (screen, controller, model, service, widget, middleware, page)';
}

/// Generate a complete screen with controller, view, and route registration
class GenerateScreenCommand extends Command<int> {
  GenerateScreenCommand({required Logger logger}) : _logger = logger {
    argParser
      ..addFlag(
        'no-route',
        help: 'Skip route registration',
        negatable: false,
      )
      ..addOption(
        'path',
        abbr: 'p',
        help: 'Custom route path (default: /<screen_name>)',
      );
  }

  final Logger _logger;

  @override
  String get name => 'screen';

  @override
  List<String> get aliases => ['s'];

  @override
  String get description =>
      'Generate a screen with controller, view, and route';

  @override
  String get invocation => 'neuron generate screen <name>';

  @override
  Future<int> run() async {
    if (argResults?.rest.isEmpty ?? true) {
      _logger.err('Please provide a screen name.');
      _logger.info('Usage: neuron generate screen <name>');
      return ExitCode.usage.code;
    }

    final screenName = argResults!.rest.first;
    final noRoute = argResults!['no-route'] as bool;
    final customPath = argResults!['path'] as String?;

    if (!await ProjectUtils.isNeuronProject()) {
      _logger.err('Not in a Neuron/Flutter project directory.');
      _logger.info(
          'Make sure you are in the root of a Flutter project with Neuron dependency.');
      return ExitCode.usage.code;
    }

    final progress = _logger.progress('Generating module "$screenName"');

    try {
      final generator = ScreenGenerator(
        screenName: screenName,
        registerRoute: !noRoute,
        customRoutePath: customPath,
        logger: _logger,
      );

      await generator.generate();

      progress.complete('Module generated successfully!');

      final rc = ReCase(screenName);

      _logger.info('');
      _logger.success('✓ Generated module: ${rc.pascalCase}');
      _logger.info('');
      _logger.info('Created files:');
      _logger.info(
          '  lib/modules/${rc.snakeCase}/${rc.snakeCase}_controller.dart');
      _logger.info('  lib/modules/${rc.snakeCase}/${rc.snakeCase}_view.dart');
      _logger.info('');
      _logger.info('Updated:');
      _logger.info('  lib/routes/app_routes.dart');
      _logger.info('  lib/di/injector.dart');
      _logger.info('');
      _logger.info('Usage in view:');
      _logger.info('  final c = ${rc.pascalCase}Controller.init;');
      _logger.info('');
      _logger.info('Navigate using:');
      _logger.info("  Neuron.toNamed('${rc.camelCase}');");
      _logger.info('  Neuron.to(const ${rc.pascalCase}View());');
      _logger.info('  Neuron.back();  // pop');

      _logger.info('');

      return ExitCode.success.code;
    } catch (e) {
      progress.fail('Failed to generate module');
      _logger.err('$e');
      return ExitCode.software.code;
    }
  }
}

/// Generate a standalone controller
class GenerateControllerCommand extends Command<int> {
  GenerateControllerCommand({required Logger logger}) : _logger = logger;

  final Logger _logger;

  @override
  String get name => 'controller';

  @override
  List<String> get aliases => ['c'];

  @override
  String get description => 'Generate a NeuronController';

  @override
  String get invocation => 'neuron generate controller <name>';

  @override
  Future<int> run() async {
    if (argResults?.rest.isEmpty ?? true) {
      _logger.err('Please provide a controller name.');
      _logger.info('Usage: neuron generate controller <name>');
      return ExitCode.usage.code;
    }

    final controllerName = argResults!.rest.first;

    if (!await ProjectUtils.isNeuronProject()) {
      _logger.err('Not in a Neuron/Flutter project directory.');
      return ExitCode.usage.code;
    }

    final progress =
        _logger.progress('Generating controller "$controllerName"');

    try {
      final generator = ControllerGenerator(
        controllerName: controllerName,
        logger: _logger,
      );

      await generator.generate();

      progress.complete('Controller generated successfully!');

      final rc = ReCase(controllerName);

      _logger.info('');
      _logger.success('✓ Generated controller: ${rc.pascalCase}Controller');
      _logger.info('');
      _logger.info('Created file:');
      _logger.info('  lib/shared/controllers/${rc.snakeCase}_controller.dart');
      _logger.info('');
      _logger.info('Usage:');
      _logger.info('  final c = ${rc.pascalCase}Controller.init;');
      _logger.info('');

      return ExitCode.success.code;
    } catch (e) {
      progress.fail('Failed to generate controller');
      _logger.err('$e');
      return ExitCode.software.code;
    }
  }
}

/// Generate a model class
class GenerateModelCommand extends Command<int> {
  GenerateModelCommand({required Logger logger}) : _logger = logger {
    argParser.addMultiOption(
      'fields',
      abbr: 'f',
      help:
          'Model fields in format: name:type (e.g., -f id:int -f name:String)',
    );
  }

  final Logger _logger;

  @override
  String get name => 'model';

  @override
  List<String> get aliases => ['m'];

  @override
  String get description => 'Generate a model class';

  @override
  String get invocation => 'neuron generate model <name> [-f field:type]';

  @override
  Future<int> run() async {
    if (argResults?.rest.isEmpty ?? true) {
      _logger.err('Please provide a model name.');
      _logger.info('Usage: neuron generate model <name> [-f field:type]');
      return ExitCode.usage.code;
    }

    final modelName = argResults!.rest.first;
    final fields = argResults!['fields'] as List<String>;

    if (!await ProjectUtils.isNeuronProject()) {
      _logger.err('Not in a Neuron/Flutter project directory.');
      return ExitCode.usage.code;
    }

    final progress = _logger.progress('Generating model "$modelName"');

    try {
      final generator = ModelGenerator(
        modelName: modelName,
        fields: fields,
        logger: _logger,
      );

      await generator.generate();

      progress.complete('Model generated successfully!');

      final rc = ReCase(modelName);

      _logger.info('');
      _logger.success('✓ Generated model: ${rc.pascalCase}');
      _logger.info('');
      _logger.info('Created file:');
      _logger.info('  lib/shared/models/${rc.snakeCase}.dart');
      _logger.info('');

      return ExitCode.success.code;
    } catch (e) {
      progress.fail('Failed to generate model');
      _logger.err('$e');
      return ExitCode.software.code;
    }
  }
}

// ─── NEW SUBCOMMANDS ────────────────────────────────────────────────────────

/// Generate a service class
class GenerateServiceCommand extends Command<int> {
  GenerateServiceCommand({required Logger logger}) : _logger = logger {
    argParser
      ..addFlag(
        'crud',
        help:
            'Include CRUD method stubs (getAll, getById, create, update, delete)',
        negatable: false,
      )
      ..addFlag(
        'http',
        help: 'Include HTTP client boilerplate with error handling',
        negatable: false,
      );
  }

  final Logger _logger;

  @override
  String get name => 'service';

  @override
  List<String> get aliases => ['svc'];

  @override
  String get description => 'Generate a service class';

  @override
  String get invocation => 'neuron generate service <name> [--crud] [--http]';

  @override
  Future<int> run() async {
    if (argResults?.rest.isEmpty ?? true) {
      _logger.err('Please provide a service name.');
      _logger.info('Usage: neuron generate service <name>');
      return ExitCode.usage.code;
    }

    final serviceName = argResults!.rest.first;
    final isCrud = argResults!['crud'] as bool;
    final isHttp = argResults!['http'] as bool;

    if (!await ProjectUtils.isNeuronProject()) {
      _logger.err('Not in a Neuron/Flutter project directory.');
      return ExitCode.usage.code;
    }

    final progress = _logger.progress('Generating service "$serviceName"');

    try {
      final generator = ServiceGenerator(
        serviceName: serviceName,
        logger: _logger,
        isCrud: isCrud,
        isHttp: isHttp,
      );

      await generator.generate();

      progress.complete('Service generated successfully!');

      final rc = ReCase(serviceName);

      _logger.info('');
      _logger.success('✓ Generated service: ${rc.pascalCase}Service');
      _logger.info('');
      _logger.info('Created file:');
      _logger.info('  lib/shared/services/${rc.snakeCase}_service.dart');
      _logger.info('');
      _logger.info('Updated:');
      _logger.info('  lib/di/injector.dart');
      _logger.info('');
      _logger.info('Usage:');
      _logger.info('  final svc = ${rc.pascalCase}Service.init;');
      _logger.info('');

      return ExitCode.success.code;
    } catch (e) {
      progress.fail('Failed to generate service');
      _logger.err('$e');
      return ExitCode.software.code;
    }
  }
}

/// Generate a reusable widget
class GenerateWidgetCommand extends Command<int> {
  GenerateWidgetCommand({required Logger logger}) : _logger = logger {
    argParser.addFlag(
      'signal',
      help:
          'Create a Signal-aware widget that accepts a Signal<T> and uses Slot',
      negatable: false,
    );
  }

  final Logger _logger;

  @override
  String get name => 'widget';

  @override
  List<String> get aliases => ['w'];

  @override
  String get description => 'Generate a reusable widget';

  @override
  String get invocation => 'neuron generate widget <name> [--signal]';

  @override
  Future<int> run() async {
    if (argResults?.rest.isEmpty ?? true) {
      _logger.err('Please provide a widget name.');
      _logger.info('Usage: neuron generate widget <name>');
      return ExitCode.usage.code;
    }

    final widgetName = argResults!.rest.first;
    final isSignal = argResults!['signal'] as bool;

    if (!await ProjectUtils.isNeuronProject()) {
      _logger.err('Not in a Neuron/Flutter project directory.');
      return ExitCode.usage.code;
    }

    final progress = _logger.progress('Generating widget "$widgetName"');

    try {
      final generator = WidgetGenerator(
        widgetName: widgetName,
        logger: _logger,
        isSignal: isSignal,
      );

      await generator.generate();

      progress.complete('Widget generated successfully!');

      final rc = ReCase(widgetName);

      _logger.info('');
      _logger.success('✓ Generated widget: ${rc.pascalCase}');
      _logger.info('');
      _logger.info('Created file:');
      _logger.info('  lib/shared/widgets/${rc.snakeCase}.dart');
      _logger.info('');

      return ExitCode.success.code;
    } catch (e) {
      progress.fail('Failed to generate widget');
      _logger.err('$e');
      return ExitCode.software.code;
    }
  }
}

/// Generate a signal middleware
class GenerateMiddlewareCommand extends Command<int> {
  GenerateMiddlewareCommand({required Logger logger}) : _logger = logger;

  final Logger _logger;

  @override
  String get name => 'middleware';

  @override
  List<String> get aliases => ['mw'];

  @override
  String get description => 'Generate a Signal middleware';

  @override
  String get invocation => 'neuron generate middleware <name>';

  @override
  Future<int> run() async {
    if (argResults?.rest.isEmpty ?? true) {
      _logger.err('Please provide a middleware name.');
      _logger.info('Usage: neuron generate middleware <name>');
      return ExitCode.usage.code;
    }

    final middlewareName = argResults!.rest.first;

    if (!await ProjectUtils.isNeuronProject()) {
      _logger.err('Not in a Neuron/Flutter project directory.');
      return ExitCode.usage.code;
    }

    final progress =
        _logger.progress('Generating middleware "$middlewareName"');

    try {
      final rc = ReCase(middlewareName);
      final middlewareDir =
          '${Directory.current.path}/lib/shared/middleware';
      await Directory(middlewareDir).create(recursive: true);

      final filePath = '$middlewareDir/${rc.snakeCase}_middleware.dart';
      if (await File(filePath).exists()) {
        throw Exception(
            'Middleware "${rc.snakeCase}_middleware.dart" already exists');
      }

      await File(filePath)
          .writeAsString(MiddlewareTemplates.middlewareDart(middlewareName));

      progress.complete('Middleware generated successfully!');

      _logger.info('');
      _logger.success('✓ Generated middleware: ${rc.pascalCase}Middleware');
      _logger.info('');
      _logger.info('Created file:');
      _logger.info(
          '  lib/shared/middleware/${rc.snakeCase}_middleware.dart');
      _logger.info('');
      _logger.info('Usage:');
      _logger.info(
          '  mySignal.addMiddleware(${rc.pascalCase}Middleware());');
      _logger.info('');

      return ExitCode.success.code;
    } catch (e) {
      progress.fail('Failed to generate middleware');
      _logger.err('$e');
      return ExitCode.software.code;
    }
  }
}

/// Generate a full-stack page (screen + service, pre-wired)
class GeneratePageCommand extends Command<int> {
  GeneratePageCommand({required Logger logger}) : _logger = logger {
    argParser.addOption(
      'path',
      abbr: 'p',
      help: 'Custom route path (default: /<page_name>)',
    );
  }

  final Logger _logger;

  @override
  String get name => 'page';

  @override
  List<String> get aliases => ['p'];

  @override
  String get description =>
      'Generate a full-stack page (controller + view + service, pre-wired)';

  @override
  String get invocation => 'neuron generate page <name>';

  @override
  Future<int> run() async {
    if (argResults?.rest.isEmpty ?? true) {
      _logger.err('Please provide a page name.');
      _logger.info('Usage: neuron generate page <name>');
      return ExitCode.usage.code;
    }

    final pageName = argResults!.rest.first;
    final customPath = argResults!['path'] as String?;

    if (!await ProjectUtils.isNeuronProject()) {
      _logger.err('Not in a Neuron/Flutter project directory.');
      return ExitCode.usage.code;
    }

    final progress =
        _logger.progress('Generating full-stack page "$pageName"');

    try {
      final generator = PageGenerator(
        pageName: pageName,
        customRoutePath: customPath,
        logger: _logger,
      );

      await generator.generate();

      progress.complete('Full-stack page generated successfully!');

      final rc = ReCase(pageName);

      _logger.info('');
      _logger.success('✓ Generated full-stack page: ${rc.pascalCase}');
      _logger.info('');
      _logger.info('Created files:');
      _logger.info(
          '  lib/modules/${rc.snakeCase}/${rc.snakeCase}_controller.dart');
      _logger.info(
          '  lib/modules/${rc.snakeCase}/${rc.snakeCase}_view.dart');
      _logger.info(
          '  lib/modules/${rc.snakeCase}/${rc.snakeCase}_service.dart');
      _logger.info('');
      _logger.info('Updated:');
      _logger.info('  lib/routes/app_routes.dart');
      _logger.info('  lib/di/injector.dart');
      _logger.info('');
      _logger.info('The controller is pre-wired with the service.');
      _logger.info(
          'The view uses AsyncSlot for loading/error/data handling.');
      _logger.info('');

      return ExitCode.success.code;
    } catch (e) {
      progress.fail('Failed to generate page');
      _logger.err('$e');
      return ExitCode.software.code;
    }
  }
}
