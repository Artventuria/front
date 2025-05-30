import 'dart:async';
import 'package:flutter/material.dart';
import 'package:uni_links/uni_links.dart';
import '../screens/auth/reset_password_page.dart';

/// Service to handle deep links in the app
class DeepLinkService {
  /// Singleton instance
  static final DeepLinkService _instance = DeepLinkService._internal();
  factory DeepLinkService() => _instance;
  DeepLinkService._internal();

  /// Stream controller to notify deep link changes
  final StreamController<String> _deepLinkStreamController =
      StreamController<String>.broadcast();
  Stream<String> get deepLinkStream => _deepLinkStreamController.stream;

  bool _isInitialized = false;

  /// Initialize the service and configure deep link listeners
  // Store a reference to the BuildContext for safe navigation
  BuildContext? _storedContext;

  Future<void> initialize(BuildContext context) async {
    if (_isInitialized) return;
    _isInitialized = true;

    // Store the context for later use
    _storedContext = context;

    // Handle deep links at app startup
    try {
      final initialLink = await getInitialLink();
      if (initialLink != null && _storedContext != null) {
        // Use the stored context
        _handleDeepLink(initialLink, _storedContext!);
      }
    } catch (e) {
      debugPrint('Error getting initial deep link: $e');
    }

    // Listen for deep links while the app is open
    linkStream.listen((String? link) {
      if (link != null && _storedContext != null) {
        // Use the stored context
        _handleDeepLink(link, _storedContext!);
        _deepLinkStreamController.add(link);
      }
    }, onError: (error) {
      debugPrint('Error handling deep link: $error');
    });
  }

  /// Handle received deep link
  void _handleDeepLink(String link, BuildContext context) {
    debugPrint('Deep link received: $link');

    try {
      final uri = Uri.parse(link);

      // Verify if it's a deep link for password reset
      if (uri.scheme == 'artventuria' && uri.host == 'resetpassword') {
        final token = uri.queryParameters['token'];
        if (token != null && token.isNotEmpty) {
          _navigateToResetPassword(context, token);
        } else {
          debugPrint('Token missing in deep link');
        }
      }
    } catch (e) {
      debugPrint('Error handling deep link: $e');
    }
  }

  /// Navigate to the reset password page
  void _navigateToResetPassword(BuildContext context, String token) {
    // Use Navigator.pushAndRemoveUntil to clear the navigation stack
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => ResetPasswordPage(token: token),
      ),
      (route) => false, // Clear all previous routes
    );
  }

  /// Release resources when the app is closed
  void dispose() {
    _deepLinkStreamController.close();
  }
}
