/// Controller entry for DI manifest tracking
class ControllerEntry {
  /// Creates a new controller entry
  const ControllerEntry({
    required this.name,
    required this.className,
    required this.importPath,
    required this.isShared,
  });

  /// Creates a controller entry from a JSON map
  factory ControllerEntry.fromJson(Map<String, dynamic> json) =>
      ControllerEntry(
        name: json['name'] as String,
        className: json['className'] as String,
        importPath: json['importPath'] as String,
        isShared: json['isShared'] as bool,
      );

  /// The name of the controller (snake_case)
  final String name;

  /// The Dart class name of the controller
  final String className;

  /// The import path to the controller file
  final String importPath;

  /// Whether this is a shared controller or module-specific
  final bool isShared;

  Map<String, dynamic> toJson() => {
        'name': name,
        'className': className,
        'importPath': importPath,
        'isShared': isShared,
      };
}

/// Templates for dependency injection
class DiTemplates {
  /// Generate the full injector.dart file from a list of controller entries
  static String injectorDart(List<ControllerEntry> controllers) {
    final buffer = StringBuffer();

    // Imports
    buffer.writeln("import 'package:neuron/neuron.dart';");
    buffer.writeln();

    for (final controller in controllers) {
      buffer.writeln("import '${controller.importPath}';");
    }

    buffer.writeln();
    buffer.writeln('/// Register all controllers for dependency injection.');
    buffer.writeln('/// DO NOT EDIT — maintained by neuron CLI.');
    buffer.writeln('void setupDependencies() {');

    for (final controller in controllers) {
      buffer.writeln(
          '  Neuron.install<${controller.className}>(${controller.className}());');
    }

    buffer.writeln('}');

    return buffer.toString();
  }
}
