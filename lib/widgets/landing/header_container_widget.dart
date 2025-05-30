import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import '../../utils/constants.dart';
import '../../l10n/app_localizations.dart';
import 'page_indicator_widget.dart';

class HeaderContainer extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final Function(int) onPageTapped;
  final double height;
  final double spaceBetweenTitleSubtitle;

  const HeaderContainer({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onPageTapped,
    required this.height,
    required this.spaceBetweenTitleSubtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(AppSizes.borderRadius),
          bottomRight: Radius.circular(AppSizes.borderRadius),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20), // Top padding inside SafeArea
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppSizes.pagePadding > 0
                    ? AppSizes.pagePadding
                    : AppSizes.pagePadding / 2,
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
                child: AutoSizeText(
                  _getLocalizedTitle(context, currentPage),
                  key: ValueKey<String>('title_$currentPage'),
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  minFontSize: 18,
                ),
              ),
            ),
            SizedBox(height: spaceBetweenTitleSubtitle),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: (AppSizes.pagePadding + 10) > 0
                    ? AppSizes.pagePadding + 15
                    : (AppSizes.pagePadding / 2) + 15,
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
                child: AutoSizeText(
                  _getLocalizedSubtitle(context, currentPage),
                  key: ValueKey<String>('subtitle_$currentPage'),
                  style: AppTextStyles.subtitleStyle,
                  textAlign: TextAlign.center,
                  maxLines: 4,
                  minFontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 10.0), // Margin between subtitle and page indicator
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: PageIndicator(
                totalPages: totalPages,
                currentPage: currentPage,
                onPageTapped: onPageTapped,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getLocalizedTitle(BuildContext context, int index) {
    final localizations = AppLocalizations.of(context)!;
    switch (index) {
      case 0:
        return localizations.landingPage1Title;
      case 1:
        return localizations.landingPage2Title;
      case 2:
        return localizations.landingPage3Title;
      case 3:
        return localizations.landingPage4Title;
      default:
        return localizations.landingPage1Title;
    }
  }

  String _getLocalizedSubtitle(BuildContext context, int index) {
    final localizations = AppLocalizations.of(context)!;
    switch (index) {
      case 0:
        return localizations.landingPage1Subtitle;
      case 1:
        return localizations.landingPage2Subtitle;
      case 2:
        return localizations.landingPage3Subtitle;
      case 3:
        return localizations.landingPage4Subtitle;
      default:
        return localizations.landingPage1Subtitle;
    }
  }
}
