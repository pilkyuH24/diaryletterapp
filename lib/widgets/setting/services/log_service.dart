// widgets/setting/services/log_service.dart

import 'package:flutter/foundation.dart';

enum LogLevel { verbose, info, warning, error }

class LogService {
  static LogLevel currentLevel = LogLevel.info;

  static void v(String message) {
    if (kDebugMode && currentLevel.index <= LogLevel.verbose.index) {
      debugPrint('🔍 VERBOSE: $message');
    }
  }

  static void i(String message) {
    if (kDebugMode && currentLevel.index <= LogLevel.info.index) {
      debugPrint('ℹ️ INFO: $message');
    }
  }

  static void w(String message) {
    if (currentLevel.index <= LogLevel.warning.index) {
      debugPrint('⚠️ WARNING: $message');
    }
  }

  static void e(String message) {
    if (currentLevel.index <= LogLevel.error.index) {
      debugPrint('❌ ERROR: $message');
    }
  }
}
