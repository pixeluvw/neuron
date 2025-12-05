/// Templates for project generation
class ProjectTemplates {
  /// Main entry point template
  static String mainDart(String projectName, bool isEmpty) {
    return '''
import 'package:flutter/material.dart';
import 'package:neuron/neuron.dart';

import 'modules/home/home_view.dart';

void main() {
  runApp(
    NeuronApp(
      title: '$projectName',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomeView(),
      // Enable DevTools in debug mode
      enableDevTools: true,
    ),
  );
}
''';
  }

  /// Home controller template (self-contained module)
  static String homeControllerDart() {
    return '''
import 'package:neuron/neuron.dart';

/// Controller for the Home screen
/// 
/// Usage:
/// ```dart
/// final c = HomeController.init;
/// ```
class HomeController extends NeuronController {
  /// Static getter for the controller (lazy singleton)
  static HomeController get init =>
      Neuron.ensure<HomeController>(() => HomeController());

  /// Counter signal - auto-disposed with controller
  late final count = Signal<int>(0).bind(this);

  /// Computed signal - derived from count
  late final doubled = Computed<int>(
    () => count.val * 2,
    [count],
  ).bind(this);

  /// Increment counter
  void increment() => count.emit(count.val + 1);

  /// Decrement counter
  void decrement() => count.emit(count.val - 1);

  /// Reset counter
  void reset() => count.emit(0);

  @override
  void onInit() {
    super.onInit();
    // Called once when controller is first accessed
  }

  @override
  void onClose() {
    // Called when controller is disposed
    super.onClose();
  }
}
''';
  }

  /// Home view template (self-contained module)
  static String homeViewDart() {
    return '''
import 'package:flutter/material.dart';
import 'package:neuron/neuron.dart';

import 'home_controller.dart';

/// Home screen view (StatelessWidget - Neuron Signal/Slot pattern)
class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the controller (creates on first access, reuses after)
    final c = HomeController.init;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Counter Value:',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            // Slot connects signal to UI - rebuilds only this widget
            Slot<int>(
              connect: c.count,
              to: (context, count) => Text(
                '\$count',
                style: Theme.of(context).textTheme.displayLarge,
              ),
            ),
            const SizedBox(height: 16),
            // Another Slot for computed value
            Slot<int>(
              connect: c.doubled,
              to: (context, doubled) => Text(
                'Doubled: \$doubled',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'decrement',
            onPressed: c.decrement,
            tooltip: 'Decrement',
            child: const Icon(Icons.remove),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: 'increment',
            onPressed: c.increment,
            tooltip: 'Increment',
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: 'reset',
            onPressed: c.reset,
            tooltip: 'Reset',
            child: const Icon(Icons.refresh),
          ),
        ],
      ),
    );
  }
}
''';
  }
}
