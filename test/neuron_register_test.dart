import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neuron/neuron.dart';

class _TestController extends NeuronController {
  final List<String> log = [];

  void registerTimer() {
    register(Timer(const Duration(seconds: 999), () {}));
    log.add('timer');
  }

  void registerStream(StreamSubscription sub) {
    register(sub);
    log.add('stream');
  }

  void registerTextController(TextEditingController ctrl) {
    register(ctrl);
    log.add('text');
  }

  void registerCallback(VoidCallback fn) {
    register(fn);
    log.add('callback');
  }
}

void main() {
  tearDown(() => Neuron.clearAll());

  group('register() auto-cleanup', () {
    test('register returns the resource', () {
      final ctrl = _TestController();
      Neuron.install(ctrl);

      final timer = ctrl.register(Timer(const Duration(seconds: 999), () {}));
      expect(timer, isA<Timer>());
    });

    test('Timer is cancelled on dispose', () {
      final ctrl = _TestController();
      Neuron.install(ctrl);

      var timerFired = false;
      ctrl.register(Timer(const Duration(milliseconds: 50), () {
        timerFired = true;
      }));

      Neuron.uninstall<_TestController>();
      // Timer was cancelled so it should not fire
      expect(timerFired, false);
    });

    test('StreamSubscription is cancelled on dispose', () async {
      final ctrl = _TestController();
      Neuron.install(ctrl);

      final streamCtrl = StreamController<int>();
      var received = <int>[];

      ctrl.register(streamCtrl.stream.listen((v) => received.add(v)));

      streamCtrl.add(1);
      await Future.delayed(Duration.zero);
      expect(received, [1]);

      Neuron.uninstall<_TestController>();

      streamCtrl.add(2);
      await Future.delayed(Duration.zero);
      expect(received, [1]); // No new events after dispose

      await streamCtrl.close();
    });

    test('ChangeNotifier (TextEditingController) is disposed', () {
      final ctrl = _TestController();
      Neuron.install(ctrl);

      final textCtrl = TextEditingController(text: 'hello');
      ctrl.register(textCtrl);

      Neuron.uninstall<_TestController>();

      // After dispose, adding a listener should throw
      expect(() => textCtrl.addListener(() {}), throwsA(isA<FlutterError>()));
    });

    test('VoidCallback is called on dispose', () {
      final ctrl = _TestController();
      Neuron.install(ctrl);

      var cleaned = false;
      ctrl.register(() => cleaned = true);

      expect(cleaned, false);
      Neuron.uninstall<_TestController>();
      expect(cleaned, true);
    });

    test('resources are disposed in reverse order (LIFO)', () {
      final ctrl = _TestController();
      Neuron.install(ctrl);

      final order = <int>[];
      ctrl.register(() => order.add(1));
      ctrl.register(() => order.add(2));
      ctrl.register(() => order.add(3));

      Neuron.uninstall<_TestController>();
      expect(order, [3, 2, 1]);
    });

    test('throws ArgumentError for unsupported types', () {
      final ctrl = _TestController();
      Neuron.install(ctrl);

      expect(() => ctrl.register(42), throwsArgumentError);
      expect(() => ctrl.register('string'), throwsArgumentError);
    });

    test('Disposable resources are added directly', () {
      final ctrl = _TestController();
      Neuron.install(ctrl);

      final signal = Signal<int>(0);
      ctrl.register(signal);

      // After dispose, emitting should fail (assert in debug mode)
      Neuron.uninstall<_TestController>();
      expect(() => signal.emit(1), throwsA(isA<AssertionError>()));
    });

    test('mixed resource types all clean up', () {
      final ctrl = _TestController();
      Neuron.install(ctrl);

      final log = <String>[];
      ctrl.register(Timer(const Duration(seconds: 999), () {}));
      ctrl.register(() => log.add('callback'));
      ctrl.register(TextEditingController());

      // Should not throw
      Neuron.uninstall<_TestController>();
      expect(log, ['callback']);
    });
  });
}
