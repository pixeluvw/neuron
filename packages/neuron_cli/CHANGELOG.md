# Changelog

## 1.1.6

### New Features
- **Full OS-level language switching**: `neuron language install` now generates a `LocaleController` with `Signal<Locale>` persisted via `shared_preferences`. Changing the locale rebuilds the entire app — like switching the system language on Linux/Windows/macOS.
- **Comprehensive translations**: ARB files now include 40+ keys per locale (navigation, auth, feedback, settings) so the whole UI translates, not just a handful of words.
- **Language picker screen**: Auto-generated `LanguageView` at `lib/modules/language/` lists installed locales with native names. Tap to switch instantly.
- **Locale-aware main.dart**: `main.dart` is rewritten with a `Slot<Locale>` wrapping `NeuronApp` so locale changes propagate app-wide.
- **Neuron-compatible widget test**: `neuron create` and `neuron init` now overwrite the default `test/widget_test.dart` with a test that imports Neuron's DI and routes, eliminating broken-test errors.

### Fixed
- Fixed ARB `@`-metadata entries output as strings instead of JSON objects (caused `flutter gen-l10n` to fail).
- Added `shared_preferences` auto-dependency when installing languages.

## 1.1.5

### Fixed
- Fixed `_ensureGenerateFlag` and `_ensureLocalizationDependency` regex to match only root-level YAML keys, preventing pubspec.yaml corruption.
- Removed `const` from generated `localizationsDelegates` list to avoid `non_constant_list_element` error.
- `isNeuronProject()` now rethrows `YamlException` instead of silently returning `false`, giving users the actual parse error.

## 1.1.4

- Updated README with documentation for `generate theme` and `language` commands.

## 1.1.3

### New Commands
- `neuron generate theme` — generate light/dark theme with `--color`, `--style` (material, minimal, glassmorphic), and `--with-controller` for runtime switching
- `neuron language install <locale>` — install a language with ARB scaffold, pubspec updates, and supported locales wiring
- `neuron language remove <locale>` — remove a language
- `neuron language list` — list installed languages

### Fixes
- Suppressed `avoid_print` lint in example file

## 1.1.2

- Fixed `list` command: replaced subcommand pattern with positional argument so `neuron list` works without arguments.
- Fixed test compilation error from merge artifact.

## 1.1.1

- Maintenance release: refined metadata, updated dependencies, and improved documentation.
- Added usage example.

## 1.1.0

### New Generate Commands
- `neuron generate service <name>` — with `--crud` and `--http` variants
- `neuron generate widget <name>` — with `--signal` for reactive widgets
- `neuron generate middleware <name>` — Signal middleware scaffolding
- `neuron generate page <name>` — full-stack page (controller + view + service, pre-wired with AsyncSignal)

### New Top-Level Commands
- `neuron list` — introspect project components (screens, controllers, services, models, routes)
- `neuron rename` — safely rename components with project-wide reference updates
- `neuron doctor` — comprehensive project health checker
- `neuron upgrade` — update neuron dependency with optional `--regen` flag

### New Remove Commands
- `neuron remove service <name>` — remove service and clean up DI
- `neuron remove widget <name>` — remove widget file

### Improvements
- Added command aliases: `g`, `r`, `l`, `mv`
- Added `regenerateFromManifest` to route and DI generators
- Expanded test suite to 47 tests

## 1.0.0

- Initial release
- `neuron create` — create new Neuron projects (counter and smart_home templates)
- `neuron init` — initialize Neuron in existing Flutter projects
- `neuron generate screen` — generate screen modules with route and DI registration
- `neuron generate controller` — generate standalone controllers
- `neuron generate model` — generate model classes with fields
- `neuron remove screen|controller|model` — remove components with cleanup
