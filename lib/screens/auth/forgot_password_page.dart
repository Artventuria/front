import 'package:flutter/material.dart';
import 'package:front/l10n/app_localizations.dart';
import '../../utils/constants.dart';
import '../../widgets/auth/auth_button_widget.dart';
import '../../widgets/auth/auth_input_field_widget.dart';
import '../../widgets/common/white_header_container.dart';
import 'sign_in_page.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _sendResetLink() {
    if (_formKey.currentState?.validate() ?? false) {
      // TODO: Implement password reset logic
      print('Send password reset link to: ${_emailController.text}');
      // Show a snackbar to inform the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Password reset link sent to: ${_emailController.text}'),
          duration: const Duration(seconds: 3),
        ),
      );
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
                title: l10n.resetPasswordTitle,
                subtitle: l10n.resetPasswordSubtitle,
                height: whiteContainerHeight,
                topPadding: 40.0, // Augmentation du padding supérieur pour un meilleur centrage
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
                      // Email field
                      AuthInputField(
                        label: l10n.email,
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return l10n.emailRequired;
                          }
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                              .hasMatch(value)) {
                            return l10n.emailInvalid;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 40),
                      // Send button
                      Center(
                        child: AuthButton(
                          text: l10n.sendButton,
                          onTap: _sendResetLink,
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
