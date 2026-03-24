import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/todo.dart';

class AddEditTodoDialog extends StatefulWidget {
  final Todo? todo;

  const AddEditTodoDialog({super.key, this.todo});

  @override
  State<AddEditTodoDialog> createState() => _AddEditTodoDialogState();
}

class _AddEditTodoDialogState extends State<AddEditTodoDialog> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _tagController;
  late Priority _selectedPriority;
  late Category _selectedCategory;
  DateTime? _selectedDueDate;
  List<String> _tags = [];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.todo?.title ?? '');
    _descriptionController = TextEditingController(text: widget.todo?.description ?? '');
    _tagController = TextEditingController();
    _selectedPriority = widget.todo?.priority ?? Priority.medium;
    _selectedCategory = widget.todo?.category ?? Category.personal;
    _selectedDueDate = widget.todo?.dueDate;
    _tags = List.from(widget.todo?.tags ?? []);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.todo != null;

    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  isEditing ? 'Edit Todo' : 'Add New Todo',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),

                // Title Field
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title *',
                    hintText: 'Enter todo title',
                    prefixIcon: Icon(Icons.title),
                  ),
                  autofocus: !isEditing,
                ),
                const SizedBox(height: 16),

                // Description Field
                TextField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'Enter description (optional)',
                    prefixIcon: Icon(Icons.description),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),

                // Category Dropdown
                DropdownButtonFormField<Category>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    prefixIcon: Icon(Icons.category),
                  ),
                  items: Category.values.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Row(
                        children: [
                          Text(category.icon),
                          const SizedBox(width: 8),
                          Text(category.displayName),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedCategory = value);
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Priority Dropdown
                DropdownButtonFormField<Priority>(
                  value: _selectedPriority,
                  decoration: const InputDecoration(
                    labelText: 'Priority',
                    prefixIcon: Icon(Icons.flag),
                  ),
                  items: Priority.values.map((priority) {
                    return DropdownMenuItem(
                      value: priority,
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: Color(priority.colorValue),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(priority.displayName),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedPriority = value);
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Due Date Picker
                InkWell(
                  onTap: _selectDueDate,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Due Date',
                      prefixIcon: Icon(Icons.calendar_today),
                      suffixIcon: Icon(Icons.arrow_drop_down),
                    ),
                    child: Text(
                      _selectedDueDate != null
                          ? DateFormat('MMM dd, yyyy').format(_selectedDueDate!)
                          : 'No due date',
                    ),
                  ),
                ),
                if (_selectedDueDate != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: TextButton.icon(
                      onPressed: () {
                        setState(() => _selectedDueDate = null);
                      },
                      icon: const Icon(Icons.clear),
                      label: const Text('Clear due date'),
                    ),
                  ),
                const SizedBox(height: 16),

                // Tags Section
                const Text(
                  'Tags',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ..._tags.map((tag) => Chip(
                          label: Text(tag),
                          onDeleted: () {
                            setState(() => _tags.remove(tag));
                          },
                        )),
                    ActionChip(
                      avatar: const Icon(Icons.add, size: 16),
                      label: const Text('Add Tag'),
                      onPressed: _showAddTagDialog,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _saveTodo,
                      child: Text(isEditing ? 'Update' : 'Add'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _selectDueDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );

    if (picked != null) {
      setState(() => _selectedDueDate = picked);
    }
  }

  void _showAddTagDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Tag'),
        content: TextField(
          controller: _tagController,
          decoration: const InputDecoration(
            hintText: 'Enter tag name',
          ),
          autofocus: true,
          onSubmitted: (value) {
            if (value.trim().isNotEmpty && !_tags.contains(value.trim())) {
              setState(() => _tags.add(value.trim()));
              _tagController.clear();
              Navigator.pop(context);
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              _tagController.clear();
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (_tagController.text.trim().isNotEmpty &&
                  !_tags.contains(_tagController.text.trim())) {
                setState(() => _tags.add(_tagController.text.trim()));
                _tagController.clear();
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _saveTodo() {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a title')),
      );
      return;
    }

    final todo = widget.todo?.copyWith(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          priority: _selectedPriority,
          category: _selectedCategory,
          dueDate: _selectedDueDate,
          tags: _tags,
        ) ??
        Todo(
          id: DateTime.now().toString(),
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          priority: _selectedPriority,
          category: _selectedCategory,
          dueDate: _selectedDueDate,
          tags: _tags,
        );

    Navigator.pop(context, todo);
  }
}

// Made with Bob
