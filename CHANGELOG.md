# Changelog

All notable changes to the Neuron package will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-11-21

### Added
- Initial release of Neuron state management framework
- Core reactive primitives: `Signal<T>`, `AsyncSignal<T>`, `Computed<T>`
- Specialized collection signals: `ListSignal<E>`, `MapSignal<K,V>`, `SetSignal<E>`
- Rate limiting signals: `DebouncedSignal`, `ThrottledSignal`, `DistinctSignal`
- Middleware system with built-in middlewares:
  - `LoggingMiddleware` - Log value changes
  - `ValidationMiddleware` - Validate before emit
  - `ClampMiddleware` - Clamp numeric values
  - `TransformMiddleware` - Transform values
  - `SanitizationMiddleware` - Sanitize strings
- Persistence adapters:
  - `PersistentSignal` - Auto-save/load
  - `JsonPersistence` - JSON serialization
  - `SimplePersistence` - String-based storage
  - `MemoryPersistence` - In-memory (testing)
- Effects and reactions:
  - `SignalReaction` - Side effects on changes
  - `SignalTransaction` - Batch updates
  - `SignalAction` - Async operations with state
- DevTools integration:
  - `SignalDevTools` - Time-travel debugging
  - Event tracking and history
  - State inspection and export
- Widget integration:
  - `Slot<T>` - Connect signals to UI
  - `AsyncSlot<T>` - Handle async states
  - `NeuronApp` - MaterialApp wrapper
- Service locator:
  - `Neuron` - Global controller registry
  - `NeuronController` - Base controller with lifecycle
  - Auto-disposal with `.bind()`
- Context-less navigation:
  - `Neuron.to()`, `Neuron.off()`, `Neuron.back()`
  - `Neuron.toNamed()`, `Neuron.offNamed()`
- Utility methods via `SignalUtils`
- Extension methods on signals
- Comprehensive example app
- Full documentation and README

### Design Philosophy
- Signal/Slot terminology and concepts
- StatelessWidget-only approach (no StatefulWidget)
- Static `init` pattern for controllers
- Clean, predictable API
- Type-safe and compile-time checked

## [1.1.0] - 2025-12-05

### Added
- **Documentation**: Comprehensive Dartdoc comments with usage examples for all public APIs.
- **DevTools Auto-Registration**: Signals bound to a controller with `.bind(this)` are now automatically registered with DevTools.
- **Unified Debug Server**: New WebSocket + HTTP debug server for better tooling integration.
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
- **DevTools Enhancements**:
  - Event filtering by type and signal ID
  - Time range queries
  - Custom event recording
  - Checkpoint creation and restoration
  - Snapshot comparison
  - Activity statistics
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
- Enhanced DevTools features
- Performance optimizations
- More comprehensive tests
- Create Dartdoc reference documentation

---

For more information, see the [README](README.md).
