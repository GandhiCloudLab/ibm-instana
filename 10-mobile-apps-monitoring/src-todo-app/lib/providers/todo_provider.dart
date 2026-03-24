import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/todo.dart';
import '../services/instana_service.dart';

class TodoProvider extends ChangeNotifier {
  List<Todo> _todos = [];
  String _searchQuery = '';
  Priority? _filterPriority;
  Category? _filterCategory;
  bool _showCompletedOnly = false;
  bool _showActiveOnly = false;

  List<Todo> get todos {
    List<Todo> filtered = List.from(_todos);

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((todo) {
        return todo.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            todo.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            todo.tags.any((tag) => tag.toLowerCase().contains(_searchQuery.toLowerCase()));
      }).toList();
    }

    // Apply priority filter
    if (_filterPriority != null) {
      filtered = filtered.where((todo) => todo.priority == _filterPriority).toList();
    }

    // Apply category filter
    if (_filterCategory != null) {
      filtered = filtered.where((todo) => todo.category == _filterCategory).toList();
    }

    // Apply completion status filter
    if (_showCompletedOnly) {
      filtered = filtered.where((todo) => todo.isCompleted).toList();
    } else if (_showActiveOnly) {
      filtered = filtered.where((todo) => !todo.isCompleted).toList();
    }

    return filtered;
  }

  List<Todo> get allTodos => _todos;
  String get searchQuery => _searchQuery;
  Priority? get filterPriority => _filterPriority;
  Category? get filterCategory => _filterCategory;
  bool get showCompletedOnly => _showCompletedOnly;
  bool get showActiveOnly => _showActiveOnly;

  int get totalTodos => _todos.length;
  int get completedTodos => _todos.where((todo) => todo.isCompleted).length;
  int get activeTodos => _todos.where((todo) => !todo.isCompleted).length;
  int get overdueTodos => _todos.where((todo) => todo.isOverdue).length;
  int get dueTodayTodos => _todos.where((todo) => todo.isDueToday).length;

  // Load todos from storage
  Future<void> loadTodos() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? todosJson = prefs.getString('todos');
      
      if (todosJson != null) {
        final List<dynamic> decoded = json.decode(todosJson);
        _todos = decoded.map((item) => Todo.fromJson(item)).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading todos: $e');
    }
  }

  // Save todos to storage
  Future<void> _saveTodos() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String encoded = json.encode(_todos.map((todo) => todo.toJson()).toList());
      await prefs.setString('todos', encoded);
    } catch (e) {
      debugPrint('Error saving todos: $e');
    }
  }

  // Add a new todo
  Future<void> addTodo(Todo todo) async {
    _todos.add(todo);
    notifyListeners();
    await _saveTodos();
    
    // Track todo creation
    InstanaService.trackUserAction('todo_created', details: {
      'priority': todo.priority.toString(),
      'category': todo.category.toString(),
      'has_due_date': todo.dueDate != null,
      'tags_count': todo.tags.length,
    });
  }

  // Update an existing todo
  Future<void> updateTodo(String id, Todo updatedTodo) async {
    final index = _todos.indexWhere((todo) => todo.id == id);
    if (index != -1) {
      _todos[index] = updatedTodo;
      notifyListeners();
      await _saveTodos();
      
      // Track todo update
      InstanaService.trackUserAction('todo_updated', details: {
        'priority': updatedTodo.priority.toString(),
        'category': updatedTodo.category.toString(),
      });
    }
  }

  // Delete a todo
  Future<void> deleteTodo(String id) async {
    final todo = _todos.firstWhere((t) => t.id == id, orElse: () => _todos.first);
    _todos.removeWhere((todo) => todo.id == id);
    notifyListeners();
    await _saveTodos();
    
    // Track todo deletion
    InstanaService.trackUserAction('todo_deleted', details: {
      'was_completed': todo.isCompleted,
    });
  }

  // Toggle todo completion
  Future<void> toggleTodo(String id) async {
    final index = _todos.indexWhere((todo) => todo.id == id);
    if (index != -1) {
      _todos[index].toggleCompleted();
      final isCompleted = _todos[index].isCompleted;
      notifyListeners();
      await _saveTodos();
      
      // Track completion toggle
      InstanaService.trackUserAction(
        isCompleted ? 'todo_completed' : 'todo_uncompleted',
        details: {
          'priority': _todos[index].priority.toString(),
          'category': _todos[index].category.toString(),
        },
      );
    }
  }

  // Search todos
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // Filter by priority
  void setFilterPriority(Priority? priority) {
    _filterPriority = priority;
    notifyListeners();
  }

  // Filter by category
  void setFilterCategory(Category? category) {
    _filterCategory = category;
    notifyListeners();
  }

  // Toggle completed filter
  void setShowCompletedOnly(bool value) {
    _showCompletedOnly = value;
    if (value) _showActiveOnly = false;
    notifyListeners();
  }

  // Toggle active filter
  void setShowActiveOnly(bool value) {
    _showActiveOnly = value;
    if (value) _showCompletedOnly = false;
    notifyListeners();
  }

  // Clear all filters
  void clearFilters() {
    _searchQuery = '';
    _filterPriority = null;
    _filterCategory = null;
    _showCompletedOnly = false;
    _showActiveOnly = false;
    notifyListeners();
  }

  // Delete all completed todos
  Future<void> deleteCompletedTodos() async {
    _todos.removeWhere((todo) => todo.isCompleted);
    notifyListeners();
    await _saveTodos();
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
}
