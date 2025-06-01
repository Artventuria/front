import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';

import '../../models/auth/user_model.dart';
import '../../utils/jwt_utils.dart';

class StorageService {
  final FlutterSecureStorage _secureStorage;

  // Key constants
  static const String _keyAccessToken = 'access_token';
  static const String _keyRefreshToken = 'refresh_token';
  static const String _keyUser = 'user';
  static const String _keyExpiresIn = 'expires_in';
  static const String _keyTokenExpiry = 'token_expiry';

  StorageService()
      : _secureStorage = const FlutterSecureStorage(
          aOptions: AndroidOptions(encryptedSharedPreferences: true),
        );

  /// Save authentication data
  Future<void> saveAuthData({
    required String accessToken,
    required String refreshToken,
    required int expiresIn,
    required UserModel user,
  }) async {
    // Calculate the expiration date from the provided duration
    final expiresAt = DateTime.now().add(Duration(seconds: expiresIn));

    // Also check the real expiration of the token by decoding it (for more security)
    final tokenExpiry = JwtUtils.getTimeToExpiry(accessToken);
    if (tokenExpiry != null) {
      // If the token contains an expiration date, use it instead of expiresIn
      final jwtExpiresAt = DateTime.now().add(Duration(seconds: tokenExpiry));
      // Take the closest date to be sure
      if (jwtExpiresAt.isBefore(expiresAt)) {
        if (kDebugMode) {
          debugPrint(
              'JWT expiration ($jwtExpiresAt) different from server expiration ($expiresAt), using JWT value');
        }
        await _secureStorage.write(
            key: _keyTokenExpiry, value: jwtExpiresAt.toIso8601String());
      } else {
        await _secureStorage.write(
            key: _keyTokenExpiry, value: expiresAt.toIso8601String());
      }
    } else {
      // If we can't extract the expiration from the JWT, use the one provided by the server
      await _secureStorage.write(
          key: _keyTokenExpiry, value: expiresAt.toIso8601String());
    }

    // Save the tokens and user data
    await _secureStorage.write(key: _keyAccessToken, value: accessToken);
    await _secureStorage.write(key: _keyRefreshToken, value: refreshToken);
    await _secureStorage.write(key: _keyUser, value: jsonEncode(user.toJson()));
  }

  // Get access token
  Future<String?> getAccessToken() async {
    return await _secureStorage.read(key: _keyAccessToken);
  }

  // Get refresh token
  Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: _keyRefreshToken);
  }

  // Get user data
  Future<UserModel?> getUser() async {
    final userJson = await _secureStorage.read(key: _keyUser);
    if (userJson == null) return null;
    try {
      return UserModel.fromJson(jsonDecode(userJson));
    } catch (e) {
      return null;
    }
  }

  /// Check if the access token is expired
  /// Uses a combination of the stored date and JWT decoding for more reliability
  Future<bool> isTokenExpired() async {
    final token = await getAccessToken();
    if (token == null || token.isEmpty) {
      return true; // No token = considered expired
    }

    // Method 1: Quick verification by expiration date stored
    final expiryString = await _secureStorage.read(key: _keyTokenExpiry);
    if (expiryString != null) {
      try {
        final expiryTime = DateTime.parse(expiryString);
        // Add a 30 second safety margin
        final safeTime = expiryTime.subtract(const Duration(seconds: 30));
        if (DateTime.now().isBefore(safeTime)) {
          // Token is still valid according to the stored date with safety margin
          return false;
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Error parsing expiration date: $e');
        }
      }
    }

    // Method 2: Verification by decoding the JWT (more precise but more expensive)
    return JwtUtils.isTokenExpired(token);
  }

  // Clear all stored auth data (logout)
  Future<void> clearAuthData() async {
    await Future.wait([
      _secureStorage.delete(key: _keyAccessToken),
      _secureStorage.delete(key: _keyRefreshToken),
      _secureStorage.delete(key: _keyUser),
      _secureStorage.delete(key: _keyExpiresIn),
      _secureStorage.delete(key: _keyTokenExpiry),
    ]);
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    if (token == null) return false;

    // Also check if token is expired
    return !(await isTokenExpired());
  }
}
