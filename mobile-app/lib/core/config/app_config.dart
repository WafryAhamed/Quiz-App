import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static String get apiBaseUrl => _normalizeLoopbackForCurrentPlatform(
        dotenv.env['API_BASE_URL'] ?? _defaultApiBaseUrl,
      );

  static String get wsBaseUrl => _normalizeLoopbackForCurrentPlatform(
        dotenv.env['WS_BASE_URL'] ?? _defaultWsBaseUrl,
      );

  static String get _defaultApiBaseUrl {
    if (_isAndroidRuntime) {
      return 'http://10.0.2.2:8080';
    }

    return 'http://127.0.0.1:8080';
  }

  static String get _defaultWsBaseUrl {
    if (_isAndroidRuntime) {
      return 'http://10.0.2.2:8080/ws-quiz';
    }

    return 'http://127.0.0.1:8080/ws-quiz';
  }

  static bool get _isAndroidRuntime =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  static String _normalizeLoopbackForCurrentPlatform(String value) {
    if (_isAndroidRuntime) {
      return value.trim();
    }

    return value.trim().replaceAll('10.0.2.2', '127.0.0.1');
  }
}
