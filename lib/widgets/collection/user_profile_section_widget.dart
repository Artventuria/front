import 'package:flutter/material.dart';
import '../../utils/constants.dart';

class UserProfileSectionWidget extends StatelessWidget {
  final String username;
  final String? fallbackUsername;

  const UserProfileSectionWidget({
    super.key,
    required this.username,
    this.fallbackUsername,
  });

  @override
  Widget build(BuildContext context) {
    final displayUsername = username.isNotEmpty ? username : (fallbackUsername ?? '?');
    final avatarLetter = displayUsername.isNotEmpty ? displayUsername.substring(0, 1).toUpperCase() : '?';

    return Padding(
      padding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 24.0),
      child: Center(
        child: Column(
          children: [
            // User avatar
            Container(
              width: 100,
              height: 100,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.lightGrey,
              ),
              child: Center(
                child: Text(
                  avatarLetter,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 36,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Username
            Text(
              displayUsername,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: AppColors.textDarkBrown,
              ),
            ),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
}