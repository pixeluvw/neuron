import 'package:recase/recase.dart';

/// Templates for service layer generation
class ServiceTemplates {
  /// Base service template
  static String serviceDart(String serviceName) {
    final rc = ReCase(serviceName);
    return '''
import 'package:neuron/neuron.dart';

/// ${rc.pascalCase} Service
///
/// Handles data operations for the ${rc.titleCase} domain.
///
/// Usage:
/// ```dart
/// final svc = ${rc.pascalCase}Service.init;
/// ```
class ${rc.pascalCase}Service extends NeuronController {
  /// Static getter for the service
  static ${rc.pascalCase}Service get init => Neuron.use<${rc.pascalCase}Service>();

  // ============================================
  // Signals - Reactive service state
  // ============================================

  /// Loading state
  late final isLoading = Signal<bool>(false).bind(this);

  /// Error state
  late final error = Signal<String?>(null).bind(this);

  // ============================================
  // Lifecycle
  // ============================================

  @override
  void onInit() {
    super.onInit();
    // Initialize service resources (DB connections, API clients, etc.)
  }

  @override
  void onClose() {
    // Release service resources
    super.onClose();
  }

  // ============================================
  // Public API
  // ============================================

  // TODO: Add your service methods here
}
''';
  }

  /// CRUD service template
  static String crudServiceDart(String serviceName) {
    final rc = ReCase(serviceName);
    return '''
import 'package:neuron/neuron.dart';

/// ${rc.pascalCase} Service — CRUD Operations
///
/// Handles create, read, update, delete for ${rc.titleCase} entities.
///
/// Usage:
/// ```dart
/// final svc = ${rc.pascalCase}Service.init;
/// final items = await svc.getAll();
/// ```
class ${rc.pascalCase}Service extends NeuronController {
  /// Static getter for the service
  static ${rc.pascalCase}Service get init => Neuron.use<${rc.pascalCase}Service>();

  // ============================================
  // Signals - Reactive service state
  // ============================================

  /// Loading state
  late final isLoading = Signal<bool>(false).bind(this);

  /// Error state
  late final error = Signal<String?>(null).bind(this);

  /// Cached items
  late final items = Signal<List<Map<String, dynamic>>>([]).bind(this);

  // ============================================
  // Lifecycle
  // ============================================

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onClose() {
    super.onClose();
  }

  // ============================================
  // CRUD Operations
  // ============================================

  /// Fetch all ${rc.titleCase} records
  Future<List<Map<String, dynamic>>> getAll() async {
    isLoading.emit(true);
    error.emit(null);
    try {
      // TODO: Replace with actual data source call
      final result = <Map<String, dynamic>>[];
      items.emit(result);
      return result;
    } catch (e) {
      error.emit(e.toString());
      rethrow;
    } finally {
      isLoading.emit(false);
    }
  }

  /// Fetch a single ${rc.titleCase} by ID
  Future<Map<String, dynamic>?> getById(String id) async {
    isLoading.emit(true);
    error.emit(null);
    try {
      // TODO: Replace with actual data source call
      return null;
    } catch (e) {
      error.emit(e.toString());
      rethrow;
    } finally {
      isLoading.emit(false);
    }
  }

  /// Create a new ${rc.titleCase}
  Future<Map<String, dynamic>> create(Map<String, dynamic> data) async {
    isLoading.emit(true);
    error.emit(null);
    try {
      // TODO: Replace with actual data source call
      await getAll(); // Refresh cache
      return data;
    } catch (e) {
      error.emit(e.toString());
      rethrow;
    } finally {
      isLoading.emit(false);
    }
  }

  /// Update an existing ${rc.titleCase}
  Future<Map<String, dynamic>> update(String id, Map<String, dynamic> data) async {
    isLoading.emit(true);
    error.emit(null);
    try {
      // TODO: Replace with actual data source call
      await getAll(); // Refresh cache
      return data;
    } catch (e) {
      error.emit(e.toString());
      rethrow;
    } finally {
      isLoading.emit(false);
    }
  }

  /// Delete a ${rc.titleCase} by ID
  Future<void> delete(String id) async {
    isLoading.emit(true);
    error.emit(null);
    try {
      // TODO: Replace with actual data source call
      await getAll(); // Refresh cache
    } catch (e) {
      error.emit(e.toString());
      rethrow;
    } finally {
      isLoading.emit(false);
    }
  }
}
''';
  }

  /// HTTP-based service template
  static String httpServiceDart(String serviceName) {
    final rc = ReCase(serviceName);
    return '''
import 'dart:convert';
import 'dart:io';

import 'package:neuron/neuron.dart';

/// ${rc.pascalCase} Service — HTTP Client
///
/// Handles HTTP operations for the ${rc.titleCase} domain.
///
/// Usage:
/// ```dart
/// final svc = ${rc.pascalCase}Service.init;
/// final data = await svc.get('/endpoint');
/// ```
class ${rc.pascalCase}Service extends NeuronController {
  /// Static getter for the service
  static ${rc.pascalCase}Service get init => Neuron.use<${rc.pascalCase}Service>();

  // ============================================
  // Configuration
  // ============================================

  /// Base URL for API calls — override in subclass or set via env
  String get baseUrl => 'https://api.example.com';

  /// Default headers sent with every request
  Map<String, String> get defaultHeaders => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  late final HttpClient _client = HttpClient();

  // ============================================
  // Signals
  // ============================================

  /// Loading state
  late final isLoading = Signal<bool>(false).bind(this);

  /// Error state
  late final error = Signal<String?>(null).bind(this);

  // ============================================
  // Lifecycle
  // ============================================

  @override
  void onClose() {
    _client.close();
    super.onClose();
  }

  // ============================================
  // HTTP Methods
  // ============================================

  /// Perform a GET request
  Future<Map<String, dynamic>> get(String path) async {
    return _request('GET', path);
  }

  /// Perform a POST request
  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    return _request('POST', path, body: body);
  }

  /// Perform a PUT request
  Future<Map<String, dynamic>> put(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    return _request('PUT', path, body: body);
  }

  /// Perform a DELETE request
  Future<Map<String, dynamic>> delete(String path) async {
    return _request('DELETE', path);
  }

  // ============================================
  // Internal
  // ============================================

  Future<Map<String, dynamic>> _request(
    String method,
    String path, {
    Map<String, dynamic>? body,
  }) async {
    isLoading.emit(true);
    error.emit(null);
    try {
      final uri = Uri.parse('\$baseUrl\$path');
      final HttpClientRequest request;

      switch (method) {
        case 'GET':
          request = await _client.getUrl(uri);
        case 'POST':
          request = await _client.postUrl(uri);
        case 'PUT':
          request = await _client.putUrl(uri);
        case 'DELETE':
          request = await _client.deleteUrl(uri);
        default:
          throw UnsupportedError('HTTP method \$method not supported');
      }

      // Apply headers
      defaultHeaders.forEach((key, value) {
        request.headers.set(key, value);
      });

      // Write body
      if (body != null) {
        request.write(jsonEncode(body));
      }

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (responseBody.isEmpty) return {};
        return jsonDecode(responseBody) as Map<String, dynamic>;
      } else {
        throw HttpException(
          'HTTP \$method \$path failed with status \${response.statusCode}: \$responseBody',
        );
      }
    } catch (e) {
      error.emit(e.toString());
      rethrow;
    } finally {
      isLoading.emit(false);
    }
  }
}
''';
  }
}
