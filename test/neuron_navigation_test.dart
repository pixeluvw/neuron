import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neuron/neuron.dart';

void main() {
  group('NeuronRoute', () {
    test('creates route with required fields', () {
      final route = NeuronRoute(
        path: '/home',
        name: 'home',
        builder: (ctx, params) => const Text('Home'),
      );

      expect(route.path, '/home');
      expect(route.name, 'home');
    });

    test('copyWith preserves and overrides fields', () {
      final route = NeuronRoute(
        path: '/home',
        name: 'home',
        builder: (ctx, params) => const Text('Home'),
        transition: NeuronPageTransition.fade,
        maintainState: true,
      );

      final copied = route.copyWith(
        path: '/dashboard',
        transition: NeuronPageTransition.slide,
      );

      expect(copied.path, '/dashboard');
      expect(copied.name, 'home');
      expect(copied.transition, NeuronPageTransition.slide);
      expect(copied.maintainState, true);
    });

    test('supports nested children routes', () {
      final route = NeuronRoute(
        path: '/settings',
        name: 'settings',
        builder: (ctx, params) => const Text('Settings'),
        children: [
          NeuronRoute(
            path: '/profile',
            name: 'settings.profile',
            builder: (ctx, params) => const Text('Profile'),
          ),
          NeuronRoute(
            path: '/theme',
            name: 'settings.theme',
            builder: (ctx, params) => const Text('Theme'),
          ),
        ],
      );

      expect(route.children.length, 2);
      expect(route.children[0].name, 'settings.profile');
    });

    test('supports all transition types', () {
      for (final transition in NeuronPageTransition.values) {
        final route = NeuronRoute(
          path: '/${transition.name}',
          name: transition.name,
          builder: (ctx, params) => Text(transition.name),
          transition: transition,
        );
        expect(route.transition, transition);
      }
    });
  });

  group('NeuronTransitionSpec', () {
    test('has sensible defaults', () {
      const spec = NeuronTransitionSpec();

      expect(spec.duration, const Duration(milliseconds: 320));
      expect(spec.curve, Curves.easeOutCubic);
    });

    test('copyWith overrides specific fields', () {
      const spec = NeuronTransitionSpec();
      final copied = spec.copyWith(
        duration: const Duration(milliseconds: 500),
        curve: Curves.bounceOut,
      );

      expect(copied.duration, const Duration(milliseconds: 500));
      expect(copied.curve, Curves.bounceOut);
    });
  });

  group('NeuronRouteGuard', () {
    test('AuthGuard blocks when not authenticated', () async {
      final guard = AuthGuard(isAuthenticated: () => false);
      final context = const NeuronRouteContext(
        path: '/protected',
        name: 'protected',
        params: {},
        query: {},
      );

      expect(await guard.canActivate(context), false);
    });

    test('AuthGuard allows when authenticated', () async {
      final guard = AuthGuard(isAuthenticated: () => true);
      final context = const NeuronRouteContext(
        path: '/protected',
        name: 'protected',
        params: {},
        query: {},
      );

      expect(await guard.canActivate(context), true);
    });

    test('AuthGuard redirects to login path when not authenticated', () async {
      final guard = AuthGuard(
        isAuthenticated: () => false,
        redirectRoute: '/login',
      );
      final context = const NeuronRouteContext(
        path: '/protected',
        name: 'protected',
        params: {},
        query: {},
      );

      expect(await guard.redirectTo(context), '/login');
    });

    test('AuthGuard returns null redirect when authenticated', () async {
      final guard = AuthGuard(isAuthenticated: () => true);
      final context = const NeuronRouteContext(
        path: '/protected',
        name: 'protected',
        params: {},
        query: {},
      );

      expect(await guard.redirectTo(context), null);
    });

    test('RoleGuard blocks when user lacks required role', () async {
      final guard = RoleGuard(
        requiredRoles: ['admin', 'editor'],
        getUserRoles: () => ['viewer'],
      );
      final context = const NeuronRouteContext(
        path: '/admin',
        name: 'admin',
        params: {},
        query: {},
      );

      expect(await guard.canActivate(context), false);
    });

    test('RoleGuard allows when user has required role', () async {
      final guard = RoleGuard(
        requiredRoles: ['admin', 'editor'],
        getUserRoles: () => ['admin'],
      );
      final context = const NeuronRouteContext(
        path: '/admin',
        name: 'admin',
        params: {},
        query: {},
      );

      expect(await guard.canActivate(context), true);
    });

    test('RoleGuard redirects when user lacks role', () async {
      final guard = RoleGuard(
        requiredRoles: ['admin'],
        getUserRoles: () => ['viewer'],
        redirectRoute: '/unauthorized',
      );
      final context = const NeuronRouteContext(
        path: '/admin',
        name: 'admin',
        params: {},
        query: {},
      );

      expect(await guard.redirectTo(context), '/unauthorized');
    });
  });

  group('NeuronNavigationMiddleware', () {
    test('NavigationLogger logs navigation events', () {
      final logs = <String>[];
      final logger = NavigationLogger(printer: (msg) => logs.add(msg));
      final context = const NeuronRouteContext(
        path: '/test',
        name: 'test',
        params: {'id': '123'},
        query: {'tab': 'details'},
      );

      logger.beforeNavigate(context);

      expect(logs.length, greaterThanOrEqualTo(1));
      expect(logs.first, contains('/test'));
    });

    test('NavigationAnalytics tracks via onTrack callback', () async {
      var trackCount = 0;
      final analytics = NavigationAnalytics(
        onTrack: (context) async {
          trackCount++;
        },
      );
      final context = const NeuronRouteContext(
        path: '/page',
        name: 'page',
        params: {},
        query: {},
      );

      await analytics.beforeNavigate(context);
      await analytics.beforeNavigate(context);

      expect(trackCount, 2);
    });
  });

  group('NeuronRouteContext', () {
    test('stores path, name, params, and query', () {
      final context = const NeuronRouteContext(
        path: '/users/:id',
        name: 'user_detail',
        params: {'id': '42'},
        query: {'tab': 'profile', 'lang': 'en'},
      );

      expect(context.path, '/users/:id');
      expect(context.name, 'user_detail');
      expect(context.params['id'], '42');
      expect(context.query['tab'], 'profile');
    });

    test('optional fields default to null', () {
      final context = const NeuronRouteContext(
        path: '/',
        name: 'root',
        params: {},
        query: {},
      );

      expect(context.meta, null);
      expect(context.uri, null);
      expect(context.route, null);
      expect(context.previous, null);
    });
  });

  group('NeuronRouteState', () {
    test('creates from required fields', () {
      final state = const NeuronRouteState(
        path: '/home',
        name: 'home',
        params: {},
        query: {},
      );

      expect(state.path, '/home');
      expect(state.name, 'home');
    });

    test('copyWith preserves and overrides', () {
      final state = const NeuronRouteState(
        path: '/home',
        name: 'home',
        params: {'id': '1'},
        query: {'sort': 'asc'},
      );

      final copied = state.copyWith(path: '/dashboard');

      expect(copied.path, '/dashboard');
      expect(copied.name, 'home');
      expect(copied.params, {'id': '1'});
    });
  });

  group('NeuronNavigationEntry', () {
    test('stores route state, timestamp, and replaced flag', () {
      final state = const NeuronRouteState(
        path: '/test',
        name: 'test',
        params: {},
        query: {},
      );

      final entry = NeuronNavigationEntry(
        state: state,
        timestamp: DateTime(2026, 1, 1),
        replaced: true,
      );

      expect(entry.state.path, '/test');
      expect(entry.timestamp, DateTime(2026, 1, 1));
      expect(entry.replaced, true);
    });

    test('replaced defaults to false', () {
      final state = const NeuronRouteState(
        path: '/test',
        name: 'test',
        params: {},
        query: {},
      );

      final entry = NeuronNavigationEntry(
        state: state,
        timestamp: DateTime.now(),
      );

      expect(entry.replaced, false);
    });
  });

  group('NeuronNavigator — route registration', () {
    test('registers routes successfully', () {
      final navigator = NeuronNavigator.instance;
      navigator.registerRoutes([
        NeuronRoute(
          path: '/home',
          name: 'home',
          builder: (ctx, params) => const Text('Home'),
        ),
        NeuronRoute(
          path: '/about',
          name: 'about',
          builder: (ctx, params) => const Text('About'),
        ),
      ], reset: true);

      // Routes registered — getCurrentRoute is null before navigation
      expect(navigator.getCurrentRoute(), null);
    });

    test('throws on unknown named route', () async {
      final navigator = NeuronNavigator.instance;
      navigator.registerRoutes([], reset: true);

      expect(
        () => navigator.toNamed('nonexistent'),
        throwsA(isA<Exception>()),
      );
    });

    test('reset clears all routes', () {
      final navigator = NeuronNavigator.instance;
      navigator.registerRoutes([
        NeuronRoute(
          path: '/page',
          name: 'page',
          builder: (ctx, params) => const Text('Page'),
        ),
      ], reset: false);

      navigator.registerRoutes([], reset: true);

      expect(
        () => navigator.toNamed('page'),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('NeuronNavigator widget integration', () {
    testWidgets('NeuronNavigatorWidget builds with initial route',
        (tester) async {
      final navigator = NeuronNavigator.instance;
      navigator.registerRoutes([
        NeuronRoute(
          path: '/',
          name: 'home',
          builder: (ctx, params) => const Text('Home Page'),
        ),
      ], reset: true);

      await tester.pumpWidget(
        MaterialApp(
          home: NeuronNavigatorWidget(
            initialRoute: '/',
            routes: [
              NeuronRoute(
                path: '/',
                name: 'home',
                builder: (ctx, params) => const Text('Home Page'),
              ),
            ],
          ),
        ),
      );

      expect(find.text('Home Page'), findsOneWidget);
    });
  });
}
