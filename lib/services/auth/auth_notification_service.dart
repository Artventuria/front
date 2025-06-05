import 'package:rxdart/rxdart.dart';

/// Enum representing different authentication events that can occur in the app
enum AuthEvent {
  /// User has been logged in successfully
  loggedIn,
  
  /// User has been logged out due to token expiration/refresh failure
  loggedOut,
  
  /// User has manually logged out
  manualLogout,
  
  /// Token refresh has failed
  refreshFailed,
}

/// Service responsible for broadcasting authentication-related events across the app
/// 
/// This service uses BehaviorSubject from RxDart to allow multiple listeners
/// to react to authentication state changes, such as forced logouts due to
/// token refresh failures.
class AuthNotificationService {
  // Private constructor for singleton pattern
  AuthNotificationService._();
  
  // Singleton instance
  static final AuthNotificationService _instance = AuthNotificationService._();
  
  // Factory constructor to return the singleton instance
  factory AuthNotificationService() => _instance;
  
  // BehaviorSubject to broadcast auth events
  // Using BehaviorSubject instead of StreamController to cache the last event
  final _authEventController = BehaviorSubject<AuthEvent>();
  
  /// Stream of authentication events that can be listened to by widgets
  Stream<AuthEvent> get authEvents => _authEventController.stream;
  
  /// Notify the app that the user has been logged in
  void notifyLoggedIn() {
    _authEventController.add(AuthEvent.loggedIn);
  }
  
  /// Notify the app that the user has been logged out (due to session expiration)
  void notifyLoggedOut() {
    _authEventController.add(AuthEvent.loggedOut);
  }
  
  /// Notify the app that the user has manually logged out
  void notifyManualLogout() {
    _authEventController.add(AuthEvent.manualLogout);
  }
  
  /// Notify the app that token refresh has failed
  void notifyRefreshFailed() {
    _authEventController.add(AuthEvent.refreshFailed);
  }
  
  /// Dispose the controller when no longer needed
  void dispose() {
    _authEventController.close();
  }
}
