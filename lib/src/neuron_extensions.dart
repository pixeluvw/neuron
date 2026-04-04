// neuron_extensions.dart
//
// ═══════════════════════════════════════════════════════════════════════════════
// NEURON EXTENSIONS - Advanced Features & Utilities
// ═══════════════════════════════════════════════════════════════════════════════
//
// This file serves as the hub for Neuron's extended functionality,
// importing and re-exporting all advanced features via `part` directives.
//
// ┌─────────────────────────────────────────────────────────────────────────────┐
// │ INCLUDED MODULES (via `part`)                                             │
// ├──────────────────────────┬──────────────────────────────────────────────────┤
// │ neuron_collections.dart    │ ListSignal, MapSignal, SetSignal             │
// │ neuron_rate_limiting.dart  │ DebouncedSignal, ThrottledSignal, Distinct   │
// │ neuron_middleware.dart     │ Signal interceptors and transformers         │
// │ neuron_persistence.dart    │ SharedPreferences & Hive adapters            │
// │ neuron_effects.dart        │ Reactions, when(), autorun()                 │
// │ neuron_utilities.dart      │ Helper functions and common patterns         │
// │ neuron_advanced.dart       │ UndoableSignal, FormSignal, ComputedAsync    │
// │ neuron_slot_effects.dart   │ SlotEffect, DirectionalEffect, SpringConfig │
// │ neuron_animated_slots.dart │ AnimatedSlot, SpringSlot, MorphSlot, etc.    │
// │ neuron_multi_slot.dart     │ MultiSlot with type-safe t2..t6 constructors │
// └──────────────────────────┴──────────────────────────────────────────────────┘
//
// USAGE:
// All exports are available through the main `neuron.dart` barrel file.
// Users don't need to import this file directly.
//
// See also:
// - neuron.dart : Main library export
// - neuron_core.dart : Core framework classes
// - neuron_signals.dart : Signal, AsyncSignal, Computed
//
// ═══════════════════════════════════════════════════════════════════════════════

import 'dart:async';
import 'dart:convert';
import 'platform/isolate_imports_stub.dart'
    if (dart.library.io) 'platform/isolate_imports_io.dart';
import 'dart:math';
import 'dart:ui' show ImageFilter;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show Icons, Colors;
import 'package:flutter/physics.dart';
import 'package:flutter/widgets.dart';

import 'neuron_core.dart';

part 'neuron_collections.dart';
part 'neuron_rate_limiting.dart';
part 'neuron_middleware.dart';
part 'neuron_persistence.dart';
part 'neuron_effects.dart';

part 'neuron_utilities.dart';
part 'neuron_advanced.dart';
part 'neuron_slot_effects.dart';
part 'neuron_animated_slots.dart';
part 'neuron_multi_slot.dart';
part 'neuron_polling.dart';
part 'neuron_text_signal.dart';
