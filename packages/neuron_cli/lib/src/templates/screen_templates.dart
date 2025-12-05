import 'package:recase/recase.dart';

/// Templates for screen generation (self-contained modules)
class ScreenTemplates {
  /// Controller template for a screen module
  static String controllerDart(String screenName) {
    final rc = ReCase(screenName);
    return '''
import 'package:neuron/neuron.dart';

/// Controller for the ${rc.pascalCase} screen
/// 
/// Usage:
/// ```dart
/// final c = ${rc.pascalCase}Controller.init;
/// ```
class ${rc.pascalCase}Controller extends NeuronController {
  /// Static getter for the controller (lazy singleton)
  static ${rc.pascalCase}Controller get init =>
      Neuron.ensure<${rc.pascalCase}Controller>(() => ${rc.pascalCase}Controller());

  // ============================================
  // Signals - Reactive state
  // ============================================

  /// Loading state signal
  late final isLoading = Signal<bool>(false).bind(this);

  /// Error message signal (null if no error)
  late final error = Signal<String?>(null).bind(this);

  // ============================================
  // Lifecycle
  // ============================================

  @override
  void onInit() {
    super.onInit();
    _loadData();
  }

  @override
  void onClose() {
    // Clean up resources here
    super.onClose();
  }

  // ============================================
  // Actions
  // ============================================

  /// Load initial data
  Future<void> _loadData() async {
    isLoading.emit(true);
    error.emit(null);

    try {
      // TODO: Load your data here
      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      error.emit(e.toString());
    } finally {
      isLoading.emit(false);
    }
  }

  /// Refresh data
  Future<void> refresh() async {
    await _loadData();
  }
}
''';
  }

  /// View template for a screen module (StatelessWidget only!)
  static String viewDart(String screenName) {
    final rc = ReCase(screenName);
    return '''
import 'package:flutter/material.dart';
import 'package:neuron/neuron.dart';

import '${rc.snakeCase}_controller.dart';

/// ${rc.pascalCase} screen view (StatelessWidget - Neuron Signal/Slot pattern)
class ${rc.pascalCase}View extends StatelessWidget {
  const ${rc.pascalCase}View({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the controller (creates on first access, reuses after)
    final c = ${rc.pascalCase}Controller.init;

    return Scaffold(
      appBar: AppBar(
        title: const Text('${rc.titleCase}'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Neuron.back(),
              )
            : null,
      ),
      body: Slot<bool>(
        connect: c.isLoading,
        to: (context, isLoading) {
          if (isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return Slot<String?>(
            connect: c.error,
            to: (context, error) {
              if (error != null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error: \$error',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: c.refresh,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              // TODO: Add your screen content here
              return const Center(
                child: Text('${rc.pascalCase} Screen'),
              );
            },
          );
        },
      ),
    );
  }
}
''';
  }
}
