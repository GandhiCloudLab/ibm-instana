import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/todo_provider.dart';
import '../providers/theme_provider.dart';
import '../models/todo.dart';
import '../widgets/todo_item.dart';
import '../widgets/add_edit_todo_dialog.dart';
import '../services/instana_service.dart';
import 'statistics_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    // Track home screen view
    InstanaService.trackView('Home Screen');
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search todos...',
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  context.read<TodoProvider>().setSearchQuery(value);
                },
              )
            : const Text('Todo List'),
        actions: [
          if (_isSearching)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                setState(() {
                  _isSearching = false;
                  _searchController.clear();
                  context.read<TodoProvider>().setSearchQuery('');
                });
              },
            )
          else
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                setState(() => _isSearching = true);
              },
            ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      drawer: _buildDrawer(),
      body: Consumer<TodoProvider>(
        builder: (context, todoProvider, child) {
          final todos = todoProvider.todos;

          if (todos.isEmpty) {
            return _buildEmptyState(todoProvider);
          }

          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Theme.of(context).colorScheme.surface,
                  Theme.of(context).colorScheme.background,
                ],
              ),
            ),
            child: Column(
            children: [
              // Active filters indicator
              if (_hasActiveFilters(todoProvider))
                _buildActiveFiltersBar(todoProvider),

              // Todo list
              Expanded(
                child: ListView.builder(
                  itemCount: todos.length,
                  itemBuilder: (context, index) {
                    final todo = todos[index];
                    return TodoItem(
                      todo: todo,
                      onToggle: () => todoProvider.toggleTodo(todo.id),
                      onDelete: () => todoProvider.deleteTodo(todo.id),
                      onEdit: () => _showAddEditDialog(todo),
                    );
                  },
                ),
              ),
            ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEditDialog(null),
        icon: const Icon(Icons.add),
        label: const Text('Add Todo'),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return DrawerHeader(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(
                      themeProvider.isDarkMode
                          ? Icons.dark_mode
                          : Icons.light_mode,
                      size: 48,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Todo App',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Consumer<TodoProvider>(
                      builder: (context, provider, child) {
                        return Text(
                          '${provider.activeTodos} active tasks',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.bar_chart),
            title: const Text('Statistics'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const StatisticsScreen(),
                ),
              );
            },
          ),
          const Divider(),
          _buildCategorySection(),
          const Divider(),
          _buildPrioritySection(),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection() {
    return Consumer<TodoProvider>(
      builder: (context, provider, child) {
        return ExpansionTile(
          leading: const Icon(Icons.category),
          title: const Text('Categories'),
          children: Category.values.map((category) {
            final count = provider.getTodosByCategory(category).length;
            return ListTile(
              leading: Text(category.icon),
              title: Text(category.displayName),
              trailing: Text('$count'),
              onTap: () {
                Navigator.pop(context);
                provider.setFilterCategory(category);
              },
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildPrioritySection() {
    return Consumer<TodoProvider>(
      builder: (context, provider, child) {
        return ExpansionTile(
          leading: const Icon(Icons.flag),
          title: const Text('Priority'),
          children: Priority.values.map((priority) {
            final count = provider.getTodosByPriority(priority).length;
            return ListTile(
              leading: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: Color(priority.colorValue),
                  shape: BoxShape.circle,
                ),
              ),
              title: Text(priority.displayName),
              trailing: Text('$count'),
              onTap: () {
                Navigator.pop(context);
                provider.setFilterPriority(priority);
              },
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildEmptyState(TodoProvider provider) {
    final hasFilters = _hasActiveFilters(provider);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            hasFilters ? Icons.search_off : Icons.check_circle_outline,
            size: 80,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            hasFilters ? 'No todos match your filters' : 'No todos yet!',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            hasFilters
                ? 'Try adjusting your filters'
                : 'Tap the + button to add your first todo',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          if (hasFilters) ...[
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => provider.clearFilters(),
              icon: const Icon(Icons.clear_all),
              label: const Text('Clear Filters'),
            ),
          ],
        ],
      ),
    );
  }

  bool _hasActiveFilters(TodoProvider provider) {
    return provider.searchQuery.isNotEmpty ||
        provider.filterPriority != null ||
        provider.filterCategory != null ||
        provider.showCompletedOnly ||
        provider.showActiveOnly;
  }

  Widget _buildActiveFiltersBar(TodoProvider provider) {
    return Container(
      padding: const EdgeInsets.all(8),
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Row(
        children: [
          const Icon(Icons.filter_list, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                if (provider.searchQuery.isNotEmpty)
                  _buildFilterChip(
                    'Search: "${provider.searchQuery}"',
                    () => provider.setSearchQuery(''),
                  ),
                if (provider.filterCategory != null)
                  _buildFilterChip(
                    provider.filterCategory!.displayName,
                    () => provider.setFilterCategory(null),
                  ),
                if (provider.filterPriority != null)
                  _buildFilterChip(
                    provider.filterPriority!.displayName,
                    () => provider.setFilterPriority(null),
                  ),
                if (provider.showCompletedOnly)
                  _buildFilterChip(
                    'Completed',
                    () => provider.setShowCompletedOnly(false),
                  ),
                if (provider.showActiveOnly)
                  _buildFilterChip(
                    'Active',
                    () => provider.setShowActiveOnly(false),
                  ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => provider.clearFilters(),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, VoidCallback onDelete) {
    return Chip(
      label: Text(label),
      onDeleted: onDelete,
      deleteIcon: const Icon(Icons.close, size: 16),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Todos'),
        content: Consumer<TodoProvider>(
          builder: (context, provider, child) {
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Status',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  CheckboxListTile(
                    title: const Text('Show Active Only'),
                    value: provider.showActiveOnly,
                    onChanged: (value) {
                      provider.setShowActiveOnly(value ?? false);
                    },
                  ),
                  CheckboxListTile(
                    title: const Text('Show Completed Only'),
                    value: provider.showCompletedOnly,
                    onChanged: (value) {
                      provider.setShowCompletedOnly(value ?? false);
                    },
                  ),
                  const Divider(),
                  const Text(
                    'Category',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  ...Category.values.map((category) {
                    return RadioListTile<Category?>(
                      title: Row(
                        children: [
                          Text(category.icon),
                          const SizedBox(width: 8),
                          Text(category.displayName),
                        ],
                      ),
                      value: category,
                      groupValue: provider.filterCategory,
                      onChanged: (value) {
                        provider.setFilterCategory(value);
                      },
                    );
                  }),
                  RadioListTile<Category?>(
                    title: const Text('All Categories'),
                    value: null,
                    groupValue: provider.filterCategory,
                    onChanged: (value) {
                      provider.setFilterCategory(null);
                    },
                  ),
                  const Divider(),
                  const Text(
                    'Priority',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  ...Priority.values.map((priority) {
                    return RadioListTile<Priority?>(
                      title: Row(
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
                      value: priority,
                      groupValue: provider.filterPriority,
                      onChanged: (value) {
                        provider.setFilterPriority(value);
                      },
                    );
                  }),
                  RadioListTile<Priority?>(
                    title: const Text('All Priorities'),
                    value: null,
                    groupValue: provider.filterPriority,
                    onChanged: (value) {
                      provider.setFilterPriority(null);
                    },
                  ),
                ],
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              context.read<TodoProvider>().clearFilters();
              Navigator.pop(context);
            },
            child: const Text('Clear All'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddEditDialog(Todo? todo) async {
    final result = await showDialog<Todo>(
      context: context,
      builder: (context) => AddEditTodoDialog(todo: todo),
    );

    if (result != null && mounted) {
      final provider = context.read<TodoProvider>();
      if (todo == null) {
        await provider.addTodo(result);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Todo added')),
          );
        }
      } else {
        await provider.updateTodo(todo.id, result);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Todo updated')),
          );
        }
      }
    }
  }
}
