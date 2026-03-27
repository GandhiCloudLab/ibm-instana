/// Instana configuration for the Flutter Todo App
/// 
/// To use environment variables, run:
/// flutter run --dart-define=INSTANA_KEY=your_key --dart-define=INSTANA_URL=your_url
class InstanaConfig {
  /// Instana reporting key
  static const String key = 'xxxxxxxxxx';
  
  /// Instana backend reporting URL
  static const String reportingUrl = 'https://eum-orange-saas.instana.io/mobile';
  
  /// Enable crash reporting
  static const bool enableCrashReporting = true;
  
  /// Enable data collection
  static const bool collectionEnabled = true;
  
  /// Slow send interval in milliseconds
  static const int slowSendInterval = 5000;
  
  /// USI refresh time interval in hours
  static const int usiRefreshTimeIntervalInHrs = 24;
  
  /// App metadata
  static Map<String, String> get metadata => {
    'app_name': 'Flutter Todo App',
    'app_version': '2.0.0',
    'environment': const String.fromEnvironment('ENV', defaultValue: 'development'),
  };
  
  /// Check if Instana is properly configured
  static bool get isConfigured {
    return key != 'YOUR_INSTANA_KEY_HERE' && 
           reportingUrl != 'https://your-instana-backend.com';
  }
}

// Made with Bob
