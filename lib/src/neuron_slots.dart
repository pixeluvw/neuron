// neuron_slots.dart
//
// ═══════════════════════════════════════════════════════════════════════════════
// NEURON SLOTS - Animated & Specialized Slot Widgets
// ═══════════════════════════════════════════════════════════════════════════════
//
// This file provides enhanced Slot widgets with animation, transitions,
// and visual effects for building polished, production-ready UIs.
//
// ┌─────────────────────────────────────────────────────────────────────────────┐
// │ SLOT WIDGET GALLERY                                                        │
// ├───────────────────┬─────────────────────────────────────────────────────────┤
// │ AnimatedSlot      │ Implicit animation with configurable effects         │
// │ SpringSlot        │ Physics-based spring animation                       │
// │ MorphSlot         │ Smooth transitions between different widgets         │
// │ PulseSlot         │ Attention-grabbing pulse effect on change            │
// │ ShimmerSlot       │ Loading shimmer effect during async operations       │
// │ GestureAnimatedSlot│ Touch-responsive animations (tap, long press)       │
// │ ParallaxSlot      │ Depth-based parallax scrolling effect                │
// │ MultiSlot         │ Combine 2-6 signals with type-safe builders          │
// └───────────────────┴─────────────────────────────────────────────────────────┘
//
// EFFECT SYSTEM:
// Effects can be combined using the `|` operator:
//   effect: SlotEffect.fade | SlotEffect.scale | SlotEffect.blur
//
// SPRING PHYSICS:
// SpringSlot uses Flutter's physics engine for natural motion:
//   SpringConfig.bouncy  - Playful, energetic (low damping)
//   SpringConfig.smooth  - Professional, elegant (high damping)
//   SpringConfig.snappy  - Quick, responsive (high stiffness)
//
// USAGE EXAMPLES:
//
// 1. Basic animated counter:
//    AnimatedSlot<int>(
//      connect: controller.count,
//      effect: SlotEffect.fadeScale,
//      to: (ctx, val) => Text('$val'),
//    )
//
// 2. Spring-animated temperature:
//    SpringSlot<double>(
//      connect: controller.temperature,
//      config: SpringConfig.smooth,
//      to: (ctx, val) => Text('${val.toStringAsFixed(1)}°'),
//    )
//
// 3. Multi-signal dashboard:
//    MultiSlot.t3(
//      signals: (temp, humidity, pressure),
//      to: (ctx, t, h, p) => DashboardCard(t, h, p),
//    )
//
// See also:
// - neuron_core.dart  : Basic Slot and AsyncSlot widgets
// - SlotEffect        : Available visual effects
// - SpringConfig      : Spring physics presets
//
// ═══════════════════════════════════════════════════════════════════════════════

part of 'neuron_extensions.dart';

/// ════════════════════════════════════════════════════════════════════════════
/// SLOT EFFECTS & TRANSITIONS
/// ════════════════════════════════════════════════════════════════════════════

/// Visual effects for slot animations.
///
/// [SlotEffect] provides a composable system for defining visual transitions
/// when signal values change. Effects can be combined using the bitwise OR
/// operator (`|`) to create rich, layered animations.
///
/// ## Basic Effects
///
/// | Effect       | Description                          |
/// |--------------|--------------------------------------|
/// | `fade`       | Opacity transition (0 → 1)          |
/// | `scale`      | Size transition (small → normal)    |
/// | `slide`      | Horizontal slide                     |
/// | `slideUp`    | Slide from bottom                    |
/// | `slideDown`  | Slide from top                       |
/// | `slideLeft`  | Slide from right                     |
/// | `slideRight` | Slide from left                      |
/// | `rotation`   | Rotate during transition             |
/// | `flip`       | 3D flip effect                       |
/// | `blur`       | Gaussian blur during transition      |
///
/// ## Dramatic Effects
///
/// | Effect    | Description                              |
/// |-----------|------------------------------------------|
/// | `bounce`  | Bouncy overshoot animation               |
/// | `elastic` | Spring-like elastic effect               |
/// | `wobble`  | Side-to-side wobble                      |
/// | `pulse`   | Attention-grabbing pulse                 |
/// | `shake`   | Quick shake effect                       |
/// | `swing`   | Pendulum-like swing                      |
///
/// ## Combining Effects
///
/// ```dart
/// // Single effect
/// effect: SlotEffect.fade
///
/// // Combined effects
/// effect: SlotEffect.fade | SlotEffect.scale | SlotEffect.blur
///
/// // Pre-combined effects
/// effect: SlotEffect.fadeScale
/// effect: SlotEffect.fadeSlideUp
/// ```
///
/// ## Usage with AnimatedSlot
///
/// ```dart
/// AnimatedSlot<int>(
///   connect: controller.count,
///   effect: SlotEffect.fadeScale | SlotEffect.blur,
///   duration: Duration(milliseconds: 400),
///   curve: Curves.easeOutBack,
///   to: (ctx, val) => Text('$val', style: TextStyle(fontSize: 48)),
/// )
/// ```
class SlotEffect {
  final int _value;
  const SlotEffect._(this._value);

  // Basic effects
  static const none = SlotEffect._(0);
  static const fade = SlotEffect._(1 << 0);
  static const scale = SlotEffect._(1 << 1);
  static const slide = SlotEffect._(1 << 2);
  static const slideUp = SlotEffect._(1 << 3);
  static const slideDown = SlotEffect._(1 << 4);
  static const slideLeft = SlotEffect._(1 << 5);
  static const slideRight = SlotEffect._(1 << 6);
  static const rotation = SlotEffect._(1 << 7);
  static const flip = SlotEffect._(1 << 8);
  static const blur = SlotEffect._(1 << 9);
  static const color = SlotEffect._(1 << 10);

  // Composite effects
  static const fadeScale = SlotEffect._(1 << 0 | 1 << 1);
  static const fadeSlide = SlotEffect._(1 << 0 | 1 << 2);
  static const fadeSlideUp = SlotEffect._(1 << 0 | 1 << 3);
  static const fadeSlideDown = SlotEffect._(1 << 0 | 1 << 4);
  static const scaleRotate = SlotEffect._(1 << 1 | 1 << 7);
  static const fadeBlur = SlotEffect._(1 << 0 | 1 << 9);

  // Dramatic effects
  static const bounce = SlotEffect._(1 << 11);
  static const elastic = SlotEffect._(1 << 12);
  static const wobble = SlotEffect._(1 << 13);
  static const pulse = SlotEffect._(1 << 14);
  static const shake = SlotEffect._(1 << 15);
  static const swing = SlotEffect._(1 << 16);

  /// Combine effects using `|` operator
  SlotEffect operator |(SlotEffect other) =>
      SlotEffect._(_value | other._value);

  /// Check if effect contains another
  bool has(SlotEffect effect) => (_value & effect._value) == effect._value;

  @override
  bool operator ==(Object other) =>
      other is SlotEffect && other._value == _value;

  @override
  int get hashCode => _value.hashCode;
}

/// Direction-aware effect configuration for value changes.
class DirectionalEffect {
  final SlotEffect forward;
  final SlotEffect reverse;

  const DirectionalEffect({
    required this.forward,
    required this.reverse,
  });

  /// Same effect for both directions
  const DirectionalEffect.symmetric(SlotEffect effect)
      : forward = effect,
        reverse = effect;

  /// Slide up when increasing, slide down when decreasing
  static const vertical = DirectionalEffect(
    forward: SlotEffect.slideUp,
    reverse: SlotEffect.slideDown,
  );

  /// Slide left when increasing, slide right when decreasing
  static const horizontal = DirectionalEffect(
    forward: SlotEffect.slideLeft,
    reverse: SlotEffect.slideRight,
  );

  /// Fade with scale for both directions
  static const fadeScale = DirectionalEffect.symmetric(SlotEffect.fadeScale);
}

/// Spring physics configuration for natural motion.
class SpringConfig {
  final double damping;
  final double stiffness;
  final double mass;

  const SpringConfig({
    this.damping = 20.0,
    this.stiffness = 180.0,
    this.mass = 1.0,
  });

  /// Bouncy spring (low damping)
  static const bouncy = SpringConfig(damping: 10, stiffness: 300, mass: 1);

  /// Smooth spring (high damping)
  static const smooth = SpringConfig(damping: 28, stiffness: 200, mass: 1);

  /// Snappy spring (high stiffness)
  static const snappy = SpringConfig(damping: 20, stiffness: 400, mass: 0.8);

  /// Gentle spring (low stiffness)
  static const gentle = SpringConfig(damping: 25, stiffness: 100, mass: 1.2);

  /// Wobbly spring (very low damping)
  static const wobbly = SpringConfig(damping: 8, stiffness: 200, mass: 1);

  /// Default iOS-like spring
  static const ios = SpringConfig(damping: 25, stiffness: 170, mass: 1);

  /// Convert to Flutter SpringDescription
  SpringDescription toSpringDescription() => SpringDescription(
        mass: mass,
        stiffness: stiffness,
        damping: damping,
      );
}

/// ============================================================================
/// ADVANCED SLOT WIDGETS
/// ============================================================================

/// AnimatedSlot - Automatically animates between value changes.
///
/// Wraps value changes with an implicit animation, providing smooth
/// transitions when the signal emits new values.
///
/// Example:
/// ```dart
/// class MyController extends NeuronController {
///   late final counter = Signal<int>(0).bind(this);
/// }
///
/// // Basic usage:
/// AnimatedSlot<int>(
///   connect: controller.counter,
///   duration: Duration(milliseconds: 300),
///   curve: Curves.easeInOut,
///   to: (ctx, val) => Text('$val'),
/// )
///
/// // With effects:
/// AnimatedSlot<int>(
///   connect: controller.counter,
///   effect: SlotEffect.fadeScale | SlotEffect.blur,
///   to: (ctx, val) => Text('$val'),
/// )
///
/// // Direction-aware animation:
/// AnimatedSlot<int>(
///   connect: controller.counter,
///   directionalEffect: DirectionalEffect.vertical,
///   to: (ctx, val) => Text('$val'),
/// )
/// ```
class AnimatedSlot<T> extends StatefulWidget {
  /// The signal to connect to. The slot rebuilds when this signal emits.
  ///
  /// ```dart
  /// AnimatedSlot<int>(
  ///   connect: controller.count,  // Your Signal<int>
  ///   to: (ctx, val) => Text('$val'),
  /// )
  /// ```
  final Signal<T> connect;

  /// Builder function that creates the widget for the current value.
  ///
  /// Called each time the signal emits with the new value.
  final Widget Function(BuildContext context, T value) to;

  /// Duration of the animation. Default: 300ms.
  ///
  /// **Tip**: Use shorter durations (150-200ms) for frequent updates,
  /// longer durations (400-600ms) for dramatic emphasis.
  final Duration duration;

  /// Curve applied to the animation. Default: [Curves.easeInOut].
  ///
  /// **Best practices**:
  /// - [Curves.easeOutCubic] for natural deceleration
  /// - [Curves.elasticOut] for bouncy effects
  /// - [Curves.fastOutSlowIn] for Material Design feel
  final Curve curve;

  /// Curve for the exiting widget. If null, uses [curve].
  final Curve? exitCurve;

  /// Visual effect applied during transitions. Default: [SlotEffect.fade].
  ///
  /// Combine effects using the `|` operator:
  /// ```dart
  /// effect: SlotEffect.fade | SlotEffect.scale | SlotEffect.blur
  /// ```
  ///
  /// **Available effects**: fade, scale, slide, slideUp, slideDown,
  /// slideLeft, slideRight, rotation, flip, blur, bounce, elastic.
  final SlotEffect effect;

  /// Direction-aware effect that changes based on value direction.
  ///
  /// ```dart
  /// directionalEffect: DirectionalEffect.vertical,  // up/down based on increase/decrease
  /// ```
  final DirectionalEffect? directionalEffect;

  /// Delay before the animation starts. Default: [Duration.zero].
  final Duration delay;

  /// Called when the animation starts.
  final VoidCallback? onAnimationStart;

  /// Called when the animation completes.
  final VoidCallback? onAnimationComplete;

  /// Optional child widget passed to the builder.
  ///
  /// Use this for static content that doesn't change,
  /// improving performance by avoiding unnecessary rebuilds.
  final Widget? child;

  // ─────────────────────────────────────────────────────────────────────────
  // Enhanced animation controls
  // ─────────────────────────────────────────────────────────────────────────

  /// Starting scale for scale effects. Default: 0.8.
  ///
  /// **Tip**: Use 0.95-1.0 for subtle effects, 0.5-0.8 for dramatic pop-in.
  final double scaleBegin;

  /// Ending scale for scale effects. Default: 1.0.
  final double scaleEnd;

  /// Offset for slide effects in relative units. Default: (0, 0.3).
  ///
  /// Values are relative to widget size (0.0-1.0 = 0%-100% of size).
  final Offset slideOffset;

  /// Number of turns for rotation effect. Default: 0.25 (90 degrees).
  final double rotationTurns;

  /// Blur intensity for blur effect. Default: 5.0.
  ///
  /// Higher values create stronger blur during transitions.
  /// **Tip**: Use 3-8 for subtle blur, 15+ for dramatic frosted glass effect.
  final double blurSigma;

  /// Whether to clip content during animation to prevent overflow.
  ///
  /// Set to `true` when slide animations might overflow their container.
  /// Default: false.
  final bool clipBehavior;

  /// Creates an AnimatedSlot that smoothly animates between value changes.
  ///
  /// ## Basic Usage
  /// ```dart
  /// AnimatedSlot<int>(
  ///   connect: controller.counter,
  ///   to: (ctx, val) => Text('$val'),
  /// )
  /// ```
  ///
  /// ## With Effects
  /// ```dart
  /// AnimatedSlot<int>(
  ///   connect: controller.counter,
  ///   effect: SlotEffect.fadeScale | SlotEffect.blur,
  ///   duration: Duration(milliseconds: 400),
  ///   curve: Curves.elasticOut,
  ///   to: (ctx, val) => Text('$val', style: TextStyle(fontSize: 48)),
  /// )
  /// ```
  ///
  /// ## Direction-Aware
  /// ```dart
  /// AnimatedSlot<int>(
  ///   connect: controller.counter,
  ///   directionalEffect: DirectionalEffect.vertical,  // slides up/down
  ///   to: (ctx, val) => Text('$val'),
  /// )
  /// ```
  const AnimatedSlot({
    super.key,
    required this.connect,
    required this.to,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
    this.exitCurve,
    this.effect = SlotEffect.fade,
    this.directionalEffect,
    this.delay = Duration.zero,
    this.onAnimationStart,
    this.onAnimationComplete,
    this.child,
    // Enhanced defaults
    this.scaleBegin = 0.8,
    this.scaleEnd = 1.0,
    this.slideOffset = const Offset(0, 0.3),
    this.rotationTurns = 0.25,
    this.blurSigma = 5.0,
    this.clipBehavior = false,
  });

  @override
  State<AnimatedSlot<T>> createState() => _AnimatedSlotState<T>();
}

class _AnimatedSlotState<T> extends State<AnimatedSlot<T>>
    with SingleTickerProviderStateMixin {
  T? _previousValue;
  bool _isForward = true;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _previousValue = widget.connect.value;
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _controller.value = 1.0; // Start fully visible
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  SlotEffect get _currentEffect {
    if (widget.directionalEffect != null) {
      return _isForward
          ? widget.directionalEffect!.forward
          : widget.directionalEffect!.reverse;
    }
    return widget.effect;
  }

  void _updateDirection(T newValue) {
    if (_previousValue != null && newValue is Comparable) {
      _isForward = (newValue as Comparable).compareTo(_previousValue) >= 0;
    }
    _previousValue = newValue;
  }

  @override
  Widget build(BuildContext context) {
    return NeuronAtomBuilder<T>(
      atom: widget.connect,
      builder: (ctx, val, ch) {
        _updateDirection(val);
        widget.onAnimationStart?.call();

        return AnimatedSwitcher(
          duration: widget.duration,
          switchInCurve: widget.curve,
          switchOutCurve: widget.exitCurve ?? widget.curve,
          layoutBuilder: (currentChild, previousChildren) {
            return Stack(
              alignment: Alignment.center,
              children: [
                ...previousChildren,
                if (currentChild != null) currentChild,
              ],
            );
          },
          transitionBuilder: (child, animation) {
            // Fire completion callback
            animation.addStatusListener((status) {
              if (status == AnimationStatus.completed) {
                widget.onAnimationComplete?.call();
              }
            });
            return _buildEffectTransition(_currentEffect, child, animation);
          },
          child: KeyedSubtree(
            key: ValueKey<T>(val),
            child: widget.to(ctx, val),
          ),
        );
      },
      child: widget.child,
    );
  }

  Widget _buildEffectTransition(
      SlotEffect effect, Widget child, Animation<double> animation) {
    Widget result = child;

    // Wrap in ClipRect if needed to prevent overflow during animations
    if (widget.clipBehavior) {
      result = ClipRect(child: result);
    }

    // Apply blur effect
    if (effect.has(SlotEffect.blur)) {
      result = AnimatedBuilder(
        animation: animation,
        builder: (context, child) => ImageFiltered(
          imageFilter: ImageFilter.blur(
            sigmaX: (1 - animation.value) * widget.blurSigma,
            sigmaY: (1 - animation.value) * widget.blurSigma,
          ),
          child: child,
        ),
        child: result,
      );
    }

    // Apply rotation
    if (effect.has(SlotEffect.rotation)) {
      result = RotationTransition(
        turns: Tween<double>(begin: widget.rotationTurns, end: 0)
            .animate(animation),
        child: result,
      );
    }

    // Apply flip
    if (effect.has(SlotEffect.flip)) {
      result = AnimatedBuilder(
        animation: animation,
        builder: (context, child) => Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY((1 - animation.value) * 3.14159),
          child: child,
        ),
        child: result,
      );
    }

    // Apply wobble effect
    if (effect.has(SlotEffect.wobble)) {
      final curvedAnimation = CurvedAnimation(
        parent: animation,
        curve: Curves.elasticOut,
      );
      result = RotationTransition(
        turns: Tween<double>(begin: 0.03, end: 0).animate(curvedAnimation),
        child: result,
      );
    }

    // Apply swing effect
    if (effect.has(SlotEffect.swing)) {
      final curvedAnimation = CurvedAnimation(
        parent: animation,
        curve: Curves.elasticOut,
      );
      result = AnimatedBuilder(
        animation: curvedAnimation,
        builder: (context, child) => Transform(
          alignment: Alignment.topCenter,
          transform: Matrix4.identity()
            ..rotateZ((1 - curvedAnimation.value) * 0.1),
          child: child,
        ),
        child: result,
      );
    }

    // Apply shake effect
    if (effect.has(SlotEffect.shake)) {
      final curvedAnimation = CurvedAnimation(
        parent: animation,
        curve: Curves.elasticOut,
      );
      result = SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.05, 0),
          end: Offset.zero,
        ).animate(curvedAnimation),
        child: result,
      );
    }

    // Apply slide effects with configurable offset
    if (effect.has(SlotEffect.slideUp)) {
      result = SlideTransition(
        position: Tween<Offset>(
          begin: Offset(0, widget.slideOffset.dy.abs()),
          end: Offset.zero,
        ).animate(animation),
        child: result,
      );
    } else if (effect.has(SlotEffect.slideDown)) {
      result = SlideTransition(
        position: Tween<Offset>(
          begin: Offset(0, -widget.slideOffset.dy.abs()),
          end: Offset.zero,
        ).animate(animation),
        child: result,
      );
    } else if (effect.has(SlotEffect.slideLeft)) {
      result = SlideTransition(
        position: Tween<Offset>(
          begin: Offset(widget.slideOffset.dx.abs(), 0),
          end: Offset.zero,
        ).animate(animation),
        child: result,
      );
    } else if (effect.has(SlotEffect.slideRight)) {
      result = SlideTransition(
        position: Tween<Offset>(
          begin: Offset(-widget.slideOffset.dx.abs(), 0),
          end: Offset.zero,
        ).animate(animation),
        child: result,
      );
    } else if (effect.has(SlotEffect.slide)) {
      result = SlideTransition(
        position: Tween<Offset>(
          begin: widget.slideOffset,
          end: Offset.zero,
        ).animate(animation),
        child: result,
      );
    }

    // Apply scale with configurable range
    if (effect.has(SlotEffect.scale)) {
      result = ScaleTransition(
        scale: Tween<double>(
          begin: widget.scaleBegin,
          end: widget.scaleEnd,
        ).animate(animation),
        child: result,
      );
    }

    // Apply bounce effect
    if (effect.has(SlotEffect.bounce)) {
      final curvedAnimation = CurvedAnimation(
        parent: animation,
        curve: Curves.bounceOut,
      );
      result = ScaleTransition(
        scale: Tween<double>(
          begin: widget.scaleBegin,
          end: widget.scaleEnd,
        ).animate(curvedAnimation),
        child: result,
      );
    }

    // Apply elastic effect
    if (effect.has(SlotEffect.elastic)) {
      final curvedAnimation = CurvedAnimation(
        parent: animation,
        curve: Curves.elasticOut,
      );
      result = ScaleTransition(
        scale: Tween<double>(
          begin: widget.scaleBegin,
          end: widget.scaleEnd,
        ).animate(curvedAnimation),
        child: result,
      );
    }

    // Apply pulse effect
    if (effect.has(SlotEffect.pulse)) {
      final curvedAnimation = CurvedAnimation(
        parent: animation,
        curve: Curves.elasticOut,
      );
      result = ScaleTransition(
        scale: Tween<double>(
          begin: 0.85,
          end: 1.0,
        ).animate(curvedAnimation),
        child: result,
      );
    }

    // Apply fade (most common, apply last for layering)
    if (effect.has(SlotEffect.fade)) {
      result = FadeTransition(opacity: animation, child: result);
    }

    return result;
  }
}

/// ConditionalSlot - Shows widget based on condition, with optional fallback.
///
/// Displays different widgets based on a boolean condition evaluated
/// from the signal's value.
///
/// ## Basic Usage
///
/// ```dart
/// final isLoggedIn = Signal<bool>(false);
///
/// ConditionalSlot<bool>(
///   connect: isLoggedIn,
///   when: (val) => val,
///   to: (context, _) => UserDashboard(),
///   orElse: (context) => LoginPage(),
/// )
/// ```
class ConditionalSlot<T> extends StatelessWidget {
  final Signal<T> connect;
  final bool Function(T value) when;
  final Widget Function(BuildContext context, T value) to;
  final Widget Function(BuildContext context)? orElse;

  const ConditionalSlot({
    super.key,
    required this.connect,
    required this.when,
    required this.to,
    this.orElse,
  });

  @override
  Widget build(BuildContext context) {
    return NeuronAtomBuilder<T>(
      atom: connect,
      builder: (ctx, val, _) {
        if (when(val)) {
          return to(ctx, val);
        }
        return orElse?.call(ctx) ?? const SizedBox.shrink();
      },
    );
  }
}

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

/// TransitionSlot - Animated transitions between different widgets.
///
/// Provides smooth transitions when the value changes, with
/// pre-built transition effects.
///
/// Example:
/// ```dart
/// enum PageType { home, profile, settings }
///
/// class NavController extends NeuronController {
///   late final currentPage = Signal<PageType>(PageType.home).bind(this);
/// }
///
/// // In your widget:
/// TransitionSlot<PageType>(
///   connect: controller.currentPage,
///   transition: SlotTransition.fade,
///   duration: Duration(milliseconds: 400),
///   to: (ctx, page) => pages[page]!,
/// )
/// ```
class TransitionSlot<T> extends StatelessWidget {
  final Signal<T> connect;
  final Widget Function(BuildContext context, T value) to;
  final SlotTransition transition;
  final Duration duration;
  final Curve curve;

  const TransitionSlot({
    super.key,
    required this.connect,
    required this.to,
    this.transition = SlotTransition.fade,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
  });

  @override
  Widget build(BuildContext context) {
    return NeuronAtomBuilder<T>(
      atom: connect,
      builder: (ctx, val, _) {
        return AnimatedSwitcher(
          duration: duration,
          switchInCurve: curve,
          switchOutCurve: curve,
          transitionBuilder: (child, animation) {
            return _buildTransition(transition, child, animation);
          },
          child: KeyedSubtree(
            key: ValueKey<T>(val),
            child: to(ctx, val),
          ),
        );
      },
    );
  }

  Widget _buildTransition(
      SlotTransition type, Widget child, Animation<double> animation) {
    switch (type) {
      case SlotTransition.fade:
        return FadeTransition(opacity: animation, child: child);

      case SlotTransition.scale:
        return ScaleTransition(scale: animation, child: child);

      case SlotTransition.slide:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        );

      case SlotTransition.slideUp:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.0, 1.0),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        );

      case SlotTransition.rotation:
        return RotationTransition(turns: animation, child: child);

      case SlotTransition.fadeScale:
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(scale: animation, child: child),
        );
    }
  }
}

/// Transition types for TransitionSlot.
enum SlotTransition {
  fade,
  scale,
  slide,
  slideUp,
  rotation,
  fadeScale,
}

/// ============================================================================
/// ADVANCED ANIMATION SLOTS
/// ============================================================================

/// AnimatedValueSlot - Interpolates numeric values with smooth animations.
///
/// Unlike AnimatedSlot which switches widgets, this animates the VALUE itself.
/// Perfect for counters, progress indicators, and numeric displays.
///
/// Example:
/// ```dart
/// class ScoreController extends NeuronController {
///   late final score = Signal<double>(0.0).bind(this);
/// }
///
/// // Animate the number smoothly:
/// AnimatedValueSlot<double>(
///   connect: controller.score,
///   duration: Duration(milliseconds: 800),
///   curve: Curves.easeOutCubic,
///   to: (ctx, animatedValue) => Text(
///     animatedValue.toStringAsFixed(0),
///     style: TextStyle(fontSize: 48),
///   ),
/// )
///
/// // With formatting:
/// AnimatedValueSlot<double>(
///   connect: controller.percentage,
///   format: (val) => '${val.toStringAsFixed(1)}%',
///   to: (ctx, formatted) => Text(formatted),
/// )
/// ```
class AnimatedValueSlot<T extends num> extends StatefulWidget {
  final Signal<T> connect;
  final Widget Function(BuildContext context, double animatedValue) to;
  final Duration duration;
  final Curve curve;
  final String Function(double value)? format;
  final VoidCallback? onAnimationComplete;

  const AnimatedValueSlot({
    super.key,
    required this.connect,
    required this.to,
    this.duration = const Duration(milliseconds: 500),
    this.curve = Curves.easeOutCubic,
    this.format,
    this.onAnimationComplete,
  });

  /// Create with formatted text output
  static AnimatedValueSlot<T> formatted<T extends num>({
    Key? key,
    required Signal<T> connect,
    required String Function(double value) format,
    required Widget Function(BuildContext context, String formatted) to,
    Duration duration = const Duration(milliseconds: 500),
    Curve curve = Curves.easeOutCubic,
  }) {
    return AnimatedValueSlot<T>(
      key: key,
      connect: connect,
      duration: duration,
      curve: curve,
      to: (ctx, val) => to(ctx, format(val)),
    );
  }

  @override
  State<AnimatedValueSlot<T>> createState() => _AnimatedValueSlotState<T>();
}

class _AnimatedValueSlotState<T extends num> extends State<AnimatedValueSlot<T>>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _previousValue = 0;
  double _targetValue = 0;

  late AtomListener _listenerHandle;

  @override
  void initState() {
    super.initState();
    _previousValue = widget.connect.value.toDouble();
    _targetValue = _previousValue;

    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _animation = Tween<double>(begin: _previousValue, end: _targetValue)
        .animate(CurvedAnimation(parent: _controller, curve: widget.curve));

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onAnimationComplete?.call();
      }
    });

    _listenerHandle = widget.connect.addListener(_onValueChanged);
  }

  @override
  void dispose() {
    widget.connect.removeListener(_listenerHandle);
    _controller.dispose();
    super.dispose();
  }

  void _onValueChanged() {
    final newValue = widget.connect.value.toDouble();
    if (newValue != _targetValue) {
      _previousValue = _animation.value;
      _targetValue = newValue;

      _animation = Tween<double>(begin: _previousValue, end: _targetValue)
          .animate(CurvedAnimation(parent: _controller, curve: widget.curve));

      _controller.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (ctx, _) => widget.to(ctx, _animation.value),
    );
  }
}

/// SpringSlot - Physics-based spring animations for natural motion.
///
/// Uses spring physics to create bouncy, natural-feeling animations.
/// Great for interactive elements, drag gestures, and micro-interactions.
///
/// Example:
/// ```dart
/// class CardController extends NeuronController {
///   late final isExpanded = Signal<bool>(false).bind(this);
///   late final scale = Signal<double>(1.0).bind(this);
/// }
///
/// // Bouncy toggle animation:
/// SpringSlot<double>(
///   connect: controller.scale,
///   spring: SpringConfig.bouncy,
///   to: (ctx, scale) => Transform.scale(
///     scale: scale,
///     child: MyCard(),
///   ),
/// )
///
/// // Smooth expansion:
/// SpringSlot<double>(
///   connect: controller.height,
///   spring: SpringConfig.smooth,
///   to: (ctx, height) => Container(height: height),
/// )
/// ```
class SpringSlot<T extends num> extends StatefulWidget {
  final Signal<T> connect;
  final Widget Function(BuildContext context, double animatedValue) to;
  final SpringConfig spring;
  final double? clampMin;
  final double? clampMax;
  final VoidCallback? onSettled;

  const SpringSlot({
    super.key,
    required this.connect,
    required this.to,
    this.spring = const SpringConfig(),
    this.clampMin,
    this.clampMax,
    this.onSettled,
  });

  @override
  State<SpringSlot<T>> createState() => _SpringSlotState<T>();
}

class _SpringSlotState<T extends num> extends State<SpringSlot<T>>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late SpringSimulation _simulation;
  double _currentValue = 0;
  double _targetValue = 0;
  double _velocity = 0;

  late AtomListener _listenerHandle;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.connect.value.toDouble();
    _targetValue = _currentValue;

    _controller = AnimationController.unbounded(vsync: this);
    _controller.addListener(_onTick);

    _listenerHandle = widget.connect.addListener(_onValueChanged);
  }

  @override
  void dispose() {
    widget.connect.removeListener(_listenerHandle);
    _controller.dispose();
    super.dispose();
  }

  void _onValueChanged() {
    final newValue = widget.connect.value.toDouble();
    if (newValue != _targetValue) {
      _targetValue = newValue;
      _startSpring();
    }
  }

  void _startSpring() {
    _simulation = SpringSimulation(
      widget.spring.toSpringDescription(),
      _currentValue,
      _targetValue,
      _velocity,
    );
    _controller.animateWith(_simulation);
  }

  void _onTick() {
    final newValue = _controller.value;
    _velocity = _simulation.dx(
        _controller.lastElapsedDuration?.inMicroseconds.toDouble() ??
            0 / 1000000);

    double clampedValue = newValue;
    if (widget.clampMin != null) {
      clampedValue = clampedValue.clamp(widget.clampMin!, double.infinity);
    }
    if (widget.clampMax != null) {
      clampedValue =
          clampedValue.clamp(double.negativeInfinity, widget.clampMax!);
    }

    if (_currentValue != clampedValue) {
      setState(() {
        _currentValue = clampedValue;
      });
    }

    if (_simulation.isDone(
        _controller.lastElapsedDuration?.inMicroseconds.toDouble() ??
            0 / 1000000)) {
      widget.onSettled?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.to(context, _currentValue);
  }
}

/// GestureAnimatedSlot - Combines gestures with animated state.
///
/// Provides tap, long-press, and drag interactions with built-in
/// press animations. Perfect for buttons and interactive cards.
///
/// Example:
/// ```dart
/// class ToggleController extends NeuronController {
///   late final isOn = Signal<bool>(false).bind(this);
///   void toggle() => isOn.emit(!isOn.val);
/// }
///
/// // Animated toggle button:
/// GestureAnimatedSlot<bool>(
///   connect: controller.isOn,
///   onTap: controller.toggle,
///   pressedScale: 0.95,
///   pressedOpacity: 0.8,
///   to: (ctx, isOn) => Container(
///     color: isOn ? Colors.green : Colors.grey,
///     child: Text(isOn ? 'ON' : 'OFF'),
///   ),
/// )
/// ```
class GestureAnimatedSlot<T> extends StatefulWidget {
  final Signal<T> connect;
  final Widget Function(BuildContext context, T value) to;
  final VoidCallback? onTap;
  final VoidCallback? onDoubleTap;
  final VoidCallback? onLongPress;
  final double pressedScale;
  final double pressedOpacity;
  final Duration pressDuration;
  final Curve pressCurve;
  final HitTestBehavior behavior;

  const GestureAnimatedSlot({
    super.key,
    required this.connect,
    required this.to,
    this.onTap,
    this.onDoubleTap,
    this.onLongPress,
    this.pressedScale = 0.95,
    this.pressedOpacity = 1.0,
    this.pressDuration = const Duration(milliseconds: 100),
    this.pressCurve = Curves.easeInOut,
    this.behavior = HitTestBehavior.opaque,
  });

  @override
  State<GestureAnimatedSlot<T>> createState() => _GestureAnimatedSlotState<T>();
}

class _GestureAnimatedSlotState<T> extends State<GestureAnimatedSlot<T>>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.pressDuration,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.pressedScale,
    ).animate(CurvedAnimation(parent: _controller, curve: widget.pressCurve));

    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: widget.pressedOpacity,
    ).animate(CurvedAnimation(parent: _controller, curve: widget.pressCurve));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) => _controller.forward();
  void _onTapUp(TapUpDetails _) => _controller.reverse();
  void _onTapCancel() => _controller.reverse();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: widget.behavior,
      onTap: widget.onTap,
      onDoubleTap: widget.onDoubleTap,
      onLongPress: widget.onLongPress,
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: NeuronAtomBuilder<T>(
        atom: widget.connect,
        builder: (ctx, val, _) {
          return AnimatedBuilder(
            animation: _controller,
            builder: (context, child) => Opacity(
              opacity: _opacityAnimation.value,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: child,
              ),
            ),
            child: widget.to(ctx, val),
          );
        },
      ),
    );
  }
}

/// PulseSlot - Continuous pulsing animation for attention.
///
/// Creates a repeating pulse effect to draw user attention.
/// Great for notifications, badges, and call-to-action elements.
///
/// Example:
/// ```dart
/// PulseSlot<int>(
///   connect: controller.unreadCount,
///   when: (count) => count > 0,  // Only pulse when there are unread items
///   to: (ctx, count) => Badge(count: count),
/// )
/// ```
class PulseSlot<T> extends StatefulWidget {
  final Signal<T> connect;
  final Widget Function(BuildContext context, T value) to;
  final bool Function(T value)? when;
  final Duration duration;
  final double minScale;
  final double maxScale;
  final double minOpacity;
  final double maxOpacity;

  const PulseSlot({
    super.key,
    required this.connect,
    required this.to,
    this.when,
    this.duration = const Duration(milliseconds: 1000),
    this.minScale = 0.95,
    this.maxScale = 1.05,
    this.minOpacity = 0.7,
    this.maxOpacity = 1.0,
  });

  @override
  State<PulseSlot<T>> createState() => _PulseSlotState<T>();
}

class _PulseSlotState<T> extends State<PulseSlot<T>>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  late AtomListener _listenerHandle;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _scaleAnimation = Tween<double>(
      begin: widget.minScale,
      end: widget.maxScale,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _opacityAnimation = Tween<double>(
      begin: widget.minOpacity,
      end: widget.maxOpacity,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _checkAndStartPulse();
    _listenerHandle = widget.connect.addListener(_checkAndStartPulse);
  }

  @override
  void dispose() {
    widget.connect.removeListener(_listenerHandle);
    _controller.dispose();
    super.dispose();
  }

  void _checkAndStartPulse() {
    final shouldPulse = widget.when?.call(widget.connect.value) ?? true;
    if (shouldPulse && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!shouldPulse && _controller.isAnimating) {
      _controller.stop();
      _controller.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    return NeuronAtomBuilder<T>(
      atom: widget.connect,
      builder: (ctx, val, _) {
        final shouldAnimate = widget.when?.call(val) ?? true;

        if (!shouldAnimate) {
          return widget.to(ctx, val);
        }

        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) => Opacity(
            opacity: _opacityAnimation.value,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: child,
            ),
          ),
          child: widget.to(ctx, val),
        );
      },
    );
  }
}

/// ShimmerSlot - Loading shimmer effect.
///
/// Displays a shimmering loading placeholder while waiting for data.
///
/// Example:
/// ```dart
/// ShimmerSlot<User?>(
///   connect: controller.user,
///   when: (user) => user == null,
///   shimmer: ShimmerPlaceholder(width: 200, height: 50),
///   to: (ctx, user) => UserProfile(user: user!),
/// )
/// ```
class ShimmerSlot<T> extends StatefulWidget {
  final Signal<T> connect;
  final Widget Function(BuildContext context, T value) to;
  final bool Function(T value) when;
  final Widget shimmer;
  final Duration duration;
  final Color baseColor;
  final Color highlightColor;

  const ShimmerSlot({
    super.key,
    required this.connect,
    required this.to,
    required this.when,
    required this.shimmer,
    this.duration = const Duration(milliseconds: 1500),
    this.baseColor = const Color(0xFFE0E0E0),
    this.highlightColor = const Color(0xFFF5F5F5),
  });

  @override
  State<ShimmerSlot<T>> createState() => _ShimmerSlotState<T>();
}

class _ShimmerSlotState<T> extends State<ShimmerSlot<T>>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NeuronAtomBuilder<T>(
      atom: widget.connect,
      builder: (ctx, val, _) {
        if (widget.when(val)) {
          return AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    widget.baseColor,
                    widget.highlightColor,
                    widget.baseColor,
                  ],
                  stops: [
                    (_controller.value - 0.3).clamp(0.0, 1.0),
                    _controller.value,
                    (_controller.value + 0.3).clamp(0.0, 1.0),
                  ],
                ).createShader(bounds),
                child: child,
              );
            },
            child: widget.shimmer,
          );
        }
        return widget.to(ctx, val);
      },
    );
  }
}

/// DebounceSlot - Debounced rebuilds for performance.
///
/// Delays rebuilding until the signal stops changing for the
/// specified duration. Perfect for search inputs or frequently
/// updating values.
///
/// Example:
/// ```dart
/// class SearchController extends NeuronController {
///   late final searchQuery = Signal<String>('').bind(this);
/// }
///
/// // In your widget:
/// DebounceSlot<String>(
///   connect: controller.searchQuery,
///   duration: Duration(milliseconds: 300),
///   to: (ctx, query) => SearchResults(query: query),
/// )
/// ```
class DebounceSlot<T> extends StatefulWidget {
  final Signal<T> connect;
  final Widget Function(BuildContext context, T value) to;
  final Duration duration;
  final Widget? child;

  const DebounceSlot({
    super.key,
    required this.connect,
    required this.to,
    this.duration = const Duration(milliseconds: 300),
    this.child,
  });

  @override
  State<DebounceSlot<T>> createState() => _DebounceSlotState<T>();
}

class _DebounceSlotState<T> extends State<DebounceSlot<T>> {
  late T _debouncedValue;
  Timer? _debounceTimer;

  late AtomListener _listenerHandle;

  @override
  void initState() {
    super.initState();
    _debouncedValue = widget.connect.value;
    _listenerHandle = widget.connect.addListener(_onValueChanged);
  }

  @override
  void dispose() {
    widget.connect.removeListener(_listenerHandle);
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onValueChanged() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(widget.duration, () {
      if (mounted) {
        setState(() {
          _debouncedValue = widget.connect.value;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.to(context, _debouncedValue);
  }
}

/// MemoizedSlot - Cache expensive builds with custom equality.
///
/// Only rebuilds when the value actually changes according to
/// the provided equality function. Great for lists and complex objects.
///
/// Example:
/// ```dart
/// class ItemsController extends NeuronController {
///   late final items = ListSignal<Item>([]).bind(this);
/// }
///
/// // In your widget:
/// MemoizedSlot<List<Item>>(
///   connect: controller.items,
///   equals: (a, b) => listEquals(a, b),
///   to: (ctx, items) => ExpensiveListWidget(items: items),
/// )
/// ```
class MemoizedSlot<T> extends StatefulWidget {
  final Signal<T> connect;
  final Widget Function(BuildContext context, T value) to;
  final bool Function(T a, T b)? equals;
  final Widget? child;

  const MemoizedSlot({
    super.key,
    required this.connect,
    required this.to,
    this.equals,
    this.child,
  });

  @override
  State<MemoizedSlot<T>> createState() => _MemoizedSlotState<T>();
}

class _MemoizedSlotState<T> extends State<MemoizedSlot<T>> {
  late T _cachedValue;
  late Widget _cachedWidget;

  late AtomListener _listenerHandle;

  @override
  void initState() {
    super.initState();
    _cachedValue = widget.connect.value;
    _cachedWidget = widget.to(context, _cachedValue);
    _listenerHandle = widget.connect.addListener(_onValueChanged);
  }

  @override
  void dispose() {
    widget.connect.removeListener(_listenerHandle);
    super.dispose();
  }

  void _onValueChanged() {
    final newValue = widget.connect.value;
    final hasChanged = widget.equals != null
        ? !widget.equals!(_cachedValue, newValue)
        : _cachedValue != newValue;

    if (hasChanged && mounted) {
      setState(() {
        _cachedValue = newValue;
        _cachedWidget = widget.to(context, _cachedValue);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _cachedWidget;
  }
}

/// ThrottleSlot - Throttled rebuilds for performance.
///
/// Limits rebuild frequency to once per duration. First value
/// is shown immediately, then subsequent changes are ignored
/// until the duration passes.
///
/// Example:
/// ```dart
/// class ScrollController extends NeuronController {
///   late final scrollPosition = Signal<double>(0.0).bind(this);
/// }
///
/// // In your widget:
/// ThrottleSlot<double>(
///   connect: controller.scrollPosition,
///   duration: Duration(milliseconds: 16), // ~60fps
///   to: (ctx, pos) => ScrollIndicator(position: pos),
/// )
/// ```
class ThrottleSlot<T> extends StatefulWidget {
  final Signal<T> connect;
  final Widget Function(BuildContext context, T value) to;
  final Duration duration;

  const ThrottleSlot({
    super.key,
    required this.connect,
    required this.to,
    this.duration = const Duration(milliseconds: 100),
  });

  @override
  State<ThrottleSlot<T>> createState() => _ThrottleSlotState<T>();
}

class _ThrottleSlotState<T> extends State<ThrottleSlot<T>> {
  late T _throttledValue;
  bool _isThrottled = false;

  late AtomListener _listenerHandle;

  @override
  void initState() {
    super.initState();
    _throttledValue = widget.connect.value;
    _listenerHandle = widget.connect.addListener(_onValueChanged);
  }

  @override
  void dispose() {
    widget.connect.removeListener(_listenerHandle);
    super.dispose();
  }

  void _onValueChanged() {
    if (!_isThrottled && mounted) {
      setState(() {
        _throttledValue = widget.connect.value;
      });
      _isThrottled = true;
      Future.delayed(widget.duration, () {
        _isThrottled = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.to(context, _throttledValue);
  }
}

/// LazySlot - Lazy build widget until first value change.
///
/// Defers building the widget until the signal's value actually changes.
/// Useful for expensive widgets that don't need to render immediately.
///
/// Example:
/// ```dart
/// class DataController extends NeuronController {
///   late final expensiveData = Signal<Data?>(null).bind(this);
///
///   Future<void> loadData() async {
///     final data = await api.fetchData();
///     expensiveData.emit(data);
///   }
/// }
///
/// // In your widget:
/// LazySlot<Data?>(
///   connect: controller.expensiveData,
///   to: (ctx, data) => ExpensiveVisualization(data: data!),
///   placeholder: (ctx) => Text('Loading...'),
/// )
/// ```
class LazySlot<T> extends StatefulWidget {
  final Signal<T> connect;
  final Widget Function(BuildContext context, T value) to;
  final Widget Function(BuildContext context)? placeholder;

  const LazySlot({
    super.key,
    required this.connect,
    required this.to,
    this.placeholder,
  });

  @override
  State<LazySlot<T>> createState() => _LazySlotState<T>();
}

class _LazySlotState<T> extends State<LazySlot<T>> {
  bool _hasBuilt = false;

  late AtomListener _listenerHandle;

  @override
  void initState() {
    super.initState();
    _listenerHandle = widget.connect.addListener(_onValueChanged);
  }

  @override
  void dispose() {
    widget.connect.removeListener(_listenerHandle);
    super.dispose();
  }

  void _onValueChanged() {
    if (mounted && !_hasBuilt) {
      setState(() {
        _hasBuilt = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasBuilt) {
      return widget.placeholder?.call(context) ?? const SizedBox.shrink();
    }
    return NeuronAtomBuilder<T>(
      atom: widget.connect,
      builder: (ctx, val, _) => widget.to(ctx, val),
    );
  }
}

/// ============================================================================
/// COMPOSABLE SLOT MODIFIERS (Extension Methods)
/// ============================================================================

/// Elegant chainable modifiers for Signal-based widgets.
///
/// Example:
/// ```dart
/// controller.count
///   .slot((ctx, val) => Text('$val'))
///   .animated(effect: SlotEffect.fadeScale)
///   .withDelay(Duration(milliseconds: 100))
///   .onTap(() => controller.increment());
/// ```
extension SignalSlotExtensions<T> on Signal<T> {
  /// Create a basic Slot widget from this signal.
  Widget slot(Widget Function(BuildContext context, T value) builder) {
    return Slot<T>(connect: this, to: builder);
  }

  /// Create an AnimatedSlot with elegant syntax.
  Widget animated({
    required Widget Function(BuildContext context, T value) to,
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeInOut,
    SlotEffect effect = SlotEffect.fade,
    DirectionalEffect? directionalEffect,
  }) {
    return AnimatedSlot<T>(
      connect: this,
      to: to,
      duration: duration,
      curve: curve,
      effect: effect,
      directionalEffect: directionalEffect,
    );
  }

  /// Create a TransitionSlot with specified transition type.
  Widget transition({
    required Widget Function(BuildContext context, T value) to,
    SlotTransition type = SlotTransition.fade,
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeInOut,
  }) {
    return TransitionSlot<T>(
      connect: this,
      to: to,
      transition: type,
      duration: duration,
      curve: curve,
    );
  }

  /// Create a conditional slot with when/orElse.
  Widget when({
    required bool Function(T value) condition,
    required Widget Function(BuildContext context, T value) to,
    Widget Function(BuildContext context)? orElse,
  }) {
    return ConditionalSlot<T>(
      connect: this,
      when: condition,
      to: to,
      orElse: orElse,
    );
  }

  /// Create a debounced slot.
  Widget debounced({
    required Widget Function(BuildContext context, T value) to,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return DebounceSlot<T>(
      connect: this,
      to: to,
      duration: duration,
    );
  }

  /// Create a throttled slot.
  Widget throttled({
    required Widget Function(BuildContext context, T value) to,
    Duration duration = const Duration(milliseconds: 100),
  }) {
    return ThrottleSlot<T>(
      connect: this,
      to: to,
      duration: duration,
    );
  }

  /// Create a memoized slot with custom equality.
  Widget memoized({
    required Widget Function(BuildContext context, T value) to,
    bool Function(T a, T b)? equals,
  }) {
    return MemoizedSlot<T>(
      connect: this,
      to: to,
      equals: equals,
    );
  }

  /// Create a lazy slot that defers building.
  Widget lazy({
    required Widget Function(BuildContext context, T value) to,
    Widget Function(BuildContext context)? placeholder,
  }) {
    return LazySlot<T>(
      connect: this,
      to: to,
      placeholder: placeholder,
    );
  }

  /// Create a pulsing slot for attention.
  Widget pulsing({
    required Widget Function(BuildContext context, T value) to,
    bool Function(T value)? when,
    Duration duration = const Duration(milliseconds: 1000),
  }) {
    return PulseSlot<T>(
      connect: this,
      to: to,
      when: when,
      duration: duration,
    );
  }

  /// Create a gesture-animated slot.
  Widget tappable({
    required Widget Function(BuildContext context, T value) to,
    VoidCallback? onTap,
    VoidCallback? onDoubleTap,
    VoidCallback? onLongPress,
    double pressedScale = 0.95,
  }) {
    return GestureAnimatedSlot<T>(
      connect: this,
      to: to,
      onTap: onTap,
      onDoubleTap: onDoubleTap,
      onLongPress: onLongPress,
      pressedScale: pressedScale,
    );
  }
}

/// Extensions for numeric signals with interpolation.
extension NumericSignalSlotExtensions<T extends num> on Signal<T> {
  /// Create an AnimatedValueSlot that interpolates the numeric value.
  Widget interpolated({
    required Widget Function(BuildContext context, double animatedValue) to,
    Duration duration = const Duration(milliseconds: 500),
    Curve curve = Curves.easeOutCubic,
  }) {
    return AnimatedValueSlot<T>(
      connect: this,
      to: to,
      duration: duration,
      curve: curve,
    );
  }

  /// Create a SpringSlot with physics-based animation.
  Widget spring({
    required Widget Function(BuildContext context, double animatedValue) to,
    SpringConfig config = const SpringConfig(),
    double? clampMin,
    double? clampMax,
  }) {
    return SpringSlot<T>(
      connect: this,
      to: to,
      spring: config,
      clampMin: clampMin,
      clampMax: clampMax,
    );
  }

  /// Create a bouncy spring animation.
  Widget bouncy({
    required Widget Function(BuildContext context, double animatedValue) to,
  }) {
    return SpringSlot<T>(
      connect: this,
      to: to,
      spring: SpringConfig.bouncy,
    );
  }

  /// Create a smooth spring animation.
  Widget smooth({
    required Widget Function(BuildContext context, double animatedValue) to,
  }) {
    return SpringSlot<T>(
      connect: this,
      to: to,
      spring: SpringConfig.smooth,
    );
  }
}

/// Widget wrapper for chainable modifiers.
extension SlotWidgetModifiers on Widget {
  /// Wrap with fade animation on appear.
  Widget withFade({
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeInOut,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: duration,
      curve: curve,
      builder: (context, opacity, child) => Opacity(
        opacity: opacity,
        child: child,
      ),
      child: this,
    );
  }

  /// Wrap with scale animation on appear.
  Widget withScale({
    double begin = 0.8,
    double end = 1.0,
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeOutBack,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: begin, end: end),
      duration: duration,
      curve: curve,
      builder: (context, scale, child) => Transform.scale(
        scale: scale,
        child: child,
      ),
      child: this,
    );
  }

  /// Wrap with slide animation on appear.
  Widget withSlide({
    Offset begin = const Offset(0, 0.2),
    Offset end = Offset.zero,
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeOutCubic,
  }) {
    return TweenAnimationBuilder<Offset>(
      tween: Tween(begin: begin, end: end),
      duration: duration,
      curve: curve,
      builder: (context, offset, child) => Transform.translate(
        offset: Offset(
          offset.dx * 100, // Convert to pixels
          offset.dy * 100,
        ),
        child: child,
      ),
      child: this,
    );
  }

  /// Add a delay before showing.
  Widget withDelay(Duration delay) {
    return _DelayedWidget(delay: delay, child: this);
  }

  /// Wrap with tap gesture.
  Widget onTap(VoidCallback onTap, {double pressedScale = 0.95}) {
    return _TappableWrapper(
      onTap: onTap,
      pressedScale: pressedScale,
      child: this,
    );
  }

  /// Wrap with hero animation.
  Widget withHero(Object tag) {
    return Hero(tag: tag, child: this);
  }

  /// Apply a shimmer loading effect.
  Widget withShimmer({
    Duration duration = const Duration(milliseconds: 1500),
    Color baseColor = const Color(0xFFE0E0E0),
    Color highlightColor = const Color(0xFFF5F5F5),
  }) {
    return _ShimmerWrapper(
      duration: duration,
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: this,
    );
  }
}

/// Internal widget for delayed appearance.
class _DelayedWidget extends StatefulWidget {
  final Duration delay;
  final Widget child;

  const _DelayedWidget({required this.delay, required this.child});

  @override
  State<_DelayedWidget> createState() => _DelayedWidgetState();
}

class _DelayedWidgetState extends State<_DelayedWidget> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(widget.delay, () {
      if (mounted) setState(() => _visible = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _visible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 200),
      child: widget.child,
    );
  }
}

/// Internal widget for tappable wrapper with press animation.
class _TappableWrapper extends StatefulWidget {
  final VoidCallback onTap;
  final double pressedScale;
  final Widget child;

  const _TappableWrapper({
    required this.onTap,
    required this.pressedScale,
    required this.child,
  });

  @override
  State<_TappableWrapper> createState() => _TappableWrapperState();
}

class _TappableWrapperState extends State<_TappableWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scale = Tween<double>(begin: 1.0, end: widget.pressedScale)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scale,
        builder: (context, child) => Transform.scale(
          scale: _scale.value,
          child: child,
        ),
        child: widget.child,
      ),
    );
  }
}

/// Internal widget for shimmer effect.
class _ShimmerWrapper extends StatefulWidget {
  final Duration duration;
  final Color baseColor;
  final Color highlightColor;
  final Widget child;

  const _ShimmerWrapper({
    required this.duration,
    required this.baseColor,
    required this.highlightColor,
    required this.child,
  });

  @override
  State<_ShimmerWrapper> createState() => _ShimmerWrapperState();
}

class _ShimmerWrapperState extends State<_ShimmerWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => ShaderMask(
        shaderCallback: (bounds) => LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            widget.baseColor,
            widget.highlightColor,
            widget.baseColor,
          ],
          stops: [
            (_controller.value - 0.3).clamp(0.0, 1.0),
            _controller.value,
            (_controller.value + 0.3).clamp(0.0, 1.0),
          ],
        ).createShader(bounds),
        child: child,
      ),
      child: widget.child,
    );
  }
}

/// ============================================================================
/// FORM SLOT - REACTIVE FORM HANDLING WITH ANIMATIONS
/// ============================================================================

/// Field state for tracking form input status.
enum FormFieldState {
  /// Field has not been interacted with
  pristine,

  /// Field has been focused at least once
  touched,

  /// Field value has been modified
  dirty,

  /// Field is currently focused
  focused,
}

/// Validation result for form fields.
class FormValidationResult {
  final bool isValid;
  final String? errorMessage;

  const FormValidationResult.valid()
      : isValid = true,
        errorMessage = null;
  const FormValidationResult.invalid(this.errorMessage) : isValid = false;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FormValidationResult &&
          isValid == other.isValid &&
          errorMessage == other.errorMessage;

  @override
  int get hashCode => Object.hash(isValid, errorMessage);
}

/// Animation effect for form validation states.
enum FormAnimationEffect {
  /// Shake effect for errors
  shake,

  /// Pulse effect for success
  pulse,

  /// Fade effect for transitions
  fade,

  /// Scale effect
  scale,

  /// Slide effect for error messages
  slide,

  /// Combined shake + fade for error display
  shakeFade,
}

/// AnimatedFormSlot - Reactive form field with built-in animations.
///
/// Provides animated feedback for form field states including validation,
/// focus, and error animations. Supports shake on error, pulse on success,
/// and smooth error message transitions.
///
/// Example:
/// ```dart
/// class LoginController extends NeuronController {
///   late final email = Signal<String>('').bind(this);
///   late final emailError = Signal<String?>('').bind(this);
///   late final emailFocused = Signal<bool>(false).bind(this);
///
///   static final _emailRegex = RegExp(
///     r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
///   );
///
///   String? validateEmail(String value) {
///     if (value.isEmpty) return 'Email is required';
///     if (!_emailRegex.hasMatch(value)) return 'Invalid email format';
///     return null;
///   }
/// }
///
/// // In your widget:
/// AnimatedFormSlot<String>(
///   connect: controller.email,
///   validator: controller.validateEmail,
///   errorSignal: controller.emailError,
///   focusedSignal: controller.emailFocused,
///   errorEffect: FormAnimationEffect.shake,
///   successEffect: FormAnimationEffect.pulse,
///   to: (context, value, validation, isFocused) => TextField(
///     onChanged: (v) => controller.email.emit(v),
///     decoration: InputDecoration(
///       labelText: 'Email',
///       errorText: validation.errorMessage,
///       border: OutlineInputBorder(
///         borderSide: BorderSide(
///           color: validation.isValid ? Colors.green : Colors.red,
///         ),
///       ),
///     ),
///   ),
/// )
/// ```
class AnimatedFormSlot<T> extends StatefulWidget {
  /// The signal containing the form field value
  final Signal<T> connect;

  /// Builder function for the form field widget
  final Widget Function(
    BuildContext context,
    T value,
    FormValidationResult validation,
    bool isFocused,
  ) to;

  /// Optional validator function
  final String? Function(T value)? validator;

  /// Optional signal to emit error messages to
  final Signal<String?>? errorSignal;

  /// Optional signal to track focus state
  final Signal<bool>? focusedSignal;

  /// Animation effect for error state
  final FormAnimationEffect errorEffect;

  /// Animation effect for success state
  final FormAnimationEffect successEffect;

  /// Duration for animations
  final Duration animationDuration;

  /// Curve for animations
  final Curve animationCurve;

  /// Whether to validate on every change
  final bool validateOnChange;

  /// Whether to show success animation
  final bool showSuccessAnimation;

  /// Delay before validation after change
  final Duration validationDelay;

  /// Callback when validation state changes
  final void Function(FormValidationResult result)? onValidationChanged;

  /// Creates an AnimatedFormSlot for form fields with validation animations.
  ///
  /// ## Basic Usage
  /// ```dart
  /// AnimatedFormSlot<String>(
  ///   connect: controller.email,
  ///   validator: (value) => value.isEmpty ? 'Required' : null,
  ///   to: (context, value, validation, isFocused) => TextField(
  ///     onChanged: (v) => controller.email.emit(v),
  ///     decoration: InputDecoration(
  ///       errorText: validation.errorMessage,
  ///     ),
  ///   ),
  /// )
  /// ```
  ///
  /// ## With Animation Effects
  /// ```dart
  /// AnimatedFormSlot<String>(
  ///   connect: controller.password,
  ///   validator: (v) => v.length < 8 ? 'Min 8 chars' : null,
  ///   errorEffect: FormAnimationEffect.shake,
  ///   successEffect: FormAnimationEffect.pulse,
  ///   showSuccessAnimation: true,
  ///   to: (context, value, validation, isFocused) => ...
  /// )
  /// ```
  ///
  /// **Best practices**:
  /// - Use [validationDelay] for debounced validation on text fields
  /// - Connect [errorSignal] to display errors elsewhere in the UI
  /// - Use [focusedSignal] to style focused fields differently
  const AnimatedFormSlot({
    super.key,
    required this.connect,
    required this.to,
    this.validator,
    this.errorSignal,
    this.focusedSignal,
    this.errorEffect = FormAnimationEffect.shake,
    this.successEffect = FormAnimationEffect.pulse,
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationCurve = Curves.easeInOut,
    this.validateOnChange = true,
    this.showSuccessAnimation = true,
    this.validationDelay = Duration.zero,
    this.onValidationChanged,
  });

  @override
  State<AnimatedFormSlot<T>> createState() => _AnimatedFormSlotState<T>();
}

class _AnimatedFormSlotState<T> extends State<AnimatedFormSlot<T>>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _shakeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  FormValidationResult _validationResult = const FormValidationResult.valid();
  FormValidationResult? _previousValidation;
  bool _isFocused = false;
  Timer? _validationTimer;
  bool _hasInteracted = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );

    _setupAnimations();

    // Listen to value changes
    widget.connect.addListener(_onValueChanged);

    // Listen to focus changes if provided
    widget.focusedSignal?.addListener(_onFocusChanged);

    // Initial validation
    if (widget.validator != null) {
      _validate(widget.connect.value, animate: false);
    }
  }

  void _setupAnimations() {
    // Shake animation for errors
    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: 10), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 10, end: -10), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -10, end: 8), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 8, end: -8), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -8, end: 5), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 5, end: -5), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -5, end: 0), weight: 1),
    ]).animate(
        CurvedAnimation(parent: _controller, curve: widget.animationCurve));

    // Scale animation for success pulse
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.05), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 1.05, end: 1.0), weight: 1),
    ]).animate(
        CurvedAnimation(parent: _controller, curve: widget.animationCurve));

    // Fade animation
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _controller, curve: widget.animationCurve));
  }

  late AtomListener _listenerHandle;
  AtomListener? _focusHandle;

  @override
  void dispose() {
    widget.connect.removeListener(_listenerHandle);
    if (_focusHandle != null) {
      widget.focusedSignal?.removeListener(_focusHandle!);
    }
    _validationTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onValueChanged() {
    _hasInteracted = true;
    if (widget.validateOnChange && widget.validator != null) {
      _validationTimer?.cancel();
      if (widget.validationDelay == Duration.zero) {
        _validate(widget.connect.value, animate: true);
      } else {
        _validationTimer = Timer(widget.validationDelay, () {
          if (mounted) {
            _validate(widget.connect.value, animate: true);
          }
        });
      }
    }
  }

  void _onFocusChanged() {
    if (mounted) {
      setState(() {
        _isFocused = widget.focusedSignal?.value ?? false;
      });
    }
  }

  void _validate(T value, {bool animate = true}) {
    final errorMessage = widget.validator?.call(value);
    final newResult = errorMessage == null
        ? const FormValidationResult.valid()
        : FormValidationResult.invalid(errorMessage);

    // Only update if changed
    if (newResult != _validationResult) {
      _previousValidation = _validationResult;
      setState(() {
        _validationResult = newResult;
      });

      // Update error signal if provided
      widget.errorSignal?.emit(newResult.errorMessage);

      // Callback
      widget.onValidationChanged?.call(newResult);

      // Animate if needed
      if (animate && _hasInteracted) {
        _animateTransition(newResult);
      }
    }
  }

  void _animateTransition(FormValidationResult result) {
    _controller.reset();
    if (!result.isValid) {
      // Error animation
      if (widget.errorEffect == FormAnimationEffect.shake ||
          widget.errorEffect == FormAnimationEffect.shakeFade) {
        _controller.forward();
      }
    } else if (widget.showSuccessAnimation &&
        _previousValidation?.isValid == false) {
      // Success animation (only when transitioning from error to valid)
      _controller.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return NeuronAtomBuilder<T>(
      atom: widget.connect,
      builder: (ctx, value, _) {
        Widget child = widget.to(ctx, value, _validationResult, _isFocused);

        return AnimatedBuilder(
          animation: _controller,
          builder: (context, staticChild) {
            Widget result = staticChild ?? child;

            // Apply error effects
            if (!_validationResult.isValid && _hasInteracted) {
              switch (widget.errorEffect) {
                case FormAnimationEffect.shake:
                case FormAnimationEffect.shakeFade:
                  result = Transform.translate(
                    offset: Offset(_shakeAnimation.value, 0),
                    child: result,
                  );
                  break;
                case FormAnimationEffect.scale:
                  result = Transform.scale(
                    scale: _scaleAnimation.value,
                    child: result,
                  );
                  break;
                case FormAnimationEffect.fade:
                case FormAnimationEffect.slide:
                case FormAnimationEffect.pulse:
                  break;
              }
            }

            // Apply success effects
            if (_validationResult.isValid &&
                _previousValidation?.isValid == false &&
                widget.showSuccessAnimation) {
              switch (widget.successEffect) {
                case FormAnimationEffect.pulse:
                case FormAnimationEffect.scale:
                  result = Transform.scale(
                    scale: _scaleAnimation.value,
                    child: result,
                  );
                  break;
                case FormAnimationEffect.fade:
                  result = Opacity(
                    opacity: _fadeAnimation.value.clamp(0.5, 1.0),
                    child: result,
                  );
                  break;
                case FormAnimationEffect.shake:
                case FormAnimationEffect.shakeFade:
                case FormAnimationEffect.slide:
                  break;
              }
            }

            return result;
          },
          child: child,
        );
      },
    );
  }
}

/// AnimatedErrorMessage - Animated error message display.
///
/// Shows and hides error messages with animations.
///
/// Example:
/// ```dart
/// AnimatedErrorMessage(
///   connect: controller.emailError,
///   effect: FormAnimationEffect.slide,
///   to: (context, error) => Text(
///     error,
///     style: TextStyle(color: Colors.red),
///   ),
/// )
/// ```
class AnimatedErrorMessage extends StatelessWidget {
  /// The signal containing the error message (or null if no error).
  final Signal<String?> connect;

  /// Builder function to display the error message.
  final Widget Function(BuildContext context, String error) to;

  /// The animation effect to use when showing/hiding the error.
  final FormAnimationEffect effect;

  /// The duration of the animation.
  final Duration duration;

  /// The curve of the animation.
  final Curve curve;

  /// Creates an animated error message widget.
  const AnimatedErrorMessage({
    super.key,
    required this.connect,
    required this.to,
    this.effect = FormAnimationEffect.slide,
    this.duration = const Duration(milliseconds: 250),
    this.curve = Curves.easeOutCubic,
  });

  @override
  Widget build(BuildContext context) {
    return NeuronAtomBuilder<String?>(
      atom: connect,
      builder: (ctx, error, _) {
        return AnimatedSwitcher(
          duration: duration,
          switchInCurve: curve,
          switchOutCurve: curve,
          transitionBuilder: (child, animation) {
            switch (effect) {
              case FormAnimationEffect.slide:
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, -0.5),
                    end: Offset.zero,
                  ).animate(animation),
                  child: FadeTransition(opacity: animation, child: child),
                );
              case FormAnimationEffect.fade:
                return FadeTransition(opacity: animation, child: child);
              case FormAnimationEffect.scale:
                return ScaleTransition(scale: animation, child: child);
              case FormAnimationEffect.shake:
              case FormAnimationEffect.pulse:
              case FormAnimationEffect.shakeFade:
                return FadeTransition(opacity: animation, child: child);
            }
          },
          child: error != null && error.isNotEmpty
              ? KeyedSubtree(
                  key: ValueKey(error),
                  child: to(ctx, error),
                )
              : const SizedBox.shrink(),
        );
      },
    );
  }
}

/// FormFieldWrapper - Convenience wrapper for form fields with validation UI.
///
/// Combines a form field with animated error message display.
///
/// Example:
/// ```dart
/// FormFieldWrapper<String>(
///   connect: controller.email,
///   validator: (v) => v.isEmpty ? 'Required' : null,
///   label: 'Email',
///   to: (context, value, onChanged) => TextField(
///     onChanged: onChanged,
///     decoration: InputDecoration(labelText: 'Email'),
///   ),
/// )
/// ```
class FormFieldWrapper<T> extends StatefulWidget {
  final Signal<T> connect;
  final Widget Function(
    BuildContext context,
    T value,
    void Function(T) onChanged,
  ) to;
  final String? Function(T value)? validator;
  final String? label;
  final FormAnimationEffect errorEffect;
  final Duration animationDuration;

  const FormFieldWrapper({
    super.key,
    required this.connect,
    required this.to,
    this.validator,
    this.label,
    this.errorEffect = FormAnimationEffect.shakeFade,
    this.animationDuration = const Duration(milliseconds: 300),
  });

  @override
  State<FormFieldWrapper<T>> createState() => _FormFieldWrapperState<T>();
}

class _FormFieldWrapperState<T> extends State<FormFieldWrapper<T>> {
  final _errorSignal = Signal<String?>(null);

  @override
  void dispose() {
    _errorSignal.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedFormSlot<T>(
          connect: widget.connect,
          validator: widget.validator,
          errorSignal: _errorSignal,
          errorEffect: widget.errorEffect,
          animationDuration: widget.animationDuration,
          to: (ctx, value, validation, isFocused) {
            return widget.to(ctx, value, (newValue) {
              widget.connect.emit(newValue);
            });
          },
        ),
        const SizedBox(height: 4),
        AnimatedErrorMessage(
          connect: _errorSignal,
          to: (ctx, error) => Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Text(
              error,
              style: const TextStyle(
                color: Color(0xFFD32F2F),
                fontSize: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// ============================================================================
/// MORPH SLOT - SHAPE/WIDGET MORPHING ANIMATIONS
/// ============================================================================

/// Morph configuration for defining how widgets transition.
class MorphConfig {
  /// Duration of the morph animation
  final Duration duration;

  /// Curve for the animation
  final Curve curve;

  /// Whether to animate size changes
  final bool morphSize;

  /// Whether to animate decoration (colors, borders, shadows)
  final bool morphDecoration;

  /// Whether to use clipping during transition
  final bool clipDuringMorph;

  /// Alignment during morph
  final Alignment alignment;

  const MorphConfig({
    this.duration = const Duration(milliseconds: 400),
    this.curve = Curves.easeInOutCubic,
    this.morphSize = true,
    this.morphDecoration = true,
    this.clipDuringMorph = true,
    this.alignment = Alignment.center,
  });

  /// Quick morph (200ms)
  static const quick = MorphConfig(
    duration: Duration(milliseconds: 200),
    curve: Curves.easeOut,
  );

  /// Smooth morph (400ms)
  static const smooth = MorphConfig(
    duration: Duration(milliseconds: 400),
    curve: Curves.easeInOutCubic,
  );

  /// Bouncy morph with overshoot
  static const bouncy = MorphConfig(
    duration: Duration(milliseconds: 500),
    curve: Curves.elasticOut,
  );

  /// Slow dramatic morph
  static const dramatic = MorphConfig(
    duration: Duration(milliseconds: 600),
    curve: Curves.easeInOutQuart,
  );
}

/// MorphSlot - Widget morphing animations.
///
/// Smoothly morphs between different widget states based on signal values.
/// Perfect for play/pause buttons, expand/collapse cards, and shape transitions.
///
/// Example:
/// ```dart
/// class PlayerController extends NeuronController {
///   late final isPlaying = Signal<bool>(false).bind(this);
///   void toggle() => isPlaying.emit(!isPlaying.val);
/// }
///
/// // Play/Pause button morph:
/// MorphSlot<bool>(
///   connect: controller.isPlaying,
///   config: MorphConfig.smooth,
///   morphBuilder: (context, value) => MorphableWidget(
///     child: Icon(value ? Icons.pause : Icons.play_arrow, size: 48),
///     decoration: BoxDecoration(
///       color: value ? Colors.red : Colors.green,
///       shape: BoxShape.circle,
///     ),
///     size: Size(80, 80),
///   ),
/// )
///
/// // Expandable card:
/// MorphSlot<bool>(
///   connect: controller.isExpanded,
///   config: MorphConfig.bouncy,
///   morphBuilder: (context, expanded) => MorphableWidget(
///     child: expanded ? ExpandedContent() : CollapsedContent(),
///     decoration: BoxDecoration(
///       color: Colors.white,
///       borderRadius: BorderRadius.circular(expanded ? 16 : 8),
///       boxShadow: [BoxShadow(blurRadius: expanded ? 20 : 8)],
///     ),
///     size: Size(double.infinity, expanded ? 300 : 80),
///   ),
/// )
/// ```
class MorphSlot<T> extends StatefulWidget {
  /// The signal to connect to
  final Signal<T> connect;

  /// Builder that returns a MorphableWidget for each value
  final MorphableWidget Function(BuildContext context, T value) morphBuilder;

  /// Configuration for the morph animation
  final MorphConfig config;

  /// Callback when morph animation starts
  final VoidCallback? onMorphStart;

  /// Callback when morph animation completes
  final VoidCallback? onMorphComplete;

  const MorphSlot({
    super.key,
    required this.connect,
    required this.morphBuilder,
    this.config = const MorphConfig(),
    this.onMorphStart,
    this.onMorphComplete,
  });

  @override
  State<MorphSlot<T>> createState() => _MorphSlotState<T>();
}

class _MorphSlotState<T> extends State<MorphSlot<T>>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  MorphableWidget? _previousWidget;
  MorphableWidget? _currentWidget;
  bool _isFirstBuild = true;

  late AtomListener _listenerHandle;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.config.duration,
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onMorphComplete?.call();
      }
    });

    _listenerHandle = widget.connect.addListener(_onValueChanged);
  }

  @override
  void dispose() {
    widget.connect.removeListener(_listenerHandle);
    _controller.dispose();
    super.dispose();
  }

  void _onValueChanged() {
    if (mounted) {
      final newWidget = widget.morphBuilder(context, widget.connect.value);
      if (_currentWidget != null) {
        _previousWidget = _currentWidget;
        _currentWidget = newWidget;
        widget.onMorphStart?.call();
        _controller.forward(from: 0);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return NeuronAtomBuilder<T>(
      atom: widget.connect,
      builder: (ctx, value, _) {
        _currentWidget = widget.morphBuilder(ctx, value);

        if (_isFirstBuild) {
          _isFirstBuild = false;
          return _buildMorphableWidget(_currentWidget!);
        }

        return AnimatedBuilder(
          animation: CurvedAnimation(
            parent: _controller,
            curve: widget.config.curve,
          ),
          builder: (context, _) {
            if (_previousWidget == null || _controller.value >= 1.0) {
              return _buildMorphableWidget(_currentWidget!);
            }

            return _buildMorphTransition(
              _previousWidget!,
              _currentWidget!,
              _controller.value,
            );
          },
        );
      },
    );
  }

  Widget _buildMorphableWidget(MorphableWidget morphable) {
    Widget child = morphable.child;

    if (morphable.decoration != null) {
      child = Container(
        decoration: morphable.decoration,
        child: child,
      );
    }

    if (morphable.size != null) {
      child = SizedBox(
        width: morphable.size!.width.isFinite ? morphable.size!.width : null,
        height: morphable.size!.height.isFinite ? morphable.size!.height : null,
        child: child,
      );
    }

    if (morphable.padding != null) {
      child = Padding(padding: morphable.padding!, child: child);
    }

    return child;
  }

  Widget _buildMorphTransition(
    MorphableWidget from,
    MorphableWidget to,
    double t,
  ) {
    // Interpolate size
    Size? size;
    if (widget.config.morphSize && from.size != null && to.size != null) {
      size = Size.lerp(from.size, to.size, t);
    } else {
      size = to.size;
    }

    // Interpolate decoration
    BoxDecoration? decoration;
    if (widget.config.morphDecoration &&
        from.decoration != null &&
        to.decoration != null) {
      decoration = BoxDecoration.lerp(from.decoration, to.decoration, t);
    } else {
      decoration = to.decoration;
    }

    // Interpolate padding
    EdgeInsets? padding;
    if (from.padding != null && to.padding != null) {
      padding = EdgeInsets.lerp(from.padding, to.padding, t);
    } else {
      padding = to.padding;
    }

    // Build the transitioning widget with cross-fade effect
    // Using a Stack to layer the outgoing and incoming widgets
    Widget child = Stack(
      alignment: widget.config.alignment,
      children: [
        Opacity(
          opacity: (1 - t).clamp(0.0, 1.0),
          child: Transform.scale(
            scale: 1 - (t * 0.1),
            child: from.child,
          ),
        ),
        Opacity(
          opacity: t.clamp(0.0, 1.0),
          child: Transform.scale(
            scale: 0.9 + (t * 0.1),
            child: to.child,
          ),
        ),
      ],
    );

    if (decoration != null) {
      child = Container(
        decoration: decoration,
        child: child,
      );
    }

    if (size != null) {
      child = SizedBox(
        width: size.width.isFinite ? size.width : null,
        height: size.height.isFinite ? size.height : null,
        child: child,
      );
    }

    if (padding != null) {
      child = Padding(padding: padding, child: child);
    }

    if (widget.config.clipDuringMorph) {
      child = ClipRect(child: child);
    }

    return child;
  }
}

/// MorphableWidget - Configuration for a morphable state.
///
/// Defines the visual properties that can be morphed between states.
class MorphableWidget {
  /// The child widget to display
  final Widget child;

  /// Optional decoration (background, border, shadow)
  final BoxDecoration? decoration;

  /// Optional size
  final Size? size;

  /// Optional padding
  final EdgeInsets? padding;

  const MorphableWidget({
    required this.child,
    this.decoration,
    this.size,
    this.padding,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MorphableWidget &&
        other.child.runtimeType == child.runtimeType &&
        other.decoration == decoration &&
        other.size == size &&
        other.padding == padding;
  }

  @override
  int get hashCode => Object.hash(child.runtimeType, decoration, size, padding);
}

/// IconMorphSlot - Specialized morph for icon transitions.
///
/// Smoothly morphs between different icons with rotation and scale effects.
///
/// Example:
/// ```dart
/// IconMorphSlot<bool>(
///   connect: controller.isPlaying,
///   iconBuilder: (value) => value ? Icons.pause : Icons.play_arrow,
///   size: 48,
///   color: Colors.white,
///   morphStyle: IconMorphStyle.rotateScale,
/// )
/// ```
class IconMorphSlot<T> extends StatelessWidget {
  final Signal<T> connect;
  final IconData Function(T value) iconBuilder;
  final double size;
  final Color? color;
  final IconMorphStyle morphStyle;
  final Duration duration;
  final Curve curve;

  const IconMorphSlot({
    super.key,
    required this.connect,
    required this.iconBuilder,
    this.size = 24,
    this.color,
    this.morphStyle = IconMorphStyle.crossFade,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
  });

  @override
  Widget build(BuildContext context) {
    return NeuronAtomBuilder<T>(
      atom: connect,
      builder: (ctx, value, _) {
        final icon = iconBuilder(value);

        return AnimatedSwitcher(
          duration: duration,
          switchInCurve: curve,
          switchOutCurve: curve,
          transitionBuilder: (child, animation) {
            return _buildTransition(child, animation);
          },
          child: Icon(
            icon,
            key: ValueKey(icon),
            size: size,
            color: color,
          ),
        );
      },
    );
  }

  Widget _buildTransition(Widget child, Animation<double> animation) {
    switch (morphStyle) {
      case IconMorphStyle.crossFade:
        return FadeTransition(opacity: animation, child: child);

      case IconMorphStyle.rotateScale:
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: animation,
            child: RotationTransition(
              turns: Tween(begin: 0.5, end: 1.0).animate(animation),
              child: child,
            ),
          ),
        );

      case IconMorphStyle.flipHorizontal:
        return AnimatedBuilder(
          animation: animation,
          builder: (context, child) => Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY((1 - animation.value) * 3.14159 / 2),
            child: child,
          ),
          child: child,
        );

      case IconMorphStyle.flipVertical:
        return AnimatedBuilder(
          animation: animation,
          builder: (context, child) => Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateX((1 - animation.value) * 3.14159 / 2),
            child: child,
          ),
          child: child,
        );

      case IconMorphStyle.scale:
        return ScaleTransition(scale: animation, child: child);

      case IconMorphStyle.slideUp:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.5),
            end: Offset.zero,
          ).animate(animation),
          child: FadeTransition(opacity: animation, child: child),
        );
    }
  }
}

/// Style options for icon morphing.
enum IconMorphStyle {
  /// Simple cross-fade between icons
  crossFade,

  /// Rotate and scale
  rotateScale,

  /// 3D flip on horizontal axis
  flipHorizontal,

  /// 3D flip on vertical axis
  flipVertical,

  /// Scale in/out
  scale,

  /// Slide up with fade
  slideUp,
}

/// ShapeMorphSlot - Morph between different shapes.
///
/// Animates between geometric shapes like circles, rectangles, and rounded rects.
///
/// Example:
/// ```dart
/// ShapeMorphSlot<bool>(
///   connect: controller.isExpanded,
///   shapeBuilder: (expanded) => expanded
///       ? ShapeConfig.roundedRect(borderRadius: 16)
///       : ShapeConfig.circle(),
///   size: (expanded) => expanded ? Size(200, 300) : Size(60, 60),
///   color: (expanded) => expanded ? Colors.blue : Colors.green,
///   child: (expanded) => expanded
///       ? ExpandedContent()
///       : Icon(Icons.add),
/// )
/// ```
class ShapeMorphSlot<T> extends StatelessWidget {
  final Signal<T> connect;
  final ShapeConfig Function(T value) shapeBuilder;
  final Size Function(T value) sizeBuilder;
  final Color Function(T value)? colorBuilder;
  final Widget Function(T value) childBuilder;
  final Duration duration;
  final Curve curve;
  final List<BoxShadow> Function(T value)? shadowBuilder;

  const ShapeMorphSlot({
    super.key,
    required this.connect,
    required this.shapeBuilder,
    required this.sizeBuilder,
    required this.childBuilder,
    this.colorBuilder,
    this.shadowBuilder,
    this.duration = const Duration(milliseconds: 400),
    this.curve = Curves.easeInOutCubic,
  });

  @override
  Widget build(BuildContext context) {
    return NeuronAtomBuilder<T>(
      atom: connect,
      builder: (ctx, value, _) {
        final shape = shapeBuilder(value);
        final size = sizeBuilder(value);
        final color = colorBuilder?.call(value);
        final shadows = shadowBuilder?.call(value);

        return AnimatedContainer(
          duration: duration,
          curve: curve,
          width: size.width,
          height: size.height,
          decoration: BoxDecoration(
            color: color,
            shape: shape.isCircle ? BoxShape.circle : BoxShape.rectangle,
            borderRadius: shape.isCircle ? null : shape.borderRadius,
            boxShadow: shadows,
          ),
          child: ClipPath(
            clipper: _ShapeClipper(shape),
            child: AnimatedSwitcher(
              duration: duration,
              child: KeyedSubtree(
                key: ValueKey(value),
                child: Center(child: childBuilder(value)),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Configuration for shape morphing.
class ShapeConfig {
  final bool isCircle;
  final BorderRadius? borderRadius;

  const ShapeConfig._({
    required this.isCircle,
    this.borderRadius,
  });

  /// Circle shape
  factory ShapeConfig.circle() => const ShapeConfig._(isCircle: true);

  /// Rectangle with no border radius
  factory ShapeConfig.rectangle() => const ShapeConfig._(
        isCircle: false,
        borderRadius: BorderRadius.zero,
      );

  /// Rounded rectangle
  factory ShapeConfig.roundedRect({double borderRadius = 8}) => ShapeConfig._(
        isCircle: false,
        borderRadius: BorderRadius.circular(borderRadius),
      );

  /// Custom border radius
  factory ShapeConfig.custom(BorderRadius borderRadius) => ShapeConfig._(
        isCircle: false,
        borderRadius: borderRadius,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ShapeConfig &&
        other.isCircle == isCircle &&
        other.borderRadius == borderRadius;
  }

  @override
  int get hashCode => Object.hash(isCircle, borderRadius);
}

/// Custom clipper for shape morphing.
class _ShapeClipper extends CustomClipper<Path> {
  final ShapeConfig shape;

  _ShapeClipper(this.shape);

  @override
  Path getClip(Size size) {
    final path = Path();

    if (shape.isCircle) {
      final center = Offset(size.width / 2, size.height / 2);
      final radius =
          size.width < size.height ? size.width / 2 : size.height / 2;
      path.addOval(Rect.fromCircle(center: center, radius: radius));
    } else if (shape.borderRadius != null) {
      path.addRRect(RRect.fromRectAndCorners(
        Rect.fromLTWH(0, 0, size.width, size.height),
        topLeft: shape.borderRadius!.topLeft,
        topRight: shape.borderRadius!.topRight,
        bottomLeft: shape.borderRadius!.bottomLeft,
        bottomRight: shape.borderRadius!.bottomRight,
      ));
    } else {
      path.addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    }

    return path;
  }

  @override
  bool shouldReclip(covariant _ShapeClipper oldClipper) {
    return shape != oldClipper.shape;
  }
}

/// ============================================================================
/// SIGNAL EXTENSIONS FOR FORM AND MORPH SLOTS
/// ============================================================================

/// Extensions for form-related signals.
extension FormSignalExtensions<T> on Signal<T> {
  /// Create a FormSlot for this signal.
  Widget form({
    required Widget Function(
      BuildContext context,
      T value,
      FormValidationResult validation,
      bool isFocused,
    ) to,
    String? Function(T value)? validator,
    FormAnimationEffect errorEffect = FormAnimationEffect.shake,
    FormAnimationEffect successEffect = FormAnimationEffect.pulse,
    Duration animationDuration = const Duration(milliseconds: 300),
  }) {
    return AnimatedFormSlot<T>(
      connect: this,
      to: to,
      validator: validator,
      errorEffect: errorEffect,
      successEffect: successEffect,
      animationDuration: animationDuration,
    );
  }
}

/// Extensions for morph-related signals.
extension MorphSignalExtensions<T> on Signal<T> {
  /// Create a MorphSlot for this signal.
  Widget morph({
    required MorphableWidget Function(BuildContext context, T value)
        morphBuilder,
    MorphConfig config = const MorphConfig(),
    VoidCallback? onMorphStart,
    VoidCallback? onMorphComplete,
  }) {
    return MorphSlot<T>(
      connect: this,
      morphBuilder: morphBuilder,
      config: config,
      onMorphStart: onMorphStart,
      onMorphComplete: onMorphComplete,
    );
  }

  /// Create an IconMorphSlot for this signal.
  Widget morphIcon({
    required IconData Function(T value) iconBuilder,
    double size = 24,
    Color? color,
    IconMorphStyle style = IconMorphStyle.crossFade,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return IconMorphSlot<T>(
      connect: this,
      iconBuilder: iconBuilder,
      size: size,
      color: color,
      morphStyle: style,
      duration: duration,
    );
  }
}

/// Extensions for boolean signals with common morph patterns.
extension BooleanMorphExtensions on Signal<bool> {
  /// Create a play/pause icon morph.
  Widget playPauseMorph({
    double size = 24,
    Color? color,
    IconMorphStyle style = IconMorphStyle.rotateScale,
  }) {
    return IconMorphSlot<bool>(
      connect: this,
      iconBuilder: (playing) => playing ? Icons.pause : Icons.play_arrow,
      size: size,
      color: color,
      morphStyle: style,
    );
  }

  /// Create an expand/collapse icon morph.
  Widget expandCollapseMorph({
    double size = 24,
    Color? color,
    IconMorphStyle style = IconMorphStyle.rotateScale,
  }) {
    return IconMorphSlot<bool>(
      connect: this,
      iconBuilder: (expanded) =>
          expanded ? Icons.expand_less : Icons.expand_more,
      size: size,
      color: color,
      morphStyle: style,
    );
  }

  /// Create a menu/close icon morph (hamburger menu).
  Widget menuCloseMorph({
    double size = 24,
    Color? color,
    IconMorphStyle style = IconMorphStyle.rotateScale,
  }) {
    return IconMorphSlot<bool>(
      connect: this,
      iconBuilder: (open) => open ? Icons.close : Icons.menu,
      size: size,
      color: color,
      morphStyle: style,
    );
  }

  /// Create a visibility toggle icon morph.
  Widget visibilityMorph({
    double size = 24,
    Color? color,
    IconMorphStyle style = IconMorphStyle.crossFade,
  }) {
    return IconMorphSlot<bool>(
      connect: this,
      iconBuilder: (visible) =>
          visible ? Icons.visibility : Icons.visibility_off,
      size: size,
      color: color,
      morphStyle: style,
    );
  }

  /// Create a favorite toggle icon morph.
  Widget favoriteMorph({
    double size = 24,
    Color? activeColor,
    Color? inactiveColor,
    IconMorphStyle style = IconMorphStyle.scale,
  }) {
    return NeuronAtomBuilder<bool>(
      atom: this,
      builder: (ctx, isFavorite, _) {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) {
            return ScaleTransition(
              scale: animation,
              child: child,
            );
          },
          child: Icon(
            isFavorite ? Icons.favorite : Icons.favorite_border,
            key: ValueKey(isFavorite),
            size: size,
            color: isFavorite ? (activeColor ?? Colors.red) : inactiveColor,
          ),
        );
      },
    );
  }
}
