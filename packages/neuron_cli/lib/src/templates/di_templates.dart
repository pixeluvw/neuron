/// The kind of dependency being registered.
enum EntryType {
  /// A service — registered before controllers so they are available
  /// when controllers resolve their dependencies.
  service,

  /// A controller — registered after services.
  controller;

  /// Parse from a string value, defaulting to [controller].
  static EntryType fromString(String? value) =>
      value == 'service' ? EntryType.service : EntryType.controller;
}

/// Controller entry for DI manifest tracking
class ControllerEntry {
  /// Creates a new controller entry for registration and tracking.
  const ControllerEntry({
    required this.name,
    required this.className,
    required this.importPath,
    required this.isShared,
    this.type = EntryType.controller,
  });

  /// The registration name of the controller.
  final String name;

  /// The Dart class name of the controller.
  final String className;

  /// The file path for importing the controller.
  final String importPath;

  /// Indicates if the controller is shared across modules.
  final bool isShared;

  /// Whether this entry is a service or a controller.
  final EntryType type;
}

/// Templates for dependency injection
class DiTemplates {
  static final _installPattern =
      RegExp(r'Neuron\.install<(\w+)>\(');
  static final _importPattern =
      RegExp(r"import\s+'([^']+)';");
  static final _serviceSection = RegExp(r'//.*Services');
  static final _controllerSection = RegExp(r'//.*Controllers');

  /// Parse a generated `injector.dart` file back into [ControllerEntry] list.
  ///
  /// This makes the Dart file the single source of truth — no JSON needed.
  static List<ControllerEntry> parseInjectorDart(String content) {
    final lines = content.split('\n').map((l) => l.trim()).toList();

    // 1. Build className → importPath map from import lines
    //    e.g. "import '../modules/home/home_controller.dart';" → HomeController → path
    final importPaths = <String, String>{};
    for (final line in lines) {
      final m = _importPattern.firstMatch(line);
      if (m != null) {
        final path = m.group(1)!;
        if (path == 'package:neuron/neuron.dart') continue;
        // Derive class name from file: home_controller.dart → HomeController
        // We'll match it later by className from install lines.
        importPaths[path] = path;
      }
    }

    // 2. Walk install lines and track current section
    var currentType = EntryType.controller;
    final entries = <ControllerEntry>[];

    for (final line in lines) {
      if (_serviceSection.hasMatch(line)) {
        currentType = EntryType.service;
        continue;
      }
      if (_controllerSection.hasMatch(line)) {
        currentType = EntryType.controller;
        continue;
      }

      final m = _installPattern.firstMatch(line);
      if (m != null) {
        final className = m.group(1)!;

        // Find the matching import path for this className
        // The import filename (snake_case) corresponds to the className (PascalCase)
        String? matchedImport;
        for (final path in importPaths.keys) {
          final basename = path.split('/').last.replaceAll('.dart', '');
          // Convert snake_case to PascalCase for comparison
          final pascal = basename
              .split('_')
              .map((s) => s.isEmpty ? '' : '${s[0].toUpperCase()}${s.substring(1)}')
              .join();
          if (pascal == className) {
            matchedImport = path;
            break;
          }
        }

        // Derive a registration name from className
        // e.g. HomeController → home, AuthService → auth
        final name = _classNameToRegistrationName(className);

        entries.add(ControllerEntry(
          name: name,
          className: className,
          importPath: matchedImport ?? '',
          isShared: currentType == EntryType.service,
          type: currentType,
        ));
      }
    }

    return entries;
  }

  /// Convert PascalCase class name to a registration name.
  ///
  /// e.g. `HomeController` → `home`, `AuthService` → `auth`,
  ///      `SupabaseRepositoryService` → `supabase_repository`
  static String _classNameToRegistrationName(String className) {
    var name = className;
    // Strip common suffixes
    for (final suffix in ['Controller', 'Service']) {
      if (name.endsWith(suffix) && name != suffix) {
        name = name.substring(0, name.length - suffix.length);
      }
    }
    // PascalCase → snake_case
    return name
        .replaceAllMapped(
            RegExp(r'[A-Z]'), (m) => '_${m.group(0)!.toLowerCase()}')
        .replaceAll(RegExp(r'^_'), '');
  }
  /// Generate the full injector.dart file from a list of controller entries.
  ///
  /// Services are always registered before controllers so that any
  /// controller that resolves a service via `Neuron.use` during `onInit`
  /// will find it already installed.
  static String injectorDart(List<ControllerEntry> entries) {
    // Sort: services first, then controllers (stable sort preserves order
    // within each group).
    final sorted = [...entries]
      ..sort((a, b) => a.type.index.compareTo(b.type.index));

    final buffer = StringBuffer();

    // Imports
    buffer.writeln("import 'package:neuron/neuron.dart';");
    buffer.writeln();

    for (final entry in sorted) {
      buffer.writeln("import '${entry.importPath}';");
    }

    buffer.writeln();
    buffer.writeln('/// Register all controllers for dependency injection.');
    buffer.writeln('/// DO NOT EDIT — maintained by neuron CLI.');
    buffer.writeln('void setupDependencies() {');

    // Emit grouped comments for readability
    final services = sorted.where((e) => e.type == EntryType.service).toList();
    final controllers =
        sorted.where((e) => e.type == EntryType.controller).toList();

    if (services.isNotEmpty) {
      buffer.writeln('  // ── Services ────────────────────────────────────');
      for (final s in services) {
        buffer.writeln(
            '  Neuron.install<${s.className}>(${s.className}());');
      }
    }

    if (controllers.isNotEmpty) {
      if (services.isNotEmpty) buffer.writeln();
      buffer.writeln('  // ── Controllers ─────────────────────────────────');
      for (final c in controllers) {
        buffer.writeln(
            '  Neuron.install<${c.className}>(${c.className}());');
      }
    }

    buffer.writeln('}');

    return buffer.toString();
  }
}
