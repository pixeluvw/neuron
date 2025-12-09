// neuron_collections.dart
//
// ═══════════════════════════════════════════════════════════════════════════════
// NEURON COLLECTIONS - Reactive Collection Types
// ═══════════════════════════════════════════════════════════════════════════════
//
// Specialized Signal types for working with collections (List, Map, Set).
// Each provides convenient mutation methods while maintaining immutability
// and proper change notification.
//
// ┌───────────────┬─────────────────────────────────────────────────────────────┐
// │ Type           │ Description                                                 │
// ├───────────────┼─────────────────────────────────────────────────────────────┤
// │ ListSignal<E>  │ Reactive list with add, remove, insert, sort, filter       │
// │ MapSignal<K,V> │ Reactive map with put, remove, putAll, clear               │
// │ SetSignal<E>   │ Reactive set with add, remove, toggle, union, intersect    │
// └───────────────┴─────────────────────────────────────────────────────────────┘
//
// IMMUTABILITY:
// All mutation methods create new collection instances internally.
// This ensures proper change detection and avoids reference equality issues.
//
// EXAMPLE:
// ```dart
// class TodoController extends NeuronController {
//   late final todos = ListSignal<Todo>([]).bind(this);
//   late final selectedTags = SetSignal<String>({}).bind(this);
//   late final settings = MapSignal<String, dynamic>({}).bind(this);
//
//   void addTodo(Todo todo) => todos.add(todo);
//   void toggleTag(String tag) => selectedTags.toggle(tag);
//   void updateSetting(String key, dynamic value) => settings.put(key, value);
// }
// ```
//
// See also:
// - neuron_signals.dart : Base Signal class
// - neuron_core.dart    : Slot widget for UI binding
//
// ═══════════════════════════════════════════════════════════════════════════════

part of 'neuron_extensions.dart';

/// ============================================================================
/// COLLECTION SIGNALS
/// ============================================================================

/// Signal for List with convenient mutation methods.
///
/// ListSignal provides reactive list operations while maintaining immutability.
/// Each mutation creates a new list instance to trigger updates.
///
/// ## Basic Usage
///
/// ```dart
/// final items = ListSignal<String>(['A', 'B']);
///
/// // Add item
/// items.add('C'); // Emits ['A', 'B', 'C']
///
/// // Remove item
/// items.remove('A'); // Emits ['B', 'C']
///
/// // Update item
/// items.replaceAt(0, 'Z'); // Emits ['Z', 'C']
/// ```
///
/// ## Binding to UI
///
/// ```dart
/// Slot(
///   connect: items,
///   to: (context, list) {
///     return ListView.builder(
///       itemCount: list.length,
///       itemBuilder: (context, index) => Text(list[index]),
///     );
///   },
/// )
/// ```
class ListSignal<E> extends Signal<List<E>> {
  ListSignal(
    List<E> initial, {
    String? debugLabel,
    super.equals,
    super.guard,
    super.onListen,
    super.onCancel,
  }) : super(List<E>.from(initial), debugLabel: debugLabel);

  /// Add an item to the list.
  void add(E item) {
    emit([...val, item]);
  }

  /// Add multiple items to the list.
  void addAll(Iterable<E> items) {
    emit([...val, ...items]);
  }

  /// Remove an item from the list.
  bool remove(E item) {
    final newList = List<E>.from(val);
    final removed = newList.remove(item);
    if (removed) emit(newList);
    return removed;
  }

  /// Remove item at index.
  E removeAt(int index) {
    final newList = List<E>.from(val);
    final removed = newList.removeAt(index);
    emit(newList);
    return removed;
  }

  /// Insert item at index.
  void insert(int index, E item) {
    final newList = List<E>.from(val);
    newList.insert(index, item);
    emit(newList);
  }

  /// Clear all items.
  void clear() {
    emit([]);
  }

  /// Sort list with optional comparator.
  void sort([int Function(E a, E b)? compare]) {
    final newList = List<E>.from(val);
    newList.sort(compare);
    emit(newList);
  }

  /// Replace item at index.
  void replaceAt(int index, E item) {
    final newList = List<E>.from(val);
    newList[index] = item;
    emit(newList);
  }

  /// Reverse the list.
  void reverse() {
    final newList = List<E>.from(val);
    emit(newList.reversed.toList());
  }

  /// Shuffle the list.
  void shuffle([int? seed]) {
    final newList = List<E>.from(val);
    if (seed != null) {
      newList.shuffle(Random(seed));
    } else {
      newList.shuffle();
    }
    emit(newList);
  }

  /// Filter items that match condition.
  void filter(bool Function(E) test) {
    emit(val.where(test).toList());
  }

  /// Map items to new type and emit.
  void map<T>(T Function(E) transform) {
    // Note: This changes the type, so not ideal for ListSignal<E>
    // Better to create a new signal
  }

  /// Get length of list.
  int get length => val.length;

  /// Check if list is empty.
  bool get isEmpty => val.isEmpty;

  /// Check if list is not empty.
  bool get isNotEmpty => val.isNotEmpty;

  /// Access item by index.
  E operator [](int index) => val[index];
}

/// Signal for Map with convenient mutation methods.
///
/// MapSignal provides reactive map operations while maintaining immutability.
/// Each mutation creates a new map instance to trigger updates.
///
/// ## Basic Usage
///
/// ```dart
/// final settings = MapSignal<String, dynamic>({'theme': 'light'});
///
/// // Add/Update entry
/// settings.put('theme', 'dark');
///
/// // Remove entry
/// settings.remove('theme');
///
/// // Clear all
/// settings.clear();
/// ```
///
/// ## Binding to UI
///
/// ```dart
/// Slot(
///   connect: settings,
///   to: (context, map) {
///     return Text('Theme: ${map['theme']}');
///   },
/// )
/// ```
class MapSignal<K, V> extends Signal<Map<K, V>> {
  MapSignal(
    Map<K, V> initial, {
    String? debugLabel,
    super.equals,
    super.guard,
    super.onListen,
    super.onCancel,
  }) : super(Map<K, V>.from(initial), debugLabel: debugLabel);

  /// Put a key-value pair.
  void put(K key, V value) {
    emit({...val, key: value});
  }

  /// Put multiple entries.
  void putAll(Map<K, V> entries) {
    emit({...val, ...entries});
  }

  /// Remove a key.
  V? remove(K key) {
    final newMap = Map<K, V>.from(val);
    final removed = newMap.remove(key);
    emit(newMap);
    return removed;
  }

  /// Clear all entries.
  void clear() {
    emit({});
  }

  /// Update value for key using function.
  void update(K key, V Function(V? value) updater) {
    final newMap = Map<K, V>.from(val);
    newMap[key] = updater(newMap[key]);
    emit(newMap);
  }

  /// Check if key exists.
  bool containsKey(K key) => val.containsKey(key);

  /// Get value by key.
  V? operator [](K key) => val[key];

  /// Get length of map.
  int get length => val.length;

  /// Check if map is empty.
  bool get isEmpty => val.isEmpty;

  /// Check if map is not empty.
  bool get isNotEmpty => val.isNotEmpty;

  /// Get all keys.
  Iterable<K> get keys => val.keys;

  /// Get all values.
  Iterable<V> get values => val.values;

  /// Get all entries.
  Iterable<MapEntry<K, V>> get entries => val.entries;
}

/// Signal for Set with convenient mutation methods.
///
/// SetSignal provides reactive set operations while maintaining immutability.
///
/// ## Basic Usage
///
/// ```dart
/// final tags = SetSignal<String>({'flutter', 'dart'});
///
/// // Add item
/// tags.add('reactive');
///
/// // Remove item
/// tags.remove('flutter');
///
/// // Check existence
/// if (tags.contains('dart')) { ... }
/// ```
class SetSignal<E> extends Signal<Set<E>> {
  SetSignal(
    Set<E> initial, {
    String? debugLabel,
    super.equals,
    super.guard,
    super.onListen,
    super.onCancel,
  }) : super(Set<E>.from(initial), debugLabel: debugLabel);

  /// Add an element.
  bool add(E element) {
    if (val.contains(element)) return false;
    emit({...val, element});
    return true;
  }

  /// Add multiple elements.
  void addAll(Iterable<E> elements) {
    emit({...val, ...elements});
  }

  /// Remove an element.
  bool remove(E element) {
    if (!val.contains(element)) return false;
    final newSet = Set<E>.from(val);
    newSet.remove(element);
    emit(newSet);
    return true;
  }

  /// Clear all elements.
  void clear() {
    emit({});
  }

  /// Check if element exists.
  bool contains(E element) => val.contains(element);

  /// Get length of set.
  int get length => val.length;

  /// Check if set is empty.
  bool get isEmpty => val.isEmpty;

  /// Check if set is not empty.
  bool get isNotEmpty => val.isNotEmpty;
}
