import 'dart:io';

import 'package:mason_logger/mason_logger.dart';
import 'package:path/path.dart' as path;

import '../templates/templates.dart';

/// Generator for managing the central DI injector file.
///
/// Uses `lib/di/injector.dart` as the single source of truth.
/// Parses the Dart file to read entries and regenerates it after mutations.
class DiGenerator {
  DiGenerator({required this.logger});

  final Logger logger;

  String get _diDir => path.join(Directory.current.path, 'lib', 'di');
  String get _injectorPath => path.join(_diDir, 'injector.dart');

  /// Read the current entries by parsing the generated Dart file.
  Future<List<ControllerEntry>> _readEntries() async {
    final file = File(_injectorPath);
    if (!await file.exists()) return [];

    try {
      final content = await file.readAsString();
      return DiTemplates.parseInjectorDart(content);
    } catch (_) {
      return [];
    }
  }

  /// Write entries by regenerating injector.dart.
  Future<void> _writeEntries(List<ControllerEntry> entries) async {
    await Directory(_diDir).create(recursive: true);
    await File(_injectorPath)
        .writeAsString(DiTemplates.injectorDart(entries));
  }

  /// Add a controller to the DI registry and regenerate.
  Future<void> addController({
    required String name,
    required String className,
    required String importPath,
    required bool isShared,
    EntryType type = EntryType.controller,
  }) async {
    final entries = await _readEntries();

    // Skip if already registered
    if (entries.any((c) => c.className == className)) return;

    entries.add(ControllerEntry(
      name: name,
      className: className,
      importPath: importPath,
      isShared: isShared,
      type: type,
    ));

    await _writeEntries(entries);
  }

  /// Remove a controller from the DI registry and regenerate.
  Future<void> removeController(String className) async {
    final entries = await _readEntries();
    final before = entries.length;
    entries.removeWhere((c) => c.className == className);

    if (entries.length < before) {
      await _writeEntries(entries);
    }
  }

  /// Generate the initial injector from a list of entries (used by create/init).
  Future<void> generateInitial(List<ControllerEntry> entries) async {
    await _writeEntries(entries);
  }

  /// Regenerate injector.dart from its current content (used by upgrade --regen).
  ///
  /// Useful when the template format changes after a CLI upgrade.
  Future<void> regenerate() async {
    final entries = await _readEntries();
    await _writeEntries(entries);
  }
}
