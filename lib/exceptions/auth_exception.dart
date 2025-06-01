/// Custom exception for authentication errors
/// This allows us to throw exceptions without the "Exception:" prefix
/// and use localized error messages
class AuthException implements Exception {
  final String message;
  final String? code;

  AuthException(this.message, {this.code});

  @override
  String toString() {
    return message;
  }
}
