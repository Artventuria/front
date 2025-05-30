import 'package:flutter/material.dart';

class AuthButton extends StatelessWidget {
  final VoidCallback onTap;
  final String text;
  final double width;
  final double height;

  const AuthButton({
    super.key,
    required this.onTap,
    required this.text,
    this.width = 155,
    this.height = 46,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color(0xFFF8A170), // Orange/peach color from left
            Color(0xFF7B9FE4), // Blue color to right
          ],
        ),
        borderRadius: BorderRadius.circular(23.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(23.0),
          onTap: onTap,
          child: Center(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
