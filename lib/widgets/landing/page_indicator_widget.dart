import 'package:flutter/material.dart';
import '../../utils/constants.dart';

class PageIndicator extends StatelessWidget {
  final int totalPages;
  final int currentPage;
  final Function(int) onPageTapped;

  const PageIndicator({
    super.key,
    required this.totalPages,
    required this.currentPage,
    required this.onPageTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalPages, (index) {
        return GestureDetector(
          onTap: () => onPageTapped(index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: currentPage == index ? 24.0 : 8.0,
            height: 8.0,
            margin: const EdgeInsets.symmetric(horizontal: 4.0),
            decoration: BoxDecoration(
              color: currentPage == index
                  ? AppColors.purpleIndicator
                  : AppColors.purpleIndicatorLight,
              borderRadius: BorderRadius.circular(4.0),
            ),
          ),
        );
      }),
    );
  }
}
