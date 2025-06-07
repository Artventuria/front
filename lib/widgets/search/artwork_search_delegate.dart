import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../models/artwork/artwork_model.dart';
import '../../providers/artwork_provider.dart';
import '../../utils/constants.dart';

class ArtworkSearchDelegate extends SearchDelegate<ArtworkModel?> {
  // Timer for the search debounce
  Timer? _debounceTimer;
  String _lastQuery = '';
  final BuildContext parentContext;

  ArtworkSearchDelegate(this.parentContext);

  @override
  void close(BuildContext context, ArtworkModel? result) {
    _cancelDebounceTimer();
    super.close(context, result);
  }

  void _cancelDebounceTimer() {
    _debounceTimer?.cancel();
    _debounceTimer = null;
  }

  @override
  String get searchFieldLabel => AppLocalizations.of(parentContext)?.searchArtwork ?? 'Search artwork';

  @override
  ThemeData appBarTheme(BuildContext context) {
    final theme = Theme.of(context);
    return theme.copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: InputBorder.none,
        hintStyle: TextStyle(color: AppColors.standardGrey),
      ),
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            query = '';
            showSuggestions(context);
          },
        ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults(context);
  }

  Widget _buildSearchResults(BuildContext context) {
    final artworkProvider = Provider.of<ArtworkProvider>(context, listen: true);

    // If the query is empty, do not search
    if (query.isEmpty) {
      // Cancel the debounce timer if the query is empty
      _cancelDebounceTimer();
      _lastQuery = '';

      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search,
                size: 64, color: AppColors.standardGrey.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.searchArtworksHint,
              style: TextStyle(color: AppColors.standardGrey, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // Launch the search if the query has changed and after a delay
    if (query.isNotEmpty && query != _lastQuery) {
      _lastQuery = query;
      _cancelDebounceTimer();

      // Wait 500ms before launching the search to avoid too many calls
      _debounceTimer = Timer(const Duration(milliseconds: 500), () {
        if (_lastQuery == query) {
          // Verify that the query has not changed during the delay
          artworkProvider.searchArtworks(query: query, resetResults: true);
        }
      });
    }

    // Display search results or loading indicator
    return Column(
      children: [
        Expanded(
          child: artworkProvider.isLoadingSearch &&
                  artworkProvider.searchResults.isEmpty
              ? const Center(
                  child: CircularProgressIndicator(
                      color: AppColors.purpleIndicator))
              : artworkProvider.searchResults.isEmpty &&
                      !artworkProvider.isLoadingSearch
                  ? _buildNoResultsWidget(context)
                  : _buildResultsList(context, artworkProvider),
        ),
      ],
    );
  }

  Widget _buildResultsList(
      BuildContext context, ArtworkProvider artworkProvider) {
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        // Detect end of scrolling to load more results
        if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent &&
            !artworkProvider.isLoadingSearch &&
            artworkProvider.hasMoreSearchResults) {
          artworkProvider.searchArtworks(query: query);
        }
        return false;
      },
      child: ListView.builder(
        itemCount: artworkProvider.searchResults.length +
            (artworkProvider.hasMoreSearchResults &&
                    artworkProvider.isLoadingSearch
                ? 1
                : 0),
        itemBuilder: (context, index) {
          // Display loading indicator at the bottom of the list if needed
          if (index >= artworkProvider.searchResults.length) {
            return const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(
                  child: CircularProgressIndicator(
                      color: AppColors.purpleIndicator)),
            );
          }

          // Display an artwork result
          final artwork = artworkProvider.searchResults[index];
          return _buildArtworkListTile(context, artwork);
        },
      ),
    );
  }

  Widget _buildArtworkListTile(BuildContext context, ArtworkModel artwork) {
    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      leading: artwork.metadata.imageUrl.isNotEmpty
          ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                artwork.metadata.imageUrl,
                width: 56,
                height: 56,
                fit: BoxFit.cover,
                errorBuilder: (context, _, __) => Container(
                  width: 56,
                  height: 56,
                  color: AppColors.lightGrey,
                  child: const Icon(Icons.image_not_supported,
                      color: AppColors.standardGrey),
                ),
              ),
            )
          : Container(
              width: 56,
              height: 56,
              color: AppColors.lightGrey,
              child: const Icon(Icons.image, color: AppColors.standardGrey),
            ),
      title: Text(
        artwork.title,
        style: const TextStyle(fontWeight: FontWeight.bold),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        artwork.artist,
        style: TextStyle(color: AppColors.textPrimary.withValues(alpha: 0.7)),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      onTap: () {
        // TODO: Navigate to artwork details
        close(context, artwork);
      },
    );
  }

  Widget _buildNoResultsWidget(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off,
              size: 64, color: AppColors.standardGrey.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.noSearchResults,
            style: TextStyle(color: AppColors.standardGrey, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
