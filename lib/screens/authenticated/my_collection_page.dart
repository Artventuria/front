import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/artwork/artwork_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_collection_provider.dart';
import '../../providers/badge_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/search/user_collection_search_delegate.dart';
import '../../widgets/collection/collection_header_widget.dart';
import '../../widgets/collection/user_profile_section_widget.dart';
import '../../widgets/collection/stats_section_widget.dart';
import '../../widgets/collection/artwork_grid_widget.dart';
import '../../widgets/collection/badge_card_widget.dart';
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
    final ArtworkModel? artwork = await showSearch<ArtworkModel?>(
      context: context,
      delegate: UserCollectionSearchDelegate(context),
    );

    if (artwork != null && mounted) {
      Navigator.pushNamed(
        context,
        '/artwork-detail',
        arguments: {'artwork': artwork},
      );
    }
  }

  void _showBadges() {
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final authProvider = Provider.of<AuthProvider>(context);

    if (!_initialLoadInitiated && authProvider.user != null) {
      _initialLoadInitiated = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _loadInitialData();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

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
              // Header
              CollectionHeaderWidget(
                title: AppLocalizations.of(context)!.myCollection,
                onSearchPressed: _showSearch,
                onMenuPressed: () {
                  // Options menu
                },
              ),

              // User profile and stats section
              Consumer<UserCollectionProvider>(
                builder: (context, provider, child) {
                  return Column(
                    children: [
                      // User profile section
                      UserProfileSectionWidget(
                        username: provider.userProfile?.username ?? '',
                        fallbackUsername: authProvider.user?.username,
                      ),

                      // Stats section with swipe hint
                      StatsSectionWidget(
                        artworkCount: provider.userProfile?.artworkCount ?? 0,
                        points: provider.userProfile?.points ?? 0,
                        badgeCount: provider.userProfile?.badgeCount ?? 0,
                        onBadgesTap: _showBadges,
                        showSwipeHint: true,
                        currentPage: _currentPage,
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
                    Consumer<UserCollectionProvider>(
                      builder: (context, provider, child) {
                        return ArtworkGridWidget(
                          artworks: provider.collectedArtworks,
                          isLoading: provider.isLoading,
                          hasMore: provider.hasMoreArtworks,
                          scrollController: _scrollController,
                          onRefresh: _refreshData,
                        );
                      },
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
                                  AppLocalizations.of(context)!
                                      .errorLoadingBadges,
                                  style: const TextStyle(
                                      color: AppColors.standardGrey,
                                      fontSize: 16),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () => badgeProvider.loadUserBadges(
                                      forceReload: true),
                                  child: Text(
                                      AppLocalizations.of(context)!.tryAgain),
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
                              return BadgeCardWidget(badge: badge);
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
}
