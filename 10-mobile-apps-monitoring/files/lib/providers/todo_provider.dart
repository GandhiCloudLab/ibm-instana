import 'package:flutter/material.dart';
import '../models/todo.dart';
import '../services/instana_service.dart';
import '../services/api_service.dart';

class TodoProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<Todo> _todos = [];
  String _searchQuery = '';
  Priority? _filterPriority;
  Category? _filterCategory;
  bool _showCompletedOnly = false;
  bool _showActiveOnly = false;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<Todo> get todos => _todos;
  List<Todo> get allTodos => _todos;
  String get searchQuery => _searchQuery;
  Priority? get filterPriority => _filterPriority;
  Category? get filterCategory => _filterCategory;
  bool get showCompletedOnly => _showCompletedOnly;
  bool get showActiveOnly => _showActiveOnly;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  int get totalTodos => _todos.length;
  int get completedTodos => _todos.where((todo) => todo.isCompleted).length;
  int get activeTodos => _todos.where((todo) => !todo.isCompleted).length;
  int get overdueTodos => _todos.where((todo) => todo.isOverdue).length;
  int get dueTodayTodos => _todos.where((todo) => todo.isDueToday).length;

  // Load todos from API
  Future<void> loadTodos() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _todos = await _apiService.getTodos(
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
        priority: _filterPriority,
        category: _filterCategory,
        completed: _showCompletedOnly
            ? true
            : _showActiveOnly
                ? false
                : null,
      );
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to load todos: ${e.toString()}';
      debugPrint(_errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add a new todo
  Future<void> addTodo(Todo todo) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final createdTodo = await _apiService.createTodo(todo);
      _todos.add(createdTodo);
      _errorMessage = null;

      // Track todo creation
      InstanaService.trackUserAction('todo_created', details: {
        'priority': todo.priority.toString(),
        'category': todo.category.toString(),
        'has_due_date': todo.dueDate != null,
        'tags_count': todo.tags.length,
      });
    } catch (e) {
      _errorMessage = 'Failed to create todo: ${e.toString()}';
      debugPrint(_errorMessage);
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update an existing todo
  Future<void> updateTodo(String id, Todo updatedTodo) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updated = await _apiService.updateTodo(id, updatedTodo);
      final index = _todos.indexWhere((todo) => todo.id == id);
      if (index != -1) {
        _todos[index] = updated;
      }
      _errorMessage = null;

      // Track todo update
      InstanaService.trackUserAction('todo_updated', details: {
        'priority': updatedTodo.priority.toString(),
        'category': updatedTodo.category.toString(),
      });
    } catch (e) {
      _errorMessage = 'Failed to update todo: ${e.toString()}';
      debugPrint(_errorMessage);
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete a todo
  Future<void> deleteTodo(String id) async {
    _isLoading = true;
    _errorMessage = null;
    
    // Store todo info for tracking before deletion
    final todo = _todos.firstWhere((t) => t.id == id, orElse: () => _todos.first);
    notifyListeners();

    try {
      await _apiService.deleteTodo(id);
      _todos.removeWhere((todo) => todo.id == id);
      _errorMessage = null;

      // Track todo deletion
      InstanaService.trackUserAction('todo_deleted', details: {
        'was_completed': todo.isCompleted,
      });
    } catch (e) {
      _errorMessage = 'Failed to delete todo: ${e.toString()}';
      debugPrint(_errorMessage);
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Toggle todo completion
  Future<void> toggleTodo(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final toggled = await _apiService.toggleTodo(id);
      final index = _todos.indexWhere((todo) => todo.id == id);
      if (index != -1) {
        _todos[index] = toggled;
      }
      _errorMessage = null;

      // Track completion toggle
      InstanaService.trackUserAction(
        toggled.isCompleted ? 'todo_completed' : 'todo_uncompleted',
        details: {
          'priority': toggled.priority.toString(),
          'category': toggled.category.toString(),
        },
      );
    } catch (e) {
      _errorMessage = 'Failed to toggle todo: ${e.toString()}';
      debugPrint(_errorMessage);
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Search todos
  void setSearchQuery(String query) {
    _searchQuery = query;
    loadTodos(); // Reload with new search query
  }

  // Filter by priority
  void setFilterPriority(Priority? priority) {
    _filterPriority = priority;
    loadTodos(); // Reload with new filter
  }

  // Filter by category
  void setFilterCategory(Category? category) {
    _filterCategory = category;
    loadTodos(); // Reload with new filter
  }

  // Toggle completed filter
  void setShowCompletedOnly(bool value) {
    _showCompletedOnly = value;
    if (value) _showActiveOnly = false;
    loadTodos(); // Reload with new filter
  }

  // Toggle active filter
  void setShowActiveOnly(bool value) {
    _showActiveOnly = value;
    if (value) _showCompletedOnly = false;
    loadTodos(); // Reload with new filter
  }

  // Clear all filters
  void clearFilters() {
    _searchQuery = '';
    _filterPriority = null;
    _filterCategory = null;
    _showCompletedOnly = false;
    _showActiveOnly = false;
    loadTodos(); // Reload without filters
  }

  // Delete all completed todos
  Future<void> deleteCompletedTodos() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _apiService.deleteCompletedTodos();
      _todos.removeWhere((todo) => todo.isCompleted);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to delete completed todos: ${e.toString()}';
      debugPrint(_errorMessage);
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get todos by category
  List<Todo> getTodosByCategory(Category category) {
    return _todos.where((todo) => todo.category == category).toList();
  }

  // Get todos by priority
  List<Todo> getTodosByPriority(Priority priority) {
    return _todos.where((todo) => todo.priority == priority).toList();
  }

  // Get overdue todos
  List<Todo> getOverdueTodos() {
    return _todos.where((todo) => todo.isOverdue).toList();
  }

  // Get today's todos
  List<Todo> getTodayTodos() {
    return _todos.where((todo) => todo.isDueToday).toList();
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _apiService.dispose();
    super.dispose();
  }
}

// Made with Bob
