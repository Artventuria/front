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
      padding: const EdgeInsets.symmetric(horizontal: 20.0), // Add horizontal padding
      child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF6A515E),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                spreadRadius: 1,
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            obscureText: isPassword,
            keyboardType: keyboardType,
            validator: validator,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              filled: true,
              fillColor: Colors.white,
              hintStyle: TextStyle(
                color: Colors.grey.withValues(alpha: 0.7),
                fontSize: 14,
              ),
            ),
            style: const TextStyle(
              color: Color(0xFF6A515E),
              fontSize: 16,
            ),
          ),
        ),
      ],
    ), // Fermeture du Column
    ); // Fermeture du Padding
  }
}
