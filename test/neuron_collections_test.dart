import 'package:flutter_test/flutter_test.dart';
import 'package:neuron/neuron.dart';

void main() {
  group('ListSignal', () {
    test('should add items', () {
      final list = ListSignal<int>([]);

      list.add(1);
      list.add(2);

      expect(list.val, [1, 2]);
      expect(list.length, 2);
    });

    test('should remove items', () {
      final list = ListSignal<int>([1, 2, 3]);

      final removed = list.remove(2);

      expect(removed, true);
      expect(list.val, [1, 3]);
    });

    test('should clear items', () {
      final list = ListSignal<int>([1, 2, 3]);

      list.clear();

      expect(list.isEmpty, true);
      expect(list.val, []);
    });

    test('should sort items', () {
      final list = ListSignal<int>([3, 1, 2]);

      list.sort();

      expect(list.val, [1, 2, 3]);
    });

    test('should reverse items', () {
      final list = ListSignal<int>([1, 2, 3]);

      list.reverse();

      expect(list.val, [3, 2, 1]);
    });

    test('should filter items', () {
      final list = ListSignal<int>([1, 2, 3, 4, 5]);

      list.filter((n) => n % 2 == 0);

      expect(list.val, [2, 4]);
    });

    test('should access items by index', () {
      final list = ListSignal<String>(['a', 'b', 'c']);

      expect(list[0], 'a');
      expect(list[1], 'b');
      expect(list[2], 'c');
    });
  });

  group('MapSignal', () {
    test('should put items', () {
      final map = MapSignal<String, int>({});

      map.put('a', 1);
      map.put('b', 2);

      expect(map.val, {'a': 1, 'b': 2});
      expect(map.length, 2);
    });

    test('should remove items', () {
      final map = MapSignal<String, int>({'a': 1, 'b': 2});

      map.remove('a');

      expect(map.val, {'b': 2});
    });

    test('should clear items', () {
      final map = MapSignal<String, int>({'a': 1, 'b': 2});

      map.clear();

      expect(map.isEmpty, true);
      expect(map.val, {});
    });

    test('should check if key exists', () {
      final map = MapSignal<String, int>({'a': 1});

      expect(map.containsKey('a'), true);
      expect(map.containsKey('b'), false);
    });

    test('should access values by key', () {
      final map = MapSignal<String, String>({'name': 'Alice', 'age': '30'});

      expect(map['name'], 'Alice');
      expect(map['age'], '30');
    });

    test('should get keys and values', () {
      final map = MapSignal<String, int>({'a': 1, 'b': 2});

      expect(map.keys, {'a', 'b'});
      expect(map.values, {1, 2});
    });
  });

  group('SetSignal', () {
    test('should add items', () {
      final set = SetSignal<int>({});

      set.add(1);
      set.add(2);
      set.add(1); // Duplicate

      expect(set.val, {1, 2});
      expect(set.length, 2);
    });

    test('should remove items', () {
      final set = SetSignal<int>({1, 2, 3});

      final removed = set.remove(2);

      expect(removed, true);
      expect(set.val, {1, 3});
    });

    test('should clear items', () {
      final set = SetSignal<int>({1, 2, 3});

      set.clear();

      expect(set.isEmpty, true);
      expect(set.val, <int>{});
    });

    test('should check if contains item', () {
      final set = SetSignal<String>({'a', 'b', 'c'});

      expect(set.contains('a'), true);
      expect(set.contains('d'), false);
    });

    test('should add multiple items', () {
      final set = SetSignal<int>({1});

      set.addAll([2, 3, 4]);

      expect(set.val, {1, 2, 3, 4});
    });
  });
}
