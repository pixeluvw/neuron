# Neuron CLI

Command-line interface for Neuron. Generate projects, screens, controllers, and models with Signal/Slot architecture.

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

### Option 3: Development Mode (verbose output)

```bash
cd packages/neuron_cli
dart pub global activate --source path .
# Note: This shows dependency resolution logs on each run
```

## Commands

### Create a new project

```bash
neuron create my_app
neuron create my_app --org com.mycompany
neuron create my_app --empty  # Without example code
```

This creates a new Flutter project with:
- Neuron dependency configured
- Project structure (`lib/screens`, `lib/controllers`, `lib/models`, etc.)
- Route system with auto-registration
- Example home screen (unless `--empty`)

### Generate a screen

```bash
neuron generate screen settings
neuron g s settings  # Short form
neuron g s settings --path /app/settings  # Custom route path
neuron g s settings --no-route  # Skip route registration
```

This generates:
- `lib/screens/settings/settings_controller.dart` - NeuronController with signals
- `lib/screens/settings/settings_view.dart` - StatelessWidget with Signal/Slot binding
- Auto-registers route in `lib/routes/app_routes.dart`
- Adds navigation helper in `lib/routes/neuron_router.dart`

### Generate a controller

```bash
neuron generate controller auth
neuron g c auth  # Short form
```

Creates a standalone controller at `lib/controllers/auth_controller.dart`.

### Generate a model

```bash
neuron generate model user
neuron g m user -f id:int -f name:String -f email:String -f createdAt:DateTime
neuron g m user -f id:int -f nickname:String?  # Nullable field
```

Creates a model at `lib/models/user.dart` with:
- Immutable fields
- `copyWith()` method
- JSON serialization (`fromJson`, `toJson`)
- Equality operators
- `toString()` implementation

## Project Structure

After creating a project with `neuron create`, you get:

```
my_app/
├── lib/
│   ├── main.dart
│   ├── app.dart
│   ├── controllers/        # Standalone controllers
│   ├── models/             # Data models
│   ├── routes/
│   │   ├── app_routes.dart      # Route definitions
│   │   └── neuron_router.dart   # Navigation helpers
│   ├── screens/
│   │   └── home/
│   │       ├── home_controller.dart
│   │       └── home_view.dart
│   ├── services/           # Business logic services
│   ├── utils/              # Utility functions
│   └── widgets/            # Reusable widgets
├── pubspec.yaml
└── ...
```

## Usage Example

After generating a screen:

```dart
// Navigate using NeuronRouter
NeuronRouter.toSettings(context);
NeuronRouter.toSettings(context, arguments: {'id': 123});

// Or use named routes
Navigator.pushNamed(context, AppRoutes.settings);
Navigator.pushNamed(context, '/settings');
```

## Architecture

Neuron CLI generates code following the Signal/Slot pattern:

- **Controllers** (`NeuronController`): Hold business logic and state as Signals
- **Views** (`StatelessWidget`): React to Signal changes using Slot widgets
- **No StatefulWidget**: All reactivity is handled by Signal/Slot binding

Example generated controller:

```dart
class SettingsController extends NeuronController {
  /// Static getter for the controller (lazy singleton)
  static SettingsController get init =>
      Neuron.ensure<SettingsController>(() => SettingsController());

  late final isDarkMode = Signal<bool>(false).bind(this);
  late final language = Signal<String>('en').bind(this);
  
  void toggleDarkMode() {
    isDarkMode.emit(!isDarkMode.val);
  }
}
```

Example generated view:

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

## License

MIT License - see the main Neuron repository for details.
