import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/constants.dart';
import '../../l10n/app_localizations.dart';
import '../search/artwork_search_delegate.dart';

class HomeHeaderWidget extends StatelessWidget {
  final ScrollController scrollController;

  const HomeHeaderWidget({
    super.key,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              scrollController.animateTo(
                0,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
              );
            },
            child: Text(
              AppLocalizations.of(context)!.homePageExplore,
              style: GoogleFonts.merriweather(
                fontSize: 22,
                fontWeight: FontWeight.w400,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.search,
                      size: 20, color: AppColors.searchIconColor),
                  onPressed: () {
                    showSearch(
                      context: context,
                      delegate: ArtworkSearchDelegate(context),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
