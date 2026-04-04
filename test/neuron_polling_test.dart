import 'package:flutter_test/flutter_test.dart';
import 'package:neuron/neuron.dart';

class _PollController extends NeuronController {
  late final items = pollingSignal<List<String>>(
    interval: const Duration(seconds: 30),
    operation: () async => ['a', 'b', 'c'],
    autoStart: false,
  );
}

void main() {
  tearDown(() => Neuron.clearAll());

  group('PollingSignal', () {
    test('starts in loading state when no initial value', () {
      final signal = PollingSignal<int>(
        interval: const Duration(seconds: 10),
        operation: () async => 42,
        autoStart: false,
      );
      expect(signal.isLoading, true);
      signal.dispose();
    });

    test('starts in data state when initial value provided', () {
      final signal = PollingSignal<int>(
        interval: const Duration(seconds: 10),
        operation: () async => 42,
        initial: 0,
        autoStart: false,
      );
      expect(signal.hasData, true);
      expect(signal.data, 0);
      signal.dispose();
    });

    test('autoStart executes immediately', () async {
      final signal = PollingSignal<int>(
        interval: const Duration(seconds: 10),
        operation: () async => 42,
        autoStart: true,
      );

      // Wait for async execute to complete
      await Future.delayed(Duration.zero);

      expect(signal.hasData, true);
      expect(signal.data, 42);
      signal.dispose();
    });

    test('start triggers immediate fetch', () async {
      final signal = PollingSignal<int>(
        interval: const Duration(seconds: 10),
        operation: () async => 99,
        autoStart: false,
      );

      signal.start();
      await Future.delayed(Duration.zero);

      expect(signal.data, 99);
      signal.dispose();
    });

    test('start is no-op if already started', () async {
      var callCount = 0;
      final signal = PollingSignal<int>(
        interval: const Duration(seconds: 10),
        operation: () async {
          callCount++;
          return callCount;
        },
        autoStart: false,
      );

      signal.start();
      await Future.delayed(Duration.zero);
      expect(callCount, 1);

      signal.start(); // Should be no-op
      await Future.delayed(Duration.zero);
      expect(callCount, 1);

      signal.dispose();
    });

    test('stop cancels the timer', () {
      final signal = PollingSignal<int>(
        interval: const Duration(seconds: 10),
        operation: () async => 1,
        autoStart: true,
      );

      expect(signal.isPolling, true);
      signal.stop();
      expect(signal.isPolling, false);
      signal.dispose();
    });

    test('pause and resume', () async {
      final signal = PollingSignal<int>(
        interval: const Duration(seconds: 10),
        operation: () async => 1,
        autoStart: true,
      );

      await Future.delayed(Duration.zero);

      signal.pause();
      expect(signal.isPaused, true);
      expect(signal.isPolling, false);

      signal.resume();
      expect(signal.isPaused, false);
      expect(signal.isPolling, true);

      signal.dispose();
    });

    test('setInterval updates interval', () {
      final signal = PollingSignal<int>(
        interval: const Duration(seconds: 10),
        operation: () async => 1,
        autoStart: false,
      );

      expect(signal.interval, const Duration(seconds: 10));
      signal.setInterval(const Duration(seconds: 5));
      expect(signal.interval, const Duration(seconds: 5));

      signal.dispose();
    });

    test('setInterval restarts timer if running', () async {
      final signal = PollingSignal<int>(
        interval: const Duration(seconds: 10),
        operation: () async => 1,
        autoStart: true,
      );

      await Future.delayed(Duration.zero);
      expect(signal.isPolling, true);

      signal.setInterval(const Duration(seconds: 5));
      expect(signal.isPolling, true);
      expect(signal.interval, const Duration(seconds: 5));

      signal.dispose();
    });

    test('dispose cancels timer', () async {
      final signal = PollingSignal<int>(
        interval: const Duration(seconds: 10),
        operation: () async => 1,
        autoStart: true,
      );

      await Future.delayed(Duration.zero);
      signal.dispose();
      expect(signal.isPolling, false);
    });

    test('handles operation errors gracefully', () async {
      final signal = PollingSignal<int>(
        interval: const Duration(seconds: 10),
        operation: () async => throw Exception('fail'),
        autoStart: true,
      );

      await Future.delayed(Duration.zero);

      expect(signal.hasError, true);
      expect(signal.error, isA<Exception>());
      signal.dispose();
    });

    test('works with controller binding and auto-dispose', () async {
      final ctrl = _PollController();
      Neuron.install(ctrl);

      ctrl.items.start();
      await Future.delayed(Duration.zero);

      expect(ctrl.items.hasData, true);
      expect(ctrl.items.data, ['a', 'b', 'c']);

      // Uninstalling should dispose the signal (and cancel the timer)
      Neuron.uninstall<_PollController>();
    });

    test('refresh re-executes the operation', () async {
      var count = 0;
      final signal = PollingSignal<int>(
        interval: const Duration(seconds: 10),
        operation: () async => ++count,
        autoStart: true,
      );

      await Future.delayed(Duration.zero);
      expect(signal.data, 1);

      await signal.refresh();
      expect(signal.data, 2);

      signal.dispose();
    });
  });
}
