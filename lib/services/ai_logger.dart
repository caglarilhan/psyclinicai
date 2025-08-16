import 'package:flutter/foundation.dart';
import '../config/env_config.dart';

enum AILogLevel {
  debug,
  info,
  warning,
  error,
}

class AILogger {
  static final AILogger _instance = AILogger._internal();
  factory AILogger() => _instance;
  AILogger._internal();

  final List<AILogEntry> _logs = [];
  final int _maxLogs = 1000;

  void _addLog(AILogLevel level, String message, {String? context, dynamic data}) {
    if (!EnvConfig.shouldLog) return;

    final entry = AILogEntry(
      timestamp: DateTime.now(),
      level: level,
      message: message,
      context: context,
      data: data,
    );

    _logs.add(entry);

    // Log sayısını sınırla
    if (_logs.length > _maxLogs) {
      _logs.removeAt(0);
    }

    // Console'a yazdır
    _printLog(entry);
  }

  void _printLog(AILogEntry entry) {
    final timestamp = entry.timestamp.toIso8601String();
    final level = entry.level.name.toUpperCase();
    final context = entry.context != null ? '[${entry.context}]' : '';
    
    if (kDebugMode) {
      print('$timestamp $level $context ${entry.message}');
      if (entry.data != null) {
        print('Data: ${entry.data}');
      }
    }
  }

  // Debug logging
  void debug(String message, {String? context, dynamic data}) {
    if (EnvConfig.shouldLogDebug) {
      _addLog(AILogLevel.debug, message, context: context, data: data);
    }
  }

  // Info logging
  void info(String message, {String? context, dynamic data}) {
    if (EnvConfig.shouldLogInfo) {
      _addLog(AILogLevel.info, message, context: context, data: data);
    }
  }

  // Warning logging
  void warning(String message, {String? context, dynamic data}) {
    if (EnvConfig.shouldLogWarning) {
      _addLog(AILogLevel.warning, message, context: context, data: data);
    }
  }

  // Error logging
  void error(String message, {String? context, dynamic data, Object? error, StackTrace? stackTrace}) {
    if (EnvConfig.shouldLogError) {
      _addLog(AILogLevel.error, message, context: context, data: data);
      
      if (error != null) {
        print('Error: $error');
      }
      
      if (stackTrace != null) {
        print('StackTrace: $stackTrace');
      }
    }
  }

  // API request logging
  void logApiRequest(String endpoint, Map<String, dynamic> requestData, {String? context}) {
    info(
      'API Request to $endpoint',
      context: context,
      data: {
        'endpoint': endpoint,
        'timestamp': DateTime.now().toIso8601String(),
        'requestData': requestData,
      },
    );
  }

  // API response logging
  void logApiResponse(String endpoint, dynamic response, {String? context, Duration? duration}) {
    info(
      'API Response from $endpoint',
      context: context,
      data: {
        'endpoint': endpoint,
        'timestamp': DateTime.now().toIso8601String(),
        'response': response,
        'duration': duration?.inMilliseconds,
      },
    );
  }

  // API error logging
  void logApiError(String endpoint, Object error, {String? context, StackTrace? stackTrace}) {
    this.error(
      'API Error from $endpoint',
      context: context,
      error: error,
      stackTrace: stackTrace,
    );
  }

  // Performance logging
  void logPerformance(String operation, Duration duration, {String? context, Map<String, dynamic>? metadata}) {
    info(
      'Performance: $operation completed in ${duration.inMilliseconds}ms',
      context: context,
      data: {
        'operation': operation,
        'duration_ms': duration.inMilliseconds,
        'metadata': metadata,
      },
    );
  }

  // Get logs
  List<AILogEntry> getLogs({AILogLevel? level, String? context, int? limit}) {
    var filteredLogs = _logs;

    if (level != null) {
      filteredLogs = filteredLogs.where((log) => log.level == level).toList();
    }

    if (context != null) {
      filteredLogs = filteredLogs.where((log) => log.context == context).toList();
    }

    if (limit != null && filteredLogs.length > limit) {
      filteredLogs = filteredLogs.sublist(filteredLogs.length - limit);
    }

    return filteredLogs;
  }

  // Clear logs
  void clearLogs() {
    _logs.clear();
  }

  // Export logs
  String exportLogs() {
    final buffer = StringBuffer();
    buffer.writeln('AI Service Logs');
    buffer.writeln('Generated: ${DateTime.now().toIso8601String()}');
    buffer.writeln('Total Logs: ${_logs.length}');
    buffer.writeln('---');

    for (final log in _logs) {
      buffer.writeln('${log.timestamp.toIso8601String()} [${log.level.name.toUpperCase()}] ${log.context != null ? '[${log.context}]' : ''} ${log.message}');
      if (log.data != null) {
        buffer.writeln('  Data: ${log.data}');
      }
    }

    return buffer.toString();
  }

  // Get log statistics
  Map<String, dynamic> getLogStatistics() {
    final now = DateTime.now();
    final lastHour = now.subtract(const Duration(hours: 1));
    final lastDay = now.subtract(const Duration(days: 1));

    final recentLogs = _logs.where((log) => log.timestamp.isAfter(lastHour)).toList();
    final dailyLogs = _logs.where((log) => log.timestamp.isAfter(lastDay)).toList();

    return {
      'total_logs': _logs.length,
      'logs_last_hour': recentLogs.length,
      'logs_last_day': dailyLogs.length,
      'error_count': _logs.where((log) => log.level == AILogLevel.error).length,
      'warning_count': _logs.where((log) => log.level == AILogLevel.warning).length,
      'info_count': _logs.where((log) => log.level == AILogLevel.info).length,
      'debug_count': _logs.where((log) => log.level == AILogLevel.debug).length,
    };
  }
}

class AILogEntry {
  final DateTime timestamp;
  final AILogLevel level;
  final String message;
  final String? context;
  final dynamic data;

  AILogEntry({
    required this.timestamp,
    required this.level,
    required this.message,
    this.context,
    this.data,
  });

  @override
  String toString() {
    return 'AILogEntry{timestamp: $timestamp, level: $level, message: $message, context: $context, data: $data}';
  }
}

