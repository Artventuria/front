import 'package:form_field_validator/form_field_validator.dart';

/// Class to validate password
class PasswordValidator {
  /// Check if a password is valid according to the backend rules
  ///
  /// Rules:
  /// - At least 8 characters
  /// - No spaces
  /// - Only letters, numbers and authorized special characters (@#$%^&+=!)
  static String? validate(String? value) {
    // Use MultiValidator to combine multiple validations
    final validator = MultiValidator([
      RequiredValidator(errorText: 'Password is required'),
      MinLengthValidator(8,
          errorText: 'Password must contain at least 8 characters'),
      PatternValidator(r'^[a-zA-Z0-9@#\$%\^&+=!]+$',
          errorText:
              'Password must contain only letters, numbers and certain special characters'),
    ]);

    // Additional space check (not included in the pattern)
    final result = validator.call(value);
    if (result != null) {
      return result;
    }

    if (value != null && value.contains(' ')) {
      return 'The password must not contain spaces';
    }

    return null;
  }
}
