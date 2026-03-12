# Neuron CLI ⚡

A powerful command-line interface for the [Neuron](https://pub.dev/packages/neuron) reactive framework.

## Installation

```bash
dart pub global activate neuron_cli
```

## Command Quick Reference

| Command | Alias | Description |
|---------|-------|-------------|
| `neuron create <name>` | — | Create a new Neuron project |
| `neuron init` | — | Add Neuron to an existing Flutter project |
| `neuron generate screen <name>` | `g s` | Screen with controller, view, route & DI |
| `neuron generate controller <name>` | `g c` | Standalone NeuronController |
| `neuron generate model <name>` | `g m` | Data model with JSON serialization |
| `neuron generate service <name>` | `g svc` | Service layer (with `--crud` / `--http`) |
| `neuron generate widget <name>` | `g w` | Reusable widget (with `--signal`) |
| `neuron generate middleware <name>` | `g mw` | Signal middleware |
| `neuron generate page <name>` | `g p` | Full-stack page (controller + view + service) |
| `neuron generate theme` | `g t` | Light/dark theme (material, minimal, glassmorphic) |
| `neuron language install <locale>` | `lang add` | Install a language (ARB + config) |
| `neuron language remove <locale>` | `lang remove` | Remove a language |
| `neuron language list` | `lang list` | List installed languages |
| `neuron remove screen <name>` | `r s` | Remove screen & clean up routes/DI |
| `neuron remove controller <name>` | `r c` | Remove controller & clean up DI |
| `neuron remove model <name>` | `r m` | Remove model file |
| `neuron remove service <name>` | `r svc` | Remove service & clean up DI |
| `neuron remove widget <name>` | `r w` | Remove widget file |
| `neuron list [type]` | `l` | List registered components |
| `neuron rename <type> <old> <new>` | `mv` | Rename & update all references |
| `neuron doctor` | — | Check project health |
| `neuron upgrade` | — | Upgrade neuron to latest (with `--regen`) |

---

## Create a New Project

```bash
neuron create my_app
neuron create my_app --org com.mycompany
neuron create my_app --empty  # minimal boilerplate
```

Creates a fully-configured Neuron project:
```
my_app/
├── lib/
│   ├── main.dart
│   ├── di/injector.dart
│   ├── routes/app_routes.dart
│   └── modules/home/
│       ├── home_controller.dart
│       └── home_view.dart
└── pubspec.yaml
```

## Init in Existing Project

```bash
cd my_existing_flutter_app
neuron init
neuron init --empty   # skip starter module
neuron init --force   # re-initialize
```

---

## Generate Components

### Screen

```bash
neuron g s login
neuron g s settings --path /app/settings
neuron g s profile --no-route
```

Creates `lib/modules/login/` with controller + view, registers route & DI.

### Controller

```bash
neuron g c auth
```

Creates `lib/shared/controllers/auth_controller.dart` and registers in DI.

### Model

```bash
neuron g m user -f id:int -f name:String -f email:String
```

Creates `lib/shared/models/user.dart` with copyWith, JSON conversion, equality.

### Service

```bash
neuron g svc auth               # base service
neuron g svc user --crud        # CRUD stubs (getAll, getById, create, update, delete)
neuron g svc api --http         # HTTP client (GET, POST, PUT, DELETE)
```

Creates `lib/shared/services/<name>_service.dart` and registers in DI.

### Widget

```bash
neuron g w avatar_card           # basic StatelessWidget
neuron g w status_badge --signal # Signal-aware widget with Slot<T>
```

Creates `lib/shared/widgets/<name>.dart`.

### Middleware

```bash
neuron g mw logging
```

Creates `lib/shared/middleware/logging_middleware.dart` extending `SignalMiddleware<T>`.

### Page (Full-Stack)

```bash
neuron g p products
neuron g p orders --path /admin/orders
```

Creates a **complete module** with:
- **Controller** — pre-wired with AsyncSignal and the service
- **View** — with AsyncSlot handling loading/error/data states
- **Service** — CRUD stubs ready for your data source

All registered in routes and DI automatically.

### Theme

```bash
neuron g t                                       # material theme, indigo
neuron g t --color blue --style minimal           # minimal theme, blue seed
neuron g t -c "#FF5722" -s glassmorphic --with-controller  # glassmorphic + runtime switching
```

Options:
- `--color` / `-c` — seed color name or hex (default: `indigo`)
- `--style` / `-s` — `material`, `minimal`, or `glassmorphic` (default: `material`)
- `--with-controller` — generate `ThemeController` for runtime light/dark switching

Creates `lib/app/theme.dart` (and optionally `lib/shared/controllers/theme_controller.dart`).

Usage:
```dart
// In MaterialApp
theme: AppTheme.light,
darkTheme: AppTheme.dark,
themeMode: ThemeMode.system,

// With controller
final tc = ThemeController.init;
tc.toggleTheme();
```

---

## Language / Localization

```bash
neuron language install es      # install Spanish
neuron language install ja      # install Japanese
neuron language list            # show installed languages
neuron language remove es       # remove Spanish
```

Aliases: `neuron lang`, `neuron l10n`

The `install` subcommand:
1. Creates `l10n.yaml` at project root
2. Creates `lib/l10n/app_en.arb` (English template) if missing
3. Creates `lib/l10n/app_<locale>.arb` with placeholder translations
4. Adds `flutter_localizations` dependency to `pubspec.yaml`
5. Sets `generate: true` in the `flutter` section
6. Updates `supportedLocales` in `main.dart`

Locale codes use ISO 639-1 (e.g. `en`, `es`, `fr`, `de`, `ja`, `zh`, `pt_BR`).

---

## Remove Components

```bash
neuron r s login          # remove screen module + routes + DI
neuron r c auth           # remove controller + DI
neuron r m user           # remove model file
neuron r svc auth         # remove service + DI
neuron r w avatar_card    # remove widget file
```

Prompts for confirmation before deleting.

---

## List Components

```bash
neuron l                  # show all components
neuron l screens          # just screens
neuron l services         # just services
neuron l routes           # just routes
neuron l controllers      # just controllers
neuron l models           # just models
```

Output:
```
📱 Screens (3):
   • home
   • login
   • settings

🎮 Controllers (1):
   • auth_controller

⚙️  Services (2):
   • shared/user_service
   • modules/products/products_service

📦 Models (1):
   • user

🔗 Routes (3):
   • home → / (HomeView)
   • login → /login (LoginView)
   • settings → /settings (SettingsView)
```

---

## Rename Components

```bash
neuron mv screen login auth       # rename module + files + references
neuron mv controller auth session # rename controller + DI
neuron mv model user account      # rename model + imports
neuron mv service auth session    # rename service + DI
```

Automatically updates:
- File & directory names
- Class names (PascalCase)
- Import paths across the project
- Route entries in `app_routes.dart`
- DI entries in `injector.dart`

---

## Doctor

```bash
neuron doctor
```

Output:
```
🏥 Neuron Doctor
─────────────────────────────────────

✓ pubspec.yaml found
✓ Flutter project detected
✓ Neuron dependency present
✓ Neuron is up to date (1.5.0)

📁 Project Structure:
   ✓ lib/modules/ (3 items)
   ✓ lib/shared/controllers/ (1 items)
   ○ lib/shared/services/ (not created yet)
   ✓ lib/routes/ (2 items)
   ✓ lib/di/ (2 items)

📋 Manifests:
   ✓ .routes.json (3 routes)
   ✓ .controllers.json (4 entries)

🔍 Orphan Check:
   ✓ No orphaned modules found

📝 Generated Files:
   ✓ lib/routes/app_routes.dart
   ✓ lib/di/injector.dart
   ✓ lib/main.dart

─────────────────────────────────────
✓ No issues found — project is healthy! 🎉
```

---

## Upgrade

```bash
neuron upgrade              # update neuron version + pub get
neuron upgrade --regen      # also regenerate routes & DI from manifests
```

---

## Architecture Overview

Neuron uses the **Signal/Slot** reactive pattern:

- **Signal** — A reactive value that notifies listeners on change
- **Slot** — A widget that rebuilds when its connected Signal changes
- **NeuronController** — Lifecycle-aware controller holding Signals
- **Neuron.use<T>()** — Service locator for dependency injection
- **NeuronApp** — App wrapper with context-less navigation

```dart
// Controller
class HomeController extends NeuronController {
  static HomeController get init => Neuron.use<HomeController>();

  late final counter = Signal<int>(0).bind(this);

  void increment() => counter.emit(counter.value + 1);
}

// View
class HomeView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = HomeController.init;
    return Slot<int>(
      connect: c.counter,
      to: (ctx, count) => Text('Count: $count'),
    );
  }
}
```

## Dynamic Version Resolution

The CLI automatically fetches the latest Neuron version from pub.dev when creating or initializing projects, ensuring you always start with the most recent release.
