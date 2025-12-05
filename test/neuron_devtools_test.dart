import 'package:flutter_test/flutter_test.dart';
import 'package:neuron/neuron.dart';

void main() {
  group('SignalDevTools', () {
    late SignalDevTools devTools;

    setUp(() {
      devTools = SignalDevTools();
      devTools.setEnabled(true);
      devTools.clearEvents();
      devTools.clearHistory();
    });

    test('should register signal', () {
      final signal = Signal<int>(0);
      devTools.register('count', signal);

      expect(devTools.signals.containsKey('count'), true);
      expect(devTools.getHistory('count'), [0]);
    });

    test('should track signal changes', () {
      final signal = Signal<int>(0);
      devTools.register('count', signal);

      signal.emit(1);
      signal.emit(2);
      signal.emit(3);

      final history = devTools.getHistory('count');
      expect(history, contains(0));
      expect(history, contains(1));
      expect(history, contains(2));
    });

    test('should record events', () {
      final signal = Signal<int>(0);
      devTools.register('count', signal);

      signal.emit(1);

      final events = devTools.events;
      expect(events.length, greaterThan(0));
      expect(events.any((e) => e.type == SignalEventType.registered), true);
      expect(events.any((e) => e.type == SignalEventType.valueChanged), true);
    });

    test('should filter events by type', () {
      final signal = Signal<int>(0);
      devTools.register('count', signal);
      signal.emit(1);

      final registeredEvents =
          devTools.getEventsByType(SignalEventType.registered);
      final changedEvents =
          devTools.getEventsByType(SignalEventType.valueChanged);

      expect(registeredEvents.length, greaterThan(0));
      expect(changedEvents.length, greaterThan(0));
    });

    test('should filter events by signal', () {
      final count = Signal<int>(0);
      final name = Signal<String>('');

      devTools.register('count', count);
      devTools.register('name', name);

      count.emit(1);
      name.emit('test');

      final countEvents = devTools.getEventsForSignal('count');
      final nameEvents = devTools.getEventsForSignal('name');

      expect(countEvents.length, greaterThan(0));
      expect(nameEvents.length, greaterThan(0));
    });

    test('should create and restore snapshots', () {
      final count = Signal<int>(0);
      final name = Signal<String>('');

      devTools.register('count', count);
      devTools.register('name', name);

      count.emit(5);
      name.emit('hello');

      final snapshot = devTools.getSnapshot();

      expect(snapshot['count'], 5);
      expect(snapshot['name'], 'hello');

      count.emit(10);
      name.emit('world');

      expect(count.val, 10);
      expect(name.val, 'world');
    });

    test('should create and restore checkpoints', () {
      final count = Signal<int>(0);
      devTools.register('count', count);

      count.emit(5);
      final checkpoint = devTools.createCheckpoint();

      count.emit(10);
      expect(count.val, 10);

      devTools.restoreCheckpoint(checkpoint);
      expect(count.val, 5);
    });

    test('should compare snapshots', () {
      final snapshot1 = {'count': 5, 'name': 'hello'};
      final snapshot2 = {'count': 10, 'name': 'hello'};

      final diff = devTools.compareSnapshots(snapshot1, snapshot2);

      expect(diff['count'], {'before': 5, 'after': 10});
      expect(diff.containsKey('name'), false); // No change
    });

    test('should track statistics', () {
      final count = Signal<int>(0);
      devTools.register('count', count);

      count.emit(1);
      count.emit(2);

      final stats = devTools.getStatistics();

      expect(stats['totalSignals'], greaterThanOrEqualTo(1));
      expect(stats['totalEvents'], greaterThan(0));
    });

    test('should record custom events', () {
      devTools.recordCustomEvent('mySignal', 'custom', 'data',
          metadata: {'key': 'value'});

      final events = devTools.getEventsForSignal('mySignal');
      expect(events.length, 1);
      expect(events.first.metadata?['customType'], 'custom');
    });

    test('should export state to JSON', () {
      final count = Signal<int>(5);
      devTools.register('count', count);

      final json = devTools.exportState();

      expect(json, isA<String>());
      expect(json, contains('count'));
      expect(json, contains('5'));
    });

    test('should limit event history', () {
      devTools.setMaxEvents(10);

      final signal = Signal<int>(0);
      devTools.register('count', signal);

      // Emit many values
      for (int i = 0; i < 20; i++) {
        signal.emit(i);
      }

      // Should only keep last 10 events
      expect(devTools.events.length, lessThanOrEqualTo(10));
    });

    test('should unregister signal', () {
      final signal = Signal<int>(0);
      devTools.register('count', signal);

      expect(devTools.signals.containsKey('count'), true);

      devTools.unregister('count');

      expect(devTools.signals.containsKey('count'), false);
    });
  });
}
