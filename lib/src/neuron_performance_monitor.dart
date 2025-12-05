// neuron_performance_monitor.dart
part of 'neuron_extensions.dart';

/// Performance monitoring for DevTools.
///
/// Tracks FPS, memory usage, and signal update performance.
/// This is primarily used by the DevTools extension but can be accessed
/// programmatically for custom monitoring.
///
/// ## Basic Usage
///
/// ```dart
/// // Run benchmarks
/// await NeuronPerformanceMonitor.instance.runBenchmarks();
///
/// // Get results
/// print(NeuronPerformanceMonitor.instance.benchmarkResults);
/// ```
class NeuronPerformanceMonitor {
  static NeuronPerformanceMonitor? _instance;
  static NeuronPerformanceMonitor get instance {
    _instance ??= NeuronPerformanceMonitor._();
    return _instance!;
  }

  NeuronPerformanceMonitor._() {
    _startMonitoring();
  }

  // FPS tracking
  final List<double> _fpsHistory = [];
  double _currentFPS = 0;
  int _frameCount = 0;
  DateTime _lastFPSUpdate = DateTime.now();

  // Memory tracking
  final List<int> _memoryHistory = [];
  int _currentMemory = 0;

  // Performance metrics
  final Map<String, int> _signalUpdateCounts = {};
  final Map<String, Duration> _signalUpdateDurations = {};
  DateTime _sessionStart = DateTime.now();

  // Benchmark results
  final Map<String, dynamic> _benchmarkResults = {};
  Map<String, dynamic> get benchmarkResults =>
      Map.unmodifiable(_benchmarkResults);

  void _startMonitoring() {
    // Track FPS using SchedulerBinding
    WidgetsBinding.instance.addPostFrameCallback(_onFrame);

    // Update memory every second
    Timer.periodic(const Duration(seconds: 1), (_) => _updateMemory());
  }

  void _onFrame(Duration timestamp) {
    _frameCount++;

    final now = DateTime.now();
    final elapsed = now.difference(_lastFPSUpdate);

    if (elapsed.inMilliseconds >= 1000) {
      _currentFPS = (_frameCount / elapsed.inSeconds).clamp(0, 120);
      _fpsHistory.add(_currentFPS);

      // Keep only last 60 seconds of data
      if (_fpsHistory.length > 60) {
        _fpsHistory.removeAt(0);
      }

      _frameCount = 0;
      _lastFPSUpdate = now;
    }

    // Schedule next frame callback
    WidgetsBinding.instance.addPostFrameCallback(_onFrame);
  }

  void _updateMemory() {
    try {
      // Get current RSS (Resident Set Size) in bytes
      final info = ProcessInfo.currentRss;
      _currentMemory = info;
      _memoryHistory.add(info);

      // Keep only last 60 seconds of data
      if (_memoryHistory.length > 60) {
        _memoryHistory.removeAt(0);
      }
    } catch (e) {
      // ProcessInfo not available on all platforms
      _currentMemory = 0;
    }
  }

  /// Track signal update performance
  void trackSignalUpdate(String signalId, Duration duration) {
    _signalUpdateCounts[signalId] = (_signalUpdateCounts[signalId] ?? 0) + 1;

    final current = _signalUpdateDurations[signalId] ?? Duration.zero;
    _signalUpdateDurations[signalId] = current + duration;
  }

  /// Run benchmark tests
  Future<void> runBenchmarks() async {
    final results = <String, dynamic>{};

    // Benchmark 1: Signal creation speed
    final createStopwatch = Stopwatch()..start();
    for (int i = 0; i < 1000; i++) {
      final s = Signal<int>(i);
      s.val; // Access to ensure it's created
    }
    createStopwatch.stop();
    results['signalCreation'] = {
      'count': 1000,
      'totalMs': createStopwatch.elapsedMilliseconds,
      'avgMs': createStopwatch.elapsedMilliseconds / 1000,
    };

    // Benchmark 2: Signal update speed
    final updateStopwatch = Stopwatch()..start();
    final testSignal = Signal<int>(0);
    for (int i = 0; i < 10000; i++) {
      testSignal.emit(i);
    }
    updateStopwatch.stop();
    results['signalUpdates'] = {
      'count': 10000,
      'totalMs': updateStopwatch.elapsedMilliseconds,
      'avgMs': updateStopwatch.elapsedMilliseconds / 10000,
    };

    // Benchmark 3: Computed signal performance
    final computedStopwatch = Stopwatch()..start();
    final source = Signal<int>(0);
    final computed = Computed(() => source.val * 2, [source]);
    for (int i = 0; i < 5000; i++) {
      source.emit(i);
      computed.value; // Force recomputation
    }
    computedStopwatch.stop();
    results['computedSignals'] = {
      'count': 5000,
      'totalMs': computedStopwatch.elapsedMilliseconds,
      'avgMs': computedStopwatch.elapsedMilliseconds / 5000,
    };

    // Benchmark 4: Effect execution speed (skip if no Effect available)
    try {
      final effectStopwatch = Stopwatch()..start();
      final effectSource = Signal<int>(0);
      // Effects are in neuron_effects.dart - just benchmark signal changes
      for (int i = 0; i < 5000; i++) {
        effectSource.emit(i);
      }
      effectStopwatch.stop();
      results['effects'] = {
        'count': 5000,
        'totalMs': effectStopwatch.elapsedMilliseconds,
        'avgMs': effectStopwatch.elapsedMilliseconds / 5000,
      };
    } catch (e) {
      // Skip effect benchmark if not available
    }

    // Benchmark 5: Memory stress test
    final memoryBefore = ProcessInfo.currentRss;
    final signals = <Signal<int>>[];
    for (int i = 0; i < 10000; i++) {
      signals.add(Signal<int>(i));
    }
    await Future.delayed(const Duration(milliseconds: 100));
    final memoryAfter = ProcessInfo.currentRss;
    results['memoryStress'] = {
      'signalsCreated': 10000,
      'memoryUsedMB': (memoryAfter - memoryBefore) / (1024 * 1024),
      'avgPerSignalBytes': (memoryAfter - memoryBefore) / 10000,
    };

    _benchmarkResults.addAll(results);
  }

  Map<String, dynamic> toMetricsJson() {
    final fpsAvg = _fpsHistory.isEmpty
        ? 0.0
        : _fpsHistory.reduce((a, b) => a + b) / _fpsHistory.length;
    final memAvg = _memoryHistory.isEmpty
        ? 0.0
        : _memoryHistory.reduce((a, b) => a + b) / _memoryHistory.length;
    final uptime = DateTime.now().difference(_sessionStart);

    return {
      'fps': {
        'current': _currentFPS,
        'average': fpsAvg,
        'history': List<double>.from(_fpsHistory),
      },
      'memory': {
        'current': _currentMemory,
        'average': memAvg.toDouble(),
        'history': List<int>.from(_memoryHistory),
      },
      'signals': {
        'counts': Map<String, int>.from(_signalUpdateCounts),
        'durationsMs': _signalUpdateDurations.map(
          (k, v) => MapEntry(k, v.inMilliseconds),
        ),
      },
      'benchmarks': Map<String, dynamic>.from(_benchmarkResults),
      'session': {
        'uptimeSeconds': uptime.inSeconds,
      },
    };
  }

  /// Get performance snapshot
  Map<String, dynamic> getPerformanceSnapshot() {
    final uptime = DateTime.now().difference(_sessionStart);

    return {
      'fps': {
        'current': _currentFPS.toStringAsFixed(1),
        'average': _fpsHistory.isEmpty
            ? '0.0'
            : (_fpsHistory.reduce((a, b) => a + b) / _fpsHistory.length)
                .toStringAsFixed(1),
        'min': _fpsHistory.isEmpty
            ? '0.0'
            : _fpsHistory.reduce((a, b) => a < b ? a : b).toStringAsFixed(1),
        'max': _fpsHistory.isEmpty
            ? '0.0'
            : _fpsHistory.reduce((a, b) => a > b ? a : b).toStringAsFixed(1),
        'history': _fpsHistory.map((f) => f.toStringAsFixed(1)).toList(),
      },
      'memory': {
        'currentMB': (_currentMemory / (1024 * 1024)).toStringAsFixed(2),
        'averageMB': _memoryHistory.isEmpty
            ? '0.00'
            : (_memoryHistory.reduce((a, b) => a + b) /
                    _memoryHistory.length /
                    (1024 * 1024))
                .toStringAsFixed(2),
        'minMB': _memoryHistory.isEmpty
            ? '0.00'
            : (_memoryHistory.reduce((a, b) => a < b ? a : b) / (1024 * 1024))
                .toStringAsFixed(2),
        'maxMB': _memoryHistory.isEmpty
            ? '0.00'
            : (_memoryHistory.reduce((a, b) => a > b ? a : b) / (1024 * 1024))
                .toStringAsFixed(2),
        'history': _memoryHistory
            .map((m) => (m / (1024 * 1024)).toStringAsFixed(2))
            .toList(),
      },
      'signalUpdates': {
        'totalUpdates':
            _signalUpdateCounts.values.fold(0, (sum, count) => sum + count),
        'uniqueSignals': _signalUpdateCounts.length,
        'topSignals': _getTopSignals(),
      },
      'session': {
        'uptimeSeconds': uptime.inSeconds,
        'uptimeFormatted': _formatDuration(uptime),
      },
      'benchmarks': _benchmarkResults,
    };
  }

  List<Map<String, dynamic>> _getTopSignals() {
    final entries = _signalUpdateCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return entries.take(5).map((e) {
      final avgDuration = _signalUpdateDurations[e.key] ?? Duration.zero;
      final avgMs =
          e.value > 0 ? avgDuration.inMicroseconds / e.value / 1000 : 0;

      return {
        'id': e.key,
        'updates': e.value,
        'avgUpdateMs': avgMs.toStringAsFixed(3),
      };
    }).toList();
  }

  String _formatDuration(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60);
    final seconds = d.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  /// Clear all performance data
  void clearData() {
    _fpsHistory.clear();
    _memoryHistory.clear();
    _signalUpdateCounts.clear();
    _signalUpdateDurations.clear();
    _benchmarkResults.clear();
    _sessionStart = DateTime.now();
  }
}
