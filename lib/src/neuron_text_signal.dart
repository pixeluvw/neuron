// neuron_text_signal.dart
//
// ═══════════════════════════════════════════════════════════════════════════════
// NEURON TEXT SIGNAL - Two-Way TextEditingController ↔ Signal Sync
// ═══════════════════════════════════════════════════════════════════════════════
//
// Provides a Signal<String> that stays in bidirectional sync with a
// TextEditingController, eliminating manual listener wiring and cleanup.
//
// See also:
// - neuron_signals.dart : Signal base class
// - neuron_core.dart    : NeuronController lifecycle
//
// ═══════════════════════════════════════════════════════════════════════════════

part of 'neuron_extensions.dart';

/// A [Signal<String>] that stays in bidirectional sync with a
/// [TextEditingController].
///
/// [TextSignal] eliminates the boilerplate of wiring a [TextEditingController]
/// to a signal, managing listeners, and disposing both. It keeps the signal
/// value and the controller text in sync automatically.
///
/// ## Basic Usage
///
/// ```dart
/// class FormController extends NeuronController {
///   late final email = textSignal();
///   late final password = textSignal();
///
///   // email.val        → current text (String)
///   // email.controller → the TextEditingController
///   // email.emit('x')  → updates both signal and controller
/// }
/// ```
///
/// ## In Widgets
///
/// ```dart
/// TextField(controller: ctrl.email.controller)
/// ```
///
/// ## Lifecycle
///
/// The internal [TextEditingController] is automatically disposed when
/// the signal is disposed (e.g., when the parent controller is uninstalled).
///
/// See also:
/// - [Signal] - Base reactive value
/// - [NeuronControllerTextSignal] - Factory extension
class TextSignal extends Signal<String> {
  /// The [TextEditingController] kept in sync with this signal.
  late final TextEditingController controller;

  bool _syncing = false;

  /// Creates a text signal with an optional initial [text] value.
  TextSignal({
    String text = '',
    String? debugLabel,
  }) : super(text, debugLabel: debugLabel) {
    controller = TextEditingController(text: text);
    controller.addListener(_onControllerChanged);
  }

  /// Creates a text signal wrapping an existing [TextEditingController].
  ///
  /// The signal takes ownership of the controller and will dispose it.
  TextSignal.fromController(
    TextEditingController existing, {
    String? debugLabel,
  }) : super(existing.text, debugLabel: debugLabel) {
    controller = existing;
    controller.addListener(_onControllerChanged);
  }

  void _onControllerChanged() {
    if (_syncing) return;
    _syncing = true;
    try {
      if (value != controller.text) {
        super.emit(controller.text);
      }
    } finally {
      _syncing = false;
    }
  }

  @override
  void emit(String val) {
    if (_syncing) return;
    _syncing = true;
    try {
      super.emit(val);
      if (controller.text != val) {
        controller.text = val;
      }
    } finally {
      _syncing = false;
    }
  }

  /// The current text value (alias for [val]).
  String get text => val;

  /// Sets the text value (alias for [emit]).
  set text(String newText) => emit(newText);

  /// Clears the text to an empty string.
  void clear() => emit('');

  /// The current text selection in the controller.
  TextSelection get selection => controller.selection;

  /// Sets the text selection in the controller.
  set selection(TextSelection sel) => controller.selection = sel;

  @override
  void dispose() {
    controller.removeListener(_onControllerChanged);
    controller.dispose();
    super.dispose();
  }
}

/// Extension providing [textSignal] factory on [NeuronController].
///
/// ```dart
/// class FormController extends NeuronController {
///   late final name = textSignal(text: 'John');
///   late final email = textSignal();
///
///   // In widget: TextField(controller: name.controller)
/// }
/// ```
extension NeuronControllerTextSignal on NeuronController {
  /// Creates a [TextSignal] and automatically binds it to this controller.
  TextSignal textSignal({
    String text = '',
    String? debugLabel,
  }) {
    return TextSignal(
      text: text,
      debugLabel: debugLabel,
    ).bind(this);
  }
}
