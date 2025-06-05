import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../env_config_service.dart';
import '../storage/storage_service.dart';
import '../auth/auth_notification_service.dart';
import '../../models/auth/auth_response_model.dart';

class ApiService {
  late final Dio _dio;
  final StorageService _storageService;
  final AuthNotificationService _authNotificationService = AuthNotificationService();

  // Lock to prevent competing refreshes
  bool _isRefreshing = false;
  // Completer to wait for a refresh in progress
  Completer<bool>? _refreshCompleter;

  ApiService(this._storageService) {
    _dio = Dio(
      BaseOptions(
        baseUrl: EnvConfigService.apiBaseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    if (kDebugMode) {
      _dio.interceptors.add(
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseHeader: true,
          responseBody: true,
          error: true,
          compact: true,
        ),
      );
    }

    // Add auth token interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storageService.getAccessToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) async {
          if (error.response?.statusCode == 401) {
            // Token expired, try to refresh
            bool refreshSuccess = false;

            // Check for concurrent refreshes
            if (_isRefreshing) {
              // A refresh is already in progress, wait for it to finish
              if (kDebugMode) {
                debugPrint('Refresh already in progress, waiting...');
              }
              refreshSuccess = await _refreshCompleter!.future;
            } else {
              // Start a new refresh
              _isRefreshing = true;
              _refreshCompleter = Completer<bool>();

              try {
                // Create a new Dio instance to avoid infinite loop with the interceptor
                final refreshDio = Dio(BaseOptions(
                  baseUrl: EnvConfigService.apiBaseUrl,
                  headers: {'Content-Type': 'application/json'},
                ));

                final refreshToken = await _storageService.getRefreshToken();
                if (refreshToken == null || refreshToken.isEmpty) {
                  // No refresh token, pass the error
                  _refreshCompleter!.complete(false);
                  _isRefreshing = false;
                  return handler.next(error);
                }

                // Limit of retries to avoid infinite loops
                int retryCount = 0;
                const maxRetries = 1;

                while (retryCount <= maxRetries) {
                  try {
                    final refreshResponse = await refreshDio.post(
                      '/api/auth/refresh',
                      data: {'refreshToken': refreshToken},
                    );

                    if (refreshResponse.statusCode == 200) {
                      // Parse the response
                      final authResponse =
                          AuthResponseModel.fromJson(refreshResponse.data);

                      // Save new tokens
                      await _storageService.saveAuthData(
                        accessToken: authResponse.tokens.accessToken,
                        refreshToken: authResponse.tokens.refreshToken,
                        expiresIn: authResponse.tokens.expiresIn,
                        user: authResponse.user,
                      );

                      refreshSuccess = true;
                      break; // Success, exit the loop
                    }
                    retryCount++;
                  } catch (e) {
                    if (kDebugMode) {
                      debugPrint(
                          'Error refreshing token (attempt $retryCount): $e');
                    }
                    retryCount++;
                    if (retryCount > maxRetries) break;
                    // Small delay before retrying
                    await Future.delayed(const Duration(milliseconds: 500));
                  }
                }

                // Notify other waiting requests
                _refreshCompleter!.complete(refreshSuccess);
                _isRefreshing = false;

                if (refreshSuccess) {
                  // Retry the original request with the new token
                  final newToken = await _storageService.getAccessToken();
                  final opts = Options(
                    method: error.requestOptions.method,
                    headers: {
                      ...error.requestOptions.headers,
                      'Authorization': 'Bearer $newToken',
                    },
                  );

                  final cloneReq = await _dio.request(
                    error.requestOptions.path,
                    options: opts,
                    data: error.requestOptions.data,
                    queryParameters: error.requestOptions.queryParameters,
                  );

                  return handler.resolve(cloneReq);
                }
              } catch (e) {
                if (kDebugMode) {
                  debugPrint('Error refreshing token: $e');
                }
                // Notify other waiting requests of the failure
                _refreshCompleter!.complete(false);
                _isRefreshing = false;
              }

              // If refresh failed, log out the user and notify the app
              if (!refreshSuccess) {
                await _storageService.clearAuthData();
                // Notify the app about the refresh failure and logout
                _authNotificationService.notifyRefreshFailed();
                _authNotificationService.notifyLoggedOut();
              }
            }
          }
          return handler.next(error);
        },
      ),
    );
  }

  // Generic GET method
  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) {
    return _dio.get(path, queryParameters: queryParameters);
  }

  // Generic POST method
  Future<Response> post(String path,
      {Object? data, Map<String, dynamic>? queryParameters}) {
    return _dio.post(path, data: data, queryParameters: queryParameters);
  }

  // Generic PUT method
  Future<Response> put(String path,
      {Object? data, Map<String, dynamic>? queryParameters}) {
    return _dio.put(path, data: data, queryParameters: queryParameters);
  }

  // Generic DELETE method
  Future<Response> delete(String path,
      {Object? data, Map<String, dynamic>? queryParameters}) {
    return _dio.delete(path, data: data, queryParameters: queryParameters);
  }
}
