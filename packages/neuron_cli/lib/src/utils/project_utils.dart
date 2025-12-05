import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:yaml/yaml.dart';

/// Utility class for project-related operations
class ProjectUtils {
  /// Check if the current directory is a Neuron/Flutter project
  static Future<bool> isNeuronProject() async {
    final pubspecFile = File(path.join(Directory.current.path, 'pubspec.yaml'));

    if (!await pubspecFile.exists()) {
      return false;
    }

    try {
      final content = await pubspecFile.readAsString();
      final yaml = loadYaml(content) as YamlMap;

      // Check for flutter dependency
      final dependencies = yaml['dependencies'] as YamlMap?;
      if (dependencies == null) return false;

      // Must have flutter
      if (!dependencies.containsKey('flutter')) return false;

      // Should have neuron (or we'll add it)
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get the project name from pubspec.yaml
  static Future<String?> getProjectName() async {
    final pubspecFile = File(path.join(Directory.current.path, 'pubspec.yaml'));

    if (!await pubspecFile.exists()) {
      return null;
    }

    try {
      final content = await pubspecFile.readAsString();
      final yaml = loadYaml(content) as YamlMap;
      return yaml['name'] as String?;
    } catch (e) {
      return null;
    }
  }

  /// Ensure a directory exists
  static Future<void> ensureDirectory(String dirPath) async {
    final dir = Directory(dirPath);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
  }

  /// Check if a file exists
  static Future<bool> fileExists(String filePath) async {
    return File(filePath).exists();
  }

  /// Read file contents
  static Future<String> readFile(String filePath) async {
    return File(filePath).readAsString();
  }

  /// Write file contents
  static Future<void> writeFile(String filePath, String content) async {
    await File(filePath).writeAsString(content);
  }
}
