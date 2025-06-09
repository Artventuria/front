import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../models/artwork/artwork_model.dart';
import '../../providers/artwork_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/home/full_screen_artwork_page.dart';

class ArtworkDetailPage extends StatefulWidget {
  final ArtworkModel artwork;

  const ArtworkDetailPage({
    super.key,
    required this.artwork,
  });

  @override
  State<ArtworkDetailPage> createState() => _ArtworkDetailPageState();
}

class _ArtworkDetailPageState extends State<ArtworkDetailPage> {
  final ScrollController _scrollController = ScrollController();
  bool _isAppBarVisible = false;

  // Cache API requests results
  late Future<bool> _artworkInCollectionFuture;
  late Future<int> _collectorsCountFuture;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    // Initialize futures once
    _artworkInCollectionFuture =
        _checkIfArtworkInCollection(widget.artwork.id.toString());
    _collectorsCountFuture =
        Provider.of<ArtworkProvider>(context, listen: false)
            .getArtworkCollectorsCount(widget.artwork.id.toString());
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  // Method to check if the artwork is in the user's collection via the provider
  Future<bool> _checkIfArtworkInCollection(String artworkId) async {
    final provider = Provider.of<ArtworkProvider>(context, listen: false);
    return await provider.isArtworkInCollection(artworkId);
  }

  void _onScroll() {
    // Show app bar when scrolled past the image
    final showAppBar = _scrollController.offset > 250;
    if (showAppBar != _isAppBarVisible) {
      setState(() {
        _isAppBarVisible = showAppBar;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56.0),
        child: AnimatedOpacity(
          opacity: _isAppBarVisible ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 200),
          child: AppBar(
            backgroundColor: Colors.white,
            elevation: 0.5,
            iconTheme: const IconThemeData(color: AppColors.textPrimary),
            title: Text(
              widget.artwork.title,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            systemOverlayStyle: SystemUiOverlayStyle.dark,
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, AppColors.homeBackgroundEnd],
          ),
        ),
        child: _buildBody(context),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return CustomScrollView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: _buildHeroHeader(context),
        ),
        SliverToBoxAdapter(
          child: _buildLocationPointsStatusRow(context),
        ),
        SliverToBoxAdapter(
          child: _buildDetailsSection(context),
        ),
      ],
    );
  }

  Widget _buildHeroHeader(BuildContext context) {
    // Use a percentage of the screen height for better adaptation
    final screenHeight = MediaQuery.of(context).size.height;
    return Container(
      height: screenHeight * 0.9, // 90% of the screen height
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Main image
          if (widget.artwork.metadata.imageUrl.isNotEmpty)
            Hero(
              tag: 'artwork-${widget.artwork.id}',
              child: CachedNetworkImage(
                imageUrl: widget.artwork.metadata.imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: AppColors.lightGrey,
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.purpleIndicator,
                      strokeWidth: 2,
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: AppColors.lightGrey,
                  child: const Icon(
                    Icons.image_not_supported,
                    color: AppColors.standardGrey,
                    size: 64,
                  ),
                ),
              ),
            ),
          // Gradient overlay for readability
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withAlpha(128),
                ],
                stops: const [0.7, 1.0],
              ),
            ),
          ),
          // Back button
          Positioned(
            top: 40,
            left: 16,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(76),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),

          // Fullscreen button positionned to bottom right like on the homepage
          Positioned(
            bottom: 16,
            right: 16,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(76),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.fullscreen, color: Colors.white),
                onPressed: () {
                  // Ensure the import is correct
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => FullScreenArtworkPage(
                        imageName: widget.artwork.metadata.imageUrl,
                        title: widget.artwork.title,
                        artist: widget.artwork.artist,
                        year: int.tryParse(
                                widget.artwork.creationDate.split('-').first) ??
                            0,
                        isNetworkImage: true,
                      ),
                    ),
                  );
                },
                tooltip: AppLocalizations.of(context)!.fullScreen,
              ),
            ),
          ),
          // Artwork title
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Column(
              mainAxisSize:
                  MainAxisSize.min, // Important to limit the column size
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.artwork.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        offset: Offset(0, 1),
                        blurRadius: 3,
                        color: Color.fromARGB(255, 0, 0, 0),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.artwork.artist,
                  style: TextStyle(
                    color: Colors.white.withAlpha(230),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    shadows: const [
                      Shadow(
                        offset: Offset(0, 1),
                        blurRadius: 2,
                        color: Color.fromARGB(255, 0, 0, 0),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Simple method for the few titles still needed
  Widget _buildMinimalTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.standardGrey),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsSection(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    // Store metadata reference to avoid repeated access
    final metadata = widget.artwork.metadata;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main description - without title
          _buildExpandableText(widget.artwork.description),
          const SizedBox(height: 16),

          // Container for technical information
          Container(
            margin: const EdgeInsets.symmetric(vertical: 0),
            decoration: BoxDecoration(
              color: AppColors.lightGrey.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Materials
                if (metadata.materials.isNotEmpty) ...[
                  _buildSpecificationItem(
                    localizations.materials,
                    metadata.materials.join(', '),
                  ),
                  const SizedBox(height: 8),
                ],
                // Dimensions
                _buildSpecificationItem(
                  localizations.dimensions,
                  _formatDimensions(metadata.dimensions),
                ),
              ],
            ),
          ),

          // Extended description if available (without title)
          if (metadata.descriptionExtended.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildExpandableText(metadata.descriptionExtended),
          ],

          // Historical context if available (with a minimal title)
          if (metadata.historicalContext.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildMinimalTitle(localizations.historicalContext, Icons.history),
            _buildExpandableText(metadata.historicalContext),
          ],

          // Tags with modern display
          if (metadata.tags.isNotEmpty) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: metadata.tags.map((tag) => _buildTagChip(tag)).toList(),
            ),
          ],

          // Additional information with "Did you know?" title and lightbulb icon
          if (metadata.additionalDetails.isNotEmpty) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.lightbulb_outline,
                    size: 20, color: AppColors.pointsColor),
                const SizedBox(width: 8),
                Text(
                  AppLocalizations.of(context)!.didYouKnow,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.pointsColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildExpandableText(metadata.additionalDetails),
          ],

          // External links
          if (metadata.externalLinks.isNotEmpty) ...[
            const SizedBox(height: 16),
            ...metadata.externalLinks.map((link) => _buildExternalLink(link)),
          ],

          // Final space reduced
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildExpandableText(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        color: AppColors.textPrimary,
        height: 1.4,
      ),
    );
  }

  Widget _buildSpecificationItem(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary.withAlpha(178),
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTagChip(String tag) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.purpleIndicator.withAlpha(25),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.purpleIndicator.withAlpha(76)),
      ),
      child: Text(
        tag,
        style: const TextStyle(
          fontSize: 12,
          color: AppColors.purpleIndicator,
        ),
      ),
    );
  }

  Widget _buildExternalLink(String link) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: () async {
          final url = Uri.parse(link);
          if (await canLaunchUrl(url)) {
            launchUrl(url);
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.lightGrey.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
                color: AppColors.purpleIndicator.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.open_in_new,
                  size: 16, color: AppColors.purpleIndicator),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _formatLink(link),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.purpleIndicator,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatLink(String url) {
    try {
      final uri = Uri.parse(url);
      if (uri.host.isNotEmpty) {
        // Returns the site name without www. and with extraction of the main path
        String displayText = uri.host.replaceFirst('www.', '');
        if (uri.pathSegments.isNotEmpty) {
          displayText += uri.pathSegments.length > 2
              ? '/${uri.pathSegments[0]}/...'
              : '/${uri.pathSegments.join('/')}';
        }
        return displayText;
      }
      return url;
    } catch (_) {
      return url;
    }
  }

  String _formatDate(String? date) {
    if (date == null) return AppLocalizations.of(context)!.notAvailable;
    try {
      final DateTime parsedDate = DateTime.parse(date);
      return '${parsedDate.year}';
    } catch (e) {
      return date;
    }
  }

  String _formatDimensions(dynamic dimensions) {
    // Access the properties of the ArtworkDimensionsModel object
    final width = dimensions.width;
    final height = dimensions.height;
    final depth = dimensions.depth;
    final unit = dimensions.unit;

    String result = '';
    if (width != null) result += '$width';
    if (height != null) result += ' × $height';
    if (depth != null && depth > 0) result += ' × $depth';
    result += ' $unit';

    return result;
  }

  // Method to display location, points and capture status
  Widget _buildLocationPointsStatusRow(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.lightGrey.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.purpleIndicator.withValues(alpha: 0.25),
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // First row: Capture status, Points and Collections
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Capture indicator based on a boolean provided by the API
              FutureBuilder<bool>(
                future: _artworkInCollectionFuture,
                builder: (context, snapshot) {
                  // Handle loading and error states
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: Colors.grey.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            AppLocalizations.of(context)!.loading,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  // Get the capture status (default to false in case of error)
                  final bool isCaptured = snapshot.data ?? false;

                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isCaptured
                          ? Colors.green.withValues(alpha: 0.1)
                          : Colors.grey.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isCaptured
                            ? Colors.green.withValues(alpha: 0.3)
                            : Colors.grey.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isCaptured
                              ? Icons.check_circle_outline
                              : Icons.radio_button_unchecked,
                          size: 14,
                          color: isCaptured ? Colors.green : Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isCaptured
                              ? AppLocalizations.of(context)!.collected
                              : AppLocalizations.of(context)!.notCollected,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isCaptured ? Colors.green : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              // Points with style consistent with the homepage
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.pointsBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.brush,
                        size: 14, color: AppColors.pointsColor),
                    const SizedBox(width: 4),
                    Text(
                      '${widget.artwork.rarityPoints} ${AppLocalizations.of(context)!.points}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.pointsColor,
                      ),
                    ),
                  ],
                ),
              ),

              // Number of collectors with API call via provider
              FutureBuilder<int>(
                future: _collectorsCountFuture,
                builder: (context, snapshot) {
                  // Display a loading indicator
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.lightGrey.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color:
                                AppColors.standardGrey.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.textDarkGrey,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            AppLocalizations.of(context)!.loadingEllipsis,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDarkGrey,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  // Get the number of collectors (default to 0 in case of error)
                  final int collectorsCount = snapshot.data ?? 0;

                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.lightGrey.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: AppColors.standardGrey.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.people_outline,
                          size: 14,
                          color: AppColors.textDarkGrey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          collectorsCount.toString(),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDarkGrey,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Second row: Location and date
          Row(
            children: [
              // Location
              const Icon(Icons.location_on_outlined,
                  size: 16, color: AppColors.standardGrey),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  widget.artwork.location,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              // Date
              const Icon(Icons.calendar_today_outlined,
                  size: 14, color: AppColors.standardGrey),
              const SizedBox(width: 4),
              Text(
                _formatDate(widget.artwork.creationDate),
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
