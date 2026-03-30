import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:instana_agent/instana_agent.dart';
import '../models/todo.dart';
import '../config/api_config.dart';

/// Exception thrown when API request fails
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, [this.statusCode]);

  @override
  String toString() => 'ApiException: $message${statusCode != null ? ' (Status: $statusCode)' : ''}';
}

/// Service class for handling all API requests with Instana monitoring
class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final http.Client _client = http.Client();

  /// Get all todos with optional filters
  Future<List<Todo>> getTodos({
    String? search,
    Priority? priority,
    Category? category,
    bool? completed,
  }) async {
    Marker? marker;
    
    try {
      // Build query parameters
      final queryParams = <String, String>{};
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (priority != null) queryParams['priority'] = priority.index.toString();
      if (category != null) queryParams['category'] = category.index.toString();
      if (completed != null) queryParams['completed'] = completed.toString();

      final uri = Uri.parse(ApiConfig.todosUrl).replace(queryParameters: queryParams);
      
      // Start Instana HTTP capture
      marker = await InstanaAgent.startCapture(
        url: uri.toString(),
        method: 'GET',
        viewName: 'TodosList',
      );
      
      final response = await _client
          .get(uri)
          .timeout(ApiConfig.connectionTimeout);

      // Set response details on marker
      marker.responseStatusCode = response.statusCode;
      marker.responseSizeBody = response.bodyBytes.length;
      marker.responseSizeBodyDecoded = response.contentLength;
      
      // Extract backend tracing ID for correlation
      marker.backendTracingID = BackendTracingIDParser.fromHeadersMap(
        response.headers.map((key, value) => MapEntry(key, value))
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        await marker.finish();
        return jsonList.map((json) => Todo.fromJson(json)).toList();
      } else {
        marker.errorMessage = 'HTTP ${response.statusCode}: ${response.body}';
        await marker.finish();
        throw ApiException(
          'Failed to load todos: ${response.body}',
          response.statusCode,
        );
      }
    } catch (e) {
      // Capture error in Instana
      if (marker != null) {
        marker.errorMessage = e.toString();
        await marker.finish();
      }
      if (e is ApiException) rethrow;
      throw ApiException('Network error: ${e.toString()}');
    }
  }

  /// Get a specific todo by ID
  Future<Todo> getTodo(String id) async {
    Marker? marker;
    
    try {
      final uri = Uri.parse(ApiConfig.todoUrl(id));
      
      // Start Instana HTTP capture
      marker = await InstanaAgent.startCapture(
        url: uri.toString(),
        method: 'GET',
        viewName: 'TodoDetail',
      );
      
      final response = await _client
          .get(uri)
          .timeout(ApiConfig.connectionTimeout);

      // Set response details on marker
      marker.responseStatusCode = response.statusCode;
      marker.responseSizeBody = response.bodyBytes.length;
      marker.responseSizeBodyDecoded = response.contentLength;
      
      // Extract backend tracing ID for correlation
      marker.backendTracingID = BackendTracingIDParser.fromHeadersMap(
        response.headers.map((key, value) => MapEntry(key, value))
      );

      if (response.statusCode == 200) {
        await marker.finish();
        return Todo.fromJson(json.decode(response.body));
      } else if (response.statusCode == 404) {
        marker.errorMessage = 'Todo not found';
        await marker.finish();
        throw ApiException('Todo not found', 404);
      } else {
        marker.errorMessage = 'HTTP ${response.statusCode}: ${response.body}';
        await marker.finish();
        throw ApiException(
          'Failed to load todo: ${response.body}',
          response.statusCode,
        );
      }
    } catch (e) {
      if (marker != null) {
        marker.errorMessage = e.toString();
        await marker.finish();
      }
      if (e is ApiException) rethrow;
      throw ApiException('Network error: ${e.toString()}');
    }
  }

  /// Create a new todo
  Future<Todo> createTodo(Todo todo) async {
    Marker? marker;
    
    try {
      final uri = Uri.parse(ApiConfig.todosUrl);
      final body = json.encode(todo.toJson());
      
      // Start Instana HTTP capture
      marker = await InstanaAgent.startCapture(
        url: uri.toString(),
        method: 'POST',
        viewName: 'CreateTodo',
      );
      
      final response = await _client
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: body,
          )
          .timeout(ApiConfig.connectionTimeout);

      // Set response details on marker
      marker.responseStatusCode = response.statusCode;
      marker.responseSizeBody = response.bodyBytes.length;
      marker.responseSizeBodyDecoded = response.contentLength;
      
      // Extract backend tracing ID for correlation
      marker.backendTracingID = BackendTracingIDParser.fromHeadersMap(
        response.headers.map((key, value) => MapEntry(key, value))
      );

      if (response.statusCode == 201) {
        await marker.finish();
        return Todo.fromJson(json.decode(response.body));
      } else {
        marker.errorMessage = 'HTTP ${response.statusCode}: ${response.body}';
        await marker.finish();
        throw ApiException(
          'Failed to create todo: ${response.body}',
          response.statusCode,
        );
      }
    } catch (e) {
      if (marker != null) {
        marker.errorMessage = e.toString();
        await marker.finish();
      }
      if (e is ApiException) rethrow;
      throw ApiException('Network error: ${e.toString()}');
    }
  }

  /// Update an existing todo
  Future<Todo> updateTodo(String id, Todo todo) async {
    Marker? marker;
    
    try {
      final uri = Uri.parse(ApiConfig.todoUrl(id));
      final body = json.encode(todo.toJson());
      
      // Start Instana HTTP capture
      marker = await InstanaAgent.startCapture(
        url: uri.toString(),
        method: 'PUT',
        viewName: 'UpdateTodo',
      );
      
      final response = await _client
          .put(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: body,
          )
          .timeout(ApiConfig.connectionTimeout);

      // Set response details on marker
      marker.responseStatusCode = response.statusCode;
      marker.responseSizeBody = response.bodyBytes.length;
      marker.responseSizeBodyDecoded = response.contentLength;
      
      // Extract backend tracing ID for correlation
      marker.backendTracingID = BackendTracingIDParser.fromHeadersMap(
        response.headers.map((key, value) => MapEntry(key, value))
      );

      if (response.statusCode == 200) {
        await marker.finish();
        return Todo.fromJson(json.decode(response.body));
      } else if (response.statusCode == 404) {
        marker.errorMessage = 'Todo not found';
        await marker.finish();
        throw ApiException('Todo not found', 404);
      } else {
        marker.errorMessage = 'HTTP ${response.statusCode}: ${response.body}';
        await marker.finish();
        throw ApiException(
          'Failed to update todo: ${response.body}',
          response.statusCode,
        );
      }
    } catch (e) {
      if (marker != null) {
        marker.errorMessage = e.toString();
        await marker.finish();
      }
      if (e is ApiException) rethrow;
      throw ApiException('Network error: ${e.toString()}');
    }
  }

  /// Toggle todo completion status
  Future<Todo> toggleTodo(String id) async {
    Marker? marker;
    
    try {
      final uri = Uri.parse(ApiConfig.toggleTodoUrl(id));
      
      // Start Instana HTTP capture
      marker = await InstanaAgent.startCapture(
        url: uri.toString(),
        method: 'PATCH',
        viewName: 'ToggleTodo',
      );
      
      final response = await _client
          .patch(uri)
          .timeout(ApiConfig.connectionTimeout);

      // Set response details on marker
      marker.responseStatusCode = response.statusCode;
      marker.responseSizeBody = response.bodyBytes.length;
      marker.responseSizeBodyDecoded = response.contentLength;
      
      // Extract backend tracing ID for correlation
      marker.backendTracingID = BackendTracingIDParser.fromHeadersMap(
        response.headers.map((key, value) => MapEntry(key, value))
      );

      if (response.statusCode == 200) {
        await marker.finish();
        return Todo.fromJson(json.decode(response.body));
      } else if (response.statusCode == 404) {
        marker.errorMessage = 'Todo not found';
        await marker.finish();
        throw ApiException('Todo not found', 404);
      } else {
        marker.errorMessage = 'HTTP ${response.statusCode}: ${response.body}';
        await marker.finish();
        throw ApiException(
          'Failed to toggle todo: ${response.body}',
          response.statusCode,
        );
      }
    } catch (e) {
      if (marker != null) {
        marker.errorMessage = e.toString();
        await marker.finish();
      }
      if (e is ApiException) rethrow;
      throw ApiException('Network error: ${e.toString()}');
    }
  }

  /// Delete a todo
  Future<void> deleteTodo(String id) async {
    Marker? marker;
    
    try {
      final uri = Uri.parse(ApiConfig.todoUrl(id));
      
      // Start Instana HTTP capture
      marker = await InstanaAgent.startCapture(
        url: uri.toString(),
        method: 'DELETE',
        viewName: 'DeleteTodo',
      );
      
      final response = await _client
          .delete(uri)
          .timeout(ApiConfig.connectionTimeout);

      // Set response details on marker
      marker.responseStatusCode = response.statusCode;
      marker.responseSizeBody = response.bodyBytes.length;
      marker.responseSizeBodyDecoded = response.contentLength;
      
      // Extract backend tracing ID for correlation
      marker.backendTracingID = BackendTracingIDParser.fromHeadersMap(
        response.headers.map((key, value) => MapEntry(key, value))
      );

      if (response.statusCode == 200) {
        await marker.finish();
        return;
      } else if (response.statusCode == 404) {
        marker.errorMessage = 'Todo not found';
        await marker.finish();
        throw ApiException('Todo not found', 404);
      } else {
        marker.errorMessage = 'HTTP ${response.statusCode}: ${response.body}';
        await marker.finish();
        throw ApiException(
          'Failed to delete todo: ${response.body}',
          response.statusCode,
        );
      }
    } catch (e) {
      if (marker != null) {
        marker.errorMessage = e.toString();
        await marker.finish();
      }
      if (e is ApiException) rethrow;
      throw ApiException('Network error: ${e.toString()}');
    }
  }

  /// Delete all completed todos
  Future<String> deleteCompletedTodos() async {
    Marker? marker;
    
    try {
      final uri = Uri.parse(ApiConfig.todosUrl);
      
      // Start Instana HTTP capture
      marker = await InstanaAgent.startCapture(
        url: uri.toString(),
        method: 'DELETE',
        viewName: 'DeleteCompletedTodos',
      );
      
      final response = await _client
          .delete(uri)
          .timeout(ApiConfig.connectionTimeout);

      // Set response details on marker
      marker.responseStatusCode = response.statusCode;
      marker.responseSizeBody = response.bodyBytes.length;
      marker.responseSizeBodyDecoded = response.contentLength;
      
      // Extract backend tracing ID for correlation
      marker.backendTracingID = BackendTracingIDParser.fromHeadersMap(
        response.headers.map((key, value) => MapEntry(key, value))
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        await marker.finish();
        return data['message'] ?? 'Completed todos deleted';
      } else {
        marker.errorMessage = 'HTTP ${response.statusCode}: ${response.body}';
        await marker.finish();
        throw ApiException(
          'Failed to delete completed todos: ${response.body}',
          response.statusCode,
        );
      }
    } catch (e) {
      if (marker != null) {
        marker.errorMessage = e.toString();
        await marker.finish();
      }
      if (e is ApiException) rethrow;
      throw ApiException('Network error: ${e.toString()}');
    }
  }

  /// Get todo statistics
  Future<Map<String, dynamic>> getStatistics() async {
    Marker? marker;
    
    try {
      final uri = Uri.parse(ApiConfig.statisticsUrl);
      
      // Start Instana HTTP capture
      marker = await InstanaAgent.startCapture(
        url: uri.toString(),
        method: 'GET',
        viewName: 'Statistics',
      );
      
      final response = await _client
          .get(uri)
          .timeout(ApiConfig.connectionTimeout);

      // Set response details on marker
      marker.responseStatusCode = response.statusCode;
      marker.responseSizeBody = response.bodyBytes.length;
      marker.responseSizeBodyDecoded = response.contentLength;
      
      // Extract backend tracing ID for correlation
      marker.backendTracingID = BackendTracingIDParser.fromHeadersMap(
        response.headers.map((key, value) => MapEntry(key, value))
      );

      if (response.statusCode == 200) {
        await marker.finish();
        return json.decode(response.body);
      } else {
        marker.errorMessage = 'HTTP ${response.statusCode}: ${response.body}';
        await marker.finish();
        throw ApiException(
          'Failed to load statistics: ${response.body}',
          response.statusCode,
        );
      }
    } catch (e) {
      if (marker != null) {
        marker.errorMessage = e.toString();
        await marker.finish();
      }
      if (e is ApiException) rethrow;
      throw ApiException('Network error: ${e.toString()}');
    }
  }

  /// Check API health
  Future<bool> checkHealth() async {
    Marker? marker;
    
    try {
      final uri = Uri.parse(ApiConfig.healthUrl);
      
      // Start Instana HTTP capture
      marker = await InstanaAgent.startCapture(
        url: uri.toString(),
        method: 'GET',
        viewName: 'HealthCheck',
      );
      
      final response = await _client
          .get(uri)
          .timeout(ApiConfig.connectionTimeout);

      // Set response details on marker
      marker.responseStatusCode = response.statusCode;
      marker.responseSizeBody = response.bodyBytes.length;
      marker.responseSizeBodyDecoded = response.contentLength;
      
      // Extract backend tracing ID for correlation
      marker.backendTracingID = BackendTracingIDParser.fromHeadersMap(
        response.headers.map((key, value) => MapEntry(key, value))
      );
      
      await marker.finish();
      return response.statusCode == 200;
    } catch (e) {
      if (marker != null) {
        marker.errorMessage = e.toString();
        await marker.finish();
      }
      return false;
    }
  }

  /// Dispose the HTTP client
  void dispose() {
    _client.close();
  }
}

// Made with Bob
