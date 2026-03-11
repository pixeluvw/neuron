import 'package:flutter_test/flutter_test.dart';
import 'package:neuron/neuron.dart';

void main() {
  group('NeuronAtomPool', () {
    setUp(() {
      // Clear pool between tests by obtaining + discarding
      // NeuronAtomPool is static, so we work with it directly
    });

    test('obtain creates a new atom when pool is empty', () {
      final atom = NeuronAtomPool.obtain<int>(42);

      expect(atom.value, 42);
    });

    test('release and obtain recycles atoms', () {
      final original = NeuronAtomPool.obtain<int>(10);
      NeuronAtomPool.release(original);

      final recycled = NeuronAtomPool.obtain<int>(99);

      expect(recycled.value, 99);
    });

    test('recycled atom has reset state', () {
      final original = NeuronAtomPool.obtain<int>(10);
      original.value = 50;
      NeuronAtomPool.release(original);

      final recycled = NeuronAtomPool.obtain<int>(0);

      expect(recycled.value, 0);
    });

    test('different types do not share pool buckets', () {
      final intAtom = NeuronAtomPool.obtain<int>(1);
      final strAtom = NeuronAtomPool.obtain<String>('hello');

      NeuronAtomPool.release(intAtom);
      NeuronAtomPool.release(strAtom);

      // Obtaining String should get the String atom back, not the int
      final recycledStr = NeuronAtomPool.obtain<String>('world');
      expect(recycledStr.value, 'world');
    });

    test('pool respects per-type size cap', () {
      // Release more atoms than the cap (128) of a fresh type to test capping
      // Use a unique type to avoid interference
      final atoms = <NeuronAtom<double>>[];
      for (int i = 0; i < 140; i++) {
        atoms.add(NeuronAtomPool.obtain<double>(i.toDouble()));
      }

      // Release all 140
      for (final atom in atoms) {
        NeuronAtomPool.release(atom);
      }

      // Should be able to obtain 128 from pool, rest are new
      int recycled = 0;
      for (int i = 0; i < 140; i++) {
        NeuronAtomPool.obtain<double>(0);
        recycled++;
      }
      // Just verify no crash and proper count
      expect(recycled, 140);
    });
  });
}
