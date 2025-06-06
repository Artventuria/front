import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../widgets/landing/model_viewer_widget.dart';
import '../../widgets/common/page_indicator_widget.dart';
import '../../widgets/landing/explore_button_widget.dart';
import '../../widgets/common/white_header_container.dart';
import '../../l10n/app_localizations.dart';
import '../auth/sign_in_page.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final int _totalPages = 4;
  int _currentPage = 0;
  final PageController _pageController = PageController(initialPage: 0);
  final double titleApproxHeight = 55;
  final double subtitleApproxHeight = 38;

  // List of 3D model paths for each page
  final List<String> _modelPaths = [
    'assets/3D/napoleon_on_a_horse.glb',
    'assets/3D/bust_of_nefertiti_foia_results.glb',
    'assets/3D/psx_painting.glb',
    'assets/3D/death_crowning_innocence_1896.glb',
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  String _getLocalizedTitle(BuildContext context, int index) {
    final l10n = AppLocalizations.of(context)!;
    switch (index) {
      case 0:
        return l10n.landingPage1Title;
      case 1:
        return l10n.landingPage2Title;
      case 2:
        return l10n.landingPage3Title;
      case 3:
        return l10n.landingPage4Title;
      default:
        return '';
    }
  }

  String _getLocalizedSubtitle(BuildContext context, int index) {
    final l10n = AppLocalizations.of(context)!;
    switch (index) {
      case 0:
        return l10n.landingPage1Subtitle;
      case 1:
        return l10n.landingPage2Subtitle;
      case 2:
        return l10n.landingPage3Subtitle;
      case 3:
        return l10n.landingPage4Subtitle;
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    const double whiteContainerHeight = 270.0;
    const double swipeThreshold = 200.0; // Threshold for swipe gesture velocity

    // Calculate image position and size
    final double imageDisplayHeight =
        MediaQuery.of(context).size.height * 0.60; // Slightly larger image
    final double pinkAreaHeight = MediaQuery.of(context).size.height - whiteContainerHeight;

    // Adjust top padding to raise the image: divide remaining space by a larger factor for top padding
    final double imageTopPaddingInPinkArea =
        (pinkAreaHeight - imageDisplayHeight) > 0
            ? (pinkAreaHeight - imageDisplayHeight) / 4 // Raised from center
            : 0;
    final double imageActualTop =
        whiteContainerHeight + imageTopPaddingInPinkArea;

    // Adjusted SizedBox heights for more compact content in white box
    final double spaceBetweenTitleSubtitle =
        (150.0 - (48.0 + titleApproxHeight)) * 0.45;
    return Scaffold(
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
            // Layer 1: PageView for 3D models
            PageView.builder(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              physics:
                  const NeverScrollableScrollPhysics(), // Disable direct PageView scrolling
              itemCount: _totalPages,
              itemBuilder: (context, index) {
                // Each page in PageView is a Stack with the positioned 3D model
                return Stack(
                  children: [
                    // Position the 3D model
                    Positioned(
                      top: imageActualTop,
                      left: 0,
                      right: 0,
                      height: imageDisplayHeight,
                      child: LandingModelViewer(
                        modelPath: _modelPaths[index],
                        isTableModel: index == 3,
                        height: imageDisplayHeight,
                      ),
                    ),
                    if (index == 3) // Conditionally add button for the fourth page
                      Positioned(
                        bottom: 60, // Position at the bottom of the screen as shown in design
                        left: 0,
                        right: 0,
                        child: Center(
                          child: ExploreButton(
                            onTap: () {
                              // Navigate to the sign in page
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => const SignInPage(),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
            // Layer 2: White container with swipe gesture detection
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: GestureDetector(
                onHorizontalDragEnd: (DragEndDetails details) {
                  if (details.primaryVelocity == null) return; // No swipe
                  // Check if swipe velocity is significant enough
                  if (details.primaryVelocity!.abs() < swipeThreshold) return;

                  if (details.primaryVelocity! < 0) {
                    // Swiped left (finger moves R to L)
                    if (_currentPage < _totalPages - 1) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      );
                    }
                  } else if (details.primaryVelocity! > 0) {
                    // Swiped right (finger moves L to R)
                    if (_currentPage > 0) {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      );
                    }
                  }
                },
                child: WhiteHeaderContainer(
                  title: _getLocalizedTitle(context, _currentPage),
                  subtitle: _getLocalizedSubtitle(context, _currentPage),
                  height: whiteContainerHeight,
                  spaceBetweenTitleSubtitle: spaceBetweenTitleSubtitle,
                  bottomWidget: PageIndicator(
                    totalPages: _totalPages,
                    currentPage: _currentPage,
                    onPageTapped: (index) {
                      _pageController.animateToPage(
                        index,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
