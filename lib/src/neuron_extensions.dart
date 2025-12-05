// neuron_extensions.dart
//
// Extended signal types and advanced features for Neuron v1
//
// Includes:
// - ListSignal, MapSignal, SetSignal (collection signals)
// - Debounced, throttled, distinct signals
// - Middleware and interceptors
// - Persistence adapters
// - Effects, reactions, and transactions
// - DevTools integration
// - Utilities
//
// Slots are separated into:
// - slots/neuron_slots_base.dart - Base reactive value slots
// - neuron_slots.dart - UI animation slots

import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:ui' show ImageFilter;
import 'dart:io' show ProcessInfo;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show Icons, Colors;
import 'package:flutter/physics.dart';
import 'package:flutter/widgets.dart';
import 'neuron_core.dart';
import 'debug/index.dart';

part 'neuron_collections.dart';
part 'neuron_rate_limiting.dart';
part 'neuron_middleware.dart';
part 'neuron_persistence.dart';
part 'neuron_effects.dart';
part 'neuron_devtools.dart';
part 'neuron_performance_monitor.dart';
part 'neuron_utilities.dart';
part 'neuron_advanced.dart';
part 'neuron_slots.dart';

// Wire performance metrics provider for debug snapshots
void _initNeuronDebug() {
  NeuronDebugRegistry.instance.metricsProvider =
      NeuronPerformanceMonitor.instance.toMetricsJson;
}

// Ensure provider is set at import time
// ignore: unused_element
final _debugInit = _initNeuronDebug();
