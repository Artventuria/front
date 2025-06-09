import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:google_fonts/google_fonts.dart'; // For Merriweather font
import '../../models/leaderboard_entry.dart'; // Ensure LeaderboardEntry is imported
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../utils/constants.dart'; // For AppColors
import '../../widgets/leaderboard/leaderboard_item.dart';
import '../../providers/leaderboard_provider.dart';
import '../../providers/auth_provider.dart';

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key});

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true; // Keep state when offscreen
  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();

  String _searchText = '';

  @override
  void initState() {
    super.initState();
    // Load data via provider at startup
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadLeaderboardData();
    });
  }

  void _loadLeaderboardData() {
    final leaderboardProvider =
        Provider.of<LeaderboardProvider>(context, listen: false);
    // Check if data already exists or needs to be forced to reload
    if (!leaderboardProvider.isInitialized ||
        leaderboardProvider.leaderboardEntries.isEmpty) {
      leaderboardProvider.loadLeaderboard();
    }
  }

  Future<void> _refreshLeaderboard() async {
    final leaderboardProvider =
        Provider.of<LeaderboardProvider>(context, listen: false);
    await leaderboardProvider.refreshLeaderboard();
  }

  void _triggerScrollToSearchedUser(String searchText) {
    if (searchText.isEmpty || !itemScrollController.isAttached) return;

    final leaderboardProvider =
        Provider.of<LeaderboardProvider>(context, listen: false);
    final sourceEntries = leaderboardProvider.leaderboardEntries;

    final List<LeaderboardEntry> currentlyDisplayedEntries = sourceEntries
        .where((entry) =>
            entry.username.toLowerCase().contains(searchText.toLowerCase()))
        .toList();

    if (currentlyDisplayedEntries.isNotEmpty) {
      final indexToScroll = currentlyDisplayedEntries.indexWhere((entry) =>
          entry.username.toLowerCase().contains(searchText.toLowerCase()));
      //This will find the first match in the filtered list. If the list is already filtered this way by build(), this is fine.

      if (indexToScroll != -1) {
        itemScrollController.scrollTo(
          index: indexToScroll,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
          alignment: 0.1, // Adjust as needed, 0.0 is top
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    final localizations = AppLocalizations.of(context)!;

    // Use provider to get data and leaderboard state
    final leaderboardProvider = Provider.of<LeaderboardProvider>(context);
    final isLoading = leaderboardProvider.isLoading;
    final hasError = leaderboardProvider.hasError;

    List<LeaderboardEntry> displayedEntries;
    if (_searchText.isEmpty) {
      displayedEntries = leaderboardProvider.leaderboardEntries;
    } else {
      displayedEntries = leaderboardProvider.leaderboardEntries
          .where((entry) =>
              entry.username.toLowerCase().contains(_searchText.toLowerCase()))
          .toList();
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.white,
              AppColors.homeBackgroundEnd
            ], // Matching homepage gradient
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 15), // Adjusted padding
                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween, // Align title and icon
                  children: [
                    Text(
                      localizations.leaderboard,
                      style: GoogleFonts.merriweather(
                        fontSize: 22,
                        fontWeight: FontWeight.w400,
                        color:
                            AppColors.textPrimary, // Matching 'Explorer' style
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.more_vert,
                          color: AppColors
                              .textPrimary), // Matching 'Explorer' icon color
                      onPressed: () {
                        // Options menu can be implemented here
                      },
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical:
                        10), // Increased horizontal padding to reduce width
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 8), // Adjusted padding for icon
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(30), // Fully rounded ends
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withValues(alpha: 0.1),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ]),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              AppColors.searchGradientStart,
                              AppColors.searchGradientEnd
                            ], // User specified gradient
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: const Icon(Icons.search,
                            color: AppColors.white, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: localizations.searchFriend,
                            hintStyle: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 15,
                              color: AppColors.hintTextGrey,
                            ),
                            border: InputBorder.none,
                            isDense: true,
                          ),
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 15,
                            color: AppColors.buttonPurple,
                          ),
                          onChanged: (value) {
                            setState(() {
                              _searchText = value;
                            });
                            // Scroll after the UI has had a chance to rebuild with the new searchText
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              _triggerScrollToSearchedUser(value);
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.buttonPurple,
                        ),
                      )
                    : hasError
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.error_outline,
                                    size: 48, color: AppColors.standardGrey),
                                const SizedBox(height: 16),
                                Text(
                                  localizations.leaderboardLoadingError,
                                  style: const TextStyle(
                                      color: AppColors.textGrey),
                                ),
                                const SizedBox(height: 24),
                                ElevatedButton(
                                  onPressed: _refreshLeaderboard,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.purpleIndicator,
                                  ),
                                  child: Text(localizations.retryButton),
                                ),
                              ],
                            ),
                          )
                        : leaderboardProvider.leaderboardEntries.isEmpty &&
                                _searchText.isEmpty
                            ? Center(
                                child: Text(
                                  localizations.leaderboardNoData,
                                  style: const TextStyle(
                                      color: AppColors.textGrey),
                                ),
                              )
                            : displayedEntries.isEmpty && _searchText.isNotEmpty
                                ? Center(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 40.0),
                                      child: Text(
                                        localizations.leaderboardNoResultsFor(
                                            _searchText),
                                        style: const TextStyle(
                                            color: AppColors.textGrey),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  )
                                : RefreshIndicator(
                                    onRefresh: _refreshLeaderboard,
                                    color: AppColors
                                        .purpleIndicator, // Changed to AppColors.purpleIndicator
                                    child: ScrollablePositionedList.builder(
                                      itemScrollController:
                                          itemScrollController,
                                      itemPositionsListener:
                                          itemPositionsListener,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 10),
                                      physics:
                                          const AlwaysScrollableScrollPhysics(),
                                      itemCount: displayedEntries.length,
                                      itemBuilder: (context, index) {
                                        final entry = displayedEntries[index];
                                        final authProvider =
                                            Provider.of<AuthProvider>(context,
                                                listen: false);
                                        final currentUserId =
                                            authProvider.user?.id;
                                        final isCurrentUser =
                                            entry.userId == currentUserId;
                                        return LeaderboardItem(
                                            entry: entry,
                                            isCurrentUser: isCurrentUser);
                                      },
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
