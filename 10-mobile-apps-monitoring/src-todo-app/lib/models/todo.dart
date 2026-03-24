import 'dart:convert';

enum Priority { low, medium, high }

enum Category { personal, work, shopping, health, other }

class Todo {
  final String id;
  String title;
  String description;
  bool isCompleted;
  Priority priority;
  Category category;
  DateTime? dueDate;
  DateTime createdAt;
  DateTime? completedAt;
  List<String> tags;

  Todo({
    required this.id,
    required this.title,
    this.description = '',
    this.isCompleted = false,
    this.priority = Priority.medium,
    this.category = Category.personal,
    this.dueDate,
    DateTime? createdAt,
    this.completedAt,
    List<String>? tags,
  })  : createdAt = createdAt ?? DateTime.now(),
        tags = tags ?? [];

  void toggleCompleted() {
    isCompleted = !isCompleted;
    completedAt = isCompleted ? DateTime.now() : null;
  }

  bool get isOverdue {
    if (dueDate == null || isCompleted) return false;
    return DateTime.now().isAfter(dueDate!);
  }

  bool get isDueToday {
    if (dueDate == null) return false;
    final now = DateTime.now();
    return dueDate!.year == now.year &&
        dueDate!.month == now.month &&
        dueDate!.day == now.day;
  }

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
      'priority': priority.index,
      'category': category.index,
      'dueDate': dueDate?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'tags': tags,
    };
  }

  // Create from JSON
  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'],
      title: json['title'],
      description: json['description'] ?? '',
      isCompleted: json['isCompleted'] ?? false,
      priority: Priority.values[json['priority'] ?? 1],
      category: Category.values[json['category'] ?? 0],
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      createdAt: DateTime.parse(json['createdAt']),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
      tags: List<String>.from(json['tags'] ?? []),
    );
  }

  // Copy with method for updates
  Todo copyWith({
    String? title,
    String? description,
    bool? isCompleted,
    Priority? priority,
    Category? category,
    DateTime? dueDate,
    List<String>? tags,
  }) {
    return Todo(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      priority: priority ?? this.priority,
      category: category ?? this.category,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt,
      completedAt: completedAt,
      tags: tags ?? this.tags,
    );
  }
}

// Extension methods for Priority
extension PriorityExtension on Priority {
  String get displayName {
    switch (this) {
      case Priority.low:
        return 'Low';
      case Priority.medium:
        return 'Medium';
      case Priority.high:
        return 'High';
    }
  }

  int get colorValue {
    switch (this) {
      case Priority.low:
        return 0xFF4CAF50; // Green
      case Priority.medium:
        return 0xFFFF9800; // Orange
      case Priority.high:
        return 0xFFF44336; // Red
    }
  }
}

// Extension methods for Category
extension CategoryExtension on Category {
  String get displayName {
    switch (this) {
      case Category.personal:
        return 'Personal';
      case Category.work:
        return 'Work';
      case Category.shopping:
        return 'Shopping';
      case Category.health:
        return 'Health';
      case Category.other:
        return 'Other';
    }
  }

  String get icon {
    switch (this) {
      case Category.personal:
        return '👤';
      case Category.work:
        return '💼';
      case Category.shopping:
        return '🛒';
      case Category.health:
        return '❤️';
      case Category.other:
        return '📌';
    }
  }
}

// Made with Bob
