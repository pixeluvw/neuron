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

```
┌─────────────────┐         ┌─────────────────┐
│     SIGNAL      │         │      SLOT       │
│                 │ connect │                 │
│  count.emit(5)  │ ───────►│  Text('5')      │
│                 │         │  rebuilds       │
└─────────────────┘         └─────────────────┘
```

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

### Controller

```dart
class SmartHomeController extends NeuronController {
  // Room states
  late final livingRoomLight = $(false);
  late final bedroomLight = $(false);
  late final kitchenLight = $(false);
  
  // Thermostat
  late final temperature = $(22.0);
  late final targetTemp = $(21.0);
  late final isHeating = computed(() => temperature.val < targetTemp.val);
  
  // Security
  late final isArmed = $(false);
  late final motionDetected = $(false);
  late final alerts = ListSignal<String>([]);
  
  // Device status (async loading)
  late final devices = asyncSignal<List<Device>>();
  
  // Computed states
  late final lightsOn = computed(() => 
    [livingRoomLight.val, bedroomLight.val, kitchenLight.val]
      .where((on) => on).length
  );
  
  late final energyUsage = computed(() {
    var watts = 0.0;
    if (livingRoomLight.val) watts += 60;
    if (bedroomLight.val) watts += 40;
    if (kitchenLight.val) watts += 100;
    if (isHeating.val) watts += 2000;
    return watts;
  });
  
  // Actions
  void toggleLight(Signal<bool> light) => light.emit(!light.val);
  void setTargetTemp(double temp) => targetTemp.emit(temp.clamp(16.0, 28.0));
  void armSecurity() => isArmed.emit(true);
  void disarmSecurity() => isArmed.emit(false);
  void dismissAlert(String alert) => alerts.remove(alert);
  
  Future<void> loadDevices() async {
    await devices.execute(() => api.fetchDevices());
  }
  
  static SmartHomeController get init => Neuron.ensure(() => SmartHomeController());
}
```

### UI with Various Slots

```dart
class SmartHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = SmartHomeController.init;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Smart Home'),
        actions: [
          // Pulse when alerts exist
          PulseSlot<List<String>>(
            connect: c.alerts,
            when: (alerts) => alerts.isNotEmpty,
            to: (_, alerts) => Badge(
              label: Text('${alerts.length}'),
              child: Icon(Icons.notifications),
            ),
          ),
        ],
      ),
      body: ListView(
        children: [
          // Energy usage with spring animation
          SpringSlot<double>(
            connect: c.energyUsage,
            spring: SpringConfig.smooth,
            to: (_, watts) => ListTile(
              leading: Icon(Icons.bolt, color: Colors.amber),
              title: Text('Energy Usage'),
              trailing: Text('${watts.toStringAsFixed(0)}W'),
            ),
          ),
          
          // Thermostat with morph animation
          MorphSlot<bool>(
            connect: c.isHeating,
            config: MorphConfig(duration: Duration(milliseconds: 500)),
            morphBuilder: (_, heating) => MorphableWidget(
              decoration: BoxDecoration(
                color: heating ? Colors.orange[100] : Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
              ),
              size: Size(double.infinity, heating ? 120 : 80),
              child: ListTile(
                leading: Icon(
                  heating ? Icons.whatshot : Icons.ac_unit,
                  color: heating ? Colors.orange : Colors.blue,
                ),
                title: Text(heating ? 'Heating...' : 'Cooling'),
                subtitle: Slot<double>(
                  connect: c.temperature,
                  to: (_, temp) => Text('${temp.toStringAsFixed(1)}°C'),
                ),
              ),
            ),
          ),
          
          // Light controls with gesture animations
          _LightToggle('Living Room', c.livingRoomLight, Icons.weekend),
          _LightToggle('Bedroom', c.bedroomLight, Icons.bed),
          _LightToggle('Kitchen', c.kitchenLight, Icons.kitchen),
          
          // Security status with animated transitions
          AnimatedSlot<bool>(
            connect: c.isArmed,
            effect: SlotEffect.scale | SlotEffect.fade,
            to: (_, armed) => ListTile(
              leading: Icon(
                armed ? Icons.shield : Icons.shield_outlined,
                color: armed ? Colors.green : Colors.grey,
              ),
              title: Text(armed ? 'Security Armed' : 'Security Disarmed'),
              trailing: Switch(
                value: armed,
                onChanged: (_) => armed ? c.disarmSecurity() : c.armSecurity(),
              ),
            ),
          ),
          
          // Devices with shimmer loading
          ShimmerSlot<List<Device>?>(
            connect: c.devices,
            when: (devices) => devices == null,
            shimmer: Column(
              children: List.generate(3, (_) => 
                Container(
                  height: 60,
                  margin: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            to: (_, devices) => Column(
              children: devices!.map((d) => DeviceCard(d)).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// Reusable light toggle with press animation
class _LightToggle extends StatelessWidget {
  final String name;
  final Signal<bool> light;
  final IconData icon;
  
  const _LightToggle(this.name, this.light, this.icon);
  
  @override
  Widget build(BuildContext context) {
    return GestureAnimatedSlot<bool>(
      connect: light,
      onTap: () => light.emit(!light.val),
      pressedScale: 0.95,
      to: (_, isOn) => ListTile(
        leading: Icon(icon, color: isOn ? Colors.amber : Colors.grey),
        title: Text(name),
        trailing: Icon(
          isOn ? Icons.lightbulb : Icons.lightbulb_outline,
          color: isOn ? Colors.amber : Colors.grey,
        ),
      ),
    );
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
