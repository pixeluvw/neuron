# Neuron

**Signal/Slot Reactive State Management for Flutter**

Neuron is a powerful, elegant reactive state management solution built around the Signal/Slot pattern. Designed for simplicity, performance, and exceptional developer experience.

[![Pub](https://img.shields.io/pub/v/neuron.svg)](https://pub.dev/packages/neuron)
[![Tests](https://img.shields.io/badge/tests-86%20passing-brightgreen)](test/)
[![Coverage](https://img.shields.io/badge/coverage-100%25-brightgreen)](test/)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![style: flutter_lints](https://img.shields.io/badge/style-flutter__lints-blue)](https://pub.dev/packages/flutter_lints)

---

<!-- ═══════════════════════════════════════════════════════════════════════════════
     SECTION 2: WHY NEURON?
     Explains the philosophy behind Neuron and its key benefits
     ═══════════════════════════════════════════════════════════════════════════════ -->

## 🤔 Why Neuron?

### Neuron's Philosophy

**"Write less, do more, stay reactive."**

Neuron brings the battle-tested **Signal/Slot** pattern from Qt to Flutter. This pattern has powered desktop applications for 30+ years because it's:

- **Intuitive**: Signals emit values, Slots receive them
- **Decoupled**: Signals don't know about Slots, and vice versa
- **Efficient**: Only connected components update
- **Predictable**: Data flows in one direction

### Key Benefits

| Feature | Neuron |
|---------|--------|
| Boilerplate | **Minimal** |
| Learning curve | **Gentle** |
| Type safety | **Excellent** |
| Fine-grained rebuilds | **Yes** |
| Context dependency | **No** |
| Memory management | **Automatic** |
| Async handling | **Built-in** |
| Animations | **Built-in** |

---

<!-- ═══════════════════════════════════════════════════════════════════════════════
     SECTION 3: UNDERSTANDING SIGNALS & SLOTS
     Core concepts - what Signals and Slots are and how they connect
     ═══════════════════════════════════════════════════════════════════════════════ -->

## 🧠 Understanding Signals & Slots

### What is a Signal?

A **Signal** is a reactive container that holds a value and notifies listeners when it changes. Think of it as a "smart variable" that broadcasts its changes.

```dart
// Create a Signal
final count = Signal<int>(0);

// Read the value
print(count.val);  // 0

// Update the value (notifies all listeners)
count.emit(5);     // All listeners receive 5

// Listen to changes
count.addListener(() => print('Changed to: ${count.val}'));
```

### What is a Slot?

A **Slot** is a widget that "plugs into" a Signal and automatically rebuilds when the Signal changes. It's the bridge between your reactive data and the UI.

```dart
Slot<int>(
  connect: count,  // Plug into the Signal
  to: (context, value) => Text('Count: $value'),  // Build UI
)
```

### The Connection

<p align="center">
  <img src="https://raw.githubusercontent.com/pixeluvw/neuron/master/example/assets/signal_slot_diagram.png" width="600" alt="Signal-Slot Connection Diagram"/>
</p>

When you call `count.emit(5)`, **only** the Slot widgets connected to `count` rebuild—not the entire widget tree. This is fine-grained reactivity.

---

<!-- ═══════════════════════════════════════════════════════════════════════════════
     SECTION 4: WHY DEVELOPERS LOVE NEURON
     Showcases the main features with code examples
     ═══════════════════════════════════════════════════════════════════════════════ -->

## ✨ Why Developers Love Neuron

### 1. Zero Boilerplate

```dart
// controller.dart
class CounterController extends NeuronController {
  // Choose your style:
  late final count = Signal<int>(0).bind(this);  // Explicit
  late final count = signal(0);                   // Clean ✨
  late final count = $(0);                        // Ultra-short
  
  void increment() => count.emit(count.val + 1);
  void decrement() => count.emit(count.val - 1);
  
  static CounterController get init => Neuron.ensure(() => CounterController());
}

// widget.dart
Slot<int>(
  connect: CounterController.init.count,
  to: (_, val) => Text('$val'),
)
```

**Result**: Clean, readable, minimal code.

### 2. No BuildContext Required

Access your controllers from anywhere—services, utils, or other controllers:

```dart
// In a service
class AnalyticsService {
  void trackClick() {
    final count = CounterController.init.count.val;
    analytics.log('button_click', {'count': count});
  }
}

// In another controller
class DashboardController extends NeuronController {
  void syncData() {
    final userCount = UserController.init.users.val.length;
    final orderCount = OrderController.init.orders.val.length;
    // No context needed!
  }
}
```

### 3. Built-in Async Handling

No more juggling loading states and error handling:

```dart
class UserController extends NeuronController {
  late final user = asyncSignal<User>();
  
  Future<void> loadUser(String id) async {
    await user.execute(() => api.fetchUser(id));
  }
  
  static UserController get init => Neuron.ensure(() => UserController());
}

// In UI - handles loading, error, and data states automatically
AsyncSlot<User>(
  connect: UserController.init.user,
  onLoading: (_) => CircularProgressIndicator(),
  onError: (_, error) => Text('Error: $error'),
  onData: (_, user) => UserCard(user),
)
```

### 4. Automatic Computed Values

Derived values that automatically update when dependencies change:

```dart
class CartController extends NeuronController {
  late final items = signal<List<CartItem>>([]);
  late final discount = signal<double>(0.0);
  
  // Automatically recalculates when items or discount changes!
  late final total = computed(() {
    final subtotal = items.val.fold(0.0, (sum, item) => sum + item.price);
    return subtotal * (1 - discount.val);
  });
  
  static CartController get init => Neuron.ensure(() => CartController());
}
```

### 5. Beautiful Animations Out of the Box

```dart
AnimatedSlot<int>(
  connect: c.count,
  effect: SlotEffect.scale | SlotEffect.fade,
  curve: Curves.elasticOut,
  to: (_, value) => Text('$value', style: TextStyle(fontSize: 48)),
)
```

---

<!-- ═══════════════════════════════════════════════════════════════════════════════
     SECTION 5: QUICK START GUIDE
     Step-by-step guide to get started with Neuron
     ═══════════════════════════════════════════════════════════════════════════════ -->

## 🚀 Quick Start

### Installation

```bash
flutter pub add neuron
```

### Step 1: Create a Controller

```dart
import 'package:neuron/neuron.dart';

class CounterController extends NeuronController {
  // Option 1: Verbose (explicit)
  late final count = Signal<int>(0).bind(this);
  
  // Option 2: Clean (recommended)
  late final count = signal(0);
  
  // Option 3: Ultra-short
  late final count = $(0);
  
  // Computed values (auto-track dependencies)
  late final doubled = computed(() => count.val * 2);
  late final isEven = computed(() => count.val % 2 == 0);
  
  // Methods
  void increment() => count.emit(count.val + 1);
  void decrement() => count.emit(count.val - 1);
  void reset() => count.emit(0);
  
  // Static accessor
  static CounterController get init => 
      Neuron.ensure<CounterController>(() => CounterController());
}
```

### Step 2: Use in Your UI

```dart
class CounterPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = CounterController.init;
    
    return Scaffold(
      appBar: AppBar(title: Text('Neuron Counter')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Connect Signal to UI
            Slot<int>(
              connect: c.count,
              to: (_, value) => Text(
                '$value',
                style: TextStyle(fontSize: 72, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 16),
            Slot<bool>(
              connect: c.isEven,
              to: (_, isEven) => Text(
                isEven ? 'Even' : 'Odd',
                style: TextStyle(color: isEven ? Colors.green : Colors.orange),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            onPressed: c.increment,
            child: Icon(Icons.add),
          ),
          SizedBox(height: 8),
          FloatingActionButton(
            onPressed: c.decrement,
            child: Icon(Icons.remove),
          ),
        ],
      ),
    );
  }
}
```

### Step 3: Run Your App

```dart
void main() => runApp(NeuronApp(home: CounterPage()));
```

---

<!-- ═══════════════════════════════════════════════════════════════════════════════
     SECTION 6: SIGNAL TYPES REFERENCE
     Complete reference of all Signal types with examples
     - Signal<T>: Basic reactive value
     - AsyncSignal<T>: Async operations with loading/error states
     - Computed<T>: Derived values with auto-tracking
     - ListSignal<E>: Reactive lists
     - MapSignal<K,V>: Reactive maps
     - SetSignal<E>: Reactive sets
     ═══════════════════════════════════════════════════════════════════════════════ -->

## 📚 Signal Types

Neuron provides specialized signals for different use cases:

### Signal&lt;T&gt; — Basic Reactive Value

```dart
final name = Signal<String>('');
final count = Signal<int>(0);
final user = Signal<User?>(null);

// Update
name.emit('John');
count.emit(count.val + 1);

// Read
print(name.val);  // 'John'
```

### AsyncSignal&lt;T&gt; — Async Operations

Handles loading, error, and data states automatically:

```dart
late final posts = asyncSignal<List<Post>>();

Future<void> loadPosts() async {
  await posts.execute(() => api.fetchPosts());
}

// Check states
posts.isLoading  // true during fetch
posts.hasError   // true if failed
posts.hasData    // true if succeeded
posts.data       // the data (nullable)
posts.error      // the error (nullable)

// Refresh (re-runs last operation)
await posts.refresh();
```

### Computed&lt;T&gt; — Derived Values

Auto-tracks dependencies and recalculates when they change:

```dart
late final firstName = signal('John');
late final lastName = signal('Doe');

// Dependencies detected automatically!
late final fullName = computed(() => '${firstName.val} ${lastName.val}');

firstName.emit('Jane');
print(fullName.val);  // 'Jane Doe' (auto-updated)
```

### ListSignal&lt;E&gt; — Reactive Lists

```dart
late final todos = ListSignal<Todo>([]);

// Mutations that trigger updates
todos.add(Todo('Buy milk'));
todos.remove(todo);
todos.removeAt(0);
todos.insert(0, Todo('First'));
todos.clear();

// Access
todos.val.length
todos.val.first
```

### MapSignal&lt;K, V&gt; — Reactive Maps

```dart
late final settings = MapSignal<String, dynamic>({});

settings.put('theme', 'dark');
settings.remove('theme');
settings.clear();

// Access
settings['theme']
settings.containsKey('theme')
```

### SetSignal&lt;E&gt; — Reactive Sets

```dart
late final tags = SetSignal<String>({});

tags.add('flutter');
tags.remove('flutter');
tags.clear();

// Access
tags.contains('flutter')
```

---

<!-- ═══════════════════════════════════════════════════════════════════════════════
     SECTION 7: WIDGET GUIDE
     Complete reference of all Slot widgets
     - Slot<T>: Basic signal-to-widget connection
     - AsyncSlot<T>: Async signal with loading/error/data states
     - MultiSlot: Combine 2-6 signals
     - ConditionalSlot: Conditional rendering
     - AnimatedSlot: Animated transitions
     - SpringSlot: Physics-based animations
     - GestureAnimatedSlot: Tap with press animations
     - PulseSlot: Attention-grabbing pulse effect
     - ShimmerSlot: Loading shimmer effect
     - MorphSlot: Smooth shape/size transitions
     ═══════════════════════════════════════════════════════════════════════════════ -->

## 📱 Widget Guide

### Slot&lt;T&gt; — Basic Connection

```dart
Slot<int>(
  connect: c.count,
  to: (context, value) => Text('Count: $value'),
)
```

### AsyncSlot&lt;T&gt; — Async States

```dart
AsyncSlot<User>(
  connect: c.user,
  onLoading: (ctx) => CircularProgressIndicator(),
  onError: (ctx, error) => Text('Error: $error'),
  onData: (ctx, user) => UserCard(user),
)
```

### MultiSlot — Multiple Signals

```dart
// 2 signals
MultiSlot.t2(
  c.firstName,
  c.lastName,
  to: (ctx, first, last) => Text('$first $last'),
)

// 3 signals
MultiSlot.t3(
  c.width,
  c.height,
  c.depth,
  to: (ctx, w, h, d) => Text('Volume: ${w * h * d}'),
)

// Up to 6 signals supported: t2, t3, t4, t5, t6
// Or use list for dynamic count:
MultiSlot.list(
  [c.a, c.b, c.c, c.d],
  to: (ctx, values) => Text('Sum: ${values.reduce((a, b) => a + b)}'),
)
```

### ConditionalSlot — Conditional Rendering

```dart
ConditionalSlot<bool>(
  connect: c.isLoggedIn,
  when: (val) => val,
  to: (ctx, _) => Dashboard(),
  orElse: (ctx) => LoginPage(),
)
```

### AnimatedSlot — Animated Transitions

```dart
AnimatedSlot<int>(
  connect: c.count,
  effect: SlotEffect.fade | SlotEffect.scale | SlotEffect.slideUp,
  duration: Duration(milliseconds: 300),
  curve: Curves.easeOutBack,
  to: (ctx, value) => Text('$value'),
)
```

### SpringSlot — Physics-Based Animations

```dart
SpringSlot<double>(
  connect: c.temperature,
  spring: SpringConfig.bouncy,
  to: (ctx, temp) => Text('${temp.toStringAsFixed(1)}°'),
)
```

### GestureAnimatedSlot — Tap with Press Animation

```dart
GestureAnimatedSlot<bool>(
  connect: c.isOn,
  onTap: () => c.toggle(),
  pressedScale: 0.9,
  to: (ctx, isOn) => Icon(
    Icons.power_settings_new,
    color: isOn ? Colors.green : Colors.grey,
  ),
)
```

### PulseSlot — Attention-Grabbing Pulse

```dart
PulseSlot<int>(
  connect: c.alerts,
  when: (count) => count > 0,  // Only pulse when alerts exist
  to: (ctx, count) => Badge(label: Text('$count')),
)
```

### ShimmerSlot — Loading Shimmer Effect

```dart
ShimmerSlot<Device?>(
  connect: c.device,
  when: (device) => device == null,  // Shimmer while loading
  shimmer: Container(height: 60, color: Colors.grey[300]),
  to: (ctx, device) => DeviceCard(device!),
)
```

### MorphSlot — Smooth Shape/Size Transitions

```dart
MorphSlot<bool>(
  connect: c.isExpanded,
  config: MorphConfig.bouncy,
  morphBuilder: (ctx, expanded) => MorphableWidget(
    child: expanded ? ExpandedContent() : CollapsedContent(),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(expanded ? 16 : 8),
    ),
    size: Size(double.infinity, expanded ? 200 : 60),
  ),
)
```

---

<!-- ═══════════════════════════════════════════════════════════════════════════════
     SECTION 8: SMART HOME EXAMPLE
     Complete real-world example demonstrating:
     - Multiple signal types working together
     - Computed values for derived state
     - Various Slot widgets for different UI needs
     - Async data loading with shimmer effects
     - Gesture animations for interactive controls
     ═══════════════════════════════════════════════════════════════════════════════ -->

## 🏠 Smart Home Example

A complete example showing how different Slots work together:

<p align="center">
  <img src="https://raw.githubusercontent.com/pixeluvw/neuron/master/example/assets/smart_home_1.png" width="250" alt="Smart Home Dashboard"/>
  <img src="https://raw.githubusercontent.com/pixeluvw/neuron/master/example/assets/smart_home_2.png" width="250" alt="Smart Home Controls"/>
  <img src="https://raw.githubusercontent.com/pixeluvw/neuron/master/example/assets/smart_home_3.png" width="250" alt="Smart Home Alert"/>
</p>

### Controller

```dart
import 'package:neuron/neuron.dart';

class Device {
  final String name;
  final String type;
  final bool isOnline;
  
  Device({required this.name, required this.type, this.isOnline = true});
}

class SmartHomeController extends NeuronController {
  // Room states
  late final livingRoomLight = $(false);
  late final bedroomLight = $(false);
  late final kitchenLight = $(false);
  
  // Thermostat
  late final temperature = $(22.0);
  late final targetTemp = $(21.0);
  // Signal for animated slots - synced via computed
  late final isHeating = $(false);
  
  // Security
  late final isArmed = $(false);
  late final isArming = $(false);
  late final armingCountdown = $(0);
  late final motionDetected = $(false);
  late final alerts = ListSignal<String>([]);
  
  // Bool signal for ToggleSlot animation on notifications
  late final hasAlerts = $(false);
  
  // Wave effect trigger - increments to trigger animation
  late final wavetrigger = $(0);
  late final waveIsArming = $(true); // true = arming (red), false = disarming (green)
  late final waveProgress = $(0.0); // 0.0 to 1.0 for wave animation
  
  // Pulse animation intensity for armed state (0.0 to 1.0 for glow intensity)
  late final pulseIntensity = $(0.0);
  
  // Screen flash intensity for alarm wave (0.0 to 1.0)
  late final screenFlashIntensity = $(0.0);
  
  // Device status (async loading)
  late final devices = $<List<Device>?>([
    Device(name: 'Smart TV', type: 'entertainment'),
    Device(name: 'Smart Speaker', type: 'audio'),
    Device(name: 'Robot Vacuum', type: 'appliance'),
  ]);
  
  // Computed states
  late final lightsOn = computed(() => 
    [livingRoomLight.val, bedroomLight.val, kitchenLight.val]
      .where((on) => on).length
  );
  
  // Signal for SpringSlot animation - synced via computed
  late final energyUsage = $(0.0);
  
  // Internal computed to drive signal updates
  late final _heatingSync = computed(() {
    final heating = temperature.val < targetTemp.val;
    if (isHeating.val != heating) {
      Future.microtask(() => isHeating.emit(heating));
    }
    return heating;
  });
  
  late final _energySync = computed(() {
    var watts = 0.0;
    if (livingRoomLight.val) watts += 60;
    if (bedroomLight.val) watts += 40;
    if (kitchenLight.val) watts += 100;
    if (_heatingSync.val) watts += 2000;
    if (energyUsage.val != watts) {
      Future.microtask(() => energyUsage.emit(watts));
    }
    return watts;
  });
  
  // Sync hasAlerts with alerts list
  late final _alertsSync = computed(() {
    final has = alerts.val.isNotEmpty;
    if (hasAlerts.val != has) {
      Future.microtask(() => hasAlerts.emit(has));
    }
    return has;
  });
  
  // Force computed evaluation on init
  void _init() {
    _heatingSync.val;
    _energySync.val;
    _alertsSync.val;
    _startTemperatureSimulation();
  }
  
  // Simulate temperature gradually approaching target
  void _startTemperatureSimulation() async {
    while (true) {
      await Future.delayed(const Duration(milliseconds: 3000));
      final current = temperature.val;
      final target = targetTemp.val;
      
      if ((current - target).abs() > 0.05) {
        // Move temperature 0.1 degree towards target
        final step = current < target ? 0.1 : -0.1;
        temperature.emit(double.parse((current + step).toStringAsFixed(1)));
      }
    }
  }
  
  // Actions
  void toggleLight(Signal<bool> light) => light.emit(!light.val);
  void setTargetTemp(double temp) => targetTemp.emit(temp.clamp(16.0, 28.0));
  
  Future<void> armSecurity() async {
    if (isArming.val || isArmed.val) return;
    isArming.emit(true);
    for (var i = 5; i > 0; i--) {
      armingCountdown.emit(i);
      await Future.delayed(const Duration(seconds: 1));
    }
    armingCountdown.emit(0);
    isArming.emit(false);
    isArmed.emit(true);
    // Add alert notification
    alerts.add('Security system armed');
    // Trigger wave animation (red for arming)
    waveIsArming.emit(true);
    wavetrigger.emit(wavetrigger.val + 1);
    _runWaveAnimation();
    _startPulseAnimation();
  }
  
  void cancelArming() {
    isArming.emit(false);
    armingCountdown.emit(0);
  }
  
  void disarmSecurity() {
    isArmed.emit(false);
    // Add alert notification
    alerts.add('Security system disarmed');
    // Trigger wave animation (green for disarming)
    waveIsArming.emit(false);
    wavetrigger.emit(wavetrigger.val + 1);
    _runWaveAnimation();
  }
  
  // Run wave animation by updating progress signal
  Future<void> _runWaveAnimation() async {
    waveProgress.emit(0.0);
    final isArming = waveIsArming.val;
    const steps = 60; // ~60fps for 1.2 seconds
    const duration = 1200; // ms
    
    for (var i = 1; i <= steps; i++) {
      await Future.delayed(const Duration(milliseconds: duration ~/ steps));
      waveProgress.emit(i / steps);
      
      // Red flash effect only when arming
      if (isArming) {
        // Flash intensity peaks at middle of animation then fades
        final flashProgress = i / steps;
        final flash = flashProgress < 0.3 
            ? flashProgress / 0.3  // Ramp up
            : (1.0 - flashProgress) / 0.7;  // Fade out
        screenFlashIntensity.emit(flash.clamp(0.0, 1.0) * 0.4);  // Max 40% intensity
      }
    }
    screenFlashIntensity.emit(0.0);  // Ensure flash is cleared
  }
  
  // Run pulse animation continuously when armed - emits intensity directly
  void _startPulseAnimation() async {
    while (isArmed.val) {
      // Ramp up
      for (var i = 0; i <= 50; i++) {
        if (!isArmed.val) {
          pulseIntensity.emit(0.0);
          return;
        }
        await Future.delayed(const Duration(milliseconds: 20));
        pulseIntensity.emit(i / 50.0);
      }
      // Ramp down
      for (var i = 50; i >= 0; i--) {
        if (!isArmed.val) {
          pulseIntensity.emit(0.0);
          return;
        }
        await Future.delayed(const Duration(milliseconds: 20));
        pulseIntensity.emit(i / 50.0);
      }
    }
    pulseIntensity.emit(0.0);
  }
  void dismissAlert(String alert) => alerts.remove(alert);
  
  static SmartHomeController get init {
    final controller = Neuron.ensure(() => SmartHomeController());
    controller._init();
    return controller;
  }
}
```

### UI with Various Slots

```dart
import 'package:flutter/material.dart';
import 'package:neuron/neuron.dart';
import 'package:smarthome/smarthome_controller.dart';

void main() {
  runApp(NeuronApp(home: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Neuron Smart Home',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0D0D0D),
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFFFFAA00),
          secondary: const Color(0xFFFF8C00),
          surface: const Color(0xFF1A1A1A),
        ),
      ),
      home: const SmartHomePage(),
    );
  }
}

// Scan wave effect widget - Using Neuron SpringSlot for smooth animation
class _ScanWaveOverlay extends StatelessWidget {
  final SmartHomeController controller;

  const _ScanWaveOverlay({required this.controller});

  @override
  Widget build(BuildContext context) {
    final c = controller;

    // Use Slot to reactively check if wave should show
    return Slot<int>(
      connect: c.wavetrigger,
      to: (_, trigger) {
        if (trigger == 0) return const SizedBox.shrink();

        // Use SpringSlot for smooth animated progress
        return SpringSlot<double>(
          connect: c.waveProgress,
          spring: SpringConfig.smooth,
          to: (_, progress) {
            if (progress >= 1.0) return const SizedBox.shrink();

            // Painter reads all values directly from controller signals
            return CustomPaint(
              painter: _ScanWavePainter(controller: c),
              size: Size.infinite,
            );
          },
        );
      },
    );
  }
}

class _ScanWavePainter extends CustomPainter {
  final SmartHomeController controller;

  _ScanWavePainter({required this.controller});

  @override
  void paint(Canvas canvas, Size size) {
    // Read values directly from controller signals
    final progress = controller.waveProgress.val;
    final isArming = controller.waveIsArming.val;
    final topToBottom = !isArming;
    final color = isArming ? const Color(0xFFFF6B6B) : const Color(0xFFFFAA00);
    final opacity = 1.0 - progress;

    // Wave position: bottom-to-top or top-to-bottom based on direction
    final waveY = topToBottom
        ? size.height *
              progress // Top to bottom (disarming)
        : size.height * (1 - progress); // Bottom to top (arming)
    final fadeOpacity = opacity;

    // Full screen tint that fades - fill area behind the wave
    final tintPaint = Paint()
      ..color = color.withValues(alpha: 0.08 * fadeOpacity);
    if (topToBottom) {
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, waveY), tintPaint);
    } else {
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, waveY), tintPaint);
    }

    // Thick main scan line with strong glow
    final lineHeight = 20.0;
    final linePaint = Paint()
      ..shader =
          LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              color.withValues(alpha: 0),
              color.withValues(alpha: 1.0 * fadeOpacity),
              color.withValues(alpha: 1.0 * fadeOpacity),
              color.withValues(alpha: 0),
            ],
            stops: const [0.0, 0.15, 0.85, 1.0],
          ).createShader(
            Rect.fromLTWH(0, waveY - lineHeight / 2, size.width, lineHeight),
          );

    canvas.drawRect(
      Rect.fromLTWH(0, waveY - lineHeight / 2, size.width, lineHeight),
      linePaint,
    );

    // Glow effect - ahead of the wave direction
    final glowHeight = 200.0;
    if (topToBottom) {
      // Glow below the line (ahead of downward motion)
      final glowPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            color.withValues(alpha: 0.4 * fadeOpacity),
            color.withValues(alpha: 0),
          ],
        ).createShader(Rect.fromLTWH(0, waveY, size.width, glowHeight));
      canvas.drawRect(
        Rect.fromLTWH(0, waveY, size.width, glowHeight),
        glowPaint,
      );
    } else {
      // Glow above the line (ahead of upward motion)
      final glowPaint = Paint()
        ..shader =
            LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                color.withValues(alpha: 0),
                color.withValues(alpha: 0.4 * fadeOpacity),
              ],
            ).createShader(
              Rect.fromLTWH(0, waveY - glowHeight, size.width, glowHeight),
            );
      canvas.drawRect(
        Rect.fromLTWH(0, waveY - glowHeight, size.width, glowHeight),
        glowPaint,
      );
    }

    // Trailing fade - behind the wave direction
    final trailHeight = 120.0;
    if (topToBottom) {
      // Trail above the line (behind downward motion)
      final trailPaint = Paint()
        ..shader =
            LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                color.withValues(alpha: 0),
                color.withValues(alpha: 0.3 * fadeOpacity),
              ],
            ).createShader(
              Rect.fromLTWH(0, waveY - trailHeight, size.width, trailHeight),
            );
      canvas.drawRect(
        Rect.fromLTWH(0, waveY - trailHeight, size.width, trailHeight),
        trailPaint,
      );
    } else {
      // Trail below the line (behind upward motion)
      final trailPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            color.withValues(alpha: 0.3 * fadeOpacity),
            color.withValues(alpha: 0),
          ],
        ).createShader(Rect.fromLTWH(0, waveY, size.width, trailHeight));
      canvas.drawRect(
        Rect.fromLTWH(0, waveY, size.width, trailHeight),
        trailPaint,
      );
    }

    // Extra bright center line
    final brightLinePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.8 * fadeOpacity)
      ..strokeWidth = 4;
    canvas.drawLine(
      Offset(size.width * 0.05, waveY),
      Offset(size.width * 0.95, waveY),
      brightLinePaint,
    );
  }

  @override
  bool shouldRepaint(_ScanWavePainter oldDelegate) => true; // Always repaint since values come from signals
}

// Continuous pulsing widget for armed state - reads intensity from controller
class _ArmedPulseWrapper extends StatelessWidget {
  final SmartHomeController controller;

  const _ArmedPulseWrapper({required this.controller});

  @override
  Widget build(BuildContext context) {
    // Use Slot - controller already provides the pulse intensity directly
    return Slot<double>(
      connect: controller.pulseIntensity,
      to: (_, pulse) => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF6B6B).withValues(alpha: 0.4 * pulse),
              blurRadius: 20 * pulse,
              spreadRadius: 2 * pulse,
            ),
          ],
        ),
        child: _SecurityCard(controller: controller),
      ),
    );
  }
}

// Modern flat dark card widget
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double blur;
  final double opacity;
  final Color? borderColor;
  final double borderRadius;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.blur = 0,
    this.opacity = 0.15,
    this.borderColor,
    this.borderRadius = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        // Flat dark background
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: borderColor ?? const Color(0xFF2A2A2A),
          width: 1,
        ),
      ),
      child: child,
    );
  }
}

class SmartHomePage extends StatelessWidget {
  const SmartHomePage({super.key});

  void _showAlertsDialog(BuildContext context, SmartHomeController c) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          border: Border.all(color: const Color(0xFF2A2A2A)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Notifications',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Slot<List<String>>(
              connect: c.alerts,
              to: (_, alerts) => alerts.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Icon(
                            Icons.notifications_off_outlined,
                            color: Colors.white.withValues(alpha: 0.5),
                            size: 48,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No notifications',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.5),
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: alerts.length,
                      itemBuilder: (context, index) {
                        final alert = alerts[index];
                        return Dismissible(
                          key: Key(alert + index.toString()),
                          onDismissed: (_) => c.dismissAlert(alert),
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 16),
                            child: const Icon(
                              Icons.delete_outline,
                              color: Color(0xFFFF6B6B),
                            ),
                          ),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.1),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFFFF6B6B,
                                    ).withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.security,
                                    color: Color(0xFFFF6B6B),
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    alert,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.close,
                                    color: Colors.white.withValues(alpha: 0.5),
                                    size: 18,
                                  ),
                                  onPressed: () => c.dismissAlert(alert),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 16),
            Slot<List<String>>(
              connect: c.alerts,
              to: (_, alerts) => alerts.isNotEmpty
                  ? Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          onPressed: () {
                            while (c.alerts.val.isNotEmpty) {
                              c.dismissAlert(c.alerts.val.first);
                            }
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFFFF6B6B),
                          ),
                          child: const Text('Clear All'),
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = SmartHomeController.init;

    return Scaffold(
      body: Stack(
        children: [
          // Main content - Flat dark background
          Container(
            color: const Color(0xFF0D0D0D),
            child: SafeArea(
              child: CustomScrollView(
                slivers: [
                  // Custom App Bar with glass effect
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome Home',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.6),
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Neuron User!',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          // Animated toggle for alerts - Neuron AnimatedSlot
                          AnimatedSlot<bool>(
                            connect: c.hasAlerts,
                            effect: SlotEffect.scale | SlotEffect.fade,
                            to: (_, hasAlerts) => GestureDetector(
                              onTap: () => _showAlertsDialog(context, c),
                              child: GlassCard(
                                padding: const EdgeInsets.all(12),
                                margin: EdgeInsets.zero,
                                borderColor: hasAlerts
                                    ? const Color(
                                        0xFFFFAA00,
                                      ).withValues(alpha: 0.5)
                                    : const Color(0xFF2A2A2A),
                                child: Slot<List<String>>(
                                  connect: c.alerts,
                                  to: (_, alerts) => Badge(
                                    isLabelVisible: alerts.isNotEmpty,
                                    label: Text('${alerts.length}'),
                                    backgroundColor: const Color(0xFFFFAA00),
                                    child: Icon(
                                      alerts.isNotEmpty
                                          ? Icons.notifications_active
                                          : Icons.notifications_outlined,
                                      color: alerts.isNotEmpty
                                          ? const Color(0xFFFFAA00)
                                          : Colors.white54,
                                      size: 24,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Energy Usage Card with SpringSlot animation
                  SliverToBoxAdapter(
                    child: SpringSlot<double>(
                      connect: c.energyUsage,
                      spring: SpringConfig.smooth,
                      to: (_, watts) {
                        // Dynamic colors based on energy usage
                        final Color iconColor;
                        final Color borderColor;
                        if (watts >= 2000) {
                          // High usage - red warning
                          iconColor = const Color(0xFFFF4444);
                          borderColor = const Color(0xFFFF4444).withValues(alpha: 0.3);
                        } else if (watts >= 100) {
                          // Medium usage - orange
                          iconColor = const Color(0xFFFFAA00);
                          borderColor = const Color(0xFFFFAA00).withValues(alpha: 0.3);
                        } else if (watts > 0) {
                          // Low usage - yellow
                          iconColor = const Color(0xFFFFCC00);
                          borderColor = const Color(0xFFFFCC00).withValues(alpha: 0.2);
                        } else {
                          // No usage - dim
                          iconColor = const Color(0xFF666666);
                          borderColor = const Color(0xFF2A2A2A);
                        }
                        return GlassCard(
                          borderColor: borderColor,
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: iconColor.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.bolt,
                                  color: iconColor,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Energy Usage',
                                      style: TextStyle(
                                        color: Colors.white.withValues(
                                          alpha: 0.7,
                                        ),
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${watts.toStringAsFixed(0)} W',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Lights on indicator
                              Slot<int>(
                                connect: c.lightsOn,
                                to: (_, count) => Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF252525),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    '$count lights on',
                                    style: TextStyle(
                                      color: count > 0 ? const Color(0xFFFFAA00) : Colors.white38,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  // Thermostat Card with AnimatedSlot animation
                  SliverToBoxAdapter(
                    child: Slot<double>(
                      connect: c.temperature,
                      to: (_, temp) {
                        // Determine icon and colors based on temperature
                        final IconData tempIcon;
                        final Color iconColor;
                        final Color borderColor;

                        if (temp >= 26) {
                          // Hot - red
                          tempIcon = Icons.local_fire_department;
                          iconColor = const Color(0xFFFF4444);
                          borderColor = const Color(0xFFFF4444).withValues(alpha: 0.3);
                        } else if (temp >= 22) {
                          // Warm - orange
                          tempIcon = Icons.whatshot;
                          iconColor = const Color(0xFFFF8C00);
                          borderColor = const Color(0xFFFF8C00).withValues(alpha: 0.3);
                        } else if (temp >= 18) {
                          // Comfortable - yellow
                          tempIcon = Icons.thermostat;
                          iconColor = const Color(0xFFFFAA00);
                          borderColor = const Color(0xFFFFAA00).withValues(alpha: 0.3);
                        } else if (temp >= 14) {
                          // Cool - dim yellow
                          tempIcon = Icons.ac_unit;
                          iconColor = const Color(0xFFCCAA00);
                          borderColor = const Color(0xFFCCAA00).withValues(alpha: 0.2);
                        } else {
                          // Cold - gray
                          tempIcon = Icons.severe_cold;
                          iconColor = const Color(0xFF666666);
                          borderColor = const Color(0xFF2A2A2A);
                        }

                        return AnimatedSlot<bool>(
                          connect: c.isHeating,
                          effect: SlotEffect.scale | SlotEffect.fade,
                          to: (_, heating) => GlassCard(
                            borderColor: borderColor,
                            child: Column(
                              children: [
                                // Top row: icon, current temp, status
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: iconColor.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        tempIcon,
                                        color: iconColor,
                                        size: 28,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            heating ? 'Heating Active' : 'Standby',
                                            style: TextStyle(
                                              color: heating ? const Color(0xFFFFAA00) : Colors.white38,
                                              fontSize: 14,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.baseline,
                                            textBaseline: TextBaseline.alphabetic,
                                            children: [
                                              AnimatedValueSlot<double>(
                                                connect: c.temperature,
                                                to: (_, t) => Text(
                                                  '${t.toStringAsFixed(1)}°',
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 32,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              const Text(
                                                'Current',
                                                style: TextStyle(
                                                  color: Colors.white38,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                // Bottom row: Target temperature controls
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF252525),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      const Text(
                                        'Target',
                                        style: TextStyle(
                                          color: Colors.white38,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const Spacer(),
                                      // Minus button
                                      GestureDetector(
                                        onTap: () => c.setTargetTemp(c.targetTemp.val - 0.5),
                                        child: Container(
                                          width: 44,
                                          height: 44,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF1A1A1A),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: const Icon(
                                            Icons.remove,
                                            color: Color(0xFFFFAA00),
                                            size: 24,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      // Target temp display
                                      AnimatedValueSlot<double>(
                                        connect: c.targetTemp,
                                        to: (_, target) => Text(
                                          '${target.toStringAsFixed(1)}°',
                                          style: const TextStyle(
                                            color: Color(0xFFFFAA00),
                                            fontSize: 28,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      // Plus button
                                      GestureDetector(
                                        onTap: () => c.setTargetTemp(c.targetTemp.val + 0.5),
                                        child: Container(
                                          width: 44,
                                          height: 44,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF1A1A1A),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: const Icon(
                                            Icons.add,
                                            color: Color(0xFFFFAA00),
                                            size: 24,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Section Header - Lights
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
                      child: Text(
                        'Room Lights',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  // Light Controls Grid with GestureAnimatedSlot
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            childAspectRatio: 0.8,
                            crossAxisSpacing: 4,
                            mainAxisSpacing: 4,
                          ),
                      delegate: SliverChildListDelegate([
                        _LightCard(
                          'Living\nRoom',
                          c.livingRoomLight,
                          Icons.weekend,
                        ),
                        _LightCard('Bedroom', c.bedroomLight, Icons.bed),
                        _LightCard('Kitchen', c.kitchenLight, Icons.kitchen),
                      ]),
                    ),
                  ),

                  // Security Card with PulseSlot for flashing when armed
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
                      child: Text(
                        'Security',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  SliverToBoxAdapter(
                    child: PulseSlot<bool>(
                      connect: c.isArmed,
                      when: (armed) => armed, // Pulse when armed
                      to: (_, armed) => AnimatedSlot<bool>(
                        connect: c.isArmed,
                        effect:
                            SlotEffect.scale |
                            SlotEffect.fade |
                            SlotEffect.slide,
                        to: (_, _) => armed
                            ? _ArmedPulseWrapper(controller: c)
                            : _SecurityCard(controller: c),
                      ),
                    ),
                  ),

                  // Devices Section with ShimmerSlot
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
                      child: Text(
                        'Connected Devices',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  SliverToBoxAdapter(
                    child: ShimmerSlot<List<Device>?>(
                      connect: c.devices,
                      when: (devices) => devices == null,
                      shimmer: Column(
                        children: List.generate(
                          3,
                          (_) => GlassCard(
                            child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ),
                      to: (_, devices) => Column(
                        children: devices!.map((d) => DeviceCard(d)).toList(),
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 24)),
                ],
              ),
            ),
          ),
          // Red flash overlay for alarm arming
          Positioned.fill(
            child: IgnorePointer(
              child: Slot<double>(
                connect: c.screenFlashIntensity,
                to: (_, intensity) => intensity > 0
                    ? Container(
                        color: const Color(
                          0xFFFF4757,
                        ).withValues(alpha: intensity),
                      )
                    : const SizedBox.shrink(),
              ),
            ),
          ),
          // Scan wave overlay - Neuron reactive with SpringSlot animation
          Positioned.fill(
            child: IgnorePointer(child: _ScanWaveOverlay(controller: c)),
          ),
        ],
      ),
    );
  }
}

// Security card widget - uses Neuron AnimatedSlots with dramatic effects (no nesting!)
class _SecurityCard extends StatelessWidget {
  final SmartHomeController controller;

  const _SecurityCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    final c = controller;

    return GlassCard(
      borderColor: c.isArmed.val
          ? const Color(0xFFFF4444).withValues(alpha: 0.4)
          : c.isArming.val
          ? const Color(0xFFFFAA00).withValues(alpha: 0.3)
          : const Color(0xFF2A2A2A),
      child: Row(
        children: [
          // Icon/Countdown container - single AnimatedSlot on arming state
          AnimatedSlot<bool>(
            connect: c.isArming,
            effect:
                SlotEffect.scale |
                SlotEffect.fade |
                SlotEffect.flip |
                SlotEffect.bounce,
            to: (_, arming) => Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: c.isArmed.val
                    ? const Color(0xFFFF4444).withValues(alpha: 0.15)
                    : arming
                    ? const Color(0xFFFFAA00).withValues(alpha: 0.15)
                    : const Color(0xFF252525),
                borderRadius: BorderRadius.circular(12),
              ),
              child: arming
                  // Countdown with dramatic animation
                  ? AnimatedSlot<int>(
                      connect: c.armingCountdown,
                      effect:
                          SlotEffect.scale |
                          SlotEffect.fade |
                          SlotEffect.flip |
                          SlotEffect.slide |
                          SlotEffect.bounce,
                      to: (_, countdown) => SizedBox(
                        width: 28,
                        height: 28,
                        child: Center(
                          child: Text(
                            '$countdown',
                            style: const TextStyle(
                              color: Color(0xFFFFAA00),
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    )
                  : Icon(
                      c.isArmed.val ? Icons.shield : Icons.shield_outlined,
                      color: c.isArmed.val ? const Color(0xFFFF4444) : Colors.white54,
                      size: 28,
                    ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status text - single AnimatedSlot on armed state
                AnimatedSlot<bool>(
                  connect: c.isArmed,
                  effect:
                      SlotEffect.slide |
                      SlotEffect.fade |
                      SlotEffect.scale |
                      SlotEffect.bounce,
                  to: (_, armed) => Text(
                    armed
                        ? 'ALARM ARMED'
                        : c.isArming.val
                        ? 'Arming...'
                        : 'Security Disarmed',
                    style: TextStyle(
                      color: armed ? const Color(0xFFFF4444) : c.isArming.val ? const Color(0xFFFFAA00) : Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                // Subtitle with countdown animation
                AnimatedSlot<int>(
                  connect: c.armingCountdown,
                  effect:
                      SlotEffect.fade |
                      SlotEffect.slide |
                      SlotEffect.scale |
                      SlotEffect.bounce,
                  to: (_, countdown) => Text(
                    c.isArmed.val
                        ? 'All sensors active'
                        : c.isArming.val
                        ? 'System will arm in $countdown seconds'
                        : 'Tap to arm system',
                    style: const TextStyle(
                      color: Colors.white38,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Button with GestureAnimatedSlot - reads other values directly
          GestureAnimatedSlot<bool>(
            connect: c.isArmed,
            pressedScale: 0.85,
            onTap: () {
              if (c.isArmed.val) {
                c.disarmSecurity();
              } else if (c.isArming.val) {
                c.cancelArming();
              } else {
                c.armSecurity();
              }
            },
            to: (_, armed) => Container(
              width: 80,
              height: 40,
              decoration: BoxDecoration(
                color: armed
                    ? const Color(0xFF2A5A2A)
                    : const Color(0xFFFFAA00),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  armed
                      ? 'Disarm'
                      : c.isArming.val
                      ? 'Cancel'
                      : 'Arm',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: armed ? const Color(0xFF4ADE80) : Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Light card with GestureAnimatedSlot
class _LightCard extends StatelessWidget {
  final String name;
  final Signal<bool> light;
  final IconData icon;

  const _LightCard(this.name, this.light, this.icon);

  @override
  Widget build(BuildContext context) {
    return GestureAnimatedSlot<bool>(
      connect: light,
      onTap: () => light.emit(!light.val),
      pressedScale: 0.92,
      to: (_, isOn) => GlassCard(
        margin: const EdgeInsets.all(6),
        padding: const EdgeInsets.all(10),
        borderColor: isOn
            ? const Color(0xFFFFAA00).withValues(alpha: 0.4)
            : const Color(0xFF2A2A2A),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isOn
                    ? const Color(0xFFFFAA00).withValues(alpha: 0.15)
                    : const Color(0xFF252525),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: isOn ? const Color(0xFFFFAA00) : Colors.white38,
                size: 22,
              ),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: Text(
                name,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
                style: TextStyle(
                  color: isOn ? Colors.white : Colors.white38,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: isOn
                    ? const Color(0xFFFFAA00).withValues(alpha: 0.15)
                    : const Color(0xFF252525),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                isOn ? 'ON' : 'OFF',
                style: TextStyle(
                  color: isOn ? const Color(0xFFFFAA00) : Colors.white38,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Device card widget - flat dark style
class DeviceCard extends StatelessWidget {
  final Device device;

  const DeviceCard(this.device, {super.key});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: device.isOnline
                  ? const Color(0xFFFFAA00).withValues(alpha: 0.15)
                  : const Color(0xFF252525),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _getIconForType(device.type),
              color: device.isOnline ? const Color(0xFFFFAA00) : Colors.white38,
              size: 22,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  device.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  device.type.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white38,
                    fontSize: 11,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: device.isOnline
                  ? const Color(0xFF2A5A2A)
                  : const Color(0xFF5A2A2A),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  device.isOnline ? Icons.wifi : Icons.wifi_off,
                  color: device.isOnline
                      ? const Color(0xFF4ADE80)
                      : const Color(0xFFFF4444),
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  device.isOnline ? 'Online' : 'Offline',
                  style: TextStyle(
                    color: device.isOnline
                        ? const Color(0xFF4ADE80)
                        : const Color(0xFFFF4444),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'entertainment':
        return Icons.tv;
      case 'audio':
        return Icons.speaker;
      case 'appliance':
        return Icons.smart_toy;
      default:
        return Icons.devices;
    }
  }
}

```

---

<!-- ═══════════════════════════════════════════════════════════════════════════════
     SECTION 9: MORE REAL-WORLD EXAMPLES
     Additional patterns and use cases:
     - E-Commerce Cart: Computed totals and discounts
     - Authentication Flow: Async user state management
     - Form Validation: Real-time validation with computed errors
     - Search with Debounce: Debounced API calls
     ═══════════════════════════════════════════════════════════════════════════════ -->

## 🎭 More Real-World Examples

### E-Commerce Cart

```dart
class CartController extends NeuronController {
  late final items = signal<List<CartItem>>([]);
  late final promoCode = signal<String?>(null);
  
  late final subtotal = computed(() => 
    items.val.fold(0.0, (sum, item) => sum + item.price * item.quantity)
  );
  
  late final discount = computed(() {
    if (promoCode.val == 'SAVE20') return 0.20;
    if (promoCode.val == 'SAVE10') return 0.10;
    return 0.0;
  });
  
  late final total = computed(() => subtotal.val * (1 - discount.val));
  
  late final itemCount = computed(() => 
    items.val.fold(0, (sum, item) => sum + item.quantity)
  );
  
  void addItem(Product product) {
    final existing = items.val.firstWhereOrNull((i) => i.productId == product.id);
    if (existing != null) {
      existing.quantity++;
      items.emit([...items.val]); // Trigger update
    } else {
      items.emit([...items.val, CartItem(product)]);
    }
  }
  
  void removeItem(String productId) {
    items.emit(items.val.where((i) => i.productId != productId).toList());
  }
  
  void applyPromo(String code) => promoCode.emit(code);
  
  static CartController get init => Neuron.ensure(() => CartController());
}
```

### Authentication Flow

```dart
class AuthController extends NeuronController {
  late final user = asyncSignal<User?>();
  late final isAuthenticated = computed(() => user.hasData && user.data != null);
  
  Future<void> login(String email, String password) async {
    await user.execute(() => authService.login(email, password));
  }
  
  Future<void> logout() async {
    await authService.logout();
    user.emitData(null);
  }
  
  Future<void> checkSession() async {
    await user.execute(() => authService.getCurrentUser());
  }
  
  static AuthController get init => Neuron.ensure(() => AuthController());
}

// In your app
class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return NeuronApp(
      home: Slot<bool>(
        connect: AuthController.init.isAuthenticated,
        to: (_, isAuth) => isAuth ? HomePage() : LoginPage(),
      ),
    );
  }
}
```

### Form Validation

```dart
class LoginFormController extends NeuronController {
  late final email = signal('');
  late final password = signal('');
  late final isSubmitting = signal(false);
  
  late final emailError = computed(() {
    if (email.val.isEmpty) return null;
    if (!email.val.contains('@')) return 'Invalid email';
    return null;
  });
  
  late final passwordError = computed(() {
    if (password.val.isEmpty) return null;
    if (password.val.length < 8) return 'Must be 8+ characters';
    return null;
  });
  
  late final isValid = computed(() => 
    email.val.isNotEmpty && 
    password.val.isNotEmpty && 
    emailError.val == null && 
    passwordError.val == null
  );
  
  Future<void> submit() async {
    if (!isValid.val) return;
    isSubmitting.emit(true);
    try {
      await AuthController.init.login(email.val, password.val);
    } finally {
      isSubmitting.emit(false);
    }
  }
  
  static LoginFormController get init => Neuron.ensure(() => LoginFormController());
}
```

### Search with Debounce

```dart
class SearchController extends NeuronController {
  late final query = signal('');
  late final results = asyncSignal<List<Product>>();
  
  // Debounced search
  late final _debouncedQuery = DebouncedSignal(query, Duration(milliseconds: 300));
  
  @override
  void onInit() {
    // Search when debounced query changes
    effect(() {
      if (_debouncedQuery.val.length >= 2) {
        results.execute(() => api.search(_debouncedQuery.val));
      }
    }, [_debouncedQuery]);
  }
  
  static SearchController get init => Neuron.ensure(() => SearchController());
}
```

---

<!-- ═══════════════════════════════════════════════════════════════════════════════
     SECTION 10: ANIMATION EFFECTS
     Reference table of all SlotEffect options
     Effects can be combined using the | operator
     ═══════════════════════════════════════════════════════════════════════════════ -->

## 🎨 Animation Effects

Neuron includes beautiful animation effects:

| Effect | Description |
|--------|-------------|
| `SlotEffect.fade` | Fade in/out |
| `SlotEffect.scale` | Scale up/down |
| `SlotEffect.slideUp` | Slide from bottom |
| `SlotEffect.slideDown` | Slide from top |
| `SlotEffect.slideLeft` | Slide from right |
| `SlotEffect.slideRight` | Slide from left |
| `SlotEffect.rotate` | Rotation |
| `SlotEffect.blur` | Blur effect |
| `SlotEffect.flip` | 3D flip |

Combine effects with `|`:

```dart
AnimatedSlot<int>(
  connect: c.count,
  effect: SlotEffect.fade | SlotEffect.scale | SlotEffect.slideUp,
  to: (_, value) => Text('$value'),
)
```

---

<!-- ═══════════════════════════════════════════════════════════════════════════════
     SECTION 11: NAVIGATION
     Context-free navigation using Neuron's global navigator
     ═══════════════════════════════════════════════════════════════════════════════ -->

## 🧭 Navigation

Context-free navigation:

```dart
// Push
Neuron.to(NextPage());

// Replace
Neuron.off(LoginPage());

// Back
Neuron.back();

// Clear stack
Neuron.offAll(HomePage());

// Named routes
Neuron.toNamed('/profile/123');
```

---

<!-- ═══════════════════════════════════════════════════════════════════════════════
     SECTION 12: ADVANCED FEATURES
     Power features for complex applications:
     - Middleware: Transform/validate/log signal emissions
     - Persistence: Auto-save signals to storage
     - Undo/Redo: Time-travel for signal values
     ═══════════════════════════════════════════════════════════════════════════════ -->

## 🔧 Advanced Features

### Middleware

```dart
final age = MiddlewareSignal<int>(0, middlewares: [
  ClampMiddleware(min: 0, max: 120),
  LoggingMiddleware(label: 'age'),
]);
```

### Persistence

```dart
final theme = PersistentSignal<String>(
  'light',
  persistence: SimplePersistence(key: 'theme', ...),
);
```

### Undo/Redo

```dart
final text = UndoableSignal<String>('');
text.emit('Hello');
text.emit('World');
text.undo(); // 'Hello'
text.redo(); // 'World'
```

---

<!-- ═══════════════════════════════════════════════════════════════════════════════
     SECTION 13: PERFORMANCE
     Key performance characteristics and optimizations
     ═══════════════════════════════════════════════════════════════════════════════ -->

## 📊 Performance

- **Fine-grained**: Only connected widgets rebuild
- **Lazy computed**: Values calculated only when accessed
- **Efficient**: Optimized listener notification
- **Auto-cleanup**: Memory managed automatically

---

<!-- ═══════════════════════════════════════════════════════════════════════════════
     SECTION 14: CONTRIBUTING & LICENSE
     How to contribute and licensing information
     ═══════════════════════════════════════════════════════════════════════════════ -->

## 🤝 Contributing

Contributions welcome! Please read [CONTRIBUTING.md](CONTRIBUTING.md).

## 📄 License

MIT License - see [LICENSE](LICENSE).

---

<p align="center">
  <b>Built with ❤️ for the Flutter community</b>
</p>
