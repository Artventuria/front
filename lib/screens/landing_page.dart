import 'package:flutter/material.dart';
import 'package:front/utils/constants.dart';
import 'package:front/l10n/app_localizations.dart';
import 'package:auto_size_text/auto_size_text.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final int _totalPages = 4;
  int _currentPage = 0;

  final double titleApproxHeight = 55;
  final double subtitleApproxHeight = 38;

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    const double whiteContainerHeight = 270.0;

    // Calculate image position and size
    final double imageDisplayHeight =
        size.height * 0.60; // Slightly larger image
    final double pinkAreaHeight = size.height - whiteContainerHeight;

    // Adjust top padding to raise the image: divide remaining space by a larger factor for top padding
    final double imageTopPaddingInPinkArea =
        (pinkAreaHeight - imageDisplayHeight) > 0
            ? (pinkAreaHeight - imageDisplayHeight) / 2.8 // Raised from center
            : 0;
    final double imageActualTop =
        whiteContainerHeight + imageTopPaddingInPinkArea;

    // Adjusted SizedBox heights for more compact content in white box
    final double spaceBetweenTitleSubtitle =
        (150.0 - (48.0 + titleApproxHeight)) * 0.45;
    final double spaceBetweenSubtitleIndicator =
        (220.0 - (150.0 + subtitleApproxHeight)) * 0.85;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.gradientStart, // Top page
              AppColors.gradientMiddle, // Middle page (F4D1D8)
              AppColors.gradientEnd, // Bottom page
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // 3D Artwork Image
            Positioned(
              top: imageActualTop,
              left: 0,
              right: 0,
              child: Image.asset(
                'assets/images/3D.png',
                fit: BoxFit.fitWidth,
              ),
            ),

            // Top white curved container
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: whiteContainerHeight,
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(AppSizes.borderRadius),
                    bottomRight: Radius.circular(AppSizes.borderRadius),
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: AppSizes.pagePadding > 0
                                  ? AppSizes.pagePadding
                                  : AppSizes.pagePadding / 2),
                          child: AutoSizeText(
                            AppLocalizations.of(context)!.landingPageTitle,
                            style: Theme.of(context).textTheme.headlineMedium,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            minFontSize: 18,
                          ),
                        ),
                        SizedBox(height: spaceBetweenTitleSubtitle),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: AppSizes.pagePadding + 10 > 0
                                  ? AppSizes.pagePadding + 15
                                  : AppSizes.pagePadding / 2 + 15),
                          child: AutoSizeText(
                            AppLocalizations.of(context)!.landingPageSubtitle,
                            style: AppTextStyles.subtitleStyle,
                            textAlign: TextAlign.center,
                            maxLines: 4,
                            minFontSize: 12,
                          ),
                        ),
                        SizedBox(height: spaceBetweenSubtitleIndicator),
                        Padding(
                          padding: EdgeInsets.only(
                              left: AppSizes.pagePadding > 0
                                  ? AppSizes.pagePadding
                                  : AppSizes.pagePadding / 2),
                          child: _buildPageIndicator(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: List.generate(_totalPages, (index) {
        return Container(
          width: AppSizes.indicatorSize,
          height: AppSizes.indicatorSize,
          margin:
              const EdgeInsets.symmetric(horizontal: AppSizes.indicatorSpacing / 2),
          decoration: BoxDecoration(
            color: _currentPage == index
                ? AppColors.purpleIndicator
                : AppColors.purpleIndicatorLight,
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }
}
