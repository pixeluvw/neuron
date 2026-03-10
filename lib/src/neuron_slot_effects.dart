// neuron_slot_effects.dart
//
// ═══════════════════════════════════════════════════════════════════════════════
// SLOT EFFECTS & TRANSITIONS — Configuration classes
// ═══════════════════════════════════════════════════════════════════════════════
//
// Contains: SlotEffect, DirectionalEffect, SpringConfig
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
