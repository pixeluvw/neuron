import 'dart:convert';

/// Utility methods to make sure debug payloads remain JSON-safe.
class NeuronDebugEncoder {
  const NeuronDebugEncoder._();

  static dynamic encodeValue(dynamic value) {
    if (value == null) return null;
    if (value is num || value is bool || value is String) return value;
    if (value is DateTime) return value.toIso8601String();
    if (value is Iterable) return value.map(encodeValue).toList();
    if (value is Map) {
      return Map<String, dynamic>.fromEntries(
        value.entries.map(
          (e) => MapEntry(e.key.toString(), encodeValue(e.value)),
        ),
      );
    }

    try {
      return jsonDecode(jsonEncode(value));
    } catch (_) {
      return value.toString();
    }
  }
}
