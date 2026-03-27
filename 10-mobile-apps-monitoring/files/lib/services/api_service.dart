import 'dart:convert';
import 'package:http/http.dart' as http;
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

/// Service class for handling all API requests
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
    try {
      // Build query parameters
      final queryParams = <String, String>{};
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (priority != null) queryParams['priority'] = priority.index.toString();
      if (category != null) queryParams['category'] = category.index.toString();
      if (completed != null) queryParams['completed'] = completed.toString();

      final uri = Uri.parse(ApiConfig.todosUrl).replace(queryParameters: queryParams);
      
      final response = await _client
          .get(uri)
          .timeout(ApiConfig.connectionTimeout);

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => Todo.fromJson(json)).toList();
      } else {
        throw ApiException(
          'Failed to load todos: ${response.body}',
          response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: ${e.toString()}');
    }
  }

  /// Get a specific todo by ID
  Future<Todo> getTodo(String id) async {
    try {
      final response = await _client
          .get(Uri.parse(ApiConfig.todoUrl(id)))
          .timeout(ApiConfig.connectionTimeout);

      if (response.statusCode == 200) {
        return Todo.fromJson(json.decode(response.body));
      } else if (response.statusCode == 404) {
        throw ApiException('Todo not found', 404);
      } else {
        throw ApiException(
          'Failed to load todo: ${response.body}',
          response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: ${e.toString()}');
    }
  }

  /// Create a new todo
  Future<Todo> createTodo(Todo todo) async {
    try {
      final response = await _client
          .post(
            Uri.parse(ApiConfig.todosUrl),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(todo.toJson()),
          )
          .timeout(ApiConfig.connectionTimeout);

      if (response.statusCode == 201) {
        return Todo.fromJson(json.decode(response.body));
      } else {
        throw ApiException(
          'Failed to create todo: ${response.body}',
          response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: ${e.toString()}');
    }
  }

  /// Update an existing todo
  Future<Todo> updateTodo(String id, Todo todo) async {
    try {
      final response = await _client
          .put(
            Uri.parse(ApiConfig.todoUrl(id)),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(todo.toJson()),
          )
          .timeout(ApiConfig.connectionTimeout);

      if (response.statusCode == 200) {
        return Todo.fromJson(json.decode(response.body));
      } else if (response.statusCode == 404) {
        throw ApiException('Todo not found', 404);
      } else {
        throw ApiException(
          'Failed to update todo: ${response.body}',
          response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: ${e.toString()}');
    }
  }

  /// Toggle todo completion status
  Future<Todo> toggleTodo(String id) async {
    try {
      final response = await _client
          .patch(Uri.parse(ApiConfig.toggleTodoUrl(id)))
          .timeout(ApiConfig.connectionTimeout);

      if (response.statusCode == 200) {
        return Todo.fromJson(json.decode(response.body));
      } else if (response.statusCode == 404) {
        throw ApiException('Todo not found', 404);
      } else {
        throw ApiException(
          'Failed to toggle todo: ${response.body}',
          response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: ${e.toString()}');
    }
  }

  /// Delete a todo
  Future<void> deleteTodo(String id) async {
    try {
      final response = await _client
          .delete(Uri.parse(ApiConfig.todoUrl(id)))
          .timeout(ApiConfig.connectionTimeout);

      if (response.statusCode == 200) {
        return;
      } else if (response.statusCode == 404) {
        throw ApiException('Todo not found', 404);
      } else {
        throw ApiException(
          'Failed to delete todo: ${response.body}',
          response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: ${e.toString()}');
    }
  }

  /// Delete all completed todos
  Future<String> deleteCompletedTodos() async {
    try {
      final response = await _client
          .delete(Uri.parse(ApiConfig.todosUrl))
          .timeout(ApiConfig.connectionTimeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['message'] ?? 'Completed todos deleted';
      } else {
        throw ApiException(
          'Failed to delete completed todos: ${response.body}',
          response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: ${e.toString()}');
    }
  }

  /// Get todo statistics
  Future<Map<String, dynamic>> getStatistics() async {
    try {
      final response = await _client
          .get(Uri.parse(ApiConfig.statisticsUrl))
          .timeout(ApiConfig.connectionTimeout);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw ApiException(
          'Failed to load statistics: ${response.body}',
          response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: ${e.toString()}');
    }
  }

  /// Check API health
  Future<bool> checkHealth() async {
    try {
      final response = await _client
          .get(Uri.parse(ApiConfig.healthUrl))
          .timeout(ApiConfig.connectionTimeout);

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Dispose the HTTP client
  void dispose() {
    _client.close();
  }
}

// Made with Bob
