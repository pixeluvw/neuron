import 'package:flutter_test/flutter_test.dart';
import 'package:neuron/neuron.dart';

class _TaggedController extends NeuronController {
  final String id;
  bool initCalled = false;
  bool closeCalled = false;

  _TaggedController(this.id);

  @override
  void onInit() => initCalled = true;

  @override
  void onClose() => closeCalled = true;
}

class _OtherController extends NeuronController {}

void main() {
  tearDown(() => Neuron.clearAll());

  group('Tagged Instances', () {
    test('install and use with tag', () {
      final c1 = _TaggedController('room-1');
      final c2 = _TaggedController('room-2');

      Neuron.install(c1, tag: 'room-1');
      Neuron.install(c2, tag: 'room-2');

      expect(Neuron.use<_TaggedController>(tag: 'room-1'), same(c1));
      expect(Neuron.use<_TaggedController>(tag: 'room-2'), same(c2));
      expect(c1.initCalled, true);
      expect(c2.initCalled, true);
    });

    test('default (no tag) works as before', () {
      final c = _TaggedController('default');
      Neuron.install(c);
      expect(Neuron.use<_TaggedController>(), same(c));
    });

    test('tagged and untagged coexist', () {
      final def = _TaggedController('default');
      final tagged = _TaggedController('tagged');

      Neuron.install(def);
      Neuron.install(tagged, tag: 'special');

      expect(Neuron.use<_TaggedController>(), same(def));
      expect(Neuron.use<_TaggedController>(tag: 'special'), same(tagged));
    });

    test('ensure creates tagged instance lazily', () {
      final c = Neuron.ensure(() => _TaggedController('lazy'), tag: 'lazy');
      expect(c.id, 'lazy');

      final same_ =
          Neuron.ensure(() => _TaggedController('new'), tag: 'lazy');
      expect(same_, same(c));
    });

    test('ensure without tag still works as singleton', () {
      final c1 = Neuron.ensure(() => _TaggedController('a'));
      final c2 = Neuron.ensure(() => _TaggedController('b'));
      expect(c1, same(c2));
      expect(c1.id, 'a');
    });

    test('isInstalled checks tag', () {
      Neuron.install(_TaggedController('x'), tag: 'x');

      expect(Neuron.isInstalled<_TaggedController>(tag: 'x'), true);
      expect(Neuron.isInstalled<_TaggedController>(tag: 'y'), false);
      expect(Neuron.isInstalled<_TaggedController>(), false);
    });

    test('uninstall removes only specific tag', () {
      final c1 = _TaggedController('1');
      final c2 = _TaggedController('2');

      Neuron.install(c1, tag: 'a');
      Neuron.install(c2, tag: 'b');

      Neuron.uninstall<_TaggedController>(tag: 'a');

      expect(c1.closeCalled, true);
      expect(Neuron.isInstalled<_TaggedController>(tag: 'a'), false);
      expect(Neuron.isInstalled<_TaggedController>(tag: 'b'), true);
    });

    test('uninstallAll disposes all instances of a type', () {
      final c1 = _TaggedController('1');
      final c2 = _TaggedController('2');
      final c3 = _TaggedController('default');

      Neuron.install(c1, tag: 'a');
      Neuron.install(c2, tag: 'b');
      Neuron.install(c3);

      Neuron.uninstallAll<_TaggedController>();

      expect(c1.closeCalled, true);
      expect(c2.closeCalled, true);
      expect(c3.closeCalled, true);
      expect(Neuron.isInstalled<_TaggedController>(tag: 'a'), false);
      expect(Neuron.isInstalled<_TaggedController>(tag: 'b'), false);
      expect(Neuron.isInstalled<_TaggedController>(), false);
    });

    test('uninstallAll does not affect other types', () {
      Neuron.install(_TaggedController('x'), tag: 'x');
      Neuron.install(_OtherController());

      Neuron.uninstallAll<_TaggedController>();

      expect(Neuron.isInstalled<_OtherController>(), true);
    });

    test('tagged returns all instances of a type', () {
      final c1 = _TaggedController('1');
      final c2 = _TaggedController('2');
      final def = _TaggedController('def');

      Neuron.install(c1, tag: 'a');
      Neuron.install(c2, tag: 'b');
      Neuron.install(def);

      final all = Neuron.tagged<_TaggedController>();
      expect(all.length, 3);
      expect(all['a'], same(c1));
      expect(all['b'], same(c2));
      expect(all[null], same(def));
    });

    test('tagged returns empty map for unknown type', () {
      expect(Neuron.tagged<_TaggedController>(), isEmpty);
    });

    test('use throws with tag info in error', () {
      expect(
        () => Neuron.use<_TaggedController>(tag: 'missing'),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('tag: missing'),
        )),
      );
    });

    test('clearAll disposes all tagged and untagged', () {
      final c1 = _TaggedController('1');
      final c2 = _TaggedController('2');

      Neuron.install(c1, tag: 'x');
      Neuron.install(c2);

      Neuron.clearAll();

      expect(c1.closeCalled, true);
      expect(c2.closeCalled, true);
    });
  });
}
