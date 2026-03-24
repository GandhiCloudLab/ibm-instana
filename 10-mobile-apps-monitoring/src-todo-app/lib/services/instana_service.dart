import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:instana_agent/instana_agent.dart';

/// Instana monitoring service for tracking app events and user actions
class InstanaService {
  
  /// Check if Instana is available (only on iOS and Android)
  static bool get isAvailable {
    if (kIsWeb) return false;
    try {
      return Platform.isIOS || Platform.isAndroid;
    } catch (e) {
      return false;
    }
  }

  /// Track custom events
  static void trackEvent(String name, {Map<String, dynamic>? meta}) {
    if (!isAvailable) return; // Skip on web
    
    try {
      final options = EventOptions()
        ..startTime = DateTime.now().millisecondsSinceEpoch
        ..duration = 0;
      
      if (meta != null) {
        // Convert Map<String, dynamic> to Map<String, String>
        options.meta = meta.map((key, value) => MapEntry(key, value.toString()));
      }
      
      InstanaAgent.reportEvent(name: name, options: options);
    } catch (e) {
      // Silently fail - don't spam console
    }
  }

  /// Track user actions with optional details
  static void trackUserAction(String action, {Map<String, dynamic>? details}) {
    final meta = <String, dynamic>{'action': action};
    if (details != null) {
      meta.addAll(details);
    }
    trackEvent('user_action', meta: meta);
  }

  /// Track errors with stack trace
  static void trackError(String error, {String? stackTrace}) {
    trackEvent('error', meta: {
      'error': error,
      'stackTrace': stackTrace ?? 'No stack trace',
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Set user information for tracking
  static Future<void> setUser(String userId, {String? userName, String? userEmail}) async {
    if (!isAvailable) return; // Skip on web
    
    try {
      await InstanaAgent.setUserID(userId);
      if (userName != null) await InstanaAgent.setUserName(userName);
      if (userEmail != null) await InstanaAgent.setUserEmail(userEmail);
    } catch (e) {
      // Silently fail
    }
  }

  /// Set custom metadata
  static Future<void> setMetadata(String key, String value) async {
    if (!isAvailable) return; // Skip on web
    
    try {
      await InstanaAgent.setMeta(key: key, value: value);
    } catch (e) {
      // Silently fail
    }
  }

  /// Track view/screen changes
  static void trackView(String viewName) {
    if (!isAvailable) return; // Skip on web
    
    try {
      InstanaAgent.setView(viewName);
      trackEvent('view_change', meta: {'view': viewName});
    } catch (e) {
      // Silently fail
    }
  }

  /// Track app lifecycle events
  static void trackAppLifecycle(String event) {
    trackEvent('app_lifecycle', meta: {'event': event});
  }

  /// Track feature usage
  static void trackFeatureUsage(String feature, {Map<String, dynamic>? details}) {
    final meta = <String, dynamic>{'feature': feature};
    if (details != null) {
      meta.addAll(details);
    }
    trackEvent('feature_usage', meta: meta);
  }

  /// Track performance metrics
  static void trackPerformance(String operation, int durationMs, {Map<String, dynamic>? meta}) {
    if (!isAvailable) return; // Skip on web
    
    final eventMeta = <String, dynamic>{'operation': operation};
    if (meta != null) {
      eventMeta.addAll(meta);
    }
    
    try {
      final options = EventOptions()
        ..startTime = DateTime.now().millisecondsSinceEpoch
        ..duration = durationMs
        ..meta = eventMeta.map((key, value) => MapEntry(key, value.toString()));
      
      InstanaAgent.reportEvent(name: 'performance', options: options);
    } catch (e) {
      // Silently fail
    }
  }
}

// Made with Bob
