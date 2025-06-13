import 'package:flutter/material.dart';
import '../../models/artwork/artwork_model.dart';
import '../../utils/constants.dart';
import '../../screens/artwork/artwork_detail_page.dart';
import '../home/full_screen_artwork_page.dart';
import '../../l10n/app_localizations.dart';

class ArtworkGridWidget extends StatelessWidget {
  final List<ArtworkModel> artworks;
  final bool isLoading;
  final bool hasMore;
  final ScrollController scrollController;
  final VoidCallback onRefresh;

  const ArtworkGridWidget({
    super.key,
    required this.artworks,
    required this.isLoading,
    required this.hasMore,
    required this.scrollController,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      color: AppColors.purpleIndicator,
      child: CustomScrollView(
        controller: scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // Space between stats and artworks grid
          const SliverToBoxAdapter(
            child: SizedBox(height: 24),
          ),

          // Grid view of artworks
          if (isLoading && artworks.isEmpty)
            const SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          else if (artworks.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Text(
                  AppLocalizations.of(context)!.noArtworksCollectedYet,
                  style: const TextStyle(
                    color: AppColors.textGrey,
                    fontSize: 18,
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  childAspectRatio: 1,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final artwork = artworks[index];
                    return _buildArtworkItem(context, artwork);
                  },
                  childCount: artworks.length,
                ),
              ),
            ),

          // Loading indicator at bottom when loading more
          if (isLoading && artworks.isNotEmpty)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),

          // Bottom padding
          const SliverToBoxAdapter(
            child: SizedBox(height: 70),
          ),
        ],
      ),
    );
  }

  Widget _buildArtworkItem(BuildContext context, ArtworkModel artwork) {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Artwork image
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
                    if (loadingProgress == null) {
                      return child;
                    }
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
                      color: AppColors.imageErrorBackground,
                      child: const Center(
                        child: Icon(Icons.broken_image,
                            size: 64, color: AppColors.standardGrey),
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
              color: AppColors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(15),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ArtworkDetailPage(artwork: artwork),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.transparentBlack,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Icon(
                    Icons.info_outline,
                    color: AppColors.white,
                    size: 16,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}