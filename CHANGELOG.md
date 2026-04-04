# Changelog

All notable changes to the Neuron package will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.6.0] - 2026-04-04

### Added

- **Tagged/Scoped Instances**: The `Neuron` service locator now supports an optional `tag` parameter on `install`, `use`, `ensure`, `isInstalled`, and `uninstall`, enabling multiple instances of the same controller type scoped to different keys.
  - `Neuron.ensure<ChatCtrl>(() => ChatCtrl(roomId), tag: roomId)`
  - `Neuron.use<ChatCtrl>(tag: roomId)`
  - New `Neuron.uninstallAll<T>()` — disposes every instance of a type (all tags).
  - New `Neuron.tagged<T>()` — returns `Map<String?, T>` of all registered instances.
- **PollingSignal\<T\>**: A new signal that wraps `AsyncSignal<T>` with automatic `Timer.periodic` re-execution. Supports `start()`, `stop()`, `pause()`, `resume()`, and `setInterval()`. Timer auto-cancels on dispose.
  - Factory: `pollingSignal<T>(interval: ..., operation: () => ...)` on controllers.
- **Auto-Cleanup `register()`**: New `register<T>(T resource)` method on `NeuronController` that accepts `Timer`, `StreamSubscription`, `ChangeNotifier` (incl. `TextEditingController`), `Disposable`, or `VoidCallback` for automatic cleanup on controller dispose. Resources are disposed in reverse registration order (LIFO).
- **TextSignal**: A `Signal<String>` that stays in bidirectional sync with a `TextEditingController`. Eliminates manual listener wiring and cleanup for text fields.
  - Factory: `textSignal(text: '')` on controllers.
  - Access: `email.val` (string), `email.controller` (for `TextField`), `email.emit('x')` (updates both).

### Changed

- Controller disposal now uses reverse (LIFO) order for `_disposables`, ensuring later-registered resources are cleaned up first.

## [1.5.2] - 2026-03-20

### Documentation

- **Enhanced API Documentation**: Improved inline Dart documentation across core modules with:
  - Expanded usage examples for `NeuronAtom`, `NeuronBatch`, and `NeuronAtomPool`
  - Added performance consideration notes
  - Added lifecycle hook examples
  - Improved parameter documentation with tables for feature summaries
- **Code Examples**: Added more practical code snippets demonstrating:
  - Custom equality usage patterns
  - Value guard implementation
  - Selective listening with `select()`
  - Resource management with lifecycle hooks
  - Batch updates for performance optimization

### Fixed

- **Computed signal listener management**: Fixed memory leak where computed signals only stored a single listener handle, causing stale subscriptions and missed updates. Now each dependency has its own listener handle.
- **Listener notification performance**: Optimized `notifyListeners` to use O(1) set lookups instead of O(n²) containment checks when listeners are modified during iteration.
- **Set equality check**: Replaced manual iteration with `Set.containsAll` for clarity and minor performance improvement.
- **Updated badges**: Corrected test count (214 passing) and coverage (40%) badges in README.

## [1.5.1] - 2026-03-12

### Added
- **NeuronApp Localization Support**: Added `localizationsDelegates` and `supportedLocales` parameters to `NeuronApp`, forwarded to the internal `MaterialApp`.

## [1.5.0] - 2026-03-04

### Added
- **Comprehensive Test Coverage**: Expanded test suite from 77 to 214 tests covering all core modules, navigation, persistence, widgets, and animations.
- **Lazy Computed**: `Computed` signals are now truly lazy. Initial computation is deferred until the first `.value` access, and subsequent dependency changes only mark the signal as stale without eagerly recomputing or wasting CPU cycles.

### Fixed
- **ComputedAsync Dependencies**: Fixed `ComputedAsync` to accept native `NeuronAtom` list dependencies (e.g., `Signal`) instead of requiring Flutter's `Listenable`, resolving an API mismatch.
- **Default Transition Specs**: Fixed `NeuronTransitionSpec` defaults scaling correctly with easeOutCubic curves.

### Documentation
- **Real-World Patterns**: Replaced minimal README examples with robust, production-ready code patterns for Form Handling & Validation, Authentication Flow (with Route Guards), and Pagination & Infinite Scroll.


## [1.4.1] - 2026-03-02

### Fixed
- `batch()` now actually batches and coalesces notifications
- `NeuronAtomPool` O(1) lookup instead of O(n) linear scan
- `AnimatedSlot` listener leak in `transitionBuilder`
- WASM compatibility — conditional `dart:isolate` import

### Changed
- `SignalSelector` uses lazy subscription (subscribe on active, unsubscribe on inactive)
- Split `neuron_slots.dart` into `neuron_slot_effects.dart`, `neuron_animated_slots.dart`, `neuron_multi_slot.dart`

### Removed
- Unused dependencies: `shelf`, `shelf_static`, `web_socket_channel`, `device_info_plus`

## [1.4.0] - 2026-03-01

### Added
- **Multithreading & Vectorization**: Added `IsolateSignal<T, M>` for heavy off-thread computations, enabling concurrent math, filtering, and JSON parsing without blocking the UI thread. Verified SIMD vector processing (`Float32x4List`) compatibility.

### Changed
- **Zero-Cost Abstractions**: Upgraded the fundamental `VoidCallback` listeners within `NeuronAtom` to use Dart 3 `extension types` (`AtomListener`), completely eliminating closure instantiation overhead.
- **Arena Memory Allocation**: Implemented `NeuronAtomPool` to intercept `.dispose()` calls, pushing dead atoms into a free-list registry. Standard instantiations now recycle directly from pooled memory, preventing VM GC thrashing during mass UI updates.
- **Bitmask State**: Compressed `NeuronAtom` booleans into unified integer bitmasks (`_state`) for ultra-fast branch predictions.

## [1.3.4] - 2026-03-01

### Changed
- Streamlined internal architecture for complete and seamless WASM deployment, resolving underlying platform incompatibilities and reducing overall package weight.

## [1.3.3] - 2026-03-01

### Fixed
- **Pub.dev Platform Support**: Resolved a strict static analysis issue where default `dart:io` compiler imports flagged the package as strictly non-WASM compatible. Defaulted platform-specific imports to web-safe stubs, unlocking the verified WebAssembly tier.

## [1.3.2] - 2026-03-01

### Docs
- **Release Polish**: Refined documentation and removed internal metrics references from the README.

## [1.3.1] - 2026-03-01

### Fixed
- **WASM Compilation**: Modernized conditional imports using `dart.library.js_interop` to correctly isolate `dart:io` symbols from the dart2wasm compiler, restoring full WebAssembly compilation.

## [1.3.0] - 2026-03-01

### Added
- **Web Platform Compatibility**: Completely removed `dart:io` restrictions. Added platform stubs for native compilation support on Flutter Web (`dart2js` & `dart2wasm`).
- **O(1) Collection Mutations**: `ListSignal`, `MapSignal`, and `SetSignal` now feature a high-performance `.mutate((data) { })` callback. This enables in-place data modifications that bypass structural equality clones, unlocking 60FPS streaming for extensive payloads.
- **RAII Finalizers**: `NeuronAtom` instances now natively hook into the Dart VM Garbage Collector. Un-bound, dynamically generated Signals automatically sweeping their `StreamControllers` from memory when abandoned to eliminate lifecycle leaks.

### Changed
- **O(1) Computed Dependencies**: Eliminated `Map` allocations and unique closure creation entirely inside `Computed` evaluation pipelines by migrating to raw structural `Set` caching and class-bound pointers.
- **Lazy Stream Controllers**: `Signal` stream properties are now lazily loaded natively rather than eagerly during object instantiation to drastically cut RAM baseline levels.
- **NeuronAtomBuilder Overhaul**: Prevent anonymous closure spawning during hot-reloads and UI build layouts.
- Formally added Explicit `platforms:` header into `pubspec.yaml`.

## [1.2.5] - 2025-12-10

### Added
- Smart Home screenshots (smart_home_1.png, smart_home_2.png, smart_home_3.png)
- Signal/Slot blueprint diagram for README

### Changed
- Improved email validation example with proper regex in AnimatedFormSlot documentation
- Updated README diagram to use image instead of ASCII art

## [1.2.4] - 2025-12-10

### Changed
- Simplified Signal/Slot connection diagram in README for better rendering

## [1.2.3] - 2025-12-10

### Added
- Smart Home example screenshots in README
- Comprehensive documentation and comments to core files
- HTML section comments in README for better navigation

### Changed
- Improved code formatting across lib and test files

### Fixed
- Escaped angle brackets in doc comments to fix `unintended_html_in_doc_comment` warnings

## [1.2.0] - 2025-12-09

### Added

#### Controller Signal Factory Extensions
New ergonomic syntax for creating signals inside controllers, eliminating boilerplate:

**Option 1: Clean Factory Methods** (`NeuronControllerSignals`)
```dart
class MyController extends NeuronController {
  late final count = signal(0);              // Signal<int>
  late final user = asyncSignal<User>();     // AsyncSignal<User>
  late final doubled = computed(() => count.val * 2);  // Computed<int>
}
```

**Option 2: Ultra-Short Syntax** (`NeuronControllerShorthand`)
```dart
class MyController extends NeuronController {
  late final count = $(0);                   // Signal<int>
  late final user = $async<User>();          // AsyncSignal<User>
  late final doubled = $computed(() => count.val * 2);
}
```

#### Sealed AsyncState Class
- New pure-Dart `AsyncState<T>` sealed class with `AsyncLoading`, `AsyncData`, and `AsyncError` subtypes
- Pattern matching support for exhaustive state handling:
```dart
user.state.when(
  loading: () => print('Loading...'),
  data: (user) => print('Got user: $user'),
  error: (e, st) => print('Error: $e'),
);
```

#### Auto-Tracking Computed Signals
- `Computed<T>` now automatically detects dependencies—no manual dependency list required
- Lazy evaluation: computed values only calculate when accessed
- Error handling: computation errors are captured and accessible via `hasError`, `error`, `stackTrace`
- Circular dependency detection with clear error messages

#### AsyncSignal Improvements
- New `refresh()` method to re-execute the last operation
- `canRefresh` getter to check if refresh is available
- Cleaner API using sealed `AsyncState<T>` internally

#### Unified MultiSlot Widget
- Consolidated `MultiSlot2`, `MultiSlot3`, `MultiSlot4`, `MultiSlot5` into single `MultiSlot` class
- Factory constructors: `MultiSlot.t2()`, `MultiSlot.t3()`, `MultiSlot.t4()`, `MultiSlot.t5()`, `MultiSlot.t6()`
- Dynamic list support: `MultiSlot.list()` for any number of signals

### Changed
- **Signal dependency tracking**: `Signal.value` getter now registers with `_DependencyTracker` for Computed auto-tracking
- **NeuronAtom lifecycle**: Added `@protected` `onActive()` and `onInactive()` lifecycle hooks for subclass customization
- **notifyListeners() optimization**: Avoids list allocation when listeners aren't modified during notification

### Fixed
- **Computed reactivity**: Fixed issue where Computed signals weren't detecting changes to Signal dependencies
- **Deprecation warning**: Replaced `Color.withOpacity()` with `Color.withValues()` in example app

### Documentation
- Comprehensive README rewrite with extensive Signal/Slot examples
- Comparison table vs other state management solutions
- Real-world examples: E-commerce cart, authentication flow, form validation, debounced search
- Added detailed Widget Guide section

## [1.1.13] - 2025-12-07

### Changed
- **NeuronApp Routes**: `NeuronApp.routes` now accepts `List<NeuronRoute>` instead of `Map<String, WidgetBuilder>` for cleaner, GetX-style routing syntax
- **Unified Routing**: Routes defined with `NeuronRoute` now work seamlessly in `NeuronApp`, including path parameters, transitions, guards, and middleware

### Added
- **Middlewares in NeuronApp**: New `middlewares` parameter to add navigation middleware directly to `NeuronApp`
- **Full Transition Support**: All 20+ `NeuronPageTransition` presets (fade, slide, scale, blur, etc.) now work with routes in `NeuronApp`
- **Path Parameters**: Dynamic route segments like `/profile/:id` are fully supported and automatically parsed

### Example
```dart
NeuronApp(
  routes: [
    NeuronRoute(
      name: 'home',
      path: '/',
      builder: (context, params) => const HomePage(),
    ),
    NeuronRoute(
      name: 'profile',
      path: '/profile/:id',
      builder: (context, params) => ProfilePage(id: params['id']),
      transition: NeuronPageTransition.slideUp,
    ),
  ],
  initialRoute: '/',
)
```

## [1.1.12] - 2025-12-06

### Fixed
- **README rendering**: Fixed ASCII diagram that wasn't displaying correctly on pub.dev

## [1.1.11] - 2025-12-06

### Added
- **Numeric Signal Shortcuts**: New extension methods for convenient numeric operations:
  - `inc()` / `dec()` - short aliases for increment/decrement
  - `add(n)` / `sub(n)` - add or subtract custom amounts
  - All work alongside existing `increment()`, `decrement()`, and `emit()` methods

### Documentation
- **Improved Signal/Slot Philosophy**: README now includes step-by-step guide showing how Signals in controllers connect to Slots in widgets with visual diagram
- **Comprehensive AnimatedSlot docs**: All 16 parameters documented with usage tips and best practices
- **AnimatedFormSlot constructor docs**: Added usage examples and best practices for form validation animations
- **Fixed gallery images**: Corrected image ordering in README gallery section

## [1.1.10] - 2025-12-06

### Documentation
- Moved README images to `example/assets` to ensure correct rendering on pub.dev.

## [1.1.9] - 2025-12-06

### Maintenance
- Updated dependencies and documentation.

## [1.1.8] - 2025-12-06

### Maintenance
- General maintenance and package scoring updates.

## [1.1.7] - 2025-12-06

### Documentation
- Added gallery images to README to showcase `AnimatedSlot` features.

## [1.1.6] - 2025-12-06

### Maintenance
- Formatted code to comply with Dart formatter and improve pub.dev score.

## [1.1.5] - 2025-12-05

### Documentation
- Added missing API documentation for `AggregateMiddleware` and `AnimatedErrorMessage`.

## [1.1.4] - 2025-12-05

### Changed
- Changed `AnimatedSlot` default `clipBehavior` to `false` to prevent clipping of shadows and overflowing content by default.

## [1.1.3] - 2025-12-05

### Maintenance
- Updated dependencies to latest versions (`device_info_plus` ^12.3.0, `flutter_lints` ^6.0.0).
- Added `analysis_options.yaml` and resolved all static analysis issues to improve pub.dev score.

## [1.1.2] - 2025-12-05

### Metadata
- Added package topics to `pubspec.yaml` for better discovery on pub.dev.
- Added `CODE_OF_CONDUCT.md`.

## [1.1.1] - 2025-12-05

### Documentation
- Added comprehensive "Widget Guide" to README.md covering `Slot`, `AsyncSlot`, `MultiSlot`, `ConditionalSlot`, and `AnimatedSlot`.

## [1.1.0] - 2025-12-05

### Added
- **Documentation**: Comprehensive Dartdoc comments with usage examples for all public APIs.
- **New Middleware**:
  - `RateLimitMiddleware` - Limits emission frequency
  - `ConditionalMiddleware` - Conditional value emission
  - `HistoryMiddleware` - Track previous values
  - `CoalesceMiddleware` - Prevent null values
  - `AggregateMiddleware` - Combine multiple middlewares
- **New Persistence Adapters**:
  - `BinaryPersistence` - Custom binary serialization
  - `EncryptedPersistence` - Encrypted storage wrapper
  - `VersionedPersistence` - Versioned data with migration support
- **Performance**:
  - Cached computed signals with TTL
  - Lazy signal initialization
  - Collection optimizations (reverse, shuffle, filter)

### Fixed
- **CLI**: Improved dependency injection in generated projects.
- **Analysis**: Resolved all linter warnings and improved code health.

### Planned
- More middleware types
- Additional persistence adapters
- Performance optimizations
- More comprehensive tests
- Create Dartdoc reference documentation

---

For more information, see the [README](README.md).
