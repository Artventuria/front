import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/artwork_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/constants.dart';
import '../../l10n/app_localizations.dart';
import '../../screens/artwork/artwork_detail_page.dart';
import '../home/full_screen_artwork_page.dart';

class ArtworkGridView extends StatelessWidget {
  const ArtworkGridView({super.key});

  @override
  Widget build(BuildContext context) {
    final artworkProvider = Provider.of<ArtworkProvider>(context);
    final artworks = artworkProvider.stillToCollectArtworks;

    if (artworkProvider.isLoading && artworks.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (artworkProvider.hasError && artworks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.errorLoadingArtworks,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                final authProvider =
                    Provider.of<AuthProvider>(context, listen: false);
                final user = authProvider.user;
                if (user != null) {
                  artworkProvider.loadStillToCollectArtworks(
                    userId: user.id,
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
      );
    }

    if (artworks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle_outline,
                size: 48, color: Colors.green),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.allCollectedCongrats,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const ClampingScrollPhysics(),
        padding: EdgeInsets.zero,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          childAspectRatio: 1,
        ),
        itemCount: artworks.length,
        itemBuilder: (context, index) {
          final artwork = artworks[index];
          // Use a SizedBox with known dimensions to wrap the Stack
          return SizedBox(
            // Dimensions constrained by the size of the grid cell
            width: double.infinity,
            height: double.infinity,
            child: Stack(
              fit:
                  StackFit.expand, // Ensure the Stack fills the available space
              children: [
                // Image of the artwork
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => FullScreenArtworkPage(
                            imageName: artwork.metadata.imageUrl,
                            title: artwork.title,
                            artist: artwork.artist,
                            year: int.tryParse(
                                    artwork.creationDate.split('-').first) ??
                                0,
                            isNetworkImage: true,
                          ),
                        ),
                      );
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: Image.network(
                        artwork.metadata.imageUrl,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[300],
                            child: const Center(
                              child: Icon(Icons.broken_image,
                                  size: 64, color: Colors.grey),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),

                // Button to access details
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(15),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                ArtworkDetailPage(artwork: artwork),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.black.withAlpha(80),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Icon(
                          Icons.info_outline,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
