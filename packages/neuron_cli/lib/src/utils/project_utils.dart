import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:yaml/yaml.dart';

/// Utility class for project-related operations
class ProjectUtils {
  /// Cached latest neuron version from pub.dev
  static String? _cachedVersion;

  /// Fetch the latest neuron package version from pub.dev.
  /// Falls back to [fallback] if the network request fails.
  static Future<String> getLatestNeuronVersion({
    String fallback = '1.5.0',
  }) async {
    if (_cachedVersion != null) return _cachedVersion!;

    try {
      final client = HttpClient()
        ..connectionTimeout = const Duration(seconds: 5);
      final request =
          await client.getUrl(Uri.parse('https://pub.dev/api/packages/neuron'));
      final response = await request.close();

      if (response.statusCode == 200) {
        final body = await response.transform(utf8.decoder).join();
        final json = jsonDecode(body) as Map<String, dynamic>;
        final version = json['latest']?['version'] as String?;
        if (version != null) {
          _cachedVersion = version;
          return version;
        }
      }
    } catch (_) {
      // Network failure — use fallback
    }
    return fallback;
  }
  /// Check if the current directory is a Neuron/Flutter project
  static Future<bool> isNeuronProject() async {
    final pubspecFile = File(path.join(Directory.current.path, 'pubspec.yaml'));

    if (!await pubspecFile.exists()) {
      return false;
    }

    try {
      final content = await pubspecFile.readAsString();
      final yaml = loadYaml(content);
      if (yaml is! YamlMap) return false;

      // Check for flutter dependency
      final dependencies = yaml['dependencies'];
      if (dependencies is! YamlMap) return false;

      // Must have flutter
      if (!dependencies.containsKey('flutter')) return false;

      // Should have neuron (or we'll add it)
      return true;
    } on YamlException {
      rethrow;
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
