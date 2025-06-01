import 'package:flutter/material.dart';
import 'package:front/l10n/app_localizations.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';

import '../../utils/constants.dart';
import '../../widgets/auth/auth_button_widget.dart';
import '../../widgets/auth/auth_input_field_widget.dart';
import '../../widgets/common/white_header_container.dart';
import '../../widgets/common/disable_swipe_back.dart';
import '../../widgets/common/page_transition.dart';
import 'sign_in_page.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _signUp() {
    if (_formKey.currentState?.validate() ?? false) {
      // TODO: Implement sign up logic
      debugPrint(
          'Sign up with username: ${_usernameController.text}, email: ${_emailController.text}');
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
                              // Create button
                              Center(
                                child: AuthButton(
                                  text: l10n.createButton,
                                  onTap: () {
                                    // Close keyboard before validating
                                    FocusScope.of(context).unfocus();
                                    _signUp();
                                  },
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
                                    style: const TextStyle(
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
