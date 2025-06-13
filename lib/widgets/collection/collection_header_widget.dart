import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/constants.dart';

class CollectionHeaderWidget extends StatelessWidget {
  final String title;
  final VoidCallback onSearchPressed;
  final VoidCallback? onBackPressed;
  final VoidCallback? onMenuPressed;

  const CollectionHeaderWidget({
    super.key,
    required this.title,
    required this.onSearchPressed,
    this.onBackPressed,
    this.onMenuPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (onBackPressed != null)
            Row(
              children: [
                GestureDetector(
                  onTap: onBackPressed,
                  child: const Icon(Icons.arrow_back,
                      color: AppColors.textPrimary),
                ),
                const SizedBox(width: 15),
                Text(
                  title,
                  style: GoogleFonts.merriweather(
                    fontSize: 22,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            )
          else
            Text(
              title,
              style: GoogleFonts.merriweather(
                fontSize: 22,
                fontWeight: FontWeight.w400,
                color: AppColors.textPrimary,
              ),
            ),
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.search,
                      size: 20, color: AppColors.searchIconColor),
                  onPressed: onSearchPressed,
                ),
              ),
              if (onMenuPressed != null) ... [
                const SizedBox(width: 10),
                IconButton(
                  icon: const Icon(Icons.more_vert,
                      size: 20, color: AppColors.textPrimary),
                  onPressed: onMenuPressed,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}