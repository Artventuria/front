import 'package:flutter/material.dart';
import '../../models/badge_model.dart';
import '../../utils/constants.dart';
import '../../l10n/app_localizations.dart';

class BadgeCardWidget extends StatelessWidget {
  final BadgeModel badge;

  const BadgeCardWidget({
    super.key,
    required this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: badge.obtained
              ? [
                  AppColors.statCardBackground.withValues(alpha: 0.8),
                  AppColors.statCardBackground.withValues(alpha: 0.5),
                ]
              : [
                  AppColors.lightGrey.withValues(alpha: 0.3),
                  AppColors.lightGrey.withValues(alpha: 0.1),
                ],
        ),
        borderRadius: BorderRadius.circular(15),
        border: badge.obtained
            ? Border.all(
                color: AppColors.purpleIndicator.withValues(alpha: 0.3),
                width: 1)
            : Border.all(
                color: AppColors.standardGrey.withValues(alpha: 0.2),
                width: 1),
      ),
      child: Row(
        children: [
          // Badge status indicator
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: badge.obtained
                  ? AppColors.purpleIndicator
                  : AppColors.standardGrey,
            ),
            child: Icon(
              badge.obtained ? Icons.check : Icons.lock_outline,
              color: AppColors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          // Badge info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  badge.name,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: badge.obtained
                        ? AppColors.textDarkBrown
                        : AppColors.standardGrey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  badge.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: badge.obtained
                        ? AppColors.textDarkBrown.withValues(alpha: 0.7)
                        : AppColors.standardGrey.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.brush,
                      size: 16,
                      color: badge.obtained
                          ? AppColors.purpleIndicator
                          : AppColors.standardGrey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${badge.points} ${AppLocalizations.of(context)!.pointsAbbreviation}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: badge.obtained
                            ? AppColors.purpleIndicator
                            : AppColors.standardGrey,
                      ),
                    ),
                    const Spacer(),
                    if (!badge.obtained)
                      Text(
                        '${AppLocalizations.of(context)!.badgeProgressionLabel}: ${badge.progress}',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.standardGrey.withValues(alpha: 0.8),
                        ),
                      ),
                    if (badge.obtained)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.purpleIndicator
                              .withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          AppLocalizations.of(context)!.badgeObtained,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: AppColors.purpleIndicator,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}