import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import '../../utils/constants.dart';

class WhiteHeaderContainer extends StatelessWidget {
  final String title;
  final String subtitle;
  final double height;
  final Widget? bottomWidget;
  final double spaceBetweenTitleSubtitle;
  final double topPadding;

  const WhiteHeaderContainer({
    super.key,
    required this.title,
    required this.subtitle,
    required this.height,
    this.bottomWidget,
    this.spaceBetweenTitleSubtitle = 16.0,
    this.topPadding = 20.0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SizedBox(
              // Explicit container for the image size
              width: MediaQuery.of(context).size.width,
              height: height + 85,
              child: Image.asset(
                'assets/images/Union.png',
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
              ),
            ),
          ),
          // Content on top of the image
          SizedBox(
            height: height,
            width: double.infinity,
            child: SafeArea(
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 2),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                    ),
                    child: AutoSizeText(
                      title,
                      style: Theme.of(context).textTheme.headlineMedium,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      minFontSize: 18,
                    ),
                  ),
                  SizedBox(height: spaceBetweenTitleSubtitle),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 39.0,
                    ),
                    child: AutoSizeText(
                      subtitle,
                      style: AppTextStyles.subtitleStyle,
                      textAlign: TextAlign.center,
                      maxLines: 4,
                      minFontSize: 12,
                    ),
                  ),
                  const Spacer(
                      flex:
                          3),
                  if (bottomWidget != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: bottomWidget!,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
