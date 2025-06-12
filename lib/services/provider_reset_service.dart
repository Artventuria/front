import 'package:flutter/foundation.dart';
import '../providers/artwork_provider.dart';
import '../providers/leaderboard_provider.dart';
import '../providers/user_collection_provider.dart';

/// Service responsible for resetting all providers when a user logs out or changes
class ProviderResetService {
  final ArtworkProvider _artworkProvider;
  final LeaderboardProvider _leaderboardProvider;
  final UserCollectionProvider _userCollectionProvider;

  ProviderResetService({
    required ArtworkProvider artworkProvider,
    required LeaderboardProvider leaderboardProvider,
    required UserCollectionProvider userCollectionProvider,
  })  : _artworkProvider = artworkProvider,
        _leaderboardProvider = leaderboardProvider,
        _userCollectionProvider = userCollectionProvider;

  /// Reset all providers data when user changes
  void resetAllProviders() {
    if (kDebugMode) {
      print('Resetting all providers data');
    }

    // Reset artwork provider data
    _artworkProvider.resetAllData();

    // Reset leaderboard provider data
    _leaderboardProvider.resetData();

    // Reset user collection provider data
    _userCollectionProvider.resetData();
  }

  /// Load initial data for the new user
  Future<void> loadInitialDataForUser(int userId) async {
    if (kDebugMode) {
      debugPrint('Loading initial data for user: $userId');
    }

    // Load data in parallel for better performance
    await Future.wait([
      _artworkProvider.loadStillToCollectArtworks(
        userId: userId,
        forceReload: true,
        refresh: true,
      ),
      _artworkProvider.loadRecentlyCollectedArtworks(forceReload: true),
      _leaderboardProvider.loadLeaderboard(forceReload: true),
      _userCollectionProvider.refreshAllData(),
    ]);
  }
}
