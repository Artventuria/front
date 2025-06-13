import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/artwork_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/constants.dart';
import '../../l10n/app_localizations.dart';
import 'artwork_scroll_item.dart';

class ArtworkScrollView extends StatelessWidget {
  const ArtworkScrollView({
    super.key,
  });

  Widget _buildCompletedCollectionMessage(BuildContext context) {
    // Container with fixed height to maintain the same position in both views
    return Container(
      height: 200,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            '👏',
            style: TextStyle(fontSize: 48),
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.allCollectedCongrats,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final artworkProvider = Provider.of<ArtworkProvider>(context);

    if (artworkProvider.isLoading &&
        artworkProvider.stillToCollectArtworks.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40),
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Show the congratulations message only if the request has succeeded and the array is empty
    // That is, when the user has really collected everything
    if (artworkProvider.stillToCollectArtworks.isEmpty && 
        !artworkProvider.isLoading && 
        !artworkProvider.hasError) {
      return _buildCompletedCollectionMessage(context);
    }
    
    if (artworkProvider.hasError &&
        artworkProvider.stillToCollectArtworks.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context)!.errorLoadingArtworks,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  final authProvider =
                      Provider.of<AuthProvider>(context, listen: false);
                  if (authProvider.user != null) {
                    artworkProvider.loadStillToCollectArtworks(
                      userId: authProvider.user!.id,
                      refresh: true,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.purpleIndicator,
                ),
                child: Text(AppLocalizations.of(context)!.retryButton),
              ),
            ],
          ),
        ),
      );
    }

    // Show the congratulations message only if the request has succeeded and the array is empty
    // That is, when the user has really collected everything
    if (artworkProvider.stillToCollectArtworks.isEmpty &&
        !artworkProvider.isLoading &&
        !artworkProvider.hasError) {
      return _buildCompletedCollectionMessage(context);
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const ClampingScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: artworkProvider.stillToCollectArtworks.length +
          (artworkProvider.hasMoreToLoad ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == artworkProvider.stillToCollectArtworks.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final artwork = artworkProvider.stillToCollectArtworks[index];
        final creationYear = DateTime.tryParse(artwork.creationDate)?.year ?? 0;

        return ArtworkScrollItem(
          imageName: artwork.metadata.imageUrl,
          title: artwork.title,
          artist: artwork.artist,
          year: creationYear,
          location: artwork.location,
          points: artwork.rarityPoints,
          description: artwork.description,
          artwork: artwork,
        );
      },
    );
  }
}
