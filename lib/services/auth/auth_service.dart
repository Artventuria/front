import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';

import '../api/api_service.dart';
import '../storage/storage_service.dart';
import './auth_notification_service.dart';
import '../../models/auth/auth_response_model.dart';
import '../../models/auth/user_model.dart';
import '../../exceptions/auth_exception.dart';

class AuthService {
  final ApiService _apiService;
  final StorageService _storageService;
  final AuthNotificationService _authNotificationService =
      AuthNotificationService();

  AuthService(this._apiService, this._storageService);

  // Register endpoint
  Future<AuthResponseModel> register(
      String username, String email, String password) async {
    try {
      final response = await _apiService.post(
        '/api/auth/register',
        data: {
          'username': username,
          'email': email,
          'password': password,
        },
      );

      final authResponse = AuthResponseModel.fromJson(response.data);

      // Save tokens and user data to secure storage
      await _storageService.saveAuthData(
        accessToken: authResponse.tokens.accessToken,
        refreshToken: authResponse.tokens.refreshToken,
        expiresIn: authResponse.tokens.expiresIn,
        user: authResponse.user,
      );

      // Notify the app that user has registered and logged in
      _authNotificationService.notifyLoggedIn();

      return authResponse;
    } on DioException catch (e) {
      if (e.response != null) {
        // Handle specific error responses
        final statusCode = e.response!.statusCode;
        final errorData = e.response!.data;

        if (statusCode == 400) {
          if (errorData is Map && errorData.containsKey('message')) {
            final message = errorData['message'];
            if (message == 'User already exists') {
              throw AuthException('registerErrorUserExists',
                  code: 'user_exists');
            } else if (message == 'Email already exists') {
              throw AuthException('registerErrorEmailExists',
                  code: 'email_exists');
            } else {
              throw AuthException('registerErrorValidation',
                  code: 'validation_error');
            }
          }
        } else if (statusCode == 409) {
          throw AuthException('registerErrorDuplicate',
              code: 'duplicate_error');
        }
      }
      // Generic error
      throw AuthException('loginErrorConnection', code: 'connection_error');
    } catch (e) {
      throw AuthException('registerErrorUnexpected', code: 'unexpected_error');
    }
  }

  // Login endpoint
  Future<AuthResponseModel> login(String email, String password) async {
    try {
      final response = await _apiService.post(
        '/api/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      final authResponse = AuthResponseModel.fromJson(response.data);

      // Save tokens and user data to secure storage
      await _storageService.saveAuthData(
        accessToken: authResponse.tokens.accessToken,
        refreshToken: authResponse.tokens.refreshToken,
        expiresIn: authResponse.tokens.expiresIn,
        user: authResponse.user,
      );

      // Notify the app that user has logged in
      _authNotificationService.notifyLoggedIn();

      return authResponse;
    } on DioException catch (e) {
      if (e.response != null) {
        // Handle specific error responses
        final statusCode = e.response!.statusCode;
        final errorData = e.response!.data;

        if (statusCode == 401) {
          throw AuthException('loginErrorInvalidCredentials',
              code: 'invalid_credentials');
        } else if (statusCode == 403) {
          throw AuthException('loginErrorAccountBlocked',
              code: 'account_blocked');
        } else if (errorData is Map && errorData.containsKey('message')) {
          throw AuthException(errorData['message']);
        }
      }
      // Generic error
      throw AuthException('loginErrorConnection', code: 'connection_error');
    } catch (e) {
      throw AuthException('loginErrorUnexpected', code: 'unexpected_error');
    }
  }

  // Get current user
  Future<UserModel?> getCurrentUser() async {
    return _storageService.getUser();
  }

  /// Refresh the access token using the refresh token
  /// Returns true if the refresh was successful
  Future<bool> refreshTokens() async {
    try {
      final refreshToken = await _storageService.getRefreshToken();

      if (refreshToken == null || refreshToken.isEmpty) {
        if (kDebugMode) {
          debugPrint('No refresh token available');
        }
        return false;
      }

      final response = await _apiService.post(
        '/api/auth/refresh',
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200) {
        final authResponse = AuthResponseModel.fromJson(response.data);

        // Store new tokens and user information
        await _storageService.saveAuthData(
          accessToken: authResponse.tokens.accessToken,
          refreshToken: authResponse.tokens.refreshToken,
          expiresIn: authResponse.tokens.expiresIn,
          user: authResponse.user,
        );

        return true;
      } else {
        if (kDebugMode) {
          debugPrint('Error refreshing token: ${response.statusCode}');
        }
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Exception refreshing token: $e');
      }
      return false;
    }
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    return await _storageService.isLoggedIn();
  }

  // Forgot password endpoint
  // Sends a password reset link to the specified email
  Future<bool> forgotPassword(String email) async {
    try {
      await _apiService.post(
        '/api/auth/forgot-password',
        data: {
          'email': email,
        },
      );
      
      // If the request was successful (didn't throw), return true
      return true;
    } on DioException catch (e) {
      if (kDebugMode) {
        debugPrint('Forgot password error: $e');
      }
      // Handle specific error responses if needed
      return false;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Unexpected error during password reset: $e');
      }
      return false;
    }
  }

  // Complete logout
  // Clears all authentication data and performs a complete cleanup
  Future<void> logout() async {
    try {
      // 1. Inform the server of the logout to invalidate tokens
      final token = await _storageService.getAccessToken();
      if (token != null && token.isNotEmpty) {
        try {
          // The token will be automatically added by the Dio interceptor
          await _apiService.post('/api/auth/logout');
          if (kDebugMode) {
            debugPrint('Server logout request successful');
          }
        } catch (e) {
          // Continue with local logout even if server logout fails
          if (kDebugMode) {
            debugPrint('Server logout request failed: $e');
          }
        }
      }

      // 2. Clear all authentication data
      await _storageService.clearAuthData();

      // 3. Notify the app that user has manually logged out
      _authNotificationService.notifyManualLogout();

      if (kDebugMode) {
        debugPrint('Logout completed successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Logout error: $e');
      }
      // Ensure we always clear local data even in case of error
      await _storageService.clearAuthData();
    }
  }
}
