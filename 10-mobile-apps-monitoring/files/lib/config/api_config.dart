/// API Configuration for Todo Backend
class ApiConfig {
  // Base URL for the API server
  static const String baseUrl = 'http://xx.yy.zz.aa:8000';
  
  // API endpoints
  static const String todosEndpoint = '/api/todos';
  static const String statisticsEndpoint = '/api/todos/statistics';
  static const String healthEndpoint = '/health';
  
  // Timeout durations
  static const Duration connectionTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 10);
  
  // Helper methods to build full URLs
  static String get todosUrl => '$baseUrl$todosEndpoint';
  static String get statisticsUrl => '$baseUrl$statisticsEndpoint';
  static String get healthUrl => '$baseUrl$healthEndpoint';
  
  static String todoUrl(String id) => '$baseUrl$todosEndpoint/$id';
  static String toggleTodoUrl(String id) => '$baseUrl$todosEndpoint/$id/toggle';
}

// Made with Bob
