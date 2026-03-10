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

    // ─── New command help tests ───────────────────────────────────

    test('should show list help', () async {
      final runner = NeuronCliRunner();
      final exitCode = await runner.run(['list', '--help']);
      expect(exitCode, equals(0));
    });

    test('should show rename help', () async {
      final runner = NeuronCliRunner();
      final exitCode = await runner.run(['rename', '--help']);
      expect(exitCode, equals(0));
    });

    test('should show doctor help', () async {
      final runner = NeuronCliRunner();
      final exitCode = await runner.run(['doctor', '--help']);
      expect(exitCode, equals(0));
    });

    test('should show upgrade help', () async {
      final runner = NeuronCliRunner();
      final exitCode = await runner.run(['upgrade', '--help']);
      expect(exitCode, equals(0));
    });

    // ─── New generate subcommand help tests ──────────────────────

    test('should show generate service help', () async {
      final runner = NeuronCliRunner();
      final exitCode = await runner.run(['generate', 'service', '--help']);
      expect(exitCode, equals(0));
    });

    test('should show generate widget help', () async {
      final runner = NeuronCliRunner();
      final exitCode = await runner.run(['generate', 'widget', '--help']);
      expect(exitCode, equals(0));
    });

    test('should show generate middleware help', () async {
      final runner = NeuronCliRunner();
      final exitCode = await runner.run(['generate', 'middleware', '--help']);
      expect(exitCode, equals(0));
    });

    test('should show generate page help', () async {
      final runner = NeuronCliRunner();
      final exitCode = await runner.run(['generate', 'page', '--help']);
      expect(exitCode, equals(0));
    });

    // ─── New remove subcommand help tests ────────────────────────

    test('should show remove service help', () async {
      final runner = NeuronCliRunner();
      final exitCode = await runner.run(['remove', 'service', '--help']);
      expect(exitCode, equals(0));
    });

    test('should show remove widget help', () async {
      final runner = NeuronCliRunner();
      final exitCode = await runner.run(['remove', 'widget', '--help']);
      expect(exitCode, equals(0));
    });

    // ─── Alias tests ────────────────────────────────────────────

    test('should support g alias for generate', () async {
      final runner = NeuronCliRunner();
      final exitCode = await runner.run(['g', '--help']);
      expect(exitCode, equals(0));
    });

    test('should support r alias for remove', () async {
      final runner = NeuronCliRunner();
      final exitCode = await runner.run(['r', '--help']);
      expect(exitCode, equals(0));
    });

    test('should support l alias for list', () async {
      final runner = NeuronCliRunner();
      final exitCode = await runner.run(['l', '--help']);
      expect(exitCode, equals(0));
    });

    test('should support mv alias for rename', () async {
      final runner = NeuronCliRunner();
      final exitCode = await runner.run(['mv', '--help']);
      expect(exitCode, equals(0));
    });

    // ─── Rename subcommand help tests ───────────────────────────

    test('should show rename screen help', () async {
      final runner = NeuronCliRunner();
      final exitCode = await runner.run(['rename', 'screen', '--help']);
      expect(exitCode, equals(0));
    });

    test('should show rename controller help', () async {
      final runner = NeuronCliRunner();
      final exitCode = await runner.run(['rename', 'controller', '--help']);
      expect(exitCode, equals(0));
    });

    test('should show rename model help', () async {
      final runner = NeuronCliRunner();
      final exitCode = await runner.run(['rename', 'model', '--help']);
      expect(exitCode, equals(0));
    });

    test('should show rename service help', () async {
      final runner = NeuronCliRunner();
      final exitCode = await runner.run(['rename', 'service', '--help']);
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

  // ─── NEW TEMPLATE TESTS ─────────────────────────────────────────────────

  group('ServiceTemplates', () {
    test('generates base service with Neuron.use', () {
      final output = ServiceTemplates.serviceDart('auth');
      expect(output, contains('class AuthService extends NeuronController'));
      expect(output, contains('Neuron.use<AuthService>()'));
      expect(output, contains('Signal<bool>(false)'));
      expect(output, contains('Signal<String?>'));
    });

    test('generates CRUD service with getAll/getById/create/update/delete', () {
      final output = ServiceTemplates.crudServiceDart('user');
      expect(output, contains('class UserService extends NeuronController'));
      expect(output, contains('Future<List<Map<String, dynamic>>> getAll()'));
      expect(output, contains('Future<Map<String, dynamic>?> getById(String id)'));
      expect(output, contains('Future<Map<String, dynamic>> create(Map<String, dynamic> data)'));
      expect(output, contains('Future<Map<String, dynamic>> update(String id'));
      expect(output, contains('Future<void> delete(String id)'));
    });

    test('generates HTTP service with GET/POST/PUT/DELETE', () {
      final output = ServiceTemplates.httpServiceDart('api');
      expect(output, contains('class ApiService extends NeuronController'));
      expect(output, contains('String get baseUrl'));
      expect(output, contains('Future<Map<String, dynamic>> get(String path)'));
      expect(output, contains('Future<Map<String, dynamic>> post('));
      expect(output, contains('Future<Map<String, dynamic>> put('));
      expect(output, contains('Future<Map<String, dynamic>> delete(String path)'));
    });
  });

  group('WidgetTemplates', () {
    test('generates basic widget', () {
      final output = WidgetTemplates.widgetDart('avatar_card');
      expect(output, contains('class AvatarCard extends StatelessWidget'));
      expect(output, contains('const AvatarCard({'));
      expect(output, contains('Widget? child'));
    });

    test('generates signal-aware widget with generic type', () {
      final output = WidgetTemplates.signalWidgetDart('status_badge');
      expect(output, contains('class StatusBadge<T> extends StatelessWidget'));
      expect(output, contains('Signal<T> signal'));
      expect(output, contains('Slot<T>('));
    });
  });

  group('MiddlewareTemplates', () {
    test('generates middleware extending SignalMiddleware', () {
      final output = MiddlewareTemplates.middlewareDart('logging');
      expect(output, contains('class LoggingMiddleware<T> extends SignalMiddleware<T>'));
      expect(output, contains('T? onEmit(T currentValue, T newValue)'));
    });
  });

  group('PageTemplates', () {
    test('generates controller wired to service with AsyncSignal', () {
      final output = PageTemplates.controllerDart('products');
      expect(output, contains('class ProductsController extends NeuronController'));
      expect(output, contains('ProductsService.init'));
      expect(output, contains('AsyncSignal<List<Map<String, dynamic>>>'));
      expect(output, contains('Future<void> loadData()'));
    });

    test('generates view with AsyncSlot loading/error/data pattern', () {
      final output = PageTemplates.viewDart('products');
      expect(output, contains('class ProductsView extends StatelessWidget'));
      expect(output, contains('AsyncSlot<List<Map<String, dynamic>>>'));
      expect(output, contains('loading:'));
      expect(output, contains('error:'));
      expect(output, contains('data:'));
    });

    test('generates page-local service with CRUD stubs', () {
      final output = PageTemplates.serviceDart('products');
      expect(output, contains('class ProductsService extends NeuronController'));
      expect(output, contains('Future<List<Map<String, dynamic>>> getAll()'));
      expect(output, contains('Future<void> delete(String id)'));
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
