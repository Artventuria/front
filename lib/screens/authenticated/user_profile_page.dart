import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/artwork/artwork_model.dart';
import '../../providers/user_profile_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/search/user_profile_search_delegate.dart';
import '../../widgets/collection/collection_header_widget.dart';
import '../../widgets/collection/user_profile_section_widget.dart';
import '../../widgets/collection/stats_section_widget.dart';
import '../../widgets/collection/artwork_grid_widget.dart';
import '../../l10n/app_localizations.dart';

class UserProfilePage extends StatefulWidget {
  final int userId;
  final String username;

  const UserProfilePage({
    super.key,
    required this.userId,
    required this.username,
  });

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final ScrollController _scrollController = ScrollController();
  late UserProfileProvider _profileProvider;
  bool _initialLoadInitiated = false;

  @override
  void initState() {
    super.initState();
    _profileProvider = Provider.of<UserProfileProvider>(context, listen: false);
    _setupScrollListener();
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent * 0.7 &&
          !_profileProvider.isLoading &&
          _profileProvider.hasMoreArtworks) {
        _profileProvider.loadCollectedArtworks();
      }
    });
  }

  Future<void> _loadInitialData() async {
    await _profileProvider.refreshAllData(widget.userId);
  }

  Future<void> _refreshData() async {
    await _profileProvider.refreshAllData(widget.userId);
  }

  Future<void> _showSearch() async {
    final ArtworkModel? artwork = await showSearch<ArtworkModel?>(
      context: context,
      delegate: UserProfileSearchDelegate(context, widget.userId),
    );

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
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialLoadInitiated) {
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
                title: 'Collection',
                onSearchPressed: _showSearch,
                onBackPressed: () => Navigator.of(context).pop(),
              ),

              // Scrollable content
              Expanded(
                child: Consumer<UserProfileProvider>(
                  builder: (context, provider, child) {
                    if (provider.isLoading && !provider.isInitialized) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (provider.isError && !provider.isInitialized) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.error_outline,
                                size: 48, color: Colors.grey),
                            const SizedBox(height: 16),
                            Text(
                              provider.errorMessage ??
                                  AppLocalizations.of(context)!
                                      .errorLoadingProfile,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _refreshData,
                              child:
                                  Text(AppLocalizations.of(context)!.tryAgain),
                            ),
                          ],
                        ),
                      );
                    }

                    return Column(
                      children: [
                        // User profile section
                        UserProfileSectionWidget(
                          username: provider.userProfile?.username ?? '',
                          fallbackUsername: widget.username,
                        ),

                        // Stats section
                        StatsSectionWidget(
                          artworkCount: provider.userProfile?.artworkCount ?? 0,
                          points: provider.userProfile?.points ?? 0,
                          badgeCount: provider.userProfile?.badgeCount ?? 0,
                        ),

                        // Artwork grid
                        Expanded(
                          child: ArtworkGridWidget(
                            artworks: provider.collectedArtworks,
                            isLoading: provider.isLoadingArtworks,
                            hasMore: provider.hasMoreArtworks,
                            scrollController: _scrollController,
                            onRefresh: _refreshData,
                          ),
                        ),
                      ],
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
}
