import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/todo.dart';

class TodoItem extends StatelessWidget {
  final Todo todo;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const TodoItem({
    super.key,
    required this.todo,
    required this.onToggle,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(todo.id),
      background: _buildSwipeBackground(Colors.green, Icons.check, Alignment.centerLeft),
      secondaryBackground: _buildSwipeBackground(Colors.red, Icons.delete, Alignment.centerRight),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          onToggle();
          return false;
        } else {
          return await _showDeleteConfirmation(context);
        }
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        elevation: 3,
        shadowColor: Color(todo.priority.colorValue).withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: Color(todo.priority.colorValue).withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                Color(todo.priority.colorValue).withOpacity(0.02),
              ],
            ),
          ),
          child: InkWell(
            onTap: onEdit,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Checkbox
                Checkbox(
                  value: todo.isCompleted,
                  onChanged: (_) => onToggle(),
                ),
                const SizedBox(width: 12),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title with priority indicator
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: Color(todo.priority.colorValue),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              todo.title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                decoration: todo.isCompleted
                                    ? TextDecoration.lineThrough
                                    : null,
                                color: todo.isCompleted
                                    ? Colors.grey
                                    : null,
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Description
                      if (todo.description.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          todo.description,
                          style: TextStyle(
                            fontSize: 14,
                            color: todo.isCompleted
                                ? Colors.grey
                                : Colors.grey[600],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],

                      // Category and Due Date
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          // Category chip
                          _buildChip(
                            '${todo.category.icon} ${todo.category.displayName}',
                            Colors.blue,
                          ),

                          // Due date chip
                          if (todo.dueDate != null)
                            _buildChip(
                              '📅 ${DateFormat('MMM dd').format(todo.dueDate!)}',
                              todo.isOverdue
                                  ? Colors.red
                                  : todo.isDueToday
                                      ? Colors.orange
                                      : Colors.grey,
                            ),

                          // Tags
                          ...todo.tags.map((tag) => _buildChip(
                                '#$tag',
                                Colors.purple,
                              )),
                        ],
                      ),
                    ],
                  ),
                ),

                // Actions
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        onEdit();
                        break;
                      case 'delete':
                        _confirmDelete(context);
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          ),
        ),
      ),
    );
  }

  Widget _buildSwipeBackground(Color color, IconData icon, Alignment alignment) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Icon(icon, color: Colors.white, size: 32),
    );
  }

  Widget _buildChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Future<bool> _showDeleteConfirmation(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Todo'),
            content: const Text('Are you sure you want to delete this todo?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _confirmDelete(BuildContext context) async {
    final confirmed = await _showDeleteConfirmation(context);
    if (confirmed) {
      onDelete();
    }
  }
}

// Made with Bob
