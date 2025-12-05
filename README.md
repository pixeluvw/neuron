# Neuron

**Signal/Slot Reactive State Management for Flutter**

Neuron is a powerful, elegant reactive state management solution built around the Signal/Slot pattern. Designed for simplicity, performance, and exceptional developer experience.

[![Tests](https://img.shields.io/badge/tests-73%20passing-brightgreen)](test/)
[![Coverage](https://img.shields.io/badge/coverage-100%25-brightgreen)](test/)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

## 🧠 What is Neuron?

Neuron brings **reactive programming** to Flutter with an intuitive Signal/Slot architecture. Think of **Signals** as reactive data containers that automatically notify their listeners when values change, and **Slots** as UI components that automatically rebuild when connected signals update.

### The Signal/Slot Philosophy

**Signals** are reactive values that emit changes:
```dart
final count = Signal<int>(0);
count.emit(5);  // Emits new value
```

**Slots** listen to signals and rebuild UI automatically:
```dart
Slot<int>(
  connect: count,
  to: (context, value) => Text('Count: $value'),
)
```

This pattern eliminates `setState()`, `StreamBuilder`, and `StatefulWidget` boilerplate while providing fine-grained reactivity.

## ✨ Features

### 🎯 Core Reactive System
- **Signal/Slot Pattern**: Clean `emit()` and `connect()` API
- **Automatic UI Updates**: Connect signals to widgets, updates happen automatically
- **Fine-Grained Reactivity**: Only connected widgets rebuild, not entire trees
- **Type-Safe**: Full Dart type safety throughout
- **Memory Efficient**: Automatic cleanup and lifecycle management

### 🚀 Developer Experience
- **StatelessWidget Only**: Write clean functional components
- **Zero Boilerplate**: No `setState()`, no `StreamBuilder`, no `Consumer` wrappers
- **Service Locator Built-in**: Controller lifecycle managed automatically
- **Hot Reload Friendly**: Preserves state during development
- **Intuitive API**: Learn once, productive immediately

### ⚡ Advanced Signals
- **Computed Signals**: Derived values that auto-update from dependencies
- **Async Signals**: Built-in loading/error/data states for async operations
- **Collection Signals**: Reactive lists, maps, and sets with mutation methods
- **Rate-Limited Signals**: Debounce, throttle, and distinct filtering
- **Middleware Signals**: Transform, validate, and control value flow

### 🔧 Production-Ready Features
- **10+ Built-in Middlewares**: Validation, logging, clamping, sanitization, etc.
- **5 Persistence Adapters**: Auto-save/load with memory, JSON, binary, encrypted, versioned storage
- **Time-Travel Debugging**: Complete history tracking and state inspection
- **DevTools Integration**: Visual debugging and performance monitoring
- **Transaction Support**: Batch multiple updates atomically
- **Effect System**: Side effects and reactions to signal changes

## 📦 Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  neuron:
    git:
      url: https://github.com/pixeluvw/Neuron-Framework
```

Then run:
```bash
flutter pub get
```

## 🚀 Quick Start

### 1. Create a Controller

```dart
import 'package:neuron/neuron.dart';

class CounterController extends NeuronController {
  late final count = Signal<int>(0).bind(this);
  late final doubled = Computed<int>(
    () => count.val * 2,
    [count],
  ).bind(this);

  void increment() => count.emit(count.val + 1);
  void decrement() => count.emit(count.val - 1);

  static CounterController get init =>
      Neuron.ensure<CounterController>(() => CounterController());
}
```

### 2. Use in StatelessWidget

```dart
class CounterPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = CounterController.init;
    return Scaffold(
      body: Column(
        children: [
          Slot<int>(connect: c.count, to: (ctx, val) => Text('Count: $val')),
          ElevatedButton(onPressed: c.increment, child: Text('Increment')),
        ],
      ),
    );
  }
}
```

### 3. Run Your App

```dart
void main() => runApp(NeuronApp(home: CounterPage()));
```

## 📚 Core Concepts

### Signals & Slots

**Signals** are reactive data containers. **Slots** are widgets that rebuild when signals change.

```dart
// Signal
final count = Signal<int>(0);

// Slot
Slot<int>(
  connect: count,
  to: (context, value) => Text('Value: $value'),
)
```

### Computed Signals

Computed signals automatically recalculate when dependencies change:

```dart
final width = Signal<double>(10);
final height = Signal<double>(20);
final area = Computed<double>(
  () => width.val * height.val,
  [width, height],
);
```

### AsyncSignal

Handles asynchronous operations with built-in loading, error, and data states.

```dart
final user = AsyncSignal<User>(null);

// Execute async operation
Future<void> loadUser() async {
  await user.execute(() => api.getUser());
}

// In UI
AsyncSlot<User>(
  connect: user,
  onData: (ctx, user) => Text(user.name),
  onLoading: (ctx) => CircularProgressIndicator(),
  onError: (ctx, error) => Text('Error: $error'),
)
```

### Collection Signals

Reactive Lists, Maps, and Sets.

```dart
final items = ListSignal<String>([]);
items.add('Hello');      // Emits change
items.remove('Hello');   // Emits change
```

### Rate Limiting

Control emission frequency with `DebouncedSignal`, `ThrottledSignal`, and `DistinctSignal`.

```dart
final search = Signal<String>('');
final debounced = DebouncedSignal(search, Duration(milliseconds: 300));
```

### Middleware

Intercept signal emissions to transform, validate, or control value flow.

```dart
final age = MiddlewareSignal<int>(
  0,
  middlewares: [
    ClampMiddleware(min: 0, max: 120),
    LoggingMiddleware(label: 'age'),
  ],
);
```

### Persistence

Automatically save and restore signal state.

```dart
final theme = PersistentSignal<String>(
  'light',
  persistence: SimplePersistence(key: 'theme', ...),
);
```

### Animations

`AnimatedSlot`, `AnimatedFormSlot`, and `MorphSlot` provide beautiful reactive animations.

```dart
AnimatedSlot<int>(
  connect: count,
  effect: SlotEffect.fade | SlotEffect.scale,
  to: (context, value) => Text('$value'),
)
```

## 🛠️ DevTools & Debugging

Neuron includes a powerful DevTools integration for debugging and performance monitoring.

### Setup

Enable DevTools in your `NeuronApp`:

```dart
void main() {
  runApp(
    NeuronApp(
      enableDevTools: true, // Default in debug mode
      maxDevToolsEvents: 500,
      home: MyApp(),
    ),
  );
}
```

### Features

1.  **Auto-Registration**: Signals bound to a controller with `.bind(this)` are automatically registered with DevTools.
2.  **Signal Inspector**: View all registered signals, current values, and listener counts.
3.  **Time Travel**: Inspect history and restore previous states.
4.  **Performance Monitor**: Track signal emit rates and build times.

### Debug Server

Neuron starts a unified Debug Server (WebSocket + HTTP) on port `9090` (or next available).
- **Dashboard**: `http://localhost:9090/ui`
- **API**: `/snapshot`, `/events`, `/health`

## 📊 Performance

Neuron is designed for high performance, outperforming many other state management solutions in benchmarks.

| Benchmark | Neuron | GetX | Riverpod | Bloc | Provider |
|-----------|--------|------|----------|------|----------|
| **Update Time** | **0.15ms** | 0.18ms | 0.25ms | 0.36ms | 0.42ms |
| **Memory/Signal** | **2.1KB** | 2.8KB | 3.5KB | 4.2KB | 3.1KB |
| **Lines of Code** | **12** | 15 | 28 | 45 | 22 |

*Benchmarks run on Android Emulator (API 33), Flutter 3.10. See `benchmark/` for details.*

## 🛠️ CLI Tool

Neuron includes a CLI for project scaffolding and code generation.

```bash
# Install
dart pub global activate --source path packages/neuron_cli

# Create Project
neuron create my_app

# Generate Screen
neuron g s settings

# Generate Controller
neuron g c auth
```

## 🤝 Contributing

Contributions welcome! Please read [CONTRIBUTING.md](CONTRIBUTING.md) first.

## 📄 License

MIT License - see [LICENSE](LICENSE) file for details.
