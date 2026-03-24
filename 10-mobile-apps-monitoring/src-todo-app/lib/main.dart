import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:instana_agent/instana_agent.dart';
import 'providers/todo_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/home_screen.dart';
import 'config/instana_config.dart';
import '/services/instana_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Instana monitoring
  try {
    // Setup with basic configuration
    await InstanaAgent.setup(
      key: InstanaConfig.key,
      reportingUrl: InstanaConfig.reportingUrl,
    );

    // Set app metadata
    InstanaService.setMetadata('app_name', 'Flutter Todo App');
    InstanaService.setMetadata('app_version', '2.0.0');
    InstanaService.setMetadata('environment', 'development');

    print('✅ Instana monitoring initialized successfully');
  } catch (e) {
    print('⚠️ Instana initialization failed: $e');
    print('App will continue without monitoring');
  }
  
  runApp(const TodoApp());
}


class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TodoProvider()..loadTodos()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()..loadThemePreference()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Todo App',
            debugShowCheckedModeBanner: false,
            theme: themeProvider.themeData,
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}
