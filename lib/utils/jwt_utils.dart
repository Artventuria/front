import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:flutter/foundation.dart';

class JwtUtils {
  /// Decode a JWT to get its payload
  static Map<String, dynamic>? decodeJwt(String token) {
    try {
      // Use the dart_jsonwebtoken library to decode the token
      final jwt = JWT.decode(token);

      // Return the payload as a Map
      return jwt.payload as Map<String, dynamic>;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error decoding JWT: $e');
      }
      return null;
    }
  }

  /// Check if a JWT token is expired
  static bool isTokenExpired(String token) {
    try {
      // Decode the token
      final jwt = JWT.decode(token);

      // Check if an expiration field exists
      if (jwt.payload is! Map<String, dynamic>) return true;
      final payload = jwt.payload as Map<String, dynamic>;

      if (!payload.containsKey('exp')) return true;

      // Get the expiration date (exp) in seconds since the epoch
      final expiration = payload['exp'];
      if (expiration == null) return true;

      // Convert to DateTime
      final expirationDate = DateTime.fromMillisecondsSinceEpoch(
          (expiration is int)
              ? expiration * 1000
              : (expiration as double).toInt() * 1000);

      // Compare with the current date with a 10 second margin of safety
      return DateTime.now()
          .isAfter(expirationDate.subtract(const Duration(seconds: 10)));
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error checking JWT expiration: $e');
      }
      return true; // In case of doubt, we consider the token is expired
    }
  }

  /// Get the time remaining before token expiration in seconds
  /// Returns null if the token is invalid or expired
  static int? getTimeToExpiry(String token) {
    try {
      final jwt = JWT.decode(token);

      if (jwt.payload is! Map<String, dynamic>) return null;
      final payload = jwt.payload as Map<String, dynamic>;

      if (!payload.containsKey('exp')) return null;

      // Get the expiration date
      final expiration = payload['exp'];
      if (expiration == null) return null;

      final expirationDate = DateTime.fromMillisecondsSinceEpoch(
          (expiration is int)
              ? expiration * 1000
              : (expiration as double).toInt() * 1000);

      final now = DateTime.now();
      if (now.isAfter(expirationDate)) return null; // Already expired

      // Calculate the remaining time in seconds
      return expirationDate.difference(now).inSeconds;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error calculating time to expiry: $e');
      }
      return null;
    }
  }
}
