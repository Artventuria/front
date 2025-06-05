import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfigService {
  static Future<void> initialize() async {
    try {
      // Try to load the environment-specific file first
      final envFile = kReleaseMode ? '.env.production' : '.env.development';
      await dotenv.load(fileName: envFile);
    } catch (e) {
      // If that fails, fall back to the default .env file
      try {
        await dotenv.load(fileName: '.env');
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Error loading environment files: $e');
        }
        // Set default values if no env file is found
        dotenv.env['API_BASE_URL'] = 'http://localhost:8081';
      }
    }
  }

  static String get apiBaseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'http://localhost:8081';
}
