import 'package:front/l10n/app_localizations.dart';

/// Utility class to centralize error message handling for authentication
class ErrorMessagesHelper {
  /// Get localized error message for authentication errors
  /// This combines both login and registration error messages
  static String getAuthErrorMessage(AppLocalizations l10n, String errorKey) {
    switch (errorKey) {
      // Login errors
      case 'loginErrorInvalidCredentials':
        return l10n.loginErrorInvalidCredentials;
      case 'loginErrorAccountBlocked':
        return l10n.loginErrorAccountBlocked;
      case 'loginErrorConnection':
        return l10n.loginErrorConnection;
      case 'loginErrorUnexpected':
        return l10n.loginErrorUnexpected;
      case 'sessionExpired':
        return l10n.sessionExpired;

      // Registration specific errors
      case 'registerErrorDuplicate':
        return l10n.registerErrorDuplicate;
      case 'USER_ALREADY_EXISTS':
      case 'registerErrorUserExists':
        return l10n.registerErrorUserExists;
      case 'EMAIL_ALREADY_EXISTS':
      case 'registerErrorEmailExists':
        return l10n.registerErrorEmailExists;
      case 'registerErrorValidation':
        return l10n.registerErrorValidation;
      case 'registerErrorUnexpected':
        return l10n.loginErrorUnexpected;

      default:
        return errorKey; // Return the original message if no translation is found
    }
  }
}
