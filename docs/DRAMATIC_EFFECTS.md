# Dramatic Effects Implementation

This document describes the six dramatic effects implemented in the `AnimatedSlot` widget.

## Overview

All dramatic effects are defined in `lib/src/neuron_slots.dart` in the `_buildEffectTransition` method of the `_AnimatedSlotState` class.

## Effects

### 1. Wobble Effect (`SlotEffect.wobble`)
- **Type**: Rotation-based animation
- **Implementation**: Uses `RotationTransition` 
- **Rotation**: 0.03 turns (approximately 11 degrees)
- **Curve**: `Curves.elasticOut`
- **Use Case**: Subtle attention-grabbing rotation, ideal for notifications or alerts

```dart
AnimatedSlot<int>(
  connect: counter,
  effect: SlotEffect.wobble,
  to: (context, value) => Text('$value'),
)
```

### 2. Swing Effect (`SlotEffect.swing`)
- **Type**: Rotation-based animation from top-center
- **Implementation**: Uses `AnimatedBuilder` with `Transform` and `rotateZ`
- **Rotation**: 0.1 radians (approximately 5.7 degrees)
- **Alignment**: `Alignment.topCenter`
- **Curve**: `Curves.elasticOut`
- **Use Case**: Pendulum-like motion, great for hanging elements or dropdown indicators

```dart
AnimatedSlot<int>(
  connect: counter,
  effect: SlotEffect.swing,
  to: (context, value) => Text('$value'),
)
```

### 3. Shake Effect (`SlotEffect.shake`)
- **Type**: Horizontal slide animation
- **Implementation**: Uses `SlideTransition`
- **Offset**: 0.05 (5% of widget width)
- **Curve**: `Curves.elasticOut`
- **Use Case**: Error indication or attention-grabbing horizontal shake

```dart
AnimatedSlot<int>(
  connect: counter,
  effect: SlotEffect.shake,
  to: (context, value) => Text('$value'),
)
```

### 4. Bounce Effect (`SlotEffect.bounce`)
- **Type**: Scale-based animation
- **Implementation**: Uses `ScaleTransition`
- **Scale Range**: From `widget.scaleBegin` to `widget.scaleEnd` (default: 0.8 to 1.0)
- **Curve**: `Curves.bounceOut`
- **Use Case**: Playful pop-in effect with bounce, ideal for counters or success messages

```dart
AnimatedSlot<int>(
  connect: counter,
  effect: SlotEffect.bounce,
  scaleBegin: 0.5,
  scaleEnd: 1.0,
  to: (context, value) => Text('$value'),
)
```

### 5. Elastic Effect (`SlotEffect.elastic`)
- **Type**: Scale-based animation
- **Implementation**: Uses `ScaleTransition`
- **Scale Range**: From `widget.scaleBegin` to `widget.scaleEnd` (default: 0.8 to 1.0)
- **Curve**: `Curves.elasticOut`
- **Use Case**: Spring-like scale animation with overshoot, great for interactive elements

```dart
AnimatedSlot<int>(
  connect: counter,
  effect: SlotEffect.elastic,
  scaleBegin: 0.3,
  scaleEnd: 1.0,
  to: (context, value) => Text('$value'),
)
```

### 6. Pulse Effect (`SlotEffect.pulse`)
- **Type**: Scale-based animation with fixed range
- **Implementation**: Uses `ScaleTransition`
- **Scale Range**: Fixed from 0.85 to 1.0
- **Curve**: `Curves.elasticOut`
- **Use Case**: Subtle breathing effect, perfect for live indicators or notifications

```dart
AnimatedSlot<int>(
  connect: counter,
  effect: SlotEffect.pulse,
  to: (context, value) => Text('$value'),
)
```

## Combining Effects

All dramatic effects can be combined with other effects using the `|` operator:

```dart
// Bounce with fade
AnimatedSlot<int>(
  connect: counter,
  effect: SlotEffect.bounce | SlotEffect.fade,
  to: (context, value) => Text('$value'),
)

// Shake with blur
AnimatedSlot<int>(
  connect: counter,
  effect: SlotEffect.shake | SlotEffect.blur,
  blurSigma: 5.0,
  to: (context, value) => Text('$value'),
)

// Wobble with rotation
AnimatedSlot<int>(
  connect: counter,
  effect: SlotEffect.wobble | SlotEffect.rotation,
  rotationTurns: 0.25,
  to: (context, value) => Text('$value'),
)
```

## Implementation Details

### Code Structure

All effects follow this pattern in `_buildEffectTransition`:

1. Check if the effect is present using `effect.has(SlotEffect.effectName)`
2. Create a `CurvedAnimation` with the appropriate curve
3. Wrap the current `result` widget with the appropriate transition widget
4. Return the wrapped widget

### Positioning in the Method

Effects are applied in this order:
1. Blur
2. Rotation
3. Flip
4. **Wobble** (new)
5. **Swing** (new)
6. **Shake** (new)
7. Slide effects (Up, Down, Left, Right)
8. Scale
9. **Bounce** (new)
10. **Elastic** (new)
11. **Pulse** (new)
12. Fade (applied last for proper layering)

This order ensures that effects compose correctly when combined.

## Testing

Comprehensive tests are provided in `test/neuron_dramatic_effects_test.dart`:
- Individual effect tests
- Effect combination tests
- Animation lifecycle tests

## Example

A complete example demonstrating all six effects is available in `example/lib/dramatic_effects_demo.dart`.

Run the example with:
```bash
flutter run example/lib/dramatic_effects_demo.dart
```
