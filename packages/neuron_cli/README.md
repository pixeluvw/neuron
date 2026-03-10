# Neuron CLI

Command-line interface for the [Neuron](https://pub.dev/packages/neuron) framework. Generate projects, screens, controllers, and models with the Signal/Slot architecture — complete with automatic routing and dependency injection.

## Installation

### Option 1: Compile Native Executable (Recommended)

```bash
cd packages/neuron_cli
dart compile exe bin/neuron.dart -o neuron.exe  # Windows
# dart compile exe bin/neuron.dart -o neuron    # macOS/Linux

# Add to PATH or move to a directory in your PATH
```

### Option 2: From pub.dev (when published)

```bash
dart pub global activate neuron_cli
```

### Option 3: Development Mode

```bash
cd packages/neuron_cli
dart pub global activate --source path .
```

## Quick Reference

| Action | Full Form | Short Form |
|---|---|---|
| Create project | `neuron create my_app` | — |
| Init in existing project | `neuron init` | — |
| Generate screen | `neuron generate screen settings` | `neuron g s settings` |
| Generate controller | `neuron generate controller auth` | `neuron g c auth` |
| Generate model | `neuron generate model user` | `neuron g m user` |
| Remove screen | `neuron remove screen settings` | `neuron r s settings` |
| Remove controller | `neuron remove controller auth` | `neuron r c auth` |
| Remove model | `neuron remove model user` | `neuron r m user` |

## Commands

### Create a new project

```bash
neuron create my_app
neuron create my_app --org com.mycompany
neuron create my_app --empty  # Without example code
```

Creates a new Flutter project with:
- Latest **neuron** dependency from pub.dev (fetched automatically)
- Modular project structure (`lib/modules/`, `lib/shared/`, `lib/routes/`, `lib/di/`)
- `NeuronApp` with `NeuronRoute`-based routing
- Central dependency injection via `setupDependencies()`
- Example home module (unless `--empty`)

### Initialize Neuron in an existing project

```bash
neuron init
neuron init --empty
```

Converts an existing Flutter project into a Neuron project — adds the dependency, creates the directory structure, and generates initial routes/DI.

### Generate a screen (module)

```bash
neuron generate screen settings    # Full form
neuron g s settings                # Short form
neuron g s settings --path /app/settings   # Custom route path
neuron g s settings --no-route     # Skip route registration
```

Generates a self-contained module:
- `lib/modules/settings/settings_controller.dart` — NeuronController with signals
- `lib/modules/settings/settings_view.dart` — StatelessWidget with Signal/Slot binding
- Auto-registers route in `lib/routes/app_routes.dart`
- Auto-registers controller in `lib/di/injector.dart`

### Generate a controller

```bash
neuron generate controller auth    # Full form
neuron g c auth                    # Short form
```

Creates a standalone controller at `lib/shared/controllers/auth_controller.dart` and registers it in the DI injector.

### Generate a model

```bash
neuron generate model user                                    # Full form
neuron g m user                                               # Short form
neuron g m user -f id:int -f name:String -f email:String      # With fields
neuron g m user -f id:int -f nickname:String?                 # Nullable field
```

Creates a model at `lib/shared/models/user.dart` with:
- Immutable fields
- `copyWith()` method
- JSON serialization (`fromJson`, `toJson`)
- Equality operators
- `toString()`

### Remove components

```bash
neuron remove screen settings      # or: neuron r s settings
neuron remove controller auth      # or: neuron r c auth
neuron remove model user           # or: neuron r m user
```

Removes the component files **and** automatically cleans up:
- Route entries from `app_routes.dart` (for screens)
- DI entries from `injector.dart` (for screens and controllers)
- JSON manifests (`.routes.json`, `.controllers.json`)

## Project Structure

After `neuron create my_app`:

```
my_app/
├── lib/
│   ├── main.dart              # NeuronApp entry point
│   ├── di/
│   │   └── injector.dart      # Central DI — setupDependencies()
│   ├── routes/
│   │   └── app_routes.dart    # NeuronRoute list — appRoutes
│   ├── modules/
│   │   └── home/
│   │       ├── home_controller.dart
│   │       └── home_view.dart
│   └── shared/
│       ├── controllers/       # Standalone controllers
│       ├── models/            # Data models
│       ├── widgets/           # Reusable widgets
│       ├── services/          # API, storage, etc.
│       └── utils/             # Utilities
├── .routes.json               # Route manifest (source of truth)
├── .controllers.json          # DI manifest (source of truth)
└── pubspec.yaml
```

## How It Works

### Automatic Routing

Routes are managed via a `.routes.json` manifest. When you add or remove a screen, the CLI updates the manifest and regenerates `app_routes.dart`:

```dart
// lib/routes/app_routes.dart (auto-generated)
import 'package:neuron/neuron.dart';
import '../modules/home/home_view.dart';
import '../modules/settings/settings_view.dart';

final List<NeuronRoute> appRoutes = [
  NeuronRoute(name: 'home', path: '/', view: () => const HomeView()),
  NeuronRoute(name: 'settings', path: '/settings', view: () => const SettingsView()),
];
```

### Dependency Injection

Controllers are managed via a `.controllers.json` manifest. The CLI generates `injector.dart` with all registrations:

```dart
// lib/di/injector.dart (auto-generated)
import 'package:neuron/neuron.dart';
import '../modules/home/home_controller.dart';
import '../modules/settings/settings_controller.dart';

void setupDependencies() {
  Neuron.install<HomeController>(() => HomeController());
  Neuron.install<SettingsController>(() => SettingsController());
}
```

### Entry Point

```dart
// lib/main.dart
import 'package:neuron/neuron.dart';
import 'di/injector.dart';
import 'routes/app_routes.dart';

void main() {
  setupDependencies();
  runApp(NeuronApp(
    routes: appRoutes,
    initialRoute: '/',
  ));
}
```

### Navigation

```dart
// Context-less navigation (from anywhere)
Neuron.toNamed('settings');
Neuron.to(const SettingsView());

// With arguments
Neuron.toNamed('settings', arguments: {'id': 123});
```

## Architecture

Neuron CLI generates code following the **Signal/Slot** pattern:

- **Controllers** (`NeuronController`) — Hold business logic and reactive state as Signals
- **Views** (`StatelessWidget`) — React to changes using Slot widgets
- **DI** (`Neuron.install` / `Neuron.use`) — Central registration, type-safe access
- **No StatefulWidget** — All reactivity is handled by Signal/Slot binding

### Example Controller

```dart
class SettingsController extends NeuronController {
  static SettingsController get init => Neuron.use<SettingsController>();

  late final isDarkMode = Signal<bool>(false).bind(this);
  late final language = Signal<String>('en').bind(this);

  void toggleDarkMode() {
    isDarkMode.emit(!isDarkMode.val);
  }
}
```

### Example View

```dart
class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = SettingsController.init;

    return Scaffold(
      body: Slot<bool>(
        connect: c.isDarkMode,
        to: (context, isDark) => Switch(
          value: isDark,
          onChanged: (_) => c.toggleDarkMode(),
        ),
      ),
    );
  }
}
```

## Dynamic Version Resolution

The CLI automatically fetches the latest `neuron` version from pub.dev when creating or initializing projects. If the network is unavailable, it falls back to a known stable version.

## License

MIT License — see the main Neuron repository for details.
