import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../providers/auth_provider.dart';
import '../../services/auth/auth_notification_service.dart';
import '../../l10n/app_localizations.dart';
import '../../screens/auth/sign_in_page.dart';
import '../../screens/landing/landing_page.dart';
import '../../screens/authenticated/home_test_page.dart';

/// Widget that handles conditional navigation based on authentication state
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _hasLaunchedBefore = false;
  bool _checkingFirstLaunch = true;

  // Auth notification service instance
  final _authNotificationService = AuthNotificationService();

  // Navigation key to allow navigation from outside of the context
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    _checkFirstLaunch();

    // Listen to auth events
    _authNotificationService.authEvents.listen(_handleAuthEvent);
  }

  @override
  void dispose() {
    super.dispose();
  }

  /// Handle authentication events
  void _handleAuthEvent(AuthEvent event) {
    final context = _navigatorKey.currentContext;
    if (context == null) return;

    switch (event) {
      case AuthEvent.loggedOut:
      case AuthEvent.refreshFailed:
        // Show a snackbar to inform the user about session expiration
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.sessionExpired),
            duration: const Duration(seconds: 3),
            backgroundColor: Colors.red,
          ),
        );

        // Update the auth provider state
        if (context.mounted) {
          Provider.of<AuthProvider>(context, listen: false).logout();
        }
        break;
      case AuthEvent.manualLogout:
        // No need to show a snackbar for manual logout
        // The AuthProvider state is already updated by the logout button
        break;
      case AuthEvent.loggedIn:
        // We don't need to do anything here as the AuthProvider
        // will handle the state update
        break;
    }
  }

  /// Check if it's the first launch
  Future<void> _checkFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    final hasLaunched = prefs.getBool('has_launched_before') ?? false;

    if (!hasLaunched) {
      /// First launch
      await prefs.setBool('has_launched_before', true);
    }

    if (mounted) {
      setState(() {
        _hasLaunchedBefore = hasLaunched;
        _checkingFirstLaunch = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    /// If we are still checking the first launch, show a loading screen
    if (_checkingFirstLaunch) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Wrap everything with a Navigator to use the navigator key
    return Navigator(
      key: _navigatorKey,
      onGenerateRoute: (settings) {
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => _buildAuthenticatedContent(context),
        );
      },
    );
  }

  /// Build the content based on authentication state
  Widget _buildAuthenticatedContent(BuildContext context) {
    /// Listen to authentication state
    final authProvider = Provider.of<AuthProvider>(context);

    /// Show a loading indicator during initial authentication verification
    if (authProvider.status == AuthStatus.initial) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    /// If the user is authenticated, show the home test page regardless of whether it's first launch
    /// This ensures that after successful registration, user goes to home page
    if (authProvider.isAuthenticated) {
      return const HomeTestPage();
    }

    /// If it's the first launch and user is not authenticated, redirect to the landing page
    if (!_hasLaunchedBefore) {
      return const LandingPage();
    }

    /// If the user is not authenticated, show the sign-in page
    return const SignInPage();
  }
}
