import 'package:flutter/material.dart';

class AuthInputField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool isPassword;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const AuthInputField({
    super.key,
    required this.label,
    required this.controller,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Input label
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF6A515E),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          // Using FormField to gain more control over validation
          FormField<String>(
            validator: (value) {
              if (validator != null) {
                return validator!(controller.text);
              }
              return null;
            },
            autovalidateMode: AutovalidateMode.onUserInteraction,
            builder: (FormFieldState<String> state) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Input container
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        // Red border if error, otherwise transparent
                        color: state.hasError
                            ? const Color(0xFFE57373)
                            : Colors.transparent,
                        width: 1.0,
                      ),
                    ),
                    child: TextFormField(
                      controller: controller,
                      obscureText: isPassword,
                      keyboardType: keyboardType,
                      // Disable integrated validation
                      validator: (_) => null,
                      // Inform the FormField of the state when the text changes
                      onChanged: (value) {
                        if (state.hasError) {
                          state.validate();
                        }
                      },
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        filled: true,
                        fillColor: Colors.white,
                        hintStyle: TextStyle(
                          color: Colors.grey.withValues(alpha: 0.7),
                          fontSize: 14,
                        ),
                        // Remove error space
                        errorStyle: const TextStyle(height: 0, fontSize: 0),
                        // Disable error border
                        errorBorder: InputBorder.none,
                        focusedErrorBorder: InputBorder.none,
                      ),
                      style: const TextStyle(
                        color: Color(0xFF6A515E),
                        fontSize: 16,
                      ),
                    ),
                  ),
                  // Error message below the field
                  if (state.hasError)
                    Padding(
                      padding: const EdgeInsets.only(top: 6.0, left: 4.0),
                      child: Text(
                        state.errorText!,
                        style: const TextStyle(
                          color: Color(0xFFE57373),
                          fontSize: 12.0,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
