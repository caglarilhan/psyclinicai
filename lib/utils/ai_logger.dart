import 'package:flutter/foundation.dart';

class AILogger {
  static final AILogger _instance = AILogger._internal();
  factory AILogger() => _instance;
  AILogger._internal();

  void info(String message, {String? context, Map<String, dynamic>? data}) {
    if (kDebugMode) {
      print('🔵 [INFO]${context != null ? ' [$context]' : ''}: $message');
      if (data != null) {
        print('   Data: $data');
      }
    }
  }

  void warning(String message, {String? context, Map<String, dynamic>? data}) {
    if (kDebugMode) {
      print('🟡 [WARNING]${context != null ? ' [$context]' : ''}: $message');
      if (data != null) {
        print('   Data: $data');
      }
    }
  }

  void error(String message, {String? context, Map<String, dynamic>? data, Object? error}) {
    if (kDebugMode) {
      print('🔴 [ERROR]${context != null ? ' [$context]' : ''}: $message');
      if (data != null) {
        print('   Data: $data');
      }
      if (error != null) {
        print('   Error: $error');
      }
    }
  }

  void debug(String message, {String? context, Map<String, dynamic>? data}) {
    if (kDebugMode) {
      print('🔍 [DEBUG]${context != null ? ' [$context]' : ''}: $message');
      if (data != null) {
        print('   Data: $data');
      }
    }
  }
}
