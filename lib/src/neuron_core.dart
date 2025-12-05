// neuron_core.dart
//
// Neuron - Qt Signal/Slot State Management for Flutter
//
// Core framework with all advanced features:
// - Service locator: Neuron
// - Base controller: NeuronController
// - UI binding widgets: Slot, AsyncSlot
// - App wrapper: NeuronApp
//
// Signals are now in neuron_signals.dart:
// - Signal<T>, AsyncSignal<T>, Computed<T>
//
// Controllers expose: static MyController get init => Neuron.ensure<MyController>(() => MyController());
// Views are StatelessWidget: final c = MyController.init;

import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'neuron_atom.dart';
import 'debug/index.dart';
import 'neuron_extensions.dart';
import 'neuron_signals.dart';
import 'neuron_navigation.dart';

// Re-export signals for backward compatibility
export 'neuron_signals.dart';
export 'neuron_atom.dart';

/// A widget that rebuilds when a [NeuronAtom] changes.
///
/// This is a low-level widget used to build reactive UI components.
/// For most use cases, consider using [Slot] or [AsyncSlot] instead.
///
/// ## Basic Usage
///
/// ```dart
/// final count = Signal(0);
///
/// NeuronAtomBuilder(
///   atom: count,
///   builder: (context, value, child) {
///     return Text('Count: $value');
///   },
/// )
/// ```
///
/// ## Performance Optimization
///
/// You can use the `child` parameter to pass a widget that doesn't need to rebuild
/// when the atom changes. This is useful for static content or expensive widgets.
///
/// ```dart
/// NeuronAtomBuilder(
///   atom: count,
///   child: const Icon(Icons.add), // Built once
///   builder: (context, value, child) {
///     return Row(
///       children: [
///         child!, // Reused
///         Text('$value'),
///       ],
///     );
///   },
/// )
/// ```
class NeuronAtomBuilder<T> extends StatefulWidget {
  final NeuronAtom<T> atom;
  final Widget Function(BuildContext context, T value, Widget? child) builder;
  final Widget? child;

  const NeuronAtomBuilder({
    super.key,
    required this.atom,
    required this.builder,
    this.child,
  });

  @override
  State<NeuronAtomBuilder<T>> createState() => _NeuronAtomBuilderState<T>();
}

class _NeuronAtomBuilderState<T> extends State<NeuronAtomBuilder<T>> {
  late T _value;
  VoidCallback? _cancel;

  @override
  void initState() {
    super.initState();
    _value = widget.atom.value;
    _subscribe();
  }

  void _subscribe() {
    _cancel = widget.atom.subscribe(() {
      if (mounted) {
        setState(() {
          _value = widget.atom.value;
        });
      }
    });
  }

  @override
  void didUpdateWidget(NeuronAtomBuilder<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.atom != oldWidget.atom) {
      _cancel?.call();
      _value = widget.atom.value;
      _subscribe();
    }
  }

  @override
  void dispose() {
    _cancel?.call();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _value, widget.child);
  }
}

/// Helper class to dispose effects.
class _EffectDisposer implements Disposable {
  final List<NeuronAtom> dependencies;
  final List<VoidCallback> listeners;

  _EffectDisposer(this.dependencies, this.listeners);

  @override
  void dispose() {
    for (int i = 0; i < dependencies.length; i++) {
      dependencies[i].removeListener(listeners[i]);
    }
    listeners.clear();
  }
}

/// ============================================================================
/// 1. NEURON CORE (Service Locator + Navigation)
/// ============================================================================

/// Global service locator and navigation manager for Neuron.
///
/// The [Neuron] class serves two primary purposes:
/// 1. **Service Locator**: Manages the lifecycle of [NeuronController] instances,
///    ensuring they are created once and disposed properly.
/// 2. **Context-less Navigation**: Provides navigation methods that don't require
///    a [BuildContext], making navigation cleaner and more testable.
///
/// ## Service Locator Usage
///
/// The most common pattern is to use [ensure] with a static getter in your controller:
///
/// ```dart
/// class MyController extends NeuronController {
///   static MyController get init => Neuron.ensure<MyController>(() => MyController());
/// }
/// ```
///
/// Then in your UI:
/// ```dart
/// final controller = MyController.init; // Returns existing or creates new
/// ```
///
/// ## Navigation Usage
///
/// All navigation methods work without a [BuildContext]:
///
/// ```dart
/// Neuron.to(DetailPage());           // Push page
/// Neuron.off(HomePage());            // Replace page
/// Neuron.back();                     // Pop page
/// Neuron.toNamed('/settings');       // Named route
/// ```
///
/// See also:
/// - [install] - Register a controller manually
/// - [use] - Get an already registered controller
/// - [ensure] - Get or create a controller
/// - [uninstall] - Dispose and remove a controller
class Neuron {
  Neuron._(); // no instances

  /// Internal registry of controllers keyed by their Type.
  static final Map<Type, NeuronController> _registry = {};

  /// Global navigator key for context-less navigation.
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  /// Registers a controller and calls its [NeuronController.onInit] hook.
  ///
  /// This method manually registers a controller instance. The controller's
  /// [NeuronController.onInit] method is called immediately after registration.
  ///
  /// ```dart
  /// final controller = MyController();
  /// Neuron.install(controller);
  /// ```
  ///
  /// **Note**: In most cases, use [ensure] instead, which handles both creation
  /// and registration in one call.
  ///
  /// Returns the registered controller instance.
  ///
  /// See also:
  /// - [ensure] - Preferred method that creates and registers if needed
  /// - [use] - Get an already installed controller
  static T install<T extends NeuronController>(T controller) {
    _registry[T] = controller;
    if (NeuronDebugRegistry.instance.isEnabled) {
      NeuronDebugRegistry.instance.registerController(controller);
    }
    controller.onInit();
    return controller;
  }

  /// Returns an already installed controller.
  ///
  /// Use this method when you know the controller has already been registered
  /// via [install] or [ensure].
  ///
  /// ```dart
  /// final controller = Neuron.use<MyController>();
  /// ```
  ///
  /// **Throws** an [Exception] if the controller is not found in the registry.
  ///
  /// **Tip**: Prefer [ensure] if you're unsure whether the controller exists,
  /// as it will create it if needed.
  ///
  /// See also:
  /// - [ensure] - Get or create a controller
  /// - [isInstalled] - Check if a controller exists
  static T use<T extends NeuronController>() {
    if (!_registry.containsKey(T)) {
      throw Exception(
        "Neuron Error: $T not installed. "
        "Use Neuron.ensure<$T>(() => ...) before calling use().",
      );
    }
    return _registry[T] as T;
  }

  /// Returns true if a controller of type [T] is already registered.
  static bool isInstalled<T extends NeuronController>() {
    return _registry.containsKey(T);
  }

  /// Returns an existing controller of type [T] if present.
  ///
  /// If the controller doesn't exist, it creates it via [factory],
  /// installs it, and returns it. This is the recommended way to access
  /// controllers in Neuron.
  ///
  /// The typical pattern is to use [ensure] in a static getter:
  ///
  /// ```dart
  /// class CounterController extends NeuronController {
  ///   late final count = Signal<int>(0).bind(this);
  ///
  ///   static CounterController get init =>
  ///       Neuron.ensure<CounterController>(() => CounterController());
  /// }
  /// ```
  ///
  /// Then in your UI:
  /// ```dart
  /// class CounterPage extends StatelessWidget {
  ///   @override
  ///   Widget build(BuildContext context) {
  ///     final c = CounterController.init; // Lazily created on first access
  ///     return Slot<int>(
  ///       connect: c.count,
  ///       to: (ctx, val) => Text('$val'),
  ///     );
  ///   }
  /// }
  /// ```
  ///
  /// Returns the controller instance (existing or newly created).
  ///
  /// See also:
  /// - [use] - Get an already installed controller (throws if not found)
  /// - [install] - Manually register a controller
  static T ensure<T extends NeuronController>(T Function() factory) {
    if (_registry.containsKey(T)) {
      return _registry[T] as T;
    }
    return install<T>(factory());
  }

  /// Disposes and removes a controller of type [T] if present.
  static void uninstall<T extends NeuronController>() {
    if (_registry.containsKey(T)) {
      final controller = _registry[T]!;
      if (NeuronDebugRegistry.instance.isEnabled) {
        NeuronDebugRegistry.instance.unregisterController(controller);
      }
      controller.dispose();
      _registry.remove(T);
    }
  }

  /// Clears all registered controllers and disposes them.
  static void clearAll() {
    for (final controller in _registry.values) {
      if (NeuronDebugRegistry.instance.isEnabled) {
        NeuronDebugRegistry.instance.unregisterController(controller);
      }
      controller.dispose();
    }
    _registry.clear();
  }

  // ---------------------------------------------------------------------------
  // CONTEXT-LESS NAVIGATION
  // ---------------------------------------------------------------------------

  /// Push a page on the navigator stack.
  static Future<T?>? to<T>(
    Widget page, {
    NeuronPageTransition? transition,
    Duration? duration,
    Duration? reverseDuration,
    Curve? curve,
    Curve? reverseCurve,
  }) {
    final nav = navigatorKey.currentState;
    if (nav == null) return null;

    if (transition == null) {
      return nav.push(MaterialPageRoute(builder: (_) => page));
    }

    final spec = NeuronTransitionSpec(
      duration: duration ?? const Duration(milliseconds: 320),
      reverseDuration: reverseDuration ?? const Duration(milliseconds: 280),
      curve: curve ?? Curves.easeOutCubic,
      reverseCurve: reverseCurve ?? Curves.easeInCubic,
    );

    return nav.push(
      PageRouteBuilder<T>(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionDuration: spec.duration,
        reverseTransitionDuration: spec.reverseDuration,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curvedAnimation = CurvedAnimation(
            parent: animation,
            curve: spec.curve,
            reverseCurve: spec.reverseCurve,
          );
          return NeuronTransitions.build(
            transition,
            curvedAnimation,
            secondaryAnimation,
            child,
            spec,
          );
        },
      ),
    );
  }

  /// Replace the current route with [page].
  static Future<T?>? off<T>(Widget page) =>
      navigatorKey.currentState?.pushReplacement(
        MaterialPageRoute(builder: (_) => page),
      );

  /// Pop the current route.
  static void back<T>([T? result]) => navigatorKey.currentState?.pop(result);

  /// Push named route.
  static Future<T?>? toNamed<T>(String routeName, {Object? arguments}) =>
      navigatorKey.currentState?.pushNamed<T>(routeName, arguments: arguments);

  /// Replace with named route.
  static Future<T?>? offNamed<T extends Object?>(String routeName,
          {Object? arguments}) =>
      navigatorKey.currentState?.pushReplacementNamed<T, T>(
        routeName,
        arguments: arguments,
      );

  /// Pop until predicate.
  static void backUntil(bool Function(Route<dynamic>) predicate) =>
      navigatorKey.currentState?.popUntil(predicate);

  /// Get current context (nullable).
  static BuildContext? get context => navigatorKey.currentContext;
}

/// ============================================================================
/// 2. BASE CONTROLLER
/// ============================================================================

/// Base class for all Neuron controllers.
///
/// Controllers in Neuron serve as the business logic layer,
/// managing state (signals) and operations. They extend [NeuronController]
/// to get automatic disposal and lifecycle hooks.
///
/// ## Lifecycle
///
/// Controllers have two lifecycle hooks:
/// - [onInit]: Called once after the controller is registered via [Neuron.install] or [Neuron.ensure]
/// - [onClose]: Called before the controller is disposed via [Neuron.uninstall]
///
/// ## Auto-disposal
///
/// Any signal that calls [SignalBinding.bind] with the controller will be
/// automatically disposed when the controller is disposed:
///
/// ```dart
/// class MyController extends NeuronController {
///   late final count = Signal<int>(0).bind(this);
///   late final doubled = Computed<int>(() => count.val * 2, [count]).bind(this);
///
///   @override
///   void onInit() {
///     print('Controller initialized');
///   }
///
///   @override
///   void onClose() {
///     print('Controller disposed');
///   }
/// }
/// ```
///
/// ## Static Init Pattern
///
/// The recommended pattern is to provide a static getter:
///
/// ```dart
/// static MyController get init => Neuron.ensure<MyController>(() => MyController());
/// ```
///
/// This ensures the controller is created once and reused across the app.
///
/// ## Lifecycle
///
/// - [onInit]: Called when the controller is first created.
/// - [onClose]: Called when the controller is disposed.
///
/// ## Side Effects
///
/// Use [effect] to run code in response to signal changes.
///
/// ```dart
/// @override
/// void onInit() {
///   effect(() {
///     print('Count changed: ${count.value}');
///   }, [count]);
/// }
/// ```
///
/// See also:
/// - [Neuron] - Service locator for managing controllers
/// - [SignalBinding] - Extension for auto-disposal
abstract class NeuronController {
  /// Called once after the controller is installed via [Neuron.install] or [Neuron.ensure].
  void onInit() {}

  /// Called right before the controller is disposed.
  void onClose() {}

  /// Internally tracked notifiers for auto-dispose.
  final List<Disposable> _disposables = [];

  /// Internal helper to register a notifier for disposal.
  void _autoDispose(Disposable n) => _disposables.add(n);

  /// Run a side effect whenever dependencies change.
  ///
  /// The effect runs immediately and whenever any dependency changes.
  /// Effects are automatically cleaned up when the controller is disposed.
  ///
  /// Example:
  /// ```dart
  /// class MyController extends NeuronController {
  ///   late final count = Signal<int>(0).bind(this);
  ///   late final name = Signal<String>('').bind(this);
  ///
  ///   @override
  ///   void onInit() {
  ///     // Log whenever count or name changes
  ///     effect(() {
  ///       print('State: count=${count.val}, name=${name.val}');
  ///     }, [count, name]);
  ///
  ///     // Save to storage when count changes
  ///     effect(() {
  ///       storage.save('count', count.val);
  ///     }, [count]);
  ///   }
  /// }
  /// ```
  void effect(
    void Function() callback,
    List<NeuronAtom> dependencies, {
    bool fireImmediately = true,
  }) {
    if (fireImmediately) {
      callback();
    }

    final listeners = <VoidCallback>[];
    for (final dep in dependencies) {
      void listener() => callback();
      listeners.add(listener);
      dep.addListener(listener);
    }

    // Store effect disposer for cleanup
    _autoDispose(_EffectDisposer(dependencies, listeners));
  }

  /// Disposes all registered notifiers and calls [onClose].
  @nonVirtual
  void dispose() {
    onClose();
    for (final d in _disposables) {
      d.dispose();
    }
    _disposables.clear();
  }
}

/// ============================================================================
/// 3. SIGNAL BINDING EXTENSION
/// ============================================================================

/// Extension to make a notifier auto-disposed with its controller.
extension SignalBinding<T extends NeuronAtom<S>, S> on T {
  /// Registers this notifier to be disposed with [parent].
  ///
  /// Example:
  /// ```dart
  /// class MyController extends NeuronController {
  ///   late final count = Signal<int>(0).bind(this);
  /// }
  /// ```
  T bind(NeuronController parent) {
    parent._autoDispose(this);

    final registry = NeuronDebugRegistry.instance;
    final shouldRegister = registry.isEnabled;
    final legacyDevTools = SignalDevTools().isEnabled;

    if (shouldRegister || legacyDevTools) {
      final id = registry.registerNotifier(
        controller: parent,
        notifier: this,
        debugLabel: _resolveDebugLabel(),
        kind: _resolveKind(),
      );

      if (legacyDevTools) {
        SignalDevTools().register(id, this);
      }
    }

    return this;
  }

  String _resolveKind() {
    if (this is Computed) return 'computed';
    if (this is AsyncSignal) return 'async';
    return 'signal';
  }

  String? _resolveDebugLabel() {
    if (this is Signal) {
      return (this as Signal).debugLabel;
    }
    if (this is AsyncSignal) {
      return (this as AsyncSignal).debugLabel;
    }
    return null;
  }
}

/// ============================================================================
/// 4. SLOT WIDGETS (BINDING SIGNALS TO UI)
/// ============================================================================

/// Connects a [ValueListenable] (signal) to the UI and rebuilds when it changes.
///
/// [Slot] is the primary widget for binding signals to UI in Neuron.
/// It uses [ValueListenableBuilder] internally for efficient, granular rebuilds.
///
/// ## Basic Usage
///
/// ```dart
/// Slot<int>(
///   connect: controller.count,
///   to: (context, value) => Text('Count: $value'),
/// )
/// ```
///
/// ## Multiple Signals
///
/// To listen to multiple signals, nest Slot widgets:
///
/// ```dart
/// Slot<int>(
///   connect: controller.count,
///   to: (ctx, count) => Slot<String>(
///     connect: controller.name,
///     to: (ctx, name) => Text('$name: $count'),
///   ),
/// )
/// ```
///
/// ## With Static Children
///
/// Use the [child] parameter to avoid rebuilding static widgets:
///
/// ```dart
/// Slot<int>(
///   connect: controller.count,
///   to: (ctx, val) => Column(
///     children: [Text('Count: $val'), child!],
///   ),
///   child: ElevatedButton(
///     onPressed: () {},
///     child: Text('Static Button'),
///   ),
/// )
/// ```
///
/// **Performance**: Only the widget returned by [to] is rebuilt when the
/// signal changes. Sibling widgets are not affected.
///
/// See also:
/// - [AsyncSlot] - For async signals with loading/error states
/// - [Signal] - Basic reactive value
/// - [Computed] - Derived values
/// A widget that rebuilds when a [Signal] or [Computed] changes.
///
/// This is the primary widget for binding signals to the UI.
///
/// ## Basic Usage
///
/// ```dart
/// final count = Signal(0);
///
/// Slot(
///   connect: count,
///   to: (context, value) => Text('Count: $value'),
/// )
/// ```
///
/// ## With Computed Signals
///
/// ```dart
/// final count = Signal(0);
/// final doubleCount = Computed(() => count.value * 2);
///
/// Slot(
///   connect: doubleCount,
///   to: (context, value) => Text('Double: $value'),
/// )
/// ```
class Slot<T> extends StatefulWidget {
  /// The signal to listen to.
  final NeuronAtom<T> connect;

  /// The builder function.
  final Widget Function(BuildContext context, T value) to;

  /// Optional child widget for optimization (not currently used in builder, but good practice).
  final Widget? child;

  const Slot({
    super.key,
    required this.connect,
    required this.to,
    this.child,
  });

  @override
  State<Slot<T>> createState() => _SlotState<T>();
}

class _SlotState<T> extends State<Slot<T>> {
  late T _value;
  VoidCallback? _cancel;

  @override
  void initState() {
    super.initState();
    _value = widget.connect.value;
    _subscribe();
  }

  void _subscribe() {
    _cancel = widget.connect.subscribe(() {
      if (mounted) {
        setState(() {
          _value = widget.connect.value;
        });
      }
    });
  }

  @override
  void didUpdateWidget(Slot<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.connect != oldWidget.connect) {
      _cancel?.call();
      _value = widget.connect.value;
      _subscribe();
    }
  }

  @override
  void dispose() {
    _cancel?.call();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.to(context, _value);
  }
}

/// A widget that rebuilds when an [AsyncSignal] changes.
///
/// Handles the different states of an [AsyncSnapshot]: data, error, and loading.
///
/// ## Basic Usage
///
/// ```dart
/// final user = AsyncSignal<User>(() => fetchUser());
///
/// AsyncSlot(
///   connect: user,
///   onData: (context, data) => UserProfile(user: data),
///   onLoading: (context) => const CircularProgressIndicator(),
///   onError: (context, error) => Text('Error: $error'),
/// )
/// ```
class AsyncSlot<T> extends StatefulWidget {
  /// The async signal to listen to.
  final AsyncSignal<T> connect;

  /// Builder for the data state.
  final Widget Function(BuildContext context, T data) onData;

  /// Builder for the error state.
  final Widget Function(BuildContext context, Object error)? onError;

  /// Builder for the loading state.
  final Widget Function(BuildContext context)? onLoading;

  const AsyncSlot({
    super.key,
    required this.connect,
    required this.onData,
    this.onError,
    this.onLoading,
  });

  @override
  State<AsyncSlot<T>> createState() => _AsyncSlotState<T>();
}

class _AsyncSlotState<T> extends State<AsyncSlot<T>> {
  late AsyncSnapshot<T> _snapshot;
  VoidCallback? _cancel;

  @override
  void initState() {
    super.initState();
    _snapshot = widget.connect.value;
    _subscribe();
  }

  void _subscribe() {
    _cancel = widget.connect.subscribe(() {
      if (mounted) {
        setState(() {
          _snapshot = widget.connect.value;
        });
      }
    });
  }

  @override
  void didUpdateWidget(AsyncSlot<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.connect != oldWidget.connect) {
      _cancel?.call();
      _snapshot = widget.connect.value;
      _subscribe();
    }
  }

  @override
  void dispose() {
    _cancel?.call();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_snapshot.hasError) {
      return widget.onError?.call(context, _snapshot.error!) ??
          Center(
            child: Text(
              "Error: ${_snapshot.error}",
              style: const TextStyle(color: Colors.red),
            ),
          );
    }
    if (_snapshot.connectionState == ConnectionState.waiting) {
      return widget.onLoading?.call(context) ??
          const Center(child: CircularProgressIndicator());
    }
    if (_snapshot.hasData) {
      return widget.onData(context, _snapshot.data as T);
    }
    return const SizedBox.shrink();
  }
}

/// ============================================================================
/// 5. APP WRAPPER
/// ============================================================================

/// Simple [MaterialApp] wrapper that wires Neuron's [Neuron.navigatorKey].
///
/// NeuronApp is a convenience wrapper that automatically sets up
/// the navigator key for context-less navigation.
///
/// Example:
/// ```dart
/// void main() {
///   runApp(NeuronApp(home: HomePage()));
/// }
/// ```
class NeuronApp extends StatefulWidget {
  final Widget? home;
  final String? title;
  final ThemeData? theme;
  final ThemeData? darkTheme;
  final ThemeMode? themeMode;
  final Map<String, WidgetBuilder>? routes;
  final String? initialRoute;
  final RouteFactory? onGenerateRoute;
  final RouteFactory? onUnknownRoute;
  final bool debugShowCheckedModeBanner;

  /// Enable SignalDevTools for debugging (default: true in debug mode)
  final bool enableDevTools;

  /// Maximum events to store in DevTools (default: 500)
  final int maxDevToolsEvents;

  /// Auto-open the debug dashboard in a desktop browser (optional).
  final bool autoOpenDevDashboard;

  const NeuronApp({
    super.key,
    this.home,
    this.title,
    this.theme,
    this.darkTheme,
    this.themeMode,
    this.routes,
    this.initialRoute,
    this.onGenerateRoute,
    this.onUnknownRoute,
    this.debugShowCheckedModeBanner = false,
    this.enableDevTools = kDebugMode,
    this.maxDevToolsEvents = 500,
    this.autoOpenDevDashboard = false,
  });

  @override
  State<NeuronApp> createState() => _NeuronAppState();
}

class _NeuronAppState extends State<NeuronApp> {
  String? _lastLog;
  DateTime? _lastLogAt;

  @override
  void initState() {
    super.initState();

    _logDevTools(
      'NeuronApp initState - enableDevTools: ${widget.enableDevTools}',
    );

    // Initialize DevTools tracking if enabled
    if (widget.enableDevTools) {
      _logDevTools(
        'DevTools enabled (maxEvents: ${widget.maxDevToolsEvents}, '
        'autoOpenDashboard: ${widget.autoOpenDevDashboard})',
        level: 'start',
      );
      SignalDevTools().setEnabled(true);
      SignalDevTools().setMaxEvents(widget.maxDevToolsEvents);
      NeuronDebugRegistry.instance.enable();
      NeuronDebugRegistry.instance.historyLimit = widget.maxDevToolsEvents;

      // Start appropriate DevTools based on platform
      _startDevTools();
    } else {
      _logDevTools('DevTools disabled (enableDevTools=false)');
    }
  }

  Future<void> _startDevTools() async {
    _logDevTools('Starting debug server (requested port: 9090)...');
    // Unified debug server (HTTP + WebSocket)
    try {
      final port = await NeuronDebugServer.instance.start(
        port: 9090,
        openDashboard: widget.autoOpenDevDashboard,
      );
      _logDevTools(
        'Debug server ready on ws://localhost:$port '
        '(dashboard at http://localhost:$port/ui). '
        'Waiting for DevTools to connect...',
        level: 'ready',
      );
    } catch (e, stack) {
      _logDevTools('Debug server failed to start: $e', level: 'error');
      if (kDebugMode) {
        debugPrint(stack.toString());
      }
    }
  }

  void _logDevTools(String message, {String level = 'info'}) {
    final prefix = switch (level) {
      'start' => '🚀',
      'ready' => '✅',
      'warn' => '⚠️',
      'error' => '❌',
      'connect' => '🔌',
      _ => '🧠',
    };
    final line = '$prefix [NeuronDevTools] $message';
    // Skip duplicates that arrive too quickly (e.g., hot reload bouncing).
    if (_lastLog == line &&
        _lastLogAt != null &&
        DateTime.now().difference(_lastLogAt!) < const Duration(seconds: 1)) {
      return;
    }
    _lastLog = line;
    _lastLogAt = DateTime.now();
    debugPrint(line); // visible in Flutter console
    developer.log(message, name: 'NeuronDevTools', level: 0);
  }

  @override
  Widget build(BuildContext context) {
    // If home is provided, remove "/" from routes to avoid conflict
    final effectiveRoutes = widget.routes ?? {};
    final cleanRoutes = widget.home != null
        ? (Map<String, WidgetBuilder>.from(effectiveRoutes)
          ..remove(Navigator.defaultRouteName))
        : effectiveRoutes;

    return MaterialApp(
      navigatorKey: Neuron.navigatorKey,
      home: widget.home,
      title: widget.title ?? 'Neuron App',
      theme: widget.theme,
      darkTheme: widget.darkTheme,
      themeMode: widget.themeMode,
      routes: cleanRoutes,
      initialRoute: widget.initialRoute,
      onGenerateRoute: widget.onGenerateRoute,
      onUnknownRoute: widget.onUnknownRoute,
      debugShowCheckedModeBanner: widget.debugShowCheckedModeBanner,
    );
  }
}
