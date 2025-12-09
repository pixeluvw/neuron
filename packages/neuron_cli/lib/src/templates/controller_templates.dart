import 'package:recase/recase.dart';

/// Templates for standalone controller generation
class ControllerTemplates {
  /// Standalone controller template
  static String controllerDart(String controllerName) {
    final rc = ReCase(controllerName);
    return '''
import 'package:neuron/neuron.dart';

/// ${rc.pascalCase} Controller
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

  /// Example signal - replace with your own
  late final example = Signal<String>('initial value').bind(this);

  /// Loading state
  late final isLoading = Signal<bool>(false).bind(this);

  // ============================================
  // Computed - Derived values
  // ============================================

  // Example computed signal (auto-tracks dependencies):
  // late final derived = Computed<String>(
  //   () => '\${example.val} processed',
  // ).bind(this);

  // ============================================
  // Lifecycle
  // ============================================

  @override
  void onInit() {
    super.onInit();
    // Called once when controller is first accessed
  }

  @override
  void onClose() {
    // Called when controller is disposed
    // Signals are automatically disposed via .bind(this)
    super.onClose();
  }

  // ============================================
  // Actions
  // ============================================

  /// Update example value
  void updateExample(String value) {
    example.emit(value);
  }

  /// Example async action
  Future<void> loadData() async {
    isLoading.emit(true);
    try {
      // TODO: Add your async logic here
      await Future.delayed(const Duration(seconds: 1));
    } finally {
      isLoading.emit(false);
    }
  }
}
''';
  }
}
