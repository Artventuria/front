import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../utils/constants.dart'; // For AppColors
import '../../models/leaderboard_entry.dart';
import '../../screens/authenticated/user_profile_page.dart';

class LeaderboardItem extends StatelessWidget {
  final LeaderboardEntry entry;
  final bool isCurrentUser;

  const LeaderboardItem({
    super.key,
    required this.entry,
    this.isCurrentUser = false, // Default to false
  });

  String _formatPoints(int points) {
    final formatter = NumberFormat('#,###', 'en_US');
    return formatter.format(points).replaceAll(',', ' ');
  }

  Border? _getTopRankBorder(int rank) {
    Color borderColor;
    double borderWidth = 2.5; // Slightly thicker border for top ranks

    switch (rank) {
      case 1:
        borderColor = AppColors.medalGold; // Gold
        break;
      case 2:
        borderColor = AppColors.medalSilver; // Silver
        break;
      case 3:
        borderColor = AppColors.medalBronze; // Bronze
        break;
      default:
        return null; // No border for other ranks
    }
    return Border.all(color: borderColor, width: borderWidth);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          // Not open profile if it's the actual user
          if (!isCurrentUser) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => UserProfilePage(
                  userId: entry.userId,
                  username: entry.username,
                ),
              ),
            );
          }
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.symmetric(
              vertical: 8,
              horizontal: 12), // Added horizontal padding for bordered item
          decoration: isCurrentUser
              ? BoxDecoration(
                  border: Border.all(color: AppColors.gradientEnd, width: 2.0),
                  borderRadius: BorderRadius.circular(12.0),
                )
              : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 0), // Horizontal padding handled by page
            child: Row(
              children: [
                // Profile Image with Rank Overlay
                Stack(
                  clipBehavior: Clip
                      .none, // Allow positioned items to go slightly outside if needed for styling
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.lightGrey, // Placeholder color
                        border: _getTopRankBorder(entry.rank),
                        boxShadow: [
                          BoxShadow(
                            color:
                                AppColors.avatarShadow, // Avatar shadow color
                            blurRadius: 50,
                            offset: const Offset(0, 20),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          entry.username.isNotEmpty
                              ? entry.username.substring(0, 1).toUpperCase()
                              : '?',
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            color: AppColors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -2, // Adjust for visual preference
                      right: -2, // Adjust for visual preference
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                            color: AppColors
                                .gradientEnd, // Background color for the rank text
                            borderRadius: BorderRadius.circular(
                                8), // Rounded corners for the rank badge
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(
                                    alpha: 0.2), // Shadow for rank badge
                                blurRadius: 3,
                                offset: const Offset(1, 1),
                              )
                            ]),
                        child: Text(
                          '${entry.rank}',
                          style: const TextStyle(
                            color: AppColors
                                .white, // Text color for rank, white contrasts well with pink
                            fontWeight: FontWeight.bold,
                            fontSize: 12, // Slightly smaller font for the badge
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                // User info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment:
                        MainAxisAlignment.center, // Vertically center the texts
                    children: [
                      Text(
                        entry.username,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 16,
                          fontWeight: FontWeight.w500, // Medium
                          color: AppColors.buttonPurple,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatPoints(entry.points),
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 20,
                          fontWeight: FontWeight.w600, // SemiBold
                          color: AppColors.buttonPurple,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16), // Spacing before badge count
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.military_tech_outlined,
                      size: 16,
                      color: AppColors.buttonPurple.withValues(alpha: 0.8),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      entry.badgeCount.toString(),
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w500, // Medium
                        color: AppColors.buttonPurple,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ));
  }
}
