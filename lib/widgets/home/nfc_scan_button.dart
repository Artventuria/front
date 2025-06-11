import 'package:flutter/material.dart';
import '../../utils/constants.dart';

class NfcScanButton extends StatelessWidget {
  final VoidCallback onTap;

  const NfcScanButton({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        height: 80,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.circularGradientStart,
              AppColors.circularGradientEnd
            ],
          ),
        ),
        child: Container(
          margin: const EdgeInsets.all(4),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFFFAE7E9),
          ),
          child: const Center(
            child: Icon(
              Icons.add,
              color: AppColors.purpleIndicator,
              size: 40,
            ),
          ),
        ),
      ),
    );
  }
}
