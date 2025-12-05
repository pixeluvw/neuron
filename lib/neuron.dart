/// Neuron - Signal/Slot State Management for Flutter
///
/// A powerful, clean reactive state management solution
/// signal/slot mechanism. Features include:
///
/// - **Clean Syntax**: Signal/Slot pattern with `emit()` and `connect()`
/// - **StatelessWidget Only**: No StatefulWidget boilerplate
/// - **Controller Pattern**: `static get init => Neuron.ensure(() => MyController())`
/// - **Advanced Features**: Middleware, persistence, time-travel debugging
///
///
/// ## Quick Start
///
/// ```dart
/// // 1. Create a controller
/// class CounterController extends NeuronController {
///   late final count = Signal<int>(0).bind(this);
///   late final doubled = Computed<int>(() => count.val * 2, [count]).bind(this);
///
///   void increment() => count.emit(count.val + 1);
///
///   static CounterController get init =>
///       Neuron.ensure<CounterController>(() => CounterController());
/// }
///
/// // 2. Use in a StatelessWidget
/// class CounterPage extends StatelessWidget {
///   @override
///   Widget build(BuildContext context) {
///     final c = CounterController.init;
///
///     return Scaffold(
///       body: Center(
///         child: Column(
///           children: [
///             Slot<int>(
///               connect: c.count,
///               to: (context, value) => Text('Count: $value'),
///             ),
///             Slot<int>(
///               connect: c.doubled,
///               to: (context, value) => Text('Doubled: $value'),
///             ),
///             ElevatedButton(
///               onPressed: c.increment,
///               child: Text('Increment'),
///             ),
///           ],
///         ),
///       ),
///     );
///   }
/// }
///
/// // 3. Run app
/// void main() {
///   runApp(NeuronApp(home: CounterPage()));
/// }
/// ```
///
/// ## Features
///
/// ### Signals
/// - `Signal<T>` - Basic reactive value
/// - `AsyncSignal<T>` - Async operations with loading/error states
/// - `Computed<T>` - Derived values that auto-update
/// - `ComputedAsync<T>` - Async computed values
/// - `UndoableSignal<T>` - Undo/redo support
/// - `FormSignal<T>` - Form fields with validation
/// - `ListSignal<E>` - Reactive lists with mutation methods
/// - `MapSignal<K,V>` - Reactive maps
/// - `SetSignal<E>` - Reactive sets
///
/// ### Rate Limiting
/// - `DebouncedSignal` - Delay emissions until quiet period
/// - `ThrottledSignal` - Limit emission frequency
/// - `DistinctSignal` - Filter duplicate values
///
/// ### UI Binding
/// - `Slot<T>` - Connect signal to widget
/// - `AsyncSlot<T>` - Connect async signal to widget
/// - `SelectSlot<T,S>` - Granular rebuilds with selectors
/// - `FormSlot<T>` - Reactive form handling with animations
/// - `MorphSlot<T>` - Shape/widget morphing animations
/// - `IconMorphSlot<T>` - Icon morphing transitions
/// - `ShapeMorphSlot<T>` - Geometric shape morphing
/// - `AnimatedSlot<T>` - Auto-animated value changes
/// - `ConditionalSlot<T>` - Show/hide based on condition
/// - `MultiSlot2/3/4/5` - Connect multiple signals at once
/// - `TransitionSlot<T>` - Page transitions with effects
/// - `DebounceSlot<T>` - Debounced rebuilds
/// - `ThrottleSlot<T>` - Throttled rebuilds
/// - `MemoizedSlot<T>` - Cached builds with custom equality
/// - `LazySlot<T>` - Lazy build on first change
///
/// ### Middleware
/// - `LoggingMiddleware` - Log value changes
/// - `ValidationMiddleware` - Validate before emit
/// - `ClampMiddleware` - Clamp numeric values
/// - `TransformMiddleware` - Transform values
/// - `SanitizationMiddleware` - Sanitize strings
///
/// ### Persistence
/// - `PersistentSignal` - Auto-save/load
/// - `JsonPersistence` - JSON serialization
/// - `SimplePersistence` - String-based storage
/// - `MemoryPersistence` - In-memory (testing)
///
/// ### Effects & Reactions
/// - `effect()` - Run side effects on signal changes
/// - `SignalReaction` - Side effects on changes
/// - `SignalTransaction` - Batch updates
/// - `SignalAction` - Async operations with state
/// - `batch()` - Batch multiple signal updates
///
/// ### Validation
/// - `Validators.required()` - Required field
/// - `Validators.email()` - Email validation
/// - `Validators.minLength()` - Minimum length
/// - `Validators.maxLength()` - Maximum length
/// - `Validators.pattern()` - Regex pattern
/// - `Validators.min()` - Minimum value
/// - `Validators.max()` - Maximum value
/// - `Validators.custom()` - Custom validation
///
/// ### DevTools
/// - `SignalDevTools` - Time-travel debugging
/// - Event tracking and history
/// - State inspection and export
///
/// ### Navigation
/// - `Neuron.to(page)` - Push page
/// - `Neuron.off(page)` - Replace page
/// - `Neuron.back()` - Pop page
/// - `Neuron.toNamed(route)` - Named routes
///
library neuron;

// Core - Service locator, controller, and base slots
export 'src/neuron_core.dart';

// Atom - Base reactive primitive
export 'src/neuron_atom.dart';

// Signals - Reactive primitives (Signal, AsyncSignal, Computed)
export 'src/neuron_signals.dart';

// Extensions - Advanced signals, middleware, persistence, UI slots
export 'src/neuron_extensions.dart';

// Navigation
export 'src/neuron_navigation.dart';

// Debug server
export 'src/debug/index.dart';
