import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:provider/provider.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';

import '../../utils/error_messages_helper.dart';

import '../../providers/auth_provider.dart';
import '../../l10n/app_localizations.dart';
import '../../utils/constants.dart';
import '../../widgets/auth/auth_button_widget.dart';
import '../../widgets/auth/auth_input_field_widget.dart';
import '../../widgets/common/white_header_container.dart';
import '../../widgets/common/disable_swipe_back.dart';
import '../../widgets/common/page_transition.dart';
import 'sign_in_page.dart';
import 'password_validator.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _signUp() async {
    // Close keyboard first
    FocusScope.of(context).unfocus();

    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      if (kDebugMode) {
        debugPrint('Processing sign up request');
      }

      try {
        // Get the authentication provider
        final authProvider = Provider.of<AuthProvider>(context, listen: false);

        // Try to sign up
        final success = await authProvider.signup(
          _usernameController.text.trim(),
          _emailController.text.trim(),
          _passwordController.text,
        );

        if (success && mounted) {
          // Redirect to home page
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/home',
            (route) => false,
          );
        } else if (mounted) {
          // Store the error message
          setState(() {
            _errorMessage = authProvider.errorMessage;
          });
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Error during signup: $e');
        }

        if (mounted) {
          // Store the generic error
          setState(() {
            _errorMessage = "registerErrorUnexpected";
          });
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    const double whiteContainerHeight = 270.0;

    return DisableSwipeBack(
      child: KeyboardDismisser(
        gestures: [GestureType.onTap, GestureType.onPanUpdateDownDirection],
        child: Scaffold(
          // Prevent content from being hidden by the keyboard
          resizeToAvoidBottomInset: true,
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.gradientStart,
                  AppColors.gradientMiddle,
                  AppColors.gradientEnd,
                ],
                stops: const [0.0, 0.5, 1.0],
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
                    title: l10n.signUpTitle,
                    subtitle: l10n.signUpSubtitle,
                    height: whiteContainerHeight,
                    topPadding: 40.0,
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
                        // AutovalidateMode allows validating on user interaction
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Username field with validation
                              AuthInputField(
                                label: l10n.username,
                                controller: _usernameController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return l10n.usernameRequired;
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              // Email field
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
                              // Password field
                              AuthInputField(
                                label: l10n.password,
                                controller: _passwordController,
                                isPassword: true,
                                validator: PasswordValidator.validate,
                              ),
                              const SizedBox(height: 24),
                              // Show error message if any
                              if (_errorMessage.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 16.0),
                                  child: Center(
                                    child: Text(
                                      // Show error message
                                      ErrorMessagesHelper.getAuthErrorMessage(
                                          AppLocalizations.of(context)!,
                                          _errorMessage),
                                      style: const TextStyle(
                                        color: AppColors.errorColor,
                                        fontSize: 14,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              // Create button
                              Center(
                                child: AuthButton(
                                  text: l10n.createButton,
                                  onTap: _isLoading ? null : _signUp,
                                  isLoading: _isLoading,
                                ),
                              ),
                              const SizedBox(height: 16),
                              // Already have an account text button
                              Center(
                                child: TextButton(
                                  onPressed: () {
                                    // Close keyboard before navigating
                                    FocusScope.of(context).unfocus();
                                    // Navigate to sign in page
                                    Navigator.of(context).pushReplacement(
                                      AppPageTransition.fade(
                                          const SignInPage()),
                                    );
                                  },
                                  child: Text(
                                    l10n.hasAccount,
                                    style: TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w300,
                                    ),
                                    textAlign: TextAlign.center,
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
