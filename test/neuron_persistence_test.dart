import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:neuron/neuron.dart';

void main() {
  group('MemoryPersistence', () {
    test('load returns null when empty', () async {
      final persistence = MemoryPersistence<String>();

      final result = await persistence.load();
      expect(result, null);
    });

    test('save and load round-trip', () async {
      final persistence = MemoryPersistence<String>();

      await persistence.save('hello');
      final result = await persistence.load();

      expect(result, 'hello');
    });

    test('delete clears stored value', () async {
      final persistence = MemoryPersistence<int>();

      await persistence.save(42);
      await persistence.delete();

      final result = await persistence.load();
      expect(result, null);
    });

    test('overwrites previous value', () async {
      final persistence = MemoryPersistence<String>();

      await persistence.save('first');
      await persistence.save('second');

      expect(await persistence.load(), 'second');
    });
  });

  group('PersistentSignal', () {
    test('starts with initial value', () {
      final persistence = MemoryPersistence<int>();
      final signal = PersistentSignal<int>(0, persistence: persistence);

      expect(signal.val, 0);
    });

    test('loads persisted value on construction', () async {
      final persistence = MemoryPersistence<String>();
      await persistence.save('saved');

      final signal =
          PersistentSignal<String>('default', persistence: persistence);

      // Allow async load to complete
      await Future.delayed(Duration.zero);

      expect(signal.val, 'saved');
    });

    test('saves to persistence on emit', () async {
      final persistence = MemoryPersistence<int>();
      final signal = PersistentSignal<int>(0, persistence: persistence);

      // Wait for initialization
      await Future.delayed(Duration.zero);

      signal.emit(42);

      // Allow async save to complete
      await Future.delayed(Duration.zero);

      expect(await persistence.load(), 42);
    });

    test('clearPersisted removes stored value', () async {
      final persistence = MemoryPersistence<String>();
      final signal = PersistentSignal<String>('test', persistence: persistence);

      await Future.delayed(Duration.zero);
      signal.emit('value');
      await Future.delayed(Duration.zero);

      await signal.clearPersisted();

      expect(await persistence.load(), null);
    });

    test('multiple emits persist latest value', () async {
      final persistence = MemoryPersistence<int>();
      final signal = PersistentSignal<int>(0, persistence: persistence);

      await Future.delayed(Duration.zero);

      signal.emit(1);
      signal.emit(2);
      signal.emit(3);

      await Future.delayed(Duration.zero);

      expect(await persistence.load(), 3);
      expect(signal.val, 3);
    });
  });

  group('JsonPersistence', () {
    test('save and load JSON round-trip', () async {
      final store = <String, String>{};
      final persistence = JsonPersistence<Map<String, dynamic>>(
        key: 'test',
        fromJson: (json) => json,
        toJson: (value) => value,
        read: (key) async => store[key],
        write: (key, value) async => store[key] = value,
        remove: (key) async => store.remove(key),
      );

      final data = {'name': 'Alice', 'age': 30};
      await persistence.save(data);

      final loaded = await persistence.load();
      expect(loaded, {'name': 'Alice', 'age': 30});
    });

    test('load returns null when key not found', () async {
      final persistence = JsonPersistence<Map<String, dynamic>>(
        key: 'missing',
        fromJson: (json) => json,
        toJson: (value) => value,
        read: (key) async => null,
        write: (key, value) async {},
        remove: (key) async {},
      );

      expect(await persistence.load(), null);
    });

    test('delete removes stored value', () async {
      final store = <String, String>{};
      final persistence = JsonPersistence<Map<String, dynamic>>(
        key: 'test',
        fromJson: (json) => json,
        toJson: (value) => value,
        read: (key) async => store[key],
        write: (key, value) async => store[key] = value,
        remove: (key) async => store.remove(key),
      );

      await persistence.save({'foo': 'bar'});
      await persistence.delete();

      expect(await persistence.load(), null);
    });
  });

  group('SimplePersistence', () {
    test('save and load primitive round-trip', () async {
      final store = <String, String>{};
      final persistence = SimplePersistence<int>(
        key: 'counter',
        fromString: (s) => int.parse(s),
        toStringValue: (v) => v.toString(),
        read: (key) async => store[key],
        write: (key, value) async => store[key] = value,
        remove: (key) async => store.remove(key),
      );

      await persistence.save(42);
      final loaded = await persistence.load();

      expect(loaded, 42);
    });

    test('load returns null when empty', () async {
      final persistence = SimplePersistence<String>(
        key: 'missing',
        fromString: (s) => s,
        toStringValue: (v) => v,
        read: (key) async => null,
        write: (key, value) async {},
        remove: (key) async {},
      );

      expect(await persistence.load(), null);
    });
  });

  group('BinaryPersistence', () {
    test('save and load binary round-trip', () async {
      final store = <String, List<int>>{};
      final persistence = BinaryPersistence<String>(
        key: 'binary_test',
        fromBytes: (bytes) => utf8.decode(bytes),
        toBytes: (value) => utf8.encode(value),
        read: (key) async => store[key],
        write: (key, bytes) async => store[key] = bytes,
        remove: (key) async => store.remove(key),
      );

      await persistence.save('hello binary');
      final loaded = await persistence.load();

      expect(loaded, 'hello binary');
    });
  });

  group('EncryptedPersistence', () {
    test('encrypts on save and decrypts on load', () async {
      final inner = MemoryPersistence<String>();

      final persistence = EncryptedPersistence<String>(
        storage: inner,
        encrypt: (data) => data.split('').reversed.join(''), // Simple reverse
        decrypt: (encrypted) => encrypted.split('').reversed.join(''),
        serialize: (value) => value,
        deserialize: (data) => data,
      );

      await persistence.save('secret');

      // Inner storage should have the "encrypted" (reversed) value
      final encrypted = await inner.load();
      expect(encrypted, 'terces');

      // But loading through EncryptedPersistence should decrypt
      final loaded = await persistence.load();
      expect(loaded, 'secret');
    });

    test('delete delegates to inner storage', () async {
      final inner = MemoryPersistence<String>();

      final persistence = EncryptedPersistence<String>(
        storage: inner,
        encrypt: (data) => data,
        decrypt: (encrypted) => encrypted,
        serialize: (value) => value,
        deserialize: (data) => data,
      );

      await persistence.save('data');
      await persistence.delete();

      expect(await inner.load(), null);
    });
  });

  group('VersionedPersistence', () {
    test('saves and loads with version wrapper', () async {
      final inner = MemoryPersistence<Map<String, dynamic>>();

      final persistence = VersionedPersistence<Map<String, dynamic>>(
        key: 'user',
        currentVersion: 2,
        storage: inner,
        fromData: (data, version) => data,
        toData: (value) => value,
      );

      await persistence.save({'name': 'Alice'});

      final stored = await inner.load();
      expect(stored!['__version__'], 2);
      expect(stored['__data__'], {'name': 'Alice'});
    });

    test('loads and migrates old version', () async {
      final inner = MemoryPersistence<Map<String, dynamic>>();

      // Store old version data
      await inner.save({
        '__version__': 1,
        '__data__': {'name': 'Alice'},
      });

      final persistence = VersionedPersistence<Map<String, dynamic>>(
        key: 'user',
        currentVersion: 2,
        storage: inner,
        fromData: (data, version) => data,
        toData: (value) => value,
        migrate: (oldData, oldVersion, newVersion) {
          // Migration: add default email
          return {...oldData, 'email': 'default@example.com'};
        },
      );

      final loaded = await persistence.load();

      expect(loaded, {'name': 'Alice', 'email': 'default@example.com'});
    });

    test('does not migrate when version matches', () async {
      final inner = MemoryPersistence<Map<String, dynamic>>();

      await inner.save({
        '__version__': 2,
        '__data__': {'name': 'Bob'},
      });

      var migrateCalled = false;
      final persistence = VersionedPersistence<Map<String, dynamic>>(
        key: 'user',
        currentVersion: 2,
        storage: inner,
        fromData: (data, version) => data,
        toData: (value) => value,
        migrate: (oldData, oldVersion, newVersion) {
          migrateCalled = true;
          return oldData;
        },
      );

      await persistence.load();

      expect(migrateCalled, false);
    });
  });
}
