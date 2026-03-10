## Plan: Modernize neuron_cli — Published Dep, Auto-Routing, DI, Remove Command

Overhaul neuron_cli to: (1) reference neuron as a pub.dev dependency (`^1.4.0`) instead of git, (2) remove all DevTools references, (3) auto-generate/maintain a central `NeuronRoute`-based routes file when adding/removing screens, (4) add a central DI injector pattern, (5) add `neuron remove` command for screens/controllers/models.

---

### Phase 1: Published Dependency & DevTools Cleanup

1. **Update [project_templates.dart](lib/src/templates/project_templates.dart)** — `mainDart()`: remove `enableDevTools: true` line and its comment
2. **Update [project_generator.dart](lib/src/generators/project_generator.dart)** — `_generateCleanPubspec()`: replace git block with `neuron: ^1.4.0`
3. **Update [init_generator.dart](lib/src/generators/init_generator.dart)** — `_rewritePubspec()`: same git→pub.dev swap
4. **Update [screen_generator.dart](lib/src/generators/screen_generator.dart)** — `_ensureNeuronDependency()`: inject `neuron: ^1.4.0` instead of git block

---

### Phase 2: Auto-Routing System (NeuronRoute-based)

Uses a JSON manifest (`lib/routes/.routes.json`) as source of truth. `lib/routes/app_routes.dart` is always regenerated from it — avoids fragile Dart code parsing.

5. **Create `route_templates.dart`** — NEW template for `app_routes.dart` generating `List<NeuronRoute> appRoutes = [...]` with imports and `NeuronRoute(name:, path:, builder:)` per screen *(parallel with 6)*
6. **Rewrite [route_generator.dart](lib/src/generators/route_generator.dart)** — manifest-based: `addRoute()` reads `.routes.json`, adds entry, regenerates `app_routes.dart`; `removeRoute()` does the inverse *(parallel with 5)*
7. **Update [screen_generator.dart](lib/src/generators/screen_generator.dart)** — after generating files, call `RouteGenerator.addRoute()` *(depends on 6)*
8. **Update [project_templates.dart](lib/src/templates/project_templates.dart)** — `mainDart()`: import routes, pass `routes: appRoutes`, use `initialRoute: '/'` instead of `home: const HomeView()`
9. **Update [project_generator.dart](lib/src/generators/project_generator.dart)** — generate initial `app_routes.dart` + manifest with home route; create `lib/routes/` dir *(depends on 5,6)*
10. **Update [init_generator.dart](lib/src/generators/init_generator.dart)** — same as step 9 *(depends on 5,6)*

---

### Phase 3: Central Dependency Injection

Same manifest approach: `lib/di/.controllers.json` → always regenerates `lib/di/injector.dart`.

11. **Create `di_templates.dart`** — NEW: template for `injector.dart` with `setupDependencies()` calling `Neuron.install<T>()` per controller *(parallel with 12)*
12. **Create `di_generator.dart`** — NEW: manifest-based `addController()`/`removeController()` *(parallel with 11)*
13. **Update [screen_generator.dart](lib/src/generators/screen_generator.dart)** — register screen controller via `DiGenerator.addController()` *(depends on 12)*
14. **Update [controller_generator.dart](lib/src/generators/controller_generator.dart)** — register shared controller in DI *(depends on 12)*
15. **Update [project_templates.dart](lib/src/templates/project_templates.dart)** — `mainDart()`: import `di/injector.dart`, call `setupDependencies()` before `runApp()`
16. **Update [project_generator.dart](lib/src/generators/project_generator.dart) and [init_generator.dart](lib/src/generators/init_generator.dart)** — generate initial `lib/di/injector.dart` *(depends on 11,12)*
17. **Update templates** — change `Neuron.ensure<T>(()=> T())` → `Neuron.use<T>()` in [screen_templates.dart](lib/src/templates/screen_templates.dart) and [controller_templates.dart](lib/src/templates/controller_templates.dart) since `setupDependencies()` guarantees registration

---

### Phase 4: Remove Command

18. **Create `remove_command.dart`** — NEW: `RemoveCommand` with 3 subcommands (aliases: `r s`, `r c`, `r m`)
19. **`RemoveScreenCommand`** (`neuron remove screen <name>`) — deletes `lib/modules/<name>/`, calls `RouteGenerator.removeRoute()` + `DiGenerator.removeController()`, confirms with user via prompt *(depends on 6,12)*
20. **`RemoveControllerCommand`** (`neuron remove controller <name>`) — deletes file, cleans DI *(depends on 12)*
21. **`RemoveModelCommand`** (`neuron remove model <name>`) — deletes file only (no route/DI impact)
22. **Register in [cli_runner.dart](lib/src/cli_runner.dart)** — add `RemoveCommand` to runner
23. **Update barrel files** — [commands.dart](lib/src/commands/commands.dart), [generators.dart](lib/src/generators/generators.dart), [templates.dart](lib/src/templates/templates.dart)

---

### Phase 5: Wiring & Testing *(depends on all above)*

24. Update [neuron_cli.dart](lib/neuron_cli.dart) for new exports
25. Update [cli_test.dart](test/cli_test.dart) — add tests for `remove --help`, route/DI round-trips
26. Manual verification via `neuron create test_app`

---

### Verification

1. `dart analyze` — no errors
2. `dart test` — all pass
3. `neuron create test_project` → `pubspec.yaml` has `neuron: ^1.4.0`, no `enableDevTools`, routes file with `/` home, injector with `HomeController`
4. `neuron generate screen profile` → module created, `app_routes.dart` + `injector.dart` updated
5. `neuron generate controller auth` → file + DI updated
6. `neuron remove screen profile` → dir deleted, routes + DI cleaned
7. `neuron remove controller auth` / `neuron remove model user` → files deleted, DI cleaned

---

### Decisions

- **JSON manifests** (`.routes.json`, `.controllers.json`) as source of truth — regenerated Dart is never parsed back
- **DI pattern**: `Neuron.use<T>()` replaces `Neuron.ensure<T>()` — guaranteed by `setupDependencies()`
- **`enableDevTools`**: removed entirely (not in `NeuronApp` API)
- **`initialRoute: '/'`** replaces `home:` parameter — unified routing model
- **Scope**: CLI only — no framework changes

### New Files (4)
- `lib/src/templates/route_templates.dart`
- `lib/src/templates/di_templates.dart`
- `lib/src/generators/di_generator.dart`
- `lib/src/commands/remove_command.dart`

### Modified Files (14)
- `lib/src/templates/project_templates.dart`, `screen_templates.dart`, `controller_templates.dart`, `templates.dart`
- `lib/src/generators/route_generator.dart`, `screen_generator.dart`, `controller_generator.dart`, `project_generator.dart`, `init_generator.dart`, `generators.dart`
- `lib/src/commands/commands.dart`
- `lib/src/cli_runner.dart`
- `lib/neuron_cli.dart`
- `test/cli_test.dart`
