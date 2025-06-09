import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/artwork_provider.dart';
import '../../services/home/home_scroll_service.dart';
import '../../widgets/home/home_header_widget.dart';
import '../../widgets/home/recently_collected_section.dart';
import '../../widgets/home/still_to_collect_section.dart';
import '../../utils/home_options_helper.dart';
import '../../utils/constants.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();
  late HomeScrollService _scrollService;

  @override
  void initState() {
    super.initState();
    _scrollService = HomeScrollService(_scrollController);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
      _scrollService.initializeScrollListener(context);
    });
  }

  /// Load initial data once if they haven't been loaded yet
  void _loadInitialData() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final artworkProvider =
        Provider.of<ArtworkProvider>(context, listen: false);

    if (authProvider.user != null) {
      // Check if the data is already initialized before loading
      // to avoid unnecessary reloads when returning to the home page
      if (!artworkProvider.isStillToCollectInitialized ||
          artworkProvider.stillToCollectArtworks.isEmpty) {
        artworkProvider.loadStillToCollectArtworks(
          userId: authProvider.user!.id,
        );
      }

      // The Recently Collected section already handles its own loading in its initState
      // and checks if the data is already initialized
      artworkProvider.loadRecentlyCollectedArtworks();
    }
  }

  /// Force the refresh of all data (pull-to-refresh)
  Future<void> _refreshData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final artworkProvider =
        Provider.of<ArtworkProvider>(context, listen: false);

    if (authProvider.user != null) {
      return artworkProvider.refreshAllData(authProvider.user!.id);
    }
    return Future.value();
  }

  @override
  void dispose() {
    _scrollService.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, AppColors.homeBackgroundEnd],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HomeHeaderWidget(
                scrollController: _scrollController,
                onOptionsPressed: () =>
                    HomeOptionsHelper.showOptionsMenu(context),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _refreshData,
                  color: AppColors.purpleIndicator,
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    padding: EdgeInsets.zero,
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 0),
                        const RecentlyCollectedSection(),
                        const SizedBox(height: 5),
                        const StillToCollectSection(),
                        const SizedBox(height: 1),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
