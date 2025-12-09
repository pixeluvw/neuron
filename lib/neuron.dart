/// # Neuron - Signal/Slot State Management for Flutter
///
/// ═══════════════════════════════════════════════════════════════════════════════
///
/// Neuron is a powerful, elegant reactive state management library built around
/// the Signal/Slot pattern. Write clean, maintainable Flutter apps with minimal
/// boilerplate.
///
/// ## Philosophy
///
/// **"Write less, do more, stay reactive."**
///
/// - **Signal**: A reactive value container that notifies when changed
/// - **Slot**: A widget that rebuilds when connected signal emits
/// - **Controller**: Business logic with auto-disposed signals
///
/// ## Why Neuron?
///
/// - ✅ **Clean Syntax**: `signal()`, `computed()`, `$()` factory methods
/// - ✅ **StatelessWidget Only**: No boilerplate, just reactive bindings
/// - ✅ **Auto-disposal**: Signals disposed with controllers
/// - ✅ **Type-safe**: Full Dart 3 pattern matching support
/// - ✅ **Feature-rich**: Persistence, middleware, DevTools, animations
///
/// ## Quick Start
///
/// ### Step 1: Create a Controller
///
/// ```dart
/// class CounterController extends NeuronController {
///   // Choose your syntax:
///   // late final count = Signal<int>(0).bind(this);  // Verbose
///   late final count = signal(0);                     // Clean (recommended)
///   // late final count = $(0);                       // Ultra-short
///
///   // Computed values auto-track dependencies
///   late final doubled = computed(() => count.val * 2);
///   late final isEven = computed(() => count.val % 2 == 0);
///
///   void increment() => count.emit(count.val + 1);
///
///   // Singleton pattern for DI
///   static CounterController get init =>
///       Neuron.ensure<CounterController>(() => CounterController());
/// }
/// ```
///
/// ### Step 2: Connect to UI
///
/// ```dart
/// class CounterPage extends StatelessWidget {
///   @override
///   Widget build(BuildContext context) {
///     final c = CounterController.init;  // Get or create controller
///
///     return Scaffold(
///       body: Column(
///         children: [
///           // Signal → Slot binding
///           Slot<int>(
///             connect: c.count,
///             to: (ctx, val) => Text('Count: $val'),
///           ),
///           Slot<int>(
///             connect: c.doubled,
///             to: (ctx, val) => Text('Doubled: $val'),
///           ),
///           ElevatedButton(
///             onPressed: c.increment,
///             child: Text('Increment'),
///           ),
///         ],
///       ),
///     );
///   }
/// }
/// ```
///
/// ### Step 3: Run App
///
/// ```dart
/// void main() {
///   runApp(NeuronApp(home: CounterPage()));
/// }
/// ```
///
/// ## Feature Overview
///
/// ### Signal Types
///
/// | Type              | Description                                    |
/// |-------------------|------------------------------------------------|
/// | `Signal<T>`       | Core reactive value                            |
/// | `AsyncSignal<T>`  | Async operations (loading/data/error)          |
/// | `Computed<T>`     | Derived values with auto-tracking              |
/// | `ListSignal<E>`   | Reactive list with mutation methods            |
/// | `MapSignal<K,V>`  | Reactive map                                   |
/// | `SetSignal<E>`    | Reactive set                                   |
/// | `UndoableSignal`  | Undo/redo support                              |
/// | `FormSignal<T>`   | Form fields with validation                    |
///
/// ### Slot Widgets
///
/// | Widget            | Description                                    |
/// |-------------------|------------------------------------------------|
/// | `Slot<T>`         | Basic signal-to-widget binding                 |
/// | `AsyncSlot<T>`    | Async signal with loading/error states         |
/// | `AnimatedSlot<T>` | Auto-animated value transitions                |
/// | `SpringSlot<T>`   | Physics-based spring animations                |
/// | `MorphSlot<T>`    | Smooth widget morphing                         |
/// | `PulseSlot<T>`    | Attention-grabbing pulse effects               |
/// | `ShimmerSlot<T>`  | Loading shimmer animations                     |
/// | `MultiSlot`       | Combine 2-6 signals (type-safe)                |
///
/// ### Rate Limiting
///
/// - `DebouncedSignal` - Delay until quiet period
/// - `ThrottledSignal` - Limit emission frequency
/// - `DistinctSignal` - Filter duplicate values
///
/// ### Middleware & Persistence
///
/// - `LoggingMiddleware` - Log value changes
/// - `ValidationMiddleware` - Validate before emit
/// - `PersistentSignal` - Auto-save to storage
/// - `JsonPersistence` - JSON serialization
///
/// ### Navigation (Context-less)
///
/// ```dart
/// Neuron.to(DetailPage());        // Push
/// Neuron.off(HomePage());         // Replace
/// Neuron.back();                  // Pop
/// Neuron.toNamed('/settings');    // Named route
/// ```
///
/// ### DevTools Integration
///
/// Built-in debugging support:
/// - Signal state inspection
/// - Event history tracking
/// - Time-travel debugging
///
/// ## More Information
///
/// - [README](https://github.com/pixeluvw/neuron) - Full documentation
/// - [CHANGELOG](https://pub.dev/packages/neuron/changelog) - Version history
/// - [Examples](https://github.com/pixeluvw/neuron/tree/master/example) - Sample apps
///
library;

// ═══════════════════════════════════════════════════════════════════════════════
// EXPORTS
// ═══════════════════════════════════════════════════════════════════════════════

/// Core framework: Service locator, controller base, Slot/AsyncSlot widgets
export 'src/neuron_core.dart';

/// Foundation: NeuronAtom base class, Disposable interface
export 'src/neuron_atom.dart';

/// Signals: `Signal<T>`, `AsyncSignal<T>`, `Computed<T>`, `AsyncState<T>`
export 'src/neuron_signals.dart';

/// Extensions: Collection signals, rate limiting, middleware, persistence,
/// effects, DevTools, advanced slots (AnimatedSlot, SpringSlot, etc.)
export 'src/neuron_extensions.dart';

/// Navigation: NeuronRoute, page transitions, middleware
export 'src/neuron_navigation.dart';

/// Debug: Debug server, registry, snapshots for DevTools integration
export 'src/debug/index.dart';
