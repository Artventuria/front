import 'package:flutter/material.dart';

class AuthButton extends StatelessWidget {
  final VoidCallback? onTap;
  final String text;
  final double width;
  final double height;
  final bool isLoading;

  const AuthButton({
    super.key,
    required this.onTap,
    required this.text,
    this.width = 155,
    this.height = 46,
    this.isLoading = false,
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
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(23.0),
          onTap: isLoading ? null : onTap,
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.0,
                    ),
                  )
                : Text(
                    text,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
