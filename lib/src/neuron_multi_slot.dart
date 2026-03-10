// neuron_multi_slot.dart
//
// ═══════════════════════════════════════════════════════════════════════════════
// MULTI SLOT - Unified multi-signal widget
// ═══════════════════════════════════════════════════════════════════════════════
//
// Contains: MultiSlot, _MultiSlotState, legacy MultiSlotN aliases
//
// ═══════════════════════════════════════════════════════════════════════════════

part of 'neuron_extensions.dart';

/// ============================================================================
/// MULTI SLOT - UNIFIED MULTI-SIGNAL WIDGET
/// ============================================================================

/// A widget that rebuilds when any of multiple signals change.
///
/// [MultiSlot] provides a clean, efficient way to subscribe to multiple signals
/// without deeply nested builders. It uses a single subscription per signal
/// and rebuilds once when any signal changes.
///
/// ## Type-Safe Factory Constructors
///
/// Use the numbered factory constructors for compile-time type safety:
///
/// ```dart
/// // Two signals
/// MultiSlot.t2(
///   connect: (nameSignal, ageSignal),
///   to: (context, name, age) => Text('$name is $age'),
/// )
///
/// // Three signals
/// MultiSlot.t3(
///   connect: (a, b, c),
///   to: (context, v1, v2, v3) => Text('$v1 $v2 $v3'),
/// )
/// ```
///
/// ## Dynamic List of Signals
///
/// For a variable number of signals (loses type safety):
///
/// ```dart
/// MultiSlot.list(
///   connect: [signal1, signal2, signal3],
///   to: (context, values) => Text(values.join(', ')),
/// )
/// ```
///
/// ## Comparison with Nested Slots
///
/// Instead of:
/// ```dart
/// Slot(
///   connect: signal1,
///   to: (ctx, v1) => Slot(
///     connect: signal2,
///     to: (ctx, v2) => Slot(
///       connect: signal3,
///       to: (ctx, v3) => MyWidget(v1, v2, v3),
///     ),
///   ),
/// )
/// ```
///
/// Use:
/// ```dart
/// MultiSlot.t3(
///   connect: (signal1, signal2, signal3),
///   to: (ctx, v1, v2, v3) => MyWidget(v1, v2, v3),
/// )
/// ```
class MultiSlot extends StatefulWidget {
  final List<NeuronAtom> _signals;
  final Widget Function(BuildContext context, List<dynamic> values) _builder;

  const MultiSlot._({
    super.key,
    required List<NeuronAtom> signals,
    required Widget Function(BuildContext context, List<dynamic> values)
        builder,
  })  : _signals = signals,
        _builder = builder;

  /// Creates a MultiSlot for two signals with type-safe builder.
  ///
  /// ```dart
  /// MultiSlot.t2(
  ///   connect: (nameSignal, ageSignal),
  ///   to: (context, name, age) => Text('$name ($age)'),
  /// )
  /// ```
  static Widget t2<T1, T2>({
    Key? key,
    required (NeuronAtom<T1>, NeuronAtom<T2>) connect,
    required Widget Function(BuildContext context, T1 v1, T2 v2) to,
  }) {
    return MultiSlot._(
      key: key,
      signals: [connect.$1, connect.$2],
      builder: (ctx, vals) => to(ctx, vals[0] as T1, vals[1] as T2),
    );
  }

  /// Creates a MultiSlot for three signals with type-safe builder.
  ///
  /// ```dart
  /// MultiSlot.t3(
  ///   connect: (a, b, c),
  ///   to: (context, v1, v2, v3) => Text('$v1 $v2 $v3'),
  /// )
  /// ```
  static Widget t3<T1, T2, T3>({
    Key? key,
    required (NeuronAtom<T1>, NeuronAtom<T2>, NeuronAtom<T3>) connect,
    required Widget Function(BuildContext context, T1 v1, T2 v2, T3 v3) to,
  }) {
    return MultiSlot._(
      key: key,
      signals: [connect.$1, connect.$2, connect.$3],
      builder: (ctx, vals) =>
          to(ctx, vals[0] as T1, vals[1] as T2, vals[2] as T3),
    );
  }

  /// Creates a MultiSlot for four signals with type-safe builder.
  static Widget t4<T1, T2, T3, T4>({
    Key? key,
    required (
      NeuronAtom<T1>,
      NeuronAtom<T2>,
      NeuronAtom<T3>,
      NeuronAtom<T4>
    ) connect,
    required Widget Function(BuildContext context, T1 v1, T2 v2, T3 v3, T4 v4)
        to,
  }) {
    return MultiSlot._(
      key: key,
      signals: [connect.$1, connect.$2, connect.$3, connect.$4],
      builder: (ctx, vals) =>
          to(ctx, vals[0] as T1, vals[1] as T2, vals[2] as T3, vals[3] as T4),
    );
  }

  /// Creates a MultiSlot for five signals with type-safe builder.
  static Widget t5<T1, T2, T3, T4, T5>({
    Key? key,
    required (
      NeuronAtom<T1>,
      NeuronAtom<T2>,
      NeuronAtom<T3>,
      NeuronAtom<T4>,
      NeuronAtom<T5>
    ) connect,
    required Widget Function(
            BuildContext context, T1 v1, T2 v2, T3 v3, T4 v4, T5 v5)
        to,
  }) {
    return MultiSlot._(
      key: key,
      signals: [connect.$1, connect.$2, connect.$3, connect.$4, connect.$5],
      builder: (ctx, vals) => to(ctx, vals[0] as T1, vals[1] as T2,
          vals[2] as T3, vals[3] as T4, vals[4] as T5),
    );
  }

  /// Creates a MultiSlot for six signals with type-safe builder.
  static Widget t6<T1, T2, T3, T4, T5, T6>({
    Key? key,
    required (
      NeuronAtom<T1>,
      NeuronAtom<T2>,
      NeuronAtom<T3>,
      NeuronAtom<T4>,
      NeuronAtom<T5>,
      NeuronAtom<T6>
    ) connect,
    required Widget Function(
            BuildContext context, T1 v1, T2 v2, T3 v3, T4 v4, T5 v5, T6 v6)
        to,
  }) {
    return MultiSlot._(
      key: key,
      signals: [
        connect.$1,
        connect.$2,
        connect.$3,
        connect.$4,
        connect.$5,
        connect.$6
      ],
      builder: (ctx, vals) => to(ctx, vals[0] as T1, vals[1] as T2,
          vals[2] as T3, vals[3] as T4, vals[4] as T5, vals[5] as T6),
    );
  }

  /// Creates a MultiSlot for a dynamic list of signals.
  ///
  /// Use this when you have a variable number of signals or when
  /// type safety is not critical.
  ///
  /// ```dart
  /// MultiSlot.list(
  ///   connect: [signal1, signal2, signal3],
  ///   to: (context, values) {
  ///     final name = values[0] as String;
  ///     final age = values[1] as int;
  ///     return Text('$name: $age');
  ///   },
  /// )
  /// ```
  static Widget list({
    Key? key,
    required List<NeuronAtom> connect,
    required Widget Function(BuildContext context, List<dynamic> values) to,
  }) {
    return MultiSlot._(
      key: key,
      signals: connect,
      builder: to,
    );
  }

  @override
  State<MultiSlot> createState() => _MultiSlotState();
}

class _MultiSlotState extends State<MultiSlot> {
  late List<dynamic> _values;
  final List<AtomListener> _cancels = [];

  @override
  void initState() {
    super.initState();
    _values = widget._signals.map((s) => s.value).toList();
    _subscribeAll();
  }

  void _subscribeAll() {
    for (int i = 0; i < widget._signals.length; i++) {
      final index = i;
      final dynamic cancel = widget._signals[i].subscribe(() {
        if (mounted) {
          setState(() {
            _values[index] = widget._signals[index].value;
          });
        }
      });
      _cancels.add(cancel as AtomListener);
    }
  }

  void _unsubscribeAll() {
    for (int i = 0; i < _cancels.length; i++) {
      widget._signals[i].removeListener(_cancels[i]);
    }
    _cancels.clear();
  }

  @override
  void didUpdateWidget(MultiSlot oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Check if signals changed
    bool changed = oldWidget._signals.length != widget._signals.length;
    if (!changed) {
      for (int i = 0; i < widget._signals.length; i++) {
        if (widget._signals[i] != oldWidget._signals[i]) {
          changed = true;
          break;
        }
      }
    }
    if (changed) {
      _unsubscribeAll();
      _values = widget._signals.map((s) => s.value).toList();
      _subscribeAll();
    }
  }

  @override
  void dispose() {
    _unsubscribeAll();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget._builder(context, _values);
  }
}

// Legacy aliases for backward compatibility
/// @Deprecated('Use MultiSlot.t2 instead')
typedef MultiSlot2<T1, T2> = _LegacyMultiSlot2<T1, T2>;

/// @Deprecated('Use MultiSlot.t3 instead')
typedef MultiSlot3<T1, T2, T3> = _LegacyMultiSlot3<T1, T2, T3>;

/// @Deprecated('Use MultiSlot.t4 instead')
typedef MultiSlot4<T1, T2, T3, T4> = _LegacyMultiSlot4<T1, T2, T3, T4>;

/// @Deprecated('Use MultiSlot.t5 instead')
typedef MultiSlot5<T1, T2, T3, T4, T5> = _LegacyMultiSlot5<T1, T2, T3, T4, T5>;

// Keep legacy classes for backward compatibility but mark as internal
class _LegacyMultiSlot2<T1, T2> extends StatelessWidget {
  final (Signal<T1>, Signal<T2>) connect;
  final Widget Function(BuildContext context, T1 val1, T2 val2) to;

  const _LegacyMultiSlot2({
    super.key,
    required this.connect,
    required this.to,
  });

  @override
  Widget build(BuildContext context) {
    return MultiSlot.t2(connect: connect, to: to);
  }
}

class _LegacyMultiSlot3<T1, T2, T3> extends StatelessWidget {
  final (Signal<T1>, Signal<T2>, Signal<T3>) connect;
  final Widget Function(BuildContext context, T1 val1, T2 val2, T3 val3) to;

  const _LegacyMultiSlot3({
    super.key,
    required this.connect,
    required this.to,
  });

  @override
  Widget build(BuildContext context) {
    return MultiSlot.t3(connect: connect, to: to);
  }
}

class _LegacyMultiSlot4<T1, T2, T3, T4> extends StatelessWidget {
  final (Signal<T1>, Signal<T2>, Signal<T3>, Signal<T4>) connect;
  final Widget Function(
      BuildContext context, T1 val1, T2 val2, T3 val3, T4 val4) to;

  const _LegacyMultiSlot4({
    super.key,
    required this.connect,
    required this.to,
  });

  @override
  Widget build(BuildContext context) {
    return MultiSlot.t4(connect: connect, to: to);
  }
}

class _LegacyMultiSlot5<T1, T2, T3, T4, T5> extends StatelessWidget {
  final (Signal<T1>, Signal<T2>, Signal<T3>, Signal<T4>, Signal<T5>) connect;
  final Widget Function(
      BuildContext context, T1 val1, T2 val2, T3 val3, T4 val4, T5 val5) to;

  const _LegacyMultiSlot5({
    super.key,
    required this.connect,
    required this.to,
  });

  @override
  Widget build(BuildContext context) {
    return MultiSlot.t5(connect: connect, to: to);
  }
}
