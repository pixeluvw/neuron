import 'package:recase/recase.dart';

/// Templates for reusable widget generation
class WidgetTemplates {
  /// Basic widget template
  static String widgetDart(String widgetName) {
    final rc = ReCase(widgetName);
    return '''
import 'package:flutter/material.dart';

/// ${rc.pascalCase} Widget
///
/// A reusable widget for ${rc.titleCase}.
///
/// Usage:
/// ```dart
/// ${rc.pascalCase}(
///   // TODO: add required params
/// )
/// ```
class ${rc.pascalCase} extends StatelessWidget {
  const ${rc.pascalCase}({
    super.key,
    this.child,
  });

  /// Optional child widget
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: child ?? const SizedBox.shrink(),
    );
  }
}
''';
  }

  /// Signal-aware widget template
  static String signalWidgetDart(String widgetName) {
    final rc = ReCase(widgetName);
    return '''
import 'package:flutter/material.dart';
import 'package:neuron/neuron.dart';

/// ${rc.pascalCase} Widget — Signal-aware
///
/// A reusable widget that reacts to a Signal.
///
/// Usage:
/// ```dart
/// ${rc.pascalCase}<String>(
///   signal: controller.mySignal,
///   builder: (context, value) => Text(value),
/// )
/// ```
class ${rc.pascalCase}<T> extends StatelessWidget {
  const ${rc.pascalCase}({
    super.key,
    required this.signal,
    required this.builder,
    this.loading,
  });

  /// The signal to connect to
  final Signal<T> signal;

  /// Builder called with the current signal value
  final Widget Function(BuildContext context, T value) builder;

  /// Optional widget shown while initially loading
  final Widget? loading;

  @override
  Widget build(BuildContext context) {
    return Slot<T>(
      connect: signal,
      to: (context, value) {
        return builder(context, value);
      },
    );
  }
}
''';
  }
}
