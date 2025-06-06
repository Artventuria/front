import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../utils/constants.dart';
import '../../providers/artwork_provider.dart';
import 'circular_artwork_widget.dart';

class RecentlyCollectedSection extends StatefulWidget {
  const RecentlyCollectedSection({super.key});

  @override
  State<RecentlyCollectedSection> createState() =>
      _RecentlyCollectedSectionState();
}

class _RecentlyCollectedSectionState extends State<RecentlyCollectedSection> {
  @override
  void initState() {
    super.initState();
    // Load recently collected artworks on widget initialization
    final artworkProvider =
        Provider.of<ArtworkProvider>(context, listen: false);
    artworkProvider.loadRecentlyCollectedArtworks();
  }

  @override
  Widget build(BuildContext context) {
    final artworkProvider = Provider.of<ArtworkProvider>(context);
    final artworks = artworkProvider.recentlyCollectedArtworks;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            AppLocalizations.of(context)!.homePageRecentlyCollected,
            style: GoogleFonts.merriweather(
              fontSize: 16,
              fontWeight: FontWeight.w300,
              color: AppColors.subtitlePink,
            ),
          ),
        ),
        const SizedBox(height: 5),
        if (artworkProvider.isLoadingRecentlyCollected && artworks.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 30),
              child: CircularProgressIndicator(),
            ),
          ),
        if (artworkProvider.hasErrorRecentlyCollected && artworks.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 24, color: AppColors.standardGrey),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context)!.errorLoadingArtworks,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.standardGrey, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      artworkProvider.loadRecentlyCollectedArtworks();
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.purpleIndicator,
                    ),
                    child: Text(AppLocalizations.of(context)!.retryButton),
                  ),
                ],
              ),
            ),
          ),
        if (!artworkProvider.isLoadingRecentlyCollected &&
            !artworkProvider.hasErrorRecentlyCollected &&
            artworks.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 30),
              child: Text(
                AppLocalizations.of(context)!.noRecentArtworks,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.standardGrey),
              ),
            ),
          ),
        if (artworks.isNotEmpty)
          SizedBox(
            height: 95,
            child: ListView.builder(
              padding: EdgeInsets.zero,
              scrollDirection: Axis.horizontal,
              itemCount: artworks.length,
              itemBuilder: (context, index) {
                EdgeInsets padding;
                if (index == 0) {
                  padding = const EdgeInsets.only(left: 20, right: 15);
                } else if (index == artworks.length - 1) {
                  padding = const EdgeInsets.only(right: 20);
                } else {
                  padding = const EdgeInsets.only(right: 15);
                }

                final artwork = artworks[index];

                return Padding(
                  padding: padding,
                  child: CircularArtworkWidget(
                    imageName: artwork.metadata.imageUrl,
                    onTap: () {
                      // TODO: Add navigation to artwork details
                    },
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
