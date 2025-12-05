// neuron_persistence.dart
part of 'neuron_extensions.dart';

/// ============================================================================
/// PERSISTENCE
/// ============================================================================

/// Abstract persistence interface.
abstract class SignalPersistence<T> {
  Future<T?> load();
  Future<void> save(T value);
  Future<void> delete();
}

/// Signal with automatic persistence.
///
/// PersistentSignal automatically saves to storage on changes
/// and loads the last saved value on initialization.
///
/// ## Basic Usage
///
/// ```dart
/// // Using SharedPreferences (example)
/// final theme = PersistentSignal<String>(
///   'light',
///   persistence: SimplePersistence(
///     key: 'app_theme',
///     read: (key) => prefs.getString(key),
///     write: (key, val) => prefs.setString(key, val),
///     // ... other required methods
///   ),
/// );
/// ```
class PersistentSignal<T> extends Signal<T> {
  final SignalPersistence<T> persistence;
  bool _isInitialized = false;

  PersistentSignal(
    T initial, {
    required this.persistence,
    String? debugLabel,
    super.equals,
    super.guard,
    super.onListen,
    super.onCancel,
  }) : super(initial, debugLabel: debugLabel) {
    _loadFromPersistence();
  }

  Future<void> _loadFromPersistence() async {
    try {
      final loaded = await persistence.load();
      if (loaded != null) {
        super.emit(loaded);
      }
      _isInitialized = true;
    } catch (e) {
      if (kDebugMode) print('Failed to load persisted value: $e');
      _isInitialized = true;
    }
  }

  @override
  void emit(T val) {
    super.emit(val);
    if (_isInitialized) {
      _saveToPersistence(val);
    }
  }

  Future<void> _saveToPersistence(T value) async {
    try {
      await persistence.save(value);
    } catch (e) {
      if (kDebugMode) print('Failed to persist value: $e');
    }
  }

  /// Clear persisted value.
  Future<void> clearPersisted() async {
    try {
      await persistence.delete();
    } catch (e) {
      if (kDebugMode) print('Failed to delete persisted value: $e');
    }
  }
}

/// In-memory persistence (for testing).
class MemoryPersistence<T> extends SignalPersistence<T> {
  T? _stored;

  @override
  Future<T?> load() async => _stored;

  @override
  Future<void> save(T value) async {
    _stored = value;
  }

  @override
  Future<void> delete() async {
    _stored = null;
  }
}

/// JSON persistence adapter.
///
/// Requires a storage backend that can read/write strings.
class JsonPersistence<T> extends SignalPersistence<T> {
  final String key;
  final T Function(Map<String, dynamic> json) fromJson;
  final Map<String, dynamic> Function(T value) toJson;
  final Future<String?> Function(String key) read;
  final Future<void> Function(String key, String value) write;
  final Future<void> Function(String key) remove;

  JsonPersistence({
    required this.key,
    required this.fromJson,
    required this.toJson,
    required this.read,
    required this.write,
    required this.remove,
  });

  @override
  Future<T?> load() async {
    try {
      final stored = await read(key);
      if (stored == null) return null;
      final json = jsonDecode(stored) as Map<String, dynamic>;
      return fromJson(json);
    } catch (e) {
      if (kDebugMode) print('JsonPersistence load error: $e');
      return null;
    }
  }

  @override
  Future<void> save(T value) async {
    try {
      final json = toJson(value);
      final encoded = jsonEncode(json);
      await write(key, encoded);
    } catch (e) {
      if (kDebugMode) print('JsonPersistence save error: $e');
    }
  }

  @override
  Future<void> delete() async {
    try {
      await remove(key);
    } catch (e) {
      if (kDebugMode) print('JsonPersistence delete error: $e');
    }
  }
}

/// Simple string persistence for primitive types.
class SimplePersistence<T> extends SignalPersistence<T> {
  final String key;
  final T Function(String value) fromString;
  final String Function(T value) toStringValue;
  final Future<String?> Function(String key) read;
  final Future<void> Function(String key, String value) write;
  final Future<void> Function(String key) remove;

  SimplePersistence({
    required this.key,
    required this.fromString,
    required this.toStringValue,
    required this.read,
    required this.write,
    required this.remove,
  });

  @override
  Future<T?> load() async {
    try {
      final stored = await read(key);
      if (stored == null) return null;
      return fromString(stored);
    } catch (e) {
      if (kDebugMode) print('SimplePersistence load error: $e');
      return null;
    }
  }

  @override
  Future<void> save(T value) async {
    try {
      final string = toStringValue(value);
      await write(key, string);
    } catch (e) {
      if (kDebugMode) print('SimplePersistence save error: $e');
    }
  }

  @override
  Future<void> delete() async {
    try {
      await remove(key);
    } catch (e) {
      if (kDebugMode) print('SimplePersistence delete error: $e');
    }
  }
}

/// Binary persistence for custom serialization.
class BinaryPersistence<T> extends SignalPersistence<T> {
  final String key;
  final T Function(List<int> bytes) fromBytes;
  final List<int> Function(T value) toBytes;
  final Future<List<int>?> Function(String key) read;
  final Future<void> Function(String key, List<int> bytes) write;
  final Future<void> Function(String key) remove;

  BinaryPersistence({
    required this.key,
    required this.fromBytes,
    required this.toBytes,
    required this.read,
    required this.write,
    required this.remove,
  });

  @override
  Future<T?> load() async {
    try {
      final bytes = await read(key);
      if (bytes == null) return null;
      return fromBytes(bytes);
    } catch (e) {
      if (kDebugMode) print('BinaryPersistence load error: $e');
      return null;
    }
  }

  @override
  Future<void> save(T value) async {
    try {
      final bytes = toBytes(value);
      await write(key, bytes);
    } catch (e) {
      if (kDebugMode) print('BinaryPersistence save error: $e');
    }
  }

  @override
  Future<void> delete() async {
    try {
      await remove(key);
    } catch (e) {
      if (kDebugMode) print('BinaryPersistence delete error: $e');
    }
  }
}

/// Encrypted persistence wrapper.
class EncryptedPersistence<T> extends SignalPersistence<T> {
  final SignalPersistence<String> storage;
  final String Function(String data) encrypt;
  final String Function(String encrypted) decrypt;
  final String Function(T value) serialize;
  final T Function(String data) deserialize;

  EncryptedPersistence({
    required this.storage,
    required this.encrypt,
    required this.decrypt,
    required this.serialize,
    required this.deserialize,
  });

  @override
  Future<T?> load() async {
    try {
      final encrypted = await storage.load();
      if (encrypted == null) return null;
      final decrypted = decrypt(encrypted);
      return deserialize(decrypted);
    } catch (e) {
      if (kDebugMode) print('EncryptedPersistence load error: $e');
      return null;
    }
  }

  @override
  Future<void> save(T value) async {
    try {
      final serialized = serialize(value);
      final encrypted = encrypt(serialized);
      await storage.save(encrypted);
    } catch (e) {
      if (kDebugMode) print('EncryptedPersistence save error: $e');
    }
  }

  @override
  Future<void> delete() async {
    await storage.delete();
  }
}

/// Versioned persistence with migration support.
class VersionedPersistence<T> extends SignalPersistence<T> {
  final String key;
  final int currentVersion;
  final SignalPersistence<Map<String, dynamic>> storage;
  final T Function(Map<String, dynamic> data, int version) fromData;
  final Map<String, dynamic> Function(T value) toData;
  final T Function(
      Map<String, dynamic> oldData, int oldVersion, int newVersion)? migrate;

  VersionedPersistence({
    required this.key,
    required this.currentVersion,
    required this.storage,
    required this.fromData,
    required this.toData,
    this.migrate,
  });

  @override
  Future<T?> load() async {
    try {
      final stored = await storage.load();
      if (stored == null) return null;

      final version = stored['__version__'] as int? ?? 1;
      final data = stored['__data__'] as Map<String, dynamic>;

      if (version < currentVersion && migrate != null) {
        final migrated = migrate!(data, version, currentVersion);
        await save(migrated); // Save migrated version
        return migrated;
      }

      return fromData(data, version);
    } catch (e) {
      if (kDebugMode) print('VersionedPersistence load error: $e');
      return null;
    }
  }

  @override
  Future<void> save(T value) async {
    try {
      final data = toData(value);
      final wrapped = {
        '__version__': currentVersion,
        '__data__': data,
      };
      await storage.save(wrapped);
    } catch (e) {
      if (kDebugMode) print('VersionedPersistence save error: $e');
    }
  }

  @override
  Future<void> delete() async {
    await storage.delete();
  }
}
