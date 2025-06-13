import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../utils/constants.dart';
import '../../l10n/app_localizations.dart';

class StatsSectionWidget extends StatelessWidget {
  final int artworkCount;
  final int points;
  final int badgeCount;
  final VoidCallback? onBadgesTap;
  final bool showSwipeHint;
  final int currentPage;

  const StatsSectionWidget({
    super.key,
    required this.artworkCount,
    required this.points,
    required this.badgeCount,
    this.onBadgesTap,
    this.showSwipeHint = false,
    this.currentPage = 0,
  });

  String _formatNumber(int number) {
    final formatter = NumberFormat('#,###', 'en_US');
    return formatter.format(number).replaceAll(',', ' ');
  }

  Widget _buildStatItem(String title, int value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: TextStyle(
            color: AppColors.textDarkBrown.withValues(alpha: 0.6),
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _formatNumber(value),
          style: const TextStyle(
            color: AppColors.textDarkBrown,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 24,
      width: 1,
      color: AppColors.dividerGrey,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.statCardBackground.withValues(alpha: 0.8),
                  AppColors.statCardBackground.withValues(alpha: 0.5),
                  AppColors.statCardBackground.withValues(alpha: 0.3),
                ],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: _buildStatItem(
                    AppLocalizations.of(context)!.artworks,
                    artworkCount,
                  ),
                ),
                _buildDivider(),
                Expanded(
                  child: _buildStatItem(
                    AppLocalizations.of(context)!.points,
                    points,
                  ),
                ),
                _buildDivider(),
                Expanded(
                  child: onBadgesTap != null
                      ? GestureDetector(
                          onTap: onBadgesTap,
                          child: _buildStatItem(
                            AppLocalizations.of(context)!.badges,
                            badgeCount,
                          ),
                        )
                      : _buildStatItem(
                          AppLocalizations.of(context)!.badges,
                          badgeCount,
                        ),
                ),
              ],
            ),
          ),
          if (showSwipeHint) ... [
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  currentPage == 0 ? Icons.swipe_left : Icons.swipe_right,
                  size: 16,
                  color: AppColors.standardGrey.withValues(alpha: 0.6),
                ),
                const SizedBox(width: 4),
                Text(
                  currentPage == 0
                      ? AppLocalizations.of(context)!.swipeToSeeBadges
                      : AppLocalizations.of(context)!.swipeToSeeArtworks,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.standardGrey.withValues(alpha: 0.6),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}