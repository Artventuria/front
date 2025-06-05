import 'package:flutter/material.dart';
import 'package:front/l10n/app_localizations.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:provider/provider.dart';

import '../../utils/error_messages_helper.dart';

import '../../providers/auth_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/auth/auth_button_widget.dart';
import '../../widgets/auth/auth_input_field_widget.dart';
import '../../widgets/common/white_header_container.dart';
import '../../widgets/common/disable_swipe_back.dart';
import '../../widgets/common/page_transition.dart';
import '../../screens/authenticated/home_page.dart';
import 'sign_up_page.dart';
import 'forgot_password_page.dart';


class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    // Close keyboard first
    FocusScope.of(context).unfocus();

    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      late bool loginSuccess;
      String? errorMsg;

      try {
        // Get the provider before async gap
        final authProvider = Provider.of<AuthProvider>(context, listen: false);

        // Perform login operation
        loginSuccess = await authProvider.login(
          _emailController.text.trim(),
          _passwordController.text,
        );

        // Store error message if login failed
        errorMsg = loginSuccess ? null : authProvider.errorMessage;
      } catch (e) {
        // Handle any exceptions
        loginSuccess = false;
        errorMsg = e.toString();
      }

      // Check if widget is still mounted after async operation
      if (!mounted) return;

      // Update state based on login results
      if (loginSuccess) {
        // Navigate to home page - this is safe since we've checked mounted
        Navigator.of(context).pushAndRemoveUntil(
          AppPageTransition.fade(
            const HomePage(),
          ),
          (route) => false,
        );
      } else if (errorMsg != null) {
        setState(() {
          _errorMessage = errorMsg!;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    const double whiteContainerHeight = 270.0;

    return DisableSwipeBack(
      child: KeyboardDismisser(
        gestures: const [
          GestureType.onTap,
          GestureType.onPanUpdateDownDirection
        ],
        child: Scaffold(
          // Prevent content from being hidden by the keyboard
          resizeToAvoidBottomInset: true,
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
                    title: l10n.signInTitle,
                    subtitle: l10n.signInSubtitle,
                    height: whiteContainerHeight,
                  ),
                ),
                // Form content
                Positioned(
                  top: whiteContainerHeight,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: SingleChildScrollView(
                    // Close keyboard when scrolling down
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    // Ensure scroll works even with little content
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 30, bottom: 40),
                      child: Form(
                        key: _formKey,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Email field with validation and autovalidation
                              AuthInputField(
                                label: l10n.email,
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return l10n.emailRequired;
                                  }
                                  if (!RegExp(
                                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                      .hasMatch(value)) {
                                    return l10n.emailInvalid;
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              // Password field with validation and autovalidation
                              AuthInputField(
                                label: l10n.password,
                                controller: _passwordController,
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
                              // Error message if any
                              if (_errorMessage.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 16.0),
                                  child: Center(
                                    child: Text(
                                      // Translate error message based on key
                                      ErrorMessagesHelper.getAuthErrorMessage(
                                          l10n, _errorMessage),
                                      style: const TextStyle(
                                        color: AppColors.errorColor,
                                        fontSize: 14,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),

                              // Sign in button
                              Center(
                                child: AuthButton(
                                  text: l10n.signInButton,
                                  onTap: _isLoading ? null : _signIn,
                                  isLoading: _isLoading,
                                ),
                              ),
                              const SizedBox(height: 16),
                              // Link to sign up
                              Center(
                                child: TextButton(
                                  onPressed: () {
                                    // Close keyboard before navigating
                                    FocusScope.of(context).unfocus();
                                    // Navigate to sign up page
                                    Navigator.of(context).pushReplacement(
                                      AppPageTransition.fade(
                                          const SignUpPage()),
                                    );
                                  },
                                  child: Text(
                                    l10n.noAccount,
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                ),
                              ),
                              // Forgot password link
                              Center(
                                child: TextButton(
                                  onPressed: () {
                                    // Close keyboard before navigating
                                    FocusScope.of(context).unfocus();
                                    // Navigate to forgot password page
                                    Navigator.of(context).pushReplacement(
                                      AppPageTransition.fade(
                                          const ForgotPasswordPage()),
                                    );
                                  },
                                  child: Text(
                                    l10n.forgotPassword,
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
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
