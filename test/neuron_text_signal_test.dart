import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neuron/neuron.dart';

class _FormController extends NeuronController {
  late final name = textSignal(text: 'John');
  late final email = textSignal();
}

void main() {
  tearDown(() => Neuron.clearAll());

  group('TextSignal', () {
    test('initial value syncs to controller', () {
      final ts = TextSignal(text: 'hello');
      expect(ts.val, 'hello');
      expect(ts.controller.text, 'hello');
      expect(ts.text, 'hello');
      ts.dispose();
    });

    test('default initial value is empty string', () {
      final ts = TextSignal();
      expect(ts.val, '');
      expect(ts.controller.text, '');
      ts.dispose();
    });

    test('emit updates both signal and controller', () {
      final ts = TextSignal();
      ts.emit('world');
      expect(ts.val, 'world');
      expect(ts.controller.text, 'world');
      ts.dispose();
    });

    test('controller text change updates signal', () {
      final ts = TextSignal();
      var notified = false;
      ts.addListener(() => notified = true);

      ts.controller.text = 'typed';
      expect(ts.val, 'typed');
      expect(notified, true);
      ts.dispose();
    });

    test('no infinite loop on emit', () {
      final ts = TextSignal();
      var notifyCount = 0;
      ts.addListener(() => notifyCount++);

      ts.emit('test');
      expect(notifyCount, 1);
      expect(ts.val, 'test');
      expect(ts.controller.text, 'test');
      ts.dispose();
    });

    test('no infinite loop on controller change', () {
      final ts = TextSignal();
      var notifyCount = 0;
      ts.addListener(() => notifyCount++);

      ts.controller.text = 'test';
      expect(notifyCount, 1);
      expect(ts.val, 'test');
      ts.dispose();
    });

    test('text setter works', () {
      final ts = TextSignal();
      ts.text = 'abc';
      expect(ts.val, 'abc');
      expect(ts.controller.text, 'abc');
      ts.dispose();
    });

    test('clear resets to empty string', () {
      final ts = TextSignal(text: 'hello');
      ts.clear();
      expect(ts.val, '');
      expect(ts.controller.text, '');
      ts.dispose();
    });

    test('fromController wraps existing TextEditingController', () {
      final ctrl = TextEditingController(text: 'existing');
      final ts = TextSignal.fromController(ctrl);

      expect(ts.val, 'existing');
      expect(ts.controller, same(ctrl));

      ts.emit('new');
      expect(ctrl.text, 'new');

      ctrl.text = 'updated';
      expect(ts.val, 'updated');

      ts.dispose();
    });

    test('dispose cleans up controller', () {
      final ts = TextSignal(text: 'test');
      final ctrl = ts.controller;

      ts.dispose();

      // Controller should be disposed — adding a listener should throw
      expect(() => ctrl.addListener(() {}), throwsA(isA<FlutterError>()));
    });

    test('same value does not notify', () {
      final ts = TextSignal(text: 'same');
      var notifyCount = 0;
      ts.addListener(() => notifyCount++);

      ts.emit('same');
      expect(notifyCount, 0);
      ts.dispose();
    });

    test('works with controller binding and auto-dispose', () {
      final ctrl = _FormController();
      Neuron.install(ctrl);

      expect(ctrl.name.val, 'John');
      expect(ctrl.name.controller.text, 'John');
      expect(ctrl.email.val, '');

      ctrl.name.emit('Jane');
      expect(ctrl.name.controller.text, 'Jane');

      ctrl.email.controller.text = 'a@b.c';
      expect(ctrl.email.val, 'a@b.c');

      // Uninstalling should dispose both TextSignals and their controllers
      Neuron.uninstall<_FormController>();
    });

    test('multiple TextSignals are independent', () {
      final a = TextSignal(text: 'a');
      final b = TextSignal(text: 'b');

      a.emit('x');
      expect(a.val, 'x');
      expect(b.val, 'b');

      b.controller.text = 'y';
      expect(b.val, 'y');
      expect(a.val, 'x');

      a.dispose();
      b.dispose();
    });
  });
}
