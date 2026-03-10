# Changelog

## 1.1.1

- Pub.dev score optimizations (shorter description, fixed repo URL, updated dependencies, added example).
- Improved documentation and code quality scores.

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
