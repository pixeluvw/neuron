import 'package:recase/recase.dart';

/// Templates for Signal middleware generation
class MiddlewareTemplates {
  /// Middleware template
  static String middlewareDart(String middlewareName) {
    final rc = ReCase(middlewareName);
    return '''
import 'package:neuron/neuron.dart';

/// ${rc.pascalCase} Middleware
///
/// Intercepts Signal emissions for ${rc.titleCase} logic.
///
/// Usage:
/// ```dart
/// final mySignal = Signal<String>('initial')
///   ..addMiddleware(${rc.pascalCase}Middleware());
/// ```
class ${rc.pascalCase}Middleware<T> extends SignalMiddleware<T> {
  @override
  T? onEmit(T currentValue, T newValue) {
    // Return null to block the emission
    // Return a modified value to transform
    // Return newValue to pass through unchanged

    // TODO: Implement your middleware logic
    return newValue;
  }
}
''';
  }
}
