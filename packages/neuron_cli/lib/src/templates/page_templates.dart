import 'package:recase/recase.dart';

/// Templates for full-stack page generation (screen + service wired together)
class PageTemplates {
  /// Controller pre-wired with a service
  static String controllerDart(String pageName) {
    final rc = ReCase(pageName);
    return '''
import 'package:neuron/neuron.dart';

import '${rc.snakeCase}_service.dart';

/// Controller for the ${rc.pascalCase} page
///
/// Pre-wired with ${rc.pascalCase}Service for data operations.
///
/// Usage:
/// ```dart
/// final c = ${rc.pascalCase}Controller.init;
/// ```
class ${rc.pascalCase}Controller extends NeuronController {
  /// Static getter for the controller
  static ${rc.pascalCase}Controller get init => Neuron.use<${rc.pascalCase}Controller>();

  /// Service for data operations
  late final _service = ${rc.pascalCase}Service.init;

  // ============================================
  // Signals
  // ============================================

  /// Async data signal — loading/data/error in one
  late final data = AsyncSignal<List<Map<String, dynamic>>>().bind(this);

  /// Search/filter query
  late final searchQuery = Signal<String>('').bind(this);

  // ============================================
  // Lifecycle
  // ============================================

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  @override
  void onClose() {
    super.onClose();
  }

  // ============================================
  // Actions
  // ============================================

  /// Load data from service
  Future<void> loadData() async {
    data.loading();
    try {
      final result = await _service.getAll();
      data.succeed(result);
    } catch (e) {
      data.fail(e.toString());
    }
  }

  /// Refresh data
  Future<void> refresh() => loadData();

  /// Create a new item
  Future<void> createItem(Map<String, dynamic> item) async {
    try {
      await _service.create(item);
      await loadData(); // Refresh list
    } catch (e) {
      data.fail(e.toString());
    }
  }

  /// Delete an item by ID
  Future<void> deleteItem(String id) async {
    try {
      await _service.delete(id);
      await loadData(); // Refresh list
    } catch (e) {
      data.fail(e.toString());
    }
  }
}
''';
  }

  /// View with loading/error/data pattern, connected to AsyncSignal
  static String viewDart(String pageName) {
    final rc = ReCase(pageName);
    return '''
import 'package:flutter/material.dart';
import 'package:neuron/neuron.dart';

import '${rc.snakeCase}_controller.dart';

/// ${rc.pascalCase} page — full-stack view with loading/error/data handling
class ${rc.pascalCase}View extends StatelessWidget {
  const ${rc.pascalCase}View({super.key});

  @override
  Widget build(BuildContext context) {
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
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: c.refresh,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: AsyncSlot<List<Map<String, dynamic>>>(
        connect: c.data,
        loading: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (context, error) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
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
                FilledButton.icon(
                  onPressed: c.refresh,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
        data: (context, items) {
          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inbox_outlined,
                    size: 64,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No items yet',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: c.refresh,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(item.toString()),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () {
                        final id = item['id']?.toString() ?? '';
                        c.deleteItem(id);
                      },
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigate to create form or show dialog
        },
        tooltip: 'Add',
        child: const Icon(Icons.add),
      ),
    );
  }
}
''';
  }

  /// Local service paired with the page (CRUD stubs)
  static String serviceDart(String pageName) {
    final rc = ReCase(pageName);
    return '''
import 'package:neuron/neuron.dart';

/// ${rc.pascalCase} Service — Data layer for the ${rc.titleCase} page
///
/// Handles all data operations. Replace the stub implementations
/// with actual API calls or database queries.
class ${rc.pascalCase}Service extends NeuronController {
  /// Static getter for the service
  static ${rc.pascalCase}Service get init => Neuron.use<${rc.pascalCase}Service>();

  // ============================================
  // CRUD Operations
  // ============================================

  /// Fetch all records
  Future<List<Map<String, dynamic>>> getAll() async {
    // TODO: Replace with actual data source
    await Future.delayed(const Duration(milliseconds: 300));
    return [];
  }

  /// Fetch a single record by ID
  Future<Map<String, dynamic>?> getById(String id) async {
    // TODO: Replace with actual data source
    return null;
  }

  /// Create a new record
  Future<Map<String, dynamic>> create(Map<String, dynamic> data) async {
    // TODO: Replace with actual data source
    return data;
  }

  /// Update an existing record
  Future<Map<String, dynamic>> update(String id, Map<String, dynamic> data) async {
    // TODO: Replace with actual data source
    return data;
  }

  /// Delete a record
  Future<void> delete(String id) async {
    // TODO: Replace with actual data source
  }
}
''';
  }
}
