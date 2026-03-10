import 'dart:convert';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:path/path.dart' as path;

import '../utils/utils.dart';

/// Command to diagnose project health
class DoctorCommand extends Command<int> {
  DoctorCommand({required Logger logger}) : _logger = logger;

  final Logger _logger;

  @override
  String get name => 'doctor';

  @override
  String get description => 'Check project health and report issues';

  @override
  Future<int> run() async {
    _logger.info('');
    _logger.info('🏥 Neuron Doctor');
    _logger.info('─────────────────────────────────────');
    _logger.info('');

    var issues = 0;
    var warnings = 0;

    // 1. Check pubspec.yaml
    final pubspecFile =
        File(path.join(Directory.current.path, 'pubspec.yaml'));
    if (!await pubspecFile.exists()) {
      _logger.err('✗ No pubspec.yaml found — not a Dart/Flutter project');
      return ExitCode.usage.code;
    }
    _logger.success('✓ pubspec.yaml found');

    // 2. Check it's a Flutter project
    if (!await ProjectUtils.isNeuronProject()) {
      _logger.err('✗ Not a Flutter project (missing flutter dependency)');
      issues++;
    } else {
      _logger.success('✓ Flutter project detected');
    }

    // 3. Check neuron dependency
    final pubContent = await pubspecFile.readAsString();
    if (!pubContent.contains('neuron:')) {
      _logger.err('✗ Neuron dependency missing from pubspec.yaml');
      _logger.info('  Fix: neuron init  (or add neuron manually)');
      issues++;
    } else {
      _logger.success('✓ Neuron dependency present');

      // Check if it's the latest version
      try {
        final latestVersion = await ProjectUtils.getLatestNeuronVersion();
        if (!pubContent.contains(latestVersion)) {
          _logger.warn(
              '⚠ Neuron may not be the latest version (latest: $latestVersion)');
          _logger.info('  Fix: neuron upgrade');
          warnings++;
        } else {
          _logger.success('✓ Neuron is up to date ($latestVersion)');
        }
      } catch (_) {
        _logger.info('  ⓘ Could not check latest version (offline?)');
      }
    }

    // 4. Check project structure
    _logger.info('');
    _logger.info('📁 Project Structure:');

    final dirs = {
      'lib/modules': 'Screen modules directory',
      'lib/shared/controllers': 'Shared controllers directory',
      'lib/shared/models': 'Models directory',
      'lib/shared/services': 'Services directory',
      'lib/shared/widgets': 'Widgets directory',
      'lib/routes': 'Routes directory',
      'lib/di': 'Dependency injection directory',
    };

    for (final entry in dirs.entries) {
      final dir =
          Directory(path.join(Directory.current.path, entry.key));
      if (await dir.exists()) {
        final count = dir
            .listSync()
            .where((e) => e is File || e is Directory)
            .length;
        _logger.success('   ✓ ${entry.key}/ ($count items)');
      } else {
        _logger.info('   ○ ${entry.key}/ (not created yet)');
      }
    }

    // 5. Check manifests
    _logger.info('');
    _logger.info('📋 Manifests:');

    final routesFile =
        File(path.join(Directory.current.path, 'lib', 'routes', '.routes.json'));
    if (await routesFile.exists()) {
      try {
        final routes = jsonDecode(await routesFile.readAsString()) as List;
        _logger.success('   ✓ .routes.json (${routes.length} routes)');

        // Verify each route's module exists
        for (final route in routes.cast<Map<String, dynamic>>()) {
          final moduleName = route['module'] as String?;
          if (moduleName != null) {
            final moduleDir = Directory(
                path.join(Directory.current.path, 'lib', 'modules', moduleName));
            if (!await moduleDir.exists()) {
              _logger.err(
                  '   ✗ Route "${route['name']}" references missing module: $moduleName');
              issues++;
            }
          }
        }
      } catch (e) {
        _logger.err('   ✗ .routes.json is malformed: $e');
        issues++;
      }
    } else {
      _logger.info('   ○ .routes.json (not created yet)');
    }

    final controllersFile =
        File(path.join(Directory.current.path, 'lib', 'di', '.controllers.json'));
    if (await controllersFile.exists()) {
      try {
        final controllers =
            jsonDecode(await controllersFile.readAsString()) as List;
        _logger.success(
            '   ✓ .controllers.json (${controllers.length} entries)');
      } catch (e) {
        _logger.err('   ✗ .controllers.json is malformed: $e');
        issues++;
      }
    } else {
      _logger.info('   ○ .controllers.json (not created yet)');
    }

    // 6. Check for orphaned modules
    _logger.info('');
    _logger.info('🔍 Orphan Check:');

    final modulesDir =
        Directory(path.join(Directory.current.path, 'lib', 'modules'));
    if (await modulesDir.exists() && await routesFile.exists()) {
      try {
        final routes = jsonDecode(await routesFile.readAsString()) as List;
        final registeredModules = routes
            .cast<Map<String, dynamic>>()
            .map((r) => r['module'] as String?)
            .whereType<String>()
            .toSet();

        for (final dir in modulesDir.listSync().whereType<Directory>()) {
          final moduleName = path.basename(dir.path);
          if (!registeredModules.contains(moduleName)) {
            _logger.warn(
                '   ⚠ Orphaned module: $moduleName (exists but not registered in routes)');
            _logger.info(
                '     Fix: neuron remove screen $moduleName  (or re-register)');
            warnings++;
          }
        }

        if (warnings == 0 && issues == 0) {
          _logger.success('   ✓ No orphaned modules found');
        }
      } catch (_) {
        // Already reported manifest issues above
      }
    } else {
      _logger.info('   ○ Skipped (no modules or routes yet)');
    }

    // 7. Check generated files exist
    _logger.info('');
    _logger.info('📝 Generated Files:');

    final generatedFiles = {
      'lib/routes/app_routes.dart': 'Route definitions',
      'lib/di/injector.dart': 'Dependency injection setup',
      'lib/main.dart': 'App entry point',
    };

    for (final entry in generatedFiles.entries) {
      final file =
          File(path.join(Directory.current.path, entry.key));
      if (await file.exists()) {
        _logger.success('   ✓ ${entry.key}');
      } else {
        _logger.warn('   ⚠ ${entry.key} missing (${entry.value})');
        warnings++;
      }
    }

    // Summary
    _logger.info('');
    _logger.info('─────────────────────────────────────');
    if (issues == 0 && warnings == 0) {
      _logger.success('✓ No issues found — project is healthy! 🎉');
    } else {
      if (issues > 0) {
        _logger.err('✗ $issues issue(s) found');
      }
      if (warnings > 0) {
        _logger.warn('⚠ $warnings warning(s)');
      }
    }
    _logger.info('');

    return issues > 0 ? ExitCode.software.code : ExitCode.success.code;
  }
}
