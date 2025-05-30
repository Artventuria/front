import 'package:flutter/material.dart';
import 'package:front/l10n/app_localizations.dart';
import '../../utils/constants.dart';
import '../../widgets/auth/auth_button_widget.dart';
import '../../widgets/auth/auth_input_field_widget.dart';
import '../../widgets/common/white_header_container.dart';
import 'sign_in_page.dart';

class ResetPasswordPage extends StatefulWidget {
  final String
      token; // Ce token sera transmis dans l'URL du lien envoyé par email

  const ResetPasswordPage({super.key, required this.token});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _resetPassword() {
    if (_formKey.currentState?.validate() ?? false) {
      // TODO: Implement password reset logic using the token
      debugPrint('Reset password with token: ${widget.token}');
      debugPrint('New password: ${_newPasswordController.text}');

      // Verify the widget is still mounted before using context
      if (!mounted) return;

      // After the reset is successful, redirect to the sign-in page
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password has been reset successfully!'),
          duration: Duration(seconds: 3),
        ),
      );

      // After a few seconds, navigate to the sign-in page
      Future.delayed(const Duration(seconds: 3), () {
        // Verify if the widget is still mounted before using the context
        if (!mounted) return;

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const SignInPage(),
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    const double whiteContainerHeight = 270.0;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.gradientStart,
              AppColors.gradientMiddle,
              AppColors.gradientEnd,
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // White container at the top
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: WhiteHeaderContainer(
                title: l10n.newPasswordTitle,
                subtitle: l10n.newPasswordSubtitle,
                height: whiteContainerHeight,
                topPadding: 40.0,
              ),
            ),
            // Form content
            Positioned(
              top: whiteContainerHeight + 50,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // New password field
                      AuthInputField(
                        label: l10n.newPassword,
                        controller: _newPasswordController,
                        isPassword: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return l10n.passwordRequired;
                          }
                          if (value.length < 6) {
                            return l10n.passwordTooShort;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      // Confirm password field
                      AuthInputField(
                        label: l10n.confirmPassword,
                        controller: _confirmPasswordController,
                        isPassword: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return l10n.passwordRequired;
                          }
                          if (value != _newPasswordController.text) {
                            return l10n.passwordsDoNotMatch;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 40),
                      // Reset button
                      Center(
                        child: AuthButton(
                          text: l10n.resetButton,
                          onTap: _resetPassword,
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Back to sign in text button
                      Center(
                        child: TextButton(
                          onPressed: () {
                            // Navigate to sign in page
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) => const SignInPage(),
                              ),
                            );
                          },
                          child: Text(
                            l10n.backToSignIn,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
