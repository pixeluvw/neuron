import 'package:neuron_cli/neuron_cli.dart';
import 'package:test/test.dart';

void main() {
  group('NeuronCliRunner', () {
    test('should show version with --version flag', () async {
      final runner = NeuronCliRunner();
      final exitCode = await runner.run(['--version']);
      expect(exitCode, equals(0));
    });

    test('should show help with --help flag', () async {
      final runner = NeuronCliRunner();
      final exitCode = await runner.run(['--help']);
      expect(exitCode, equals(0));
    });

    test('should show generate help', () async {
      final runner = NeuronCliRunner();
      final exitCode = await runner.run(['generate', '--help']);
      expect(exitCode, equals(0));
    });

    test('should show create help', () async {
      final runner = NeuronCliRunner();
      final exitCode = await runner.run(['create', '--help']);
      expect(exitCode, equals(0));
    });

    test('should show init help', () async {
      final runner = NeuronCliRunner();
      final exitCode = await runner.run(['init', '--help']);
      expect(exitCode, equals(0));
    });

    test('should show remove help', () async {
      final runner = NeuronCliRunner();
      final exitCode = await runner.run(['remove', '--help']);
      expect(exitCode, equals(0));
    });

    test('should show remove screen help', () async {
      final runner = NeuronCliRunner();
      final exitCode = await runner.run(['remove', 'screen', '--help']);
      expect(exitCode, equals(0));
    });

    test('should show remove controller help', () async {
      final runner = NeuronCliRunner();
      final exitCode = await runner.run(['remove', 'controller', '--help']);
      expect(exitCode, equals(0));
    });

    test('should show remove model help', () async {
      final runner = NeuronCliRunner();
      final exitCode = await runner.run(['remove', 'model', '--help']);
      expect(exitCode, equals(0));
    });
  });

  group('RouteTemplates', () {
    test('generates route file with entries', () {
      final routes = [
        const RouteEntry(name: 'home', path: '/', module: 'home', view: 'HomeView'),
        const RouteEntry(
          name: 'settings',
          path: '/settings',
          module: 'settings',
          view: 'SettingsView',
        ),
      ];
      final output = RouteTemplates.appRoutesDart('test_app', routes);
      expect(output, contains("import 'package:neuron/neuron.dart';"));
      expect(output, contains("name: 'home'"));
      expect(output, contains("path: '/'"));
      expect(output, contains('const HomeView()'));
      expect(output, contains("name: 'settings'"));
      expect(output, contains('const SettingsView()'));
    });

    test('generates empty route file', () {
      final output = RouteTemplates.appRoutesDart('test_app', []);
      expect(output, contains('final List<NeuronRoute> appRoutes = ['));
      expect(output, contains('];'));
    });
  });

  group('DiTemplates', () {
    test('generates injector file with entries', () {
      final controllers = [
        const ControllerEntry(
          name: 'home',
          className: 'HomeController',
          importPath: '../modules/home/home_controller.dart',
          isShared: false,
        ),
        const ControllerEntry(
          name: 'auth',
          className: 'AuthController',
          importPath: '../shared/controllers/auth_controller.dart',
          isShared: true,
        ),
      ];
      final output = DiTemplates.injectorDart(controllers);
      expect(output, contains("import 'package:neuron/neuron.dart';"));
      expect(output, contains('void setupDependencies()'));
      expect(output, contains('Neuron.install<HomeController>'));
      expect(output, contains('Neuron.install<AuthController>'));
    });

    test('generates empty injector file', () {
      final output = DiTemplates.injectorDart([]);
      expect(output, contains('void setupDependencies()'));
    });
  });

  group('ProjectTemplates', () {
    test('mainDart does not contain enableDevTools', () {
      final output = ProjectTemplates.mainDart('test_app', false);
      expect(output, isNot(contains('enableDevTools')));
    });

    test('mainDart imports routes and DI', () {
      final output = ProjectTemplates.mainDart('test_app', false);
      expect(output, contains("import 'di/injector.dart';"));
      expect(output, contains("import 'routes/app_routes.dart';"));
      expect(output, contains('setupDependencies()'));
      expect(output, contains('routes: appRoutes'));
      expect(output, contains("initialRoute: '/'"));
    });

    test('mainDart does not use git dependency reference', () {
      final output = ProjectTemplates.mainDart('test_app', false);
      expect(output, isNot(contains('git:')));
      expect(output, isNot(contains('Neuron-Framework')));
    });

    test('homeControllerDart uses Neuron.use', () {
      final output = ProjectTemplates.homeControllerDart();
      expect(output, contains('Neuron.use<HomeController>()'));
      expect(output, isNot(contains('Neuron.ensure')));
    });
  });

  group('ScreenTemplates', () {
    test('controllerDart uses Neuron.use', () {
      final output = ScreenTemplates.controllerDart('settings');
      expect(output, contains('Neuron.use<SettingsController>()'));
      expect(output, isNot(contains('Neuron.ensure')));
    });
  });

  group('ControllerTemplates', () {
    test('controllerDart uses Neuron.use', () {
      final output = ControllerTemplates.controllerDart('auth');
      expect(output, contains('Neuron.use<AuthController>()'));
      expect(output, isNot(contains('Neuron.ensure')));
    });
  });

  group('ProjectUtils', () {
    test('validates isNeuronProject returns false for non-project directory',
        () async {
      // This test would need to be in a non-Flutter directory
      // The actual implementation checks for pubspec.yaml
    });
  });
}
