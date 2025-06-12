import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../models/artwork/artwork_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_collection_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/search/user_collection_search_delegate.dart';
import '../../screens/artwork/artwork_detail_page.dart';
import '../../widgets/home/full_screen_artwork_page.dart';
import '../../l10n/app_localizations.dart';

class MyCollectionPage extends StatefulWidget {
  const MyCollectionPage({super.key});

  @override
  State<MyCollectionPage> createState() => _MyCollectionPageState();
}

class _MyCollectionPageState extends State<MyCollectionPage>
    with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();
  late UserCollectionProvider _collectionProvider;
  bool _initialLoadInitiated = false;

  @override
  void initState() {
    super.initState();
    _collectionProvider =
        Provider.of<UserCollectionProvider>(context, listen: false);
    _setupScrollListener();
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent * 0.7 &&
          !_collectionProvider.isLoading &&
          _collectionProvider.hasMoreArtworks) {
        _collectionProvider.loadCollectedArtworks();
      }
    });
  }

  Future<void> _loadInitialData() async {
    await _collectionProvider.refreshAllData();
  }

  Future<void> _refreshData() async {
    await _collectionProvider.refreshAllData();
  }

  Future<void> _showSearch() async {
    // Use await with showSearch to handle the asynchronous operation properly
    final ArtworkModel? artwork = await showSearch<ArtworkModel?>(
      context: context,
      delegate: UserCollectionSearchDelegate(context),
    );
    
    // Check if the widget is still mounted and artwork is not null before proceeding
    if (artwork != null && mounted) {
      Navigator.pushNamed(
        context,
        '/artwork-detail',
        arguments: {'artwork': artwork},
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  Widget _buildDivider() {
    return Container(
      height: 24,
      width: 1,
      color: AppColors.dividerGrey,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final authProvider = Provider.of<AuthProvider>(context);

    if (!_initialLoadInitiated && authProvider.user != null) {
      _initialLoadInitiated =
          true; // Mark as initiated to prevent multiple loads
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _loadInitialData();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.white, AppColors.homeBackgroundEnd],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // Fixed header
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.myCollection,
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
                            onPressed: _showSearch,
                          ),
                        ),
                        const SizedBox(width: 10),
                        IconButton(
                          icon: const Icon(Icons.more_vert,
                              size: 20, color: AppColors.textPrimary),
                          onPressed: () {
                            // Options menu
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Scrollable content
              Expanded(
                child: Consumer<UserCollectionProvider>(
                  builder: (context, provider, child) {
                    return RefreshIndicator(
                      onRefresh: _refreshData,
                      color: AppColors.purpleIndicator,
                      child: CustomScrollView(
                        controller: _scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        slivers: [
                          // User profile section
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                  24.0, 16.0, 24.0, 24.0),
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
                                          provider.userProfile != null &&
                                                  provider.userProfile!.username
                                                      .isNotEmpty
                                              ? provider.userProfile!.username
                                                  .substring(0, 1)
                                                  .toUpperCase()
                                              : authProvider.user != null &&
                                                      authProvider.user!
                                                          .username.isNotEmpty
                                                  ? authProvider.user!.username
                                                      .substring(0, 1)
                                                      .toUpperCase()
                                                  : '?',
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
                                      provider.userProfile?.username ??
                                          authProvider.user?.username ??
                                          AppLocalizations.of(context)!.user,
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
                            ),
                          ),

                          // Stats row
                          SliverToBoxAdapter(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16.0),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      AppColors.statCardBackground
                                          .withValues(alpha: 0.8),
                                      AppColors.statCardBackground
                                          .withValues(alpha: 0.5),
                                      AppColors.statCardBackground
                                          .withValues(alpha: 0.3),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    _buildStatItem(
                                        AppLocalizations.of(context)!.artworks,
                                        provider.userProfile?.artworkCount ??
                                            0),
                                    _buildDivider(),
                                    _buildStatItem('Points',
                                        provider.userProfile?.points ?? 0),
                                    _buildDivider(),
                                    _buildStatItem(
                                        AppLocalizations.of(context)!.badges,
                                        provider.userProfile?.badgeCount ?? 0),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // Space between stats and artworks grid
                          SliverToBoxAdapter(
                            child: SizedBox(height: 24.0),
                          ),

                          // Grid view of artworks
                          if (provider.isLoading &&
                              provider.collectedArtworks.isEmpty)
                            SliverFillRemaining(
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            )
                          else if (provider.collectedArtworks.isEmpty)
                            SliverFillRemaining(
                              child: Center(
                                child: Text(
                                  AppLocalizations.of(context)!
                                      .noArtworksCollectedYet,
                                  style: const TextStyle(
                                    color: AppColors.textGrey,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            )
                          else
                            SliverPadding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20.0),
                              sliver: SliverGrid(
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 20,
                                  mainAxisSpacing: 20,
                                  childAspectRatio: 1,
                                ),
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) {
                                    final artwork =
                                        provider.collectedArtworks[index];
                                    return SizedBox(
                                      width: double.infinity,
                                      height: double.infinity,
                                      child: Stack(
                                        fit: StackFit.expand,
                                        children: [
                                          // Artwork image
                                          Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                            ),
                                            child: GestureDetector(
                                              onTap: () {
                                                // Navigate to full screen artwork page
                                                Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        FullScreenArtworkPage(
                                                      imageName: artwork
                                                          .metadata.imageUrl,
                                                      title: artwork.title,
                                                      artist: artwork.artist,
                                                      year: int.tryParse(artwork
                                                              .creationDate
                                                              .split('-')
                                                              .first) ??
                                                          0,
                                                    ),
                                                  ),
                                                );
                                              },
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                                child: Image.network(
                                                  artwork.metadata.imageUrl,
                                                  fit: BoxFit.cover,
                                                  loadingBuilder: (context,
                                                      child, loadingProgress) {
                                                    if (loadingProgress ==
                                                        null) {
                                                      return child;
                                                    }
                                                    return Center(
                                                      child:
                                                          CircularProgressIndicator(
                                                        value: loadingProgress
                                                                    .expectedTotalBytes !=
                                                                null
                                                            ? loadingProgress
                                                                    .cumulativeBytesLoaded /
                                                                loadingProgress
                                                                    .expectedTotalBytes!
                                                            : null,
                                                      ),
                                                    );
                                                  },
                                                  errorBuilder: (context, error,
                                                      stackTrace) {
                                                    return Container(
                                                      color: AppColors.imageErrorBackground,
                                                      child: const Center(
                                                        child: Icon(
                                                            Icons.broken_image,
                                                            size: 64,
                                                            color: AppColors.standardGrey),
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
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                                onTap: () {
                                                  // Navigate to artwork detail page
                                                  Navigator.of(context).push(
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          ArtworkDetailPage(
                                                              artwork: artwork),
                                                    ),
                                                  );
                                                },
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.all(6),
                                                  decoration: BoxDecoration(
                                                    color: AppColors.transparentBlack,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15),
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
                                  },
                                  childCount: provider.collectedArtworks.length,
                                ),
                              ),
                            ),

                          // Loading indicator at bottom when loading more
                          if (provider.isLoading &&
                              provider.collectedArtworks.isNotEmpty)
                            SliverToBoxAdapter(
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
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatNumber(int number) {
    final formatter = NumberFormat('#,###', 'en_US');
    return formatter.format(number).replaceAll(',', ' ');
  }

  Widget _buildStatItem(String title, int value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: TextStyle(
            color: AppColors.textDarkBrown.withValues(alpha: 0.6),
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _formatNumber(value),
          style: const TextStyle(
            color: AppColors.textDarkBrown,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
      ],
    );
  }
}
