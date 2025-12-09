/// Neuron Navigation System
///
/// A comprehensive, signal-aware navigation layer with:
/// - Named + path-based routing (with params and deep links)
/// - Route guards and middleware (before/after navigation)
/// - Rich transition library (20+ motion presets + custom builders)
/// - Reactive state (current route, history, canGoBack, isNavigating)
/// - Elegant, context-less API via `NeuronNavigator.instance`
library;

import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'neuron_core.dart';

typedef NeuronRouteBuilder = Widget Function(
  BuildContext context,
  Map<String, dynamic> params,
);

class NeuronTransitionSpec {
  final Duration duration;
  final Duration reverseDuration;
  final Curve curve;
  final Curve reverseCurve;
  final Alignment alignment;
  final double parallax;
  final double blurSigma;

  const NeuronTransitionSpec({
    this.duration = const Duration(milliseconds: 320),
    this.reverseDuration = const Duration(milliseconds: 280),
    this.curve = Curves.easeOutCubic,
    this.reverseCurve = Curves.easeInCubic,
    this.alignment = Alignment.center,
    this.parallax = 0.08,
    this.blurSigma = 8,
  });

  NeuronTransitionSpec copyWith({
    Duration? duration,
    Duration? reverseDuration,
    Curve? curve,
    Curve? reverseCurve,
    Alignment? alignment,
    double? parallax,
    double? blurSigma,
  }) {
    return NeuronTransitionSpec(
      duration: duration ?? this.duration,
      reverseDuration: reverseDuration ?? this.reverseDuration,
      curve: curve ?? this.curve,
      reverseCurve: reverseCurve ?? this.reverseCurve,
      alignment: alignment ?? this.alignment,
      parallax: parallax ?? this.parallax,
      blurSigma: blurSigma ?? this.blurSigma,
    );
  }
}

class NeuronRoute {
  final String path;
  final String name;
  final NeuronRouteBuilder builder;
  final List<NeuronRouteGuard> guards;
  final Map<String, dynamic>? meta;
  final NeuronPageTransition transition;
  final NeuronTransitionSpec transitionSpec;
  final RouteTransitionsBuilder? customTransition;
  final bool maintainState;
  final bool fullscreenDialog;
  final List<NeuronRoute> children;

  const NeuronRoute({
    required this.path,
    required this.name,
    required this.builder,
    this.guards = const [],
    this.meta,
    this.transition = NeuronPageTransition.fade,
    this.transitionSpec = const NeuronTransitionSpec(),
    this.customTransition,
    this.maintainState = true,
    this.fullscreenDialog = false,
    this.children = const [],
  });

  NeuronRoute copyWith({
    String? path,
    String? name,
    NeuronRouteBuilder? builder,
    List<NeuronRouteGuard>? guards,
    Map<String, dynamic>? meta,
    NeuronPageTransition? transition,
    NeuronTransitionSpec? transitionSpec,
    RouteTransitionsBuilder? customTransition,
    bool? maintainState,
    bool? fullscreenDialog,
    List<NeuronRoute>? children,
  }) {
    return NeuronRoute(
      path: path ?? this.path,
      name: name ?? this.name,
      builder: builder ?? this.builder,
      guards: guards ?? this.guards,
      meta: meta ?? this.meta,
      transition: transition ?? this.transition,
      transitionSpec: transitionSpec ?? this.transitionSpec,
      customTransition: customTransition ?? this.customTransition,
      maintainState: maintainState ?? this.maintainState,
      fullscreenDialog: fullscreenDialog ?? this.fullscreenDialog,
      children: children ?? this.children,
    );
  }
}

abstract class NeuronRouteGuard {
  Future<bool> canActivate(NeuronRouteContext context);

  Future<String?> redirectTo(NeuronRouteContext context) => Future.value(null);
}

class NeuronRouteContext {
  final String path;
  final String name;
  final Map<String, dynamic> params;
  final Map<String, dynamic> query;
  final Map<String, dynamic>? meta;
  final Uri? uri;
  final NeuronRoute? route;
  final NeuronNavigationEntry? previous;

  const NeuronRouteContext({
    required this.path,
    required this.name,
    required this.params,
    required this.query,
    this.meta,
    this.uri,
    this.route,
    this.previous,
  });
}

class NeuronRouteState extends NeuronRouteContext {
  const NeuronRouteState({
    required super.path,
    required super.name,
    required super.params,
    required super.query,
    super.meta,
    super.uri,
    super.route,
    super.previous,
  });

  NeuronRouteState copyWith({
    String? path,
    String? name,
    Map<String, dynamic>? params,
    Map<String, dynamic>? query,
    Map<String, dynamic>? meta,
    Uri? uri,
    NeuronRoute? route,
    NeuronNavigationEntry? previous,
  }) {
    return NeuronRouteState(
      path: path ?? this.path,
      name: name ?? this.name,
      params: params ?? this.params,
      query: query ?? this.query,
      meta: meta ?? this.meta,
      uri: uri ?? this.uri,
      route: route ?? this.route,
      previous: previous ?? this.previous,
    );
  }
}

enum NeuronPageTransition {
  none,
  fade,
  fadeScale,
  fadeThrough,
  slide,
  slideLeft,
  slideRight,
  slideUp,
  slideDown,
  slideAndFade,
  scale,
  rotation,
  size,
  depth,
  parallax,
  zoomOut,
  blur,
  flipX,
  flipY,
  cube,
  sharedAxisX,
  sharedAxisY,
  sharedAxisZ,
  material,
  cupertino,
  custom,
}

class NeuronNavigationEntry {
  final NeuronRouteState state;
  final DateTime timestamp;
  final bool replaced;

  const NeuronNavigationEntry({
    required this.state,
    required this.timestamp,
    this.replaced = false,
  });
}

abstract class NeuronNavigationMiddleware {
  FutureOr<void> beforeNavigate(NeuronRouteContext context) async {}

  FutureOr<void> afterNavigate(NeuronRouteState state) async {}

  @Deprecated('Use beforeNavigate instead')
  FutureOr<void> onNavigate(NeuronRouteContext context) async {}
}

class AuthGuard extends NeuronRouteGuard {
  final bool Function() isAuthenticated;
  final String redirectRoute;

  AuthGuard({
    required this.isAuthenticated,
    this.redirectRoute = '/login',
  });

  @override
  Future<bool> canActivate(NeuronRouteContext context) async {
    return isAuthenticated();
  }

  @override
  Future<String?> redirectTo(NeuronRouteContext context) async {
    return isAuthenticated() ? null : redirectRoute;
  }
}

class RoleGuard extends NeuronRouteGuard {
  final List<String> requiredRoles;
  final List<String> Function() getUserRoles;
  final String redirectRoute;

  RoleGuard({
    required this.requiredRoles,
    required this.getUserRoles,
    this.redirectRoute = '/unauthorized',
  });

  @override
  Future<bool> canActivate(NeuronRouteContext context) async {
    final userRoles = getUserRoles();
    return requiredRoles.any(userRoles.contains);
  }

  @override
  Future<String?> redirectTo(NeuronRouteContext context) async {
    final userRoles = getUserRoles();
    final hasRole = requiredRoles.any(userRoles.contains);
    return hasRole ? null : redirectRoute;
  }
}

class NavigationLogger extends NeuronNavigationMiddleware {
  final void Function(String message)? printer;

  NavigationLogger({this.printer});

  @override
  FutureOr<void> beforeNavigate(NeuronRouteContext context) {
    final log = printer ?? print;
    log('[Navigation] ${context.name} (${context.path})');
    if (context.params.isNotEmpty) {
      log('  Params: ${context.params}');
    }
    if (context.query.isNotEmpty) {
      log('  Query: ${context.query}');
    }
  }
}

class NavigationAnalytics extends NeuronNavigationMiddleware {
  final Future<void> Function(NeuronRouteContext context) onTrack;

  NavigationAnalytics({required this.onTrack});

  @override
  Future<void> beforeNavigate(NeuronRouteContext context) async {
    await onTrack(context);
  }
}

class NeuronRouteScope extends InheritedWidget {
  final NeuronRouteState state;

  const NeuronRouteScope({
    super.key,
    required this.state,
    required super.child,
  });

  static NeuronRouteState? of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<NeuronRouteScope>()
        ?.state;
  }

  @override
  bool updateShouldNotify(covariant NeuronRouteScope oldWidget) {
    return oldWidget.state != state;
  }
}

class NeuronNavigator extends NeuronController {
  static NeuronNavigator? _instance;

  late final currentRoute = Signal<NeuronRouteState?>(null).bind(this);
  late final navigationHistory =
      Signal<List<NeuronNavigationEntry>>([]).bind(this);
  late final isNavigating = Signal<bool>(false).bind(this);
  late final canGoBack = Computed<bool>(
    () => navigationHistory.val.length > 1,
  ).bind(this);
  late final canGoForward = Signal<bool>(false).bind(this);

  final Map<String, _IndexedRoute> _routesByName = {};
  final List<_IndexedRoute> _routes = [];
  final List<NeuronNavigationMiddleware> _middlewares = [];
  final GlobalKey<NavigatorState> navigatorKey = Neuron.navigatorKey;

  int _historyIndex = -1;

  NeuronNavigator._();

  static NeuronNavigator get instance {
    _instance ??= NeuronNavigator._();
    return _instance!;
  }

  void registerRoutes(List<NeuronRoute> routes, {bool reset = false}) {
    if (reset) {
      _routesByName.clear();
      _routes.clear();
    }
    for (final route in routes) {
      _indexRoute(route, parentPath: '');
    }
  }

  void addMiddleware(NeuronNavigationMiddleware middleware) {
    _middlewares.add(middleware);
  }

  Future<T?> toNamed<T>(
    String name, {
    Map<String, dynamic> params = const {},
    Map<String, dynamic> query = const {},
    bool replace = false,
    Object? arguments,
  }) async {
    final target = _routesByName[name];
    if (target == null) {
      throw Exception('Route not found: $name');
    }

    final match = _RouteMatch(
      route: target.route,
      fullPath: target.fullPath,
      params: params,
      query: query,
      uri: Uri(path: target.fullPath, queryParameters: query),
    );
    return _navigate<T>(match, replace: replace, arguments: arguments);
  }

  Future<T?> to<T>(
    String path, {
    Map<String, dynamic> query = const {},
    bool replace = false,
    Object? arguments,
  }) async {
    final match = _findRouteByPath(path, query: query);
    if (match == null) {
      throw Exception('Route not found for path: $path');
    }
    return _navigate<T>(match, replace: replace, arguments: arguments);
  }

  Future<T?> toUri<T>(
    Uri uri, {
    bool replace = false,
    Object? arguments,
  }) {
    return to<T>(
      uri.path.isEmpty ? '/' : uri.path,
      query: uri.queryParameters,
      replace: replace,
      arguments: arguments ?? uri.fragment,
    );
  }

  Future<void> back<T>([T? result]) async {
    if (canGoBack.value) {
      navigatorKey.currentState?.pop(result);
      _historyIndex =
          (_historyIndex - 1).clamp(0, navigationHistory.val.length - 1);
      final entry = navigationHistory.val.isNotEmpty
          ? navigationHistory.val[_historyIndex]
          : null;
      if (entry != null) {
        currentRoute.emit(entry.state);
      }
    }
  }

  Future<void> forward() async {
    if (_historyIndex < navigationHistory.val.length - 1) {
      _historyIndex++;
      final entry = navigationHistory.val[_historyIndex];
      await toNamed(entry.state.name,
          params: entry.state.params, query: entry.state.query);
    }
  }

  void clearHistory() {
    navigationHistory.emit([]);
    _historyIndex = -1;
  }

  void popUntil(String routeName) {
    navigatorKey.currentState
        ?.popUntil((route) => route.settings.name == routeName);
  }

  Future<T?> offAllNamed<T>(
    String name, {
    Map<String, dynamic> params = const {},
    Map<String, dynamic> query = const {},
    Object? arguments,
  }) async {
    navigatorKey.currentState?.popUntil((route) => false);
    clearHistory();
    return toNamed<T>(name, params: params, query: query, arguments: arguments);
  }

  NeuronRoute? getCurrentRoute() => currentRoute.val?.route;

  NeuronRouteState? getCurrentRouteState() => currentRoute.val;

  Future<T?> _navigate<T>(
    _RouteMatch match, {
    bool replace = false,
    Object? arguments,
  }) async {
    final previousEntry =
        _historyIndex >= 0 && _historyIndex < navigationHistory.val.length
            ? navigationHistory.val[_historyIndex]
            : null;

    final context = NeuronRouteContext(
      path: match.fullPath,
      name: match.route.name,
      params: match.params,
      query: match.query,
      meta: match.route.meta,
      uri: match.uri,
      route: match.route,
      previous: previousEntry,
    );

    final allowed = await _runGuards(match.route, context);
    if (!allowed) return null;

    await _runMiddlewaresBefore(context);

    final state = NeuronRouteState(
      path: match.fullPath,
      name: match.route.name,
      params: match.params,
      query: match.query,
      meta: match.route.meta,
      uri: match.uri,
      route: match.route,
      previous: previousEntry,
    );

    isNavigating.emit(true);
    final route = _buildPageRoute<T>(match.route, state, arguments: arguments);
    final nav = navigatorKey.currentState;
    if (nav == null) {
      isNavigating.emit(false);
      throw Exception(
          'Navigator is not ready. Wrap your app with NeuronNavigatorWidget or set navigatorKey.');
    }

    final future =
        replace ? nav.pushReplacement<T, dynamic>(route) : nav.push<T>(route);
    _updateHistory(state, replaced: replace);
    currentRoute.emit(state);
    isNavigating.emit(false);

    await _runMiddlewaresAfter(state);
    return future;
  }

  Future<bool> _runGuards(NeuronRoute route, NeuronRouteContext context) async {
    for (final guard in route.guards) {
      final canActivate = await guard.canActivate(context);
      if (!canActivate) {
        final redirect = await guard.redirectTo(context);
        if (redirect != null) {
          await toNamed(redirect, params: context.params, query: context.query);
        }
        return false;
      }
    }
    return true;
  }

  Future<void> _runMiddlewaresBefore(NeuronRouteContext context) async {
    for (final middleware in _middlewares) {
      await middleware.beforeNavigate(context);
      // ignore: deprecated_member_use_from_same_package
      await middleware.onNavigate(context);
    }
  }

  Future<void> _runMiddlewaresAfter(NeuronRouteState state) async {
    for (final middleware in _middlewares) {
      await middleware.afterNavigate(state);
    }
  }

  void _updateHistory(NeuronRouteState state, {required bool replaced}) {
    final entry = NeuronNavigationEntry(
      state: state,
      timestamp: DateTime.now(),
      replaced: replaced,
    );

    final history = List<NeuronNavigationEntry>.from(navigationHistory.val);
    if (replaced && history.isNotEmpty) {
      history[history.length - 1] = entry;
      _historyIndex = history.length - 1;
    } else {
      if (_historyIndex < history.length - 1) {
        history.removeRange(_historyIndex + 1, history.length);
      }
      history.add(entry);
      _historyIndex = history.length - 1;
    }
    navigationHistory.emit(history);
    canGoForward.emit(false);
  }

  _RouteMatch? _findRouteByPath(String path,
      {Map<String, dynamic> query = const {}}) {
    final normalized = _normalizePath(path);
    final uri = Uri.parse(normalized);
    final incoming = uri.pathSegments;

    for (final candidate in _routes) {
      final params = <String, dynamic>{};
      if (_matches(candidate.segments, incoming, params)) {
        return _RouteMatch(
          route: candidate.route,
          fullPath: candidate.fullPath,
          params: params,
          query: {...query, ...uri.queryParameters},
          uri: uri,
        );
      }
    }
    return null;
  }

  void _indexRoute(NeuronRoute route, {required String parentPath}) {
    final fullPath = _normalizePath(_joinPath(parentPath, route.path));
    final entry = _IndexedRoute(
      route: route,
      fullPath: fullPath,
      segments: Uri.parse(fullPath).pathSegments,
    );

    if (_routesByName.containsKey(route.name)) {
      throw Exception('Duplicate route name detected: ${route.name}');
    }

    _routesByName[route.name] = entry;
    _routes.add(entry);

    for (final child in route.children) {
      _indexRoute(child, parentPath: fullPath);
    }
  }

  PageRoute<T> _buildPageRoute<T>(
    NeuronRoute route,
    NeuronRouteState state, {
    Object? arguments,
  }) {
    NeuronRouteScope builder(BuildContext context) {
      final page = route.builder(context, state.params);
      return NeuronRouteScope(
        state: state,
        child: page,
      );
    }

    final settings =
        RouteSettings(name: state.name, arguments: arguments ?? state);
    final spec = route.transitionSpec;

    if (route.transition == NeuronPageTransition.cupertino) {
      return CupertinoPageRoute<T>(
        builder: builder,
        settings: settings,
        maintainState: route.maintainState,
        fullscreenDialog: route.fullscreenDialog,
      );
    }

    if (route.transition == NeuronPageTransition.none) {
      return MaterialPageRoute<T>(
        builder: builder,
        settings: settings,
        maintainState: route.maintainState,
        fullscreenDialog: route.fullscreenDialog,
      );
    }

    final transitionBuilder = route.transition == NeuronPageTransition.custom
        ? (route.customTransition ?? NeuronTransitions.none)
        : (BuildContext context, Animation<double> animation,
            Animation<double> secondaryAnimation, Widget child) {
            final curved = CurvedAnimation(
              parent: animation,
              curve: spec.curve,
              reverseCurve: spec.reverseCurve,
            );
            final curvedSecondary = CurvedAnimation(
              parent: secondaryAnimation,
              curve: spec.reverseCurve,
              reverseCurve: spec.curve,
            );
            return NeuronTransitions.build(
              route.transition,
              curved,
              curvedSecondary,
              child,
              spec,
            );
          };

    return PageRouteBuilder<T>(
      settings: settings,
      transitionDuration: spec.duration,
      reverseTransitionDuration: spec.reverseDuration,
      maintainState: route.maintainState,
      fullscreenDialog: route.fullscreenDialog,
      pageBuilder: (context, animation, secondaryAnimation) => builder(context),
      transitionsBuilder: transitionBuilder,
    );
  }

  static String _normalizePath(String path) {
    if (path.isEmpty) return '/';
    if (!path.startsWith('/')) return '/$path';
    return path;
  }

  static String _joinPath(String parent, String child) {
    if (child.startsWith('/')) return child;
    if (parent.isEmpty || parent == '/') return '/$child';
    return '$parent/$child';
  }

  bool _matches(List<String> routeSegments, List<String> incoming,
      Map<String, dynamic> params) {
    if (routeSegments.isEmpty && incoming.isEmpty) return true;
    if (routeSegments.isEmpty || incoming.isEmpty) return false;

    if (routeSegments.length > incoming.length && routeSegments.last != '*') {
      return false;
    }

    for (int i = 0; i < routeSegments.length; i++) {
      final routeSegment = routeSegments[i];
      final isWildcard = routeSegment == '*';
      final incomingSegment = i < incoming.length ? incoming[i] : '';

      if (isWildcard) {
        params['*'] = incoming.skip(i).join('/');
        return true;
      }

      if (routeSegment.startsWith(':')) {
        params[routeSegment.substring(1)] = incomingSegment;
        continue;
      }

      if (routeSegment != incomingSegment) {
        return false;
      }
    }

    return routeSegments.length == incoming.length || routeSegments.last == '*';
  }
}

class NeuronNavigationObserver extends NavigatorObserver {
  final NeuronNavigator nav;

  NeuronNavigationObserver(this.nav);

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    final history = nav.navigationHistory.val;
    if (history.isNotEmpty) {
      final updated = List<NeuronNavigationEntry>.from(history)..removeLast();
      nav.navigationHistory.emit(updated);
      nav._historyIndex = updated.length - 1;
      nav.canGoForward.emit(false);
    }
    if (previousRoute?.settings.name != null) {
      final entry = nav.navigationHistory.val.isNotEmpty
          ? nav.navigationHistory.val.last
          : null;
      if (entry != null) {
        nav.currentRoute.emit(entry.state);
      }
    }
  }
}

class NeuronNavigatorWidget extends StatelessWidget {
  final List<NeuronRoute> routes;
  final String initialRoute;
  final List<NeuronNavigationMiddleware> middlewares;
  final Widget Function(BuildContext, Widget?)? builder;
  final ThemeData? theme;
  final ThemeData? darkTheme;
  final ThemeMode? themeMode;
  final bool debugShowCheckedModeBanner;

  const NeuronNavigatorWidget({
    super.key,
    required this.routes,
    required this.initialRoute,
    this.middlewares = const [],
    this.builder,
    this.theme,
    this.darkTheme,
    this.themeMode,
    this.debugShowCheckedModeBanner = false,
  });

  @override
  Widget build(BuildContext context) {
    final navigator = NeuronNavigator.instance;

    navigator.registerRoutes(routes, reset: true);
    for (final middleware in middlewares) {
      navigator.addMiddleware(middleware);
    }

    return MaterialApp(
      navigatorKey: navigator.navigatorKey,
      builder: builder,
      theme: theme,
      darkTheme: darkTheme,
      themeMode: themeMode,
      navigatorObservers: [NeuronNavigationObserver(navigator)],
      onGenerateRoute: (settings) {
        final name = settings.name ?? initialRoute;
        final uri = Uri.tryParse(name);
        if (uri != null) {
          final match =
              navigator._findRouteByPath(uri.path, query: uri.queryParameters);
          if (match != null) {
            final state = NeuronRouteState(
              path: match.fullPath,
              name: match.route.name,
              params: match.params,
              query: match.query,
              meta: match.route.meta,
              uri: uri,
              route: match.route,
              previous: navigator.getCurrentRouteState() != null
                  ? NeuronNavigationEntry(
                      state: navigator.getCurrentRouteState()!,
                      timestamp: DateTime.now(),
                    )
                  : null,
            );
            navigator._updateHistory(state, replaced: false);
            navigator.currentRoute.emit(state);
            return navigator._buildPageRoute(
              match.route,
              state,
              arguments: settings.arguments,
            );
          }
        }
        final fallback = routes.first;
        final state = NeuronRouteState(
          path: fallback.path,
          name: fallback.name,
          params: const {},
          query: const {},
          meta: fallback.meta,
          uri: Uri(path: fallback.path),
          route: fallback,
        );
        navigator._updateHistory(state, replaced: false);
        navigator.currentRoute.emit(state);
        return navigator._buildPageRoute(
          fallback,
          state,
          arguments: settings.arguments,
        );
      },
      initialRoute: initialRoute,
      debugShowCheckedModeBanner: debugShowCheckedModeBanner,
    );
  }
}

class NeuronTransitions {
  static Widget build(
    NeuronPageTransition transition,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
    NeuronTransitionSpec spec,
  ) {
    switch (transition) {
      case NeuronPageTransition.fade:
        return FadeTransition(opacity: animation, child: child);

      case NeuronPageTransition.fadeScale:
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.92, end: 1.0).animate(animation),
            alignment: spec.alignment,
            child: child,
          ),
        );

      case NeuronPageTransition.fadeThrough:
        final fadeOut =
            Tween<double>(begin: 1, end: 0).animate(secondaryAnimation);
        final fadeIn = Tween<double>(begin: 0, end: 1).animate(animation);
        final scaleIn = Tween<double>(begin: 0.92, end: 1).animate(animation);
        return FadeTransition(
          opacity: fadeIn,
          child: ScaleTransition(
            scale: scaleIn,
            child: FadeTransition(
              opacity: fadeOut,
              child: child,
            ),
          ),
        );

      case NeuronPageTransition.slide:
      case NeuronPageTransition.slideRight:
        return _slide(child, animation, const Offset(1, 0), spec);

      case NeuronPageTransition.slideLeft:
        return _slide(child, animation, const Offset(-1, 0), spec);

      case NeuronPageTransition.slideUp:
        return _slide(child, animation, const Offset(0, 1), spec);

      case NeuronPageTransition.slideDown:
        return _slide(child, animation, const Offset(0, -1), spec);

      case NeuronPageTransition.slideAndFade:
        return FadeTransition(
          opacity: animation,
          child: _slide(child, animation, const Offset(0.12, 0), spec),
        );

      case NeuronPageTransition.scale:
        return ScaleTransition(
          scale: Tween<double>(begin: 0.9, end: 1.0).animate(animation),
          alignment: spec.alignment,
          child: child,
        );

      case NeuronPageTransition.rotation:
        return RotationTransition(
          turns: Tween<double>(begin: -0.02, end: 0.0).animate(animation),
          child: FadeTransition(opacity: animation, child: child),
        );

      case NeuronPageTransition.size:
        return Align(
          alignment: spec.alignment,
          child: SizeTransition(
            sizeFactor: animation,
            axisAlignment: -1,
            child: child,
          ),
        );

      case NeuronPageTransition.depth:
        return AnimatedBuilder(
          animation: animation,
          builder: (context, _) {
            final scale =
                Tween<double>(begin: 0.95, end: 1.0).transform(animation.value);
            final opacity =
                Tween<double>(begin: 0.0, end: 1.0).transform(animation.value);
            return Transform.scale(
              scale: scale,
              alignment: spec.alignment,
              child: Opacity(opacity: opacity, child: child),
            );
          },
        );

      case NeuronPageTransition.parallax:
        return AnimatedBuilder(
          animation: animation,
          builder: (context, _) {
            final dx = Tween<double>(begin: spec.parallax, end: 0)
                .transform(animation.value);
            return FractionalTranslation(
              translation: Offset(dx, 0),
              child: child,
            );
          },
        );

      case NeuronPageTransition.zoomOut:
        return ScaleTransition(
          scale: Tween<double>(begin: 1.08, end: 1.0).animate(animation),
          alignment: spec.alignment,
          child: FadeTransition(opacity: animation, child: child),
        );

      case NeuronPageTransition.blur:
        return AnimatedBuilder(
          animation: animation,
          builder: (context, _) {
            final sigma = Tween<double>(begin: spec.blurSigma, end: 0)
                .transform(animation.value);
            return BackdropFilter(
              filter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
              child: FadeTransition(opacity: animation, child: child),
            );
          },
        );

      case NeuronPageTransition.flipX:
        return _flip(child, animation, Axis.horizontal);

      case NeuronPageTransition.flipY:
        return _flip(child, animation, Axis.vertical);

      case NeuronPageTransition.cube:
        return _cube(child, animation);

      case NeuronPageTransition.sharedAxisX:
        return _sharedAxis(child, animation, Axis.horizontal);

      case NeuronPageTransition.sharedAxisY:
        return _sharedAxis(child, animation, Axis.vertical);

      case NeuronPageTransition.sharedAxisZ:
        return _sharedAxis(child, animation, Axis.horizontal, scale: true);

      case NeuronPageTransition.material:
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.08),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );

      case NeuronPageTransition.cupertino:
        // Handled in _buildPageRoute via CupertinoPageRoute, included for exhaustiveness.
        return child;

      case NeuronPageTransition.custom:
        return child;

      case NeuronPageTransition.none:
        return child;
    }
  }

  static Widget _slide(
    Widget child,
    Animation<double> animation,
    Offset begin,
    NeuronTransitionSpec spec,
  ) {
    final tween = Tween<Offset>(begin: begin, end: Offset.zero);
    return SlideTransition(
      position: tween.animate(animation),
      child: child,
    );
  }

  static Widget _flip(Widget child, Animation<double> animation, Axis axis) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final angle = animation.value * pi;
        final transform = Matrix4.identity()
          ..setEntry(3, 2, 0.001)
          ..rotateY(axis == Axis.horizontal ? angle : 0)
          ..rotateX(axis == Axis.vertical ? angle : 0);
        final opacity = animation.value <= 0.5 ? 1.0 : 1.0;
        return Transform(
          transform: transform,
          alignment: Alignment.center,
          child: Opacity(opacity: opacity, child: child),
        );
      },
    );
  }

  static Widget _cube(Widget child, Animation<double> animation) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final angle = (1 - animation.value) * (pi / 2);
        final transform = Matrix4.identity()
          ..setEntry(3, 2, 0.001)
          ..setTranslationRaw(animation.value * 50.0, 0.0, 0.0)
          ..rotateY(angle);
        return Transform(
          transform: transform,
          alignment: Alignment.centerRight,
          child: child,
        );
      },
    );
  }

  static Widget _sharedAxis(
    Widget child,
    Animation<double> animation,
    Axis axis, {
    bool scale = false,
  }) {
    final positionTween = Tween<Offset>(
      begin: axis == Axis.horizontal
          ? const Offset(0.15, 0)
          : const Offset(0, 0.15),
      end: Offset.zero,
    );
    final fade = FadeTransition(
      opacity: animation,
      child: child,
    );
    final slide = SlideTransition(
      position: positionTween.animate(animation),
      child: fade,
    );
    if (!scale) return slide;
    return ScaleTransition(
      scale: Tween<double>(begin: 0.92, end: 1.0).animate(animation),
      child: slide,
    );
  }

  static Widget none(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) =>
      child;
}

class _RouteMatch {
  final NeuronRoute route;
  final String fullPath;
  final Map<String, dynamic> params;
  final Map<String, dynamic> query;
  final Uri uri;

  _RouteMatch({
    required this.route,
    required this.fullPath,
    required this.params,
    required this.query,
    required this.uri,
  });
}

class _IndexedRoute {
  final NeuronRoute route;
  final String fullPath;
  final List<String> segments;

  _IndexedRoute({
    required this.route,
    required this.fullPath,
    required this.segments,
  });
}
