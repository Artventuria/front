import 'package:flutter/foundation.dart';
import '../models/leaderboard_entry.dart';
import '../services/leaderboard/leaderboard_service.dart';
import '../services/api/api_service.dart';

enum LeaderboardLoadStatus { initial, loading, loaded, error }

class LeaderboardProvider extends ChangeNotifier {
  final LeaderboardService _leaderboardService;

  List<LeaderboardEntry> _leaderboardEntries = [];
  LeaderboardEntry? _currentUserEntry;
  bool _isLoading = false;
  bool _hasError = false;
  String? _errorMessage;
  bool _isInitialized = false;

  // Getters
  List<LeaderboardEntry> get leaderboardEntries => _leaderboardEntries;
  LeaderboardEntry? get currentUserEntry => _currentUserEntry;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  String? get errorMessage => _errorMessage;
  bool get isInitialized => _isInitialized;

  LeaderboardProvider(this._leaderboardService);

  // Factory to create the provider with its dependencies
  static LeaderboardProvider create(ApiService apiService) {
    return LeaderboardProvider(LeaderboardService(apiService));
  }

  /// Load leaderboard data
  Future<void> loadLeaderboard({bool forceReload = false}) async {
    // Skip if already initialized and not forcing reload
    if (_isInitialized && !forceReload && _leaderboardEntries.isNotEmpty) {
      return;
    }

    try {
      _isLoading = true;
      _hasError = false;
      _errorMessage = null;
      notifyListeners();

      // Load global leaderboard first
      final entries = await _leaderboardService.getLeaderboard();
      _leaderboardEntries = entries;

      try {
        // Try to get current user's position
        final userEntry = await _leaderboardService.getCurrentUserPosition();
        _currentUserEntry = userEntry;
      } catch (e) {
        // If there's an error getting the user position, we still have the global leaderboard
        if (kDebugMode) {
          debugPrint('Error loading user leaderboard position: $e');
        }
      }

      // If leaderboard is empty, try to get nearby positions
      if (_leaderboardEntries.isEmpty) {
        try {
          final nearbyEntries = await _leaderboardService.getNearbyPositions();
          _leaderboardEntries = nearbyEntries;
        } catch (e) {
          if (kDebugMode) {
            debugPrint('Error loading nearby leaderboard positions: $e');
          }
        }
      }

      _isLoading = false;
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      _hasError = true;
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      if (kDebugMode) {
        debugPrint('Error loading leaderboard: $e');
      }
    }
  }

  /// Reset error state
  void resetError() {
    _hasError = false;
    _errorMessage = null;
    notifyListeners();
  }
  
  /// Reset all data when user changes
  void resetData() {
    _leaderboardEntries = [];
    _currentUserEntry = null;
    _isLoading = false;
    _hasError = false;
    _errorMessage = null;
    _isInitialized = false;
    notifyListeners();
  }

  /// Refresh leaderboard data
  Future<void> refreshLeaderboard() async {
    await loadLeaderboard(forceReload: true);
  }
}
