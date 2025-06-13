import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../models/artwork/artwork_model.dart';
import '../../models/badge_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_collection_provider.dart';
import '../../providers/badge_provider.dart';
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
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late UserCollectionProvider _collectionProvider;
  bool _initialLoadInitiated = false;

  // Page controller for swiping between artworks and badges
  late PageController _pageController;

  // Current page index (0: artworks, 1: badges)
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _collectionProvider =
        Provider.of<UserCollectionProvider>(context, listen: false);
    _setupScrollListener();

    // Initialize page controller
    _pageController = PageController(initialPage: 0);

    // Load badges when module is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BadgeProvider>(context, listen: false).loadUserBadges();
    });
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

  void _showBadges() {
    // Switch to badges page (index 1)
    if (_currentPage != 1) {
      _pageController.animateToPage(
        1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _pageController.dispose();
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
              // Fixed header section with user profile and stats
              Consumer<UserCollectionProvider>(
                builder: (context, provider, child) {
                  return Column(
                    children: [
                      // User profile section
                      Padding(
                        padding:
                            const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 24.0),
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
                                                authProvider
                                                    .user!.username.isNotEmpty
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

                      // Stats row with swipe hint
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          children: [
                            Container(
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
                                      provider.userProfile?.artworkCount ?? 0),
                                  _buildDivider(),
                                  _buildStatItem(AppLocalizations.of(context)!.points,
                                      provider.userProfile?.points ?? 0),
                                  _buildDivider(),
                                  GestureDetector(
                                    onTap: _showBadges,
                                    child: _buildStatItem(
                                        AppLocalizations.of(context)!.badges,
                                        provider.userProfile?.badgeCount ?? 0),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Swipe hint
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _currentPage == 0
                                      ? Icons.swipe_left
                                      : Icons.swipe_right,
                                  size: 16,
                                  color: AppColors.standardGrey
                                      .withValues(alpha: 0.6),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _currentPage == 0
                                      ? AppLocalizations.of(context)!.swipeToSeeBadges
                                      : AppLocalizations.of(context)!.swipeToSeeArtworks,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.standardGrey
                                        .withValues(alpha: 0.6),
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),

              // Swipeable content area (artworks/badges)
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() => _currentPage = index);
                  },
                  children: [
                    // ARTWORKS PAGE (index 0)
                    RefreshIndicator(
                      onRefresh: _refreshData,
                      color: AppColors.purpleIndicator,
                      child: Consumer<UserCollectionProvider>(
                        builder: (context, provider, child) {
                          return CustomScrollView(
                            controller: _scrollController,
                            physics: const AlwaysScrollableScrollPhysics(),
                            slivers: [
                              // Space between stats and artworks grid
                              const SliverToBoxAdapter(
                                child: SizedBox(height: 24),
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
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20.0),
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
                                                    Navigator.of(context).push(
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            FullScreenArtworkPage(
                                                          imageName: artwork
                                                              .metadata
                                                              .imageUrl,
                                                          title: artwork.title,
                                                          artist:
                                                              artwork.artist,
                                                          year: int.tryParse(
                                                                  artwork
                                                                      .creationDate
                                                                      .split(
                                                                          '-')
                                                                      .first) ??
                                                              0,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            30),
                                                    child: Image.network(
                                                      artwork.metadata.imageUrl,
                                                      fit: BoxFit.cover,
                                                      loadingBuilder: (context,
                                                          child,
                                                          loadingProgress) {
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
                                                      errorBuilder: (context,
                                                          error, stackTrace) {
                                                        return Container(
                                                          color: AppColors
                                                              .imageErrorBackground,
                                                          child: const Center(
                                                            child: Icon(
                                                                Icons
                                                                    .broken_image,
                                                                size: 64,
                                                                color: AppColors
                                                                    .standardGrey),
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
                                                        BorderRadius.circular(
                                                            15),
                                                    onTap: () {
                                                      // Navigate to artwork detail page
                                                      Navigator.of(context)
                                                          .push(
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              ArtworkDetailPage(
                                                                  artwork:
                                                                      artwork),
                                                        ),
                                                      );
                                                    },
                                                    child: Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              6),
                                                      decoration: BoxDecoration(
                                                        color: AppColors
                                                            .transparentBlack,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(15),
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
                                      childCount:
                                          provider.collectedArtworks.length,
                                    ),
                                  ),
                                ),

                              // Loading indicator at bottom when loading more
                              if (provider.isLoading &&
                                  provider.collectedArtworks.isNotEmpty)
                                SliverToBoxAdapter(
                                  child: Padding(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 16.0),
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
                          );
                        },
                      ),
                    ),

                    // BADGES PAGE (index 1)
                    Consumer<BadgeProvider>(
                      builder: (context, badgeProvider, child) {
                        if (badgeProvider.isLoading) {
                          return const Center(
                            child: CircularProgressIndicator(
                                color: AppColors.purpleIndicator),
                          );
                        }

                        if (badgeProvider.error != null) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.error_outline,
                                    size: 64, color: AppColors.standardGrey),
                                const SizedBox(height: 16),
                                Text(
                                  AppLocalizations.of(context)!.errorLoadingBadges,
                                  style: TextStyle(
                                      color: AppColors.standardGrey,
                                      fontSize: 16),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () => badgeProvider.loadUserBadges(
                                      forceReload: true),
                                  child: Text(AppLocalizations.of(context)!.tryAgain),
                                ),
                              ],
                            ),
                          );
                        }

                        if (badgeProvider.badges.isEmpty) {
                          return Center(
                            child: Text(
                              AppLocalizations.of(context)!.noBadgesAvailable,
                              style: const TextStyle(
                                  color: AppColors.textGrey, fontSize: 18),
                            ),
                          );
                        }

                        return RefreshIndicator(
                          onRefresh: () =>
                              badgeProvider.loadUserBadges(forceReload: true),
                          color: AppColors.purpleIndicator,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(20),
                            itemCount: badgeProvider.badges.length,
                            itemBuilder: (context, index) {
                              final badge = badgeProvider.badges[index];
                              return _buildBadgeCard(badge);
                            },
                          ),
                        );
                      },
                    ),
                  ],
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

  Widget _buildBadgeCard(BadgeModel badge) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: badge.obtained
              ? [
                  AppColors.statCardBackground.withValues(alpha: 0.8),
                  AppColors.statCardBackground.withValues(alpha: 0.5),
                ]
              : [
                  AppColors.lightGrey.withValues(alpha: 0.3),
                  AppColors.lightGrey.withValues(alpha: 0.1),
                ],
        ),
        borderRadius: BorderRadius.circular(15),
        border: badge.obtained
            ? Border.all(
                color: AppColors.purpleIndicator.withValues(alpha: 0.3),
                width: 1)
            : Border.all(
                color: AppColors.standardGrey.withValues(alpha: 0.2), width: 1),
      ),
      child: Row(
        children: [
          // Badge status indicator
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: badge.obtained
                  ? AppColors.purpleIndicator
                  : AppColors.standardGrey,
            ),
            child: Icon(
              badge.obtained ? Icons.check : Icons.lock_outline,
              color: AppColors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          // Badge info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  badge.name,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: badge.obtained
                        ? AppColors.textDarkBrown
                        : AppColors.standardGrey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  badge.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: badge.obtained
                        ? AppColors.textDarkBrown.withValues(alpha: 0.7)
                        : AppColors.standardGrey.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.stars,
                      size: 16,
                      color: badge.obtained
                          ? AppColors.purpleIndicator
                          : AppColors.standardGrey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${badge.points} ${AppLocalizations.of(context)!.pointsAbbreviation}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: badge.obtained
                            ? AppColors.purpleIndicator
                            : AppColors.standardGrey,
                      ),
                    ),
                    const Spacer(),
                    if (!badge.obtained)
                      Text(
                        '${AppLocalizations.of(context)!.badgeProgressionLabel}: ${badge.progress}',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.standardGrey.withValues(alpha: 0.8),
                        ),
                      ),
                    if (badge.obtained)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color:
                              AppColors.purpleIndicator.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          AppLocalizations.of(context)!.badgeObtained,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: AppColors.purpleIndicator,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
