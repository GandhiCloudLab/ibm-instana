import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/todo_provider.dart';
import '../services/instana_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    // Track settings screen view
    InstanaService.trackView('Settings Screen');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          _buildSection(
            context,
            'Appearance',
            [
              Consumer<ThemeProvider>(
                builder: (context, themeProvider, child) {
                  return SwitchListTile(
                    title: const Text('Dark Mode'),
                    subtitle: const Text('Enable dark theme'),
                    value: themeProvider.isDarkMode,
                    onChanged: (value) {
                      themeProvider.toggleTheme();
                    },
                    secondary: Icon(
                      themeProvider.isDarkMode
                          ? Icons.dark_mode
                          : Icons.light_mode,
                    ),
                  );
                },
              ),
            ],
          ),
          const Divider(),
          _buildSection(
            context,
            'Data Management',
            [
              ListTile(
                leading: const Icon(Icons.delete_sweep),
                title: const Text('Clear Completed Todos'),
                subtitle: const Text('Remove all completed tasks'),
                onTap: () => _showClearCompletedDialog(context),
              ),
              ListTile(
                leading: const Icon(Icons.delete_forever),
                title: const Text('Clear All Todos'),
                subtitle: const Text('Remove all tasks'),
                onTap: () => _showClearAllDialog(context),
              ),
            ],
          ),
          const Divider(),
          _buildSection(
            context,
            'About',
            [
              const ListTile(
                leading: Icon(Icons.info),
                title: Text('Version'),
                subtitle: Text('2.0.0'),
              ),
              const ListTile(
                leading: Icon(Icons.code),
                title: Text('Developer'),
                subtitle: Text('Flutter Todo App'),
              ),
              ListTile(
                leading: const Icon(Icons.description),
                title: const Text('Licenses'),
                onTap: () {
                  showLicensePage(
                    context: context,
                    applicationName: 'Todo App',
                    applicationVersion: '2.0.0',
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        ...children,
      ],
    );
  }

  void _showClearCompletedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Completed Todos'),
        content: const Text(
          'Are you sure you want to delete all completed todos? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<TodoProvider>().deleteCompletedTodos();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Completed todos cleared'),
                ),
              );
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showClearAllDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Todos'),
        content: const Text(
          'Are you sure you want to delete ALL todos? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final provider = context.read<TodoProvider>();
              final allTodos = List.from(provider.allTodos);
              for (var todo in allTodos) {
                provider.deleteTodo(todo.id);
              }
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All todos cleared'),
                ),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }
}

// Made with Bob
