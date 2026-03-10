import 'dart:convert';
import 'dart:io';

import 'package:mason_logger/mason_logger.dart';
import 'package:path/path.dart' as path;

import '../templates/templates.dart';

/// Generator for managing the central DI injector file.
///
/// Uses a JSON manifest (`lib/di/.controllers.json`) as source of truth.
/// Always regenerates `lib/di/injector.dart` from the manifest.
class DiGenerator {
  DiGenerator({required this.logger});

  final Logger logger;

  String get _diDir => path.join(Directory.current.path, 'lib', 'di');
  String get _manifestPath => path.join(_diDir, '.controllers.json');
  String get _injectorPath => path.join(_diDir, 'injector.dart');

  /// Read the current controller manifest
  Future<List<ControllerEntry>> _readManifest() async {
    final file = File(_manifestPath);
    if (!await file.exists()) return [];

    try {
      final content = await file.readAsString();
      final list = jsonDecode(content) as List;
      return list
          .map((e) => ControllerEntry.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Write the manifest and regenerate injector.dart
  Future<void> _writeManifest(List<ControllerEntry> controllers) async {
    await Directory(_diDir).create(recursive: true);

    // Write JSON manifest
    final json =
        const JsonEncoder.withIndent('  ').convert(controllers.map((c) => c.toJson()).toList());
    await File(_manifestPath).writeAsString(json);

    // Regenerate injector.dart
    await File(_injectorPath)
        .writeAsString(DiTemplates.injectorDart(controllers));
  }

  /// Add a controller to the DI manifest and regenerate
  Future<void> addController({
    required String name,
    required String className,
    required String importPath,
    required bool isShared,
  }) async {
    final controllers = await _readManifest();

    // Skip if already registered
    if (controllers.any((c) => c.className == className)) return;

    controllers.add(ControllerEntry(
      name: name,
      className: className,
      importPath: importPath,
      isShared: isShared,
    ));

    await _writeManifest(controllers);
  }

  /// Remove a controller from the DI manifest and regenerate
  Future<void> removeController(String className) async {
    final controllers = await _readManifest();
    final before = controllers.length;
    controllers.removeWhere((c) => c.className == className);

    if (controllers.length < before) {
      await _writeManifest(controllers);
    }
  }

  /// Generate the initial injector from a list of entries (used by create/init)
  Future<void> generateInitial(List<ControllerEntry> controllers) async {
    await _writeManifest(controllers);
  }
}
