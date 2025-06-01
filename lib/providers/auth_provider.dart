import 'package:flutter/foundation.dart';

import '../models/auth/user_model.dart';
import '../services/auth/auth_service.dart';
import '../exceptions/auth_exception.dart';

enum AuthStatus {
  initial,
  authenticated,
  unauthenticated,
  authenticating,
  error
}

class AuthProvider with ChangeNotifier {
  final AuthService _authService;
  AuthStatus _status = AuthStatus.initial;
  UserModel? _user;
  String _errorMessage = '';

  AuthProvider(this._authService) {
    // Check if user is already logged in at startup
    _checkCurrentAuthStatus();
  }

  // Getters
  AuthStatus get status => _status;
  UserModel? get user => _user;
  String get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  // Initial check of auth status
  Future<void> _checkCurrentAuthStatus() async {
    try {
      final isLoggedIn = await _authService.isLoggedIn();
      
      if (isLoggedIn) {
        _user = await _authService.getCurrentUser();
        _status = AuthStatus.authenticated;
      } else {
        _status = AuthStatus.unauthenticated;
      }
    } catch (e) {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  // Login method
  Future<bool> login(String email, String password) async {
    try {
      _status = AuthStatus.authenticating;
      _errorMessage = '';
      notifyListeners();

      final authResponse = await _authService.login(email, password);
      _user = authResponse.user;
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _status = AuthStatus.error;
      // Store the translation key directly if it's an AuthException
      if (e is AuthException) {
        _errorMessage = e.message;
      } else {
        // Fallback for other types of exceptions
        _errorMessage = 'loginErrorUnexpected';
      }
      notifyListeners();
      return false;
    }
  }

  // Signup method will be implemented here
  Future<bool> signup(String username, String email, String password) async {
    // This will be implemented in the next step
    return false;
  }

  // Logout method
  Future<void> logout() async {
    try {
      await _authService.logout();
      _user = null;
      _status = AuthStatus.unauthenticated;
    } catch (e) {
      // Store the translation key directly if it's an AuthException
      if (e is AuthException) {
        _errorMessage = e.message;
      } else {
        // Fallback for other types of exceptions
        _errorMessage = 'loginErrorUnexpected';
      }
    }
    notifyListeners();
  }

  // Reset error state
  void resetError() {
    _errorMessage = '';
    if (_status == AuthStatus.error) {
      _status = AuthStatus.unauthenticated;
      notifyListeners();
    }
  }
}
