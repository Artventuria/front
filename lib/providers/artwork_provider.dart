import 'package:flutter/foundation.dart';

import '../models/artwork/artwork_model.dart';
import '../services/api/api_service.dart';
import '../services/storage/storage_service.dart';
import '../services/artwork/artwork_service.dart';

enum ArtworkLoadStatus { initial, loading, loaded, error, noMoreData }

class ArtworkProvider extends ChangeNotifier {
  final ArtworkService _artworkService;

  List<ArtworkModel> _stillToCollectArtworks = [];
  List<ArtworkModel> _recentlyCollectedArtworks = [];
  bool _isLoadingStillToCollect = false;
  bool _isLoadingRecentlyCollected = false;
  bool _hasErrorStillToCollect = false;
  bool _hasErrorRecentlyCollected = false;
  String? _errorStillToCollect;
  String? _errorRecentlyCollected;
  String? _nextPageCursor;

  // Flags to track if data has been loaded at least once
  bool _stillToCollectInitialized = false;
  bool _recentlyCollectedInitialized = false;
  DateTime? _lastStillToCollectUpdate;
  DateTime? _lastRecentlyCollectedUpdate;

  // Getters
  List<ArtworkModel> get stillToCollectArtworks => _stillToCollectArtworks;
  List<ArtworkModel> get recentlyCollectedArtworks =>
      _recentlyCollectedArtworks;

  bool get isLoading => _isLoadingStillToCollect || _isLoadingRecentlyCollected;
  bool get isLoadingStillToCollect => _isLoadingStillToCollect;
  bool get isLoadingRecentlyCollected => _isLoadingRecentlyCollected;

  // Getters for initialization status
  bool get isStillToCollectInitialized => _stillToCollectInitialized;
  bool get isRecentlyCollectedInitialized => _recentlyCollectedInitialized;
  DateTime? get lastStillToCollectUpdate => _lastStillToCollectUpdate;
  DateTime? get lastRecentlyCollectedUpdate => _lastRecentlyCollectedUpdate;

  bool get hasError => _hasErrorStillToCollect || _hasErrorRecentlyCollected;
  bool get hasErrorStillToCollect => _hasErrorStillToCollect;
  bool get hasErrorRecentlyCollected => _hasErrorRecentlyCollected;

  String? get error => _errorStillToCollect ?? _errorRecentlyCollected;
  String? get errorStillToCollect => _errorStillToCollect;
  String? get errorRecentlyCollected => _errorRecentlyCollected;

  String? get nextPageCursor => _nextPageCursor;
  bool get hasMoreToLoad =>
      true; // Always true because the API restarts at the beginning if we have browsed all the artworks

  ArtworkProvider(this._artworkService);

  // Factory to create the provider with its dependencies
  static ArtworkProvider create(
      StorageService storageService, ApiService apiService) {
    return ArtworkProvider(ArtworkService(apiService));
  }

  /// Load artworks to collect
  /// [userId] : User ID
  /// [refresh] : If true, refresh the complete list instead of adding to the existing list
  /// [forceReload] : If true, reload data even if it has been initialized already
  Future<void> loadStillToCollectArtworks({
    required int userId,
    bool refresh = false,
    bool forceReload = false,
    int limit = 10,
  }) async {
    // Skip if already initialized and not forcing reload, but only for complete refreshes
    // For infinite scroll, continue loading even if initialized
    if (_stillToCollectInitialized &&
        !forceReload &&
        refresh &&
        _stillToCollectArtworks.isNotEmpty) {
      return;
    }
    try {
      if (refresh) {
        _stillToCollectArtworks = [];
        _nextPageCursor = null;
      }
      _isLoadingStillToCollect = true;
      _hasErrorStillToCollect = false;
      _errorStillToCollect = null;
      notifyListeners();

      final artworks = await _artworkService.getStillToCollect(
        userId: userId,
        limit: limit,
        cursor: _nextPageCursor,
      );

      if (artworks.isNotEmpty) {
        // Use the cursor stored in the service instead of accessing artworks.last.nextPageCursor
        _nextPageCursor = _artworkService.lastCursor;
        _stillToCollectArtworks.addAll(artworks);
      }

      _isLoadingStillToCollect = false;
      _stillToCollectInitialized = true;
      _lastStillToCollectUpdate = DateTime.now();
      notifyListeners();
    } catch (e) {
      _hasErrorStillToCollect = true;
      _errorStillToCollect = e.toString();
      _isLoadingStillToCollect = false;
      notifyListeners();
      if (kDebugMode) {
        print('Error loading still to collect artworks: $e');
      }
    }
  }

  // Load collected artworks
  Future<void> loadCollectedArtworks({required int userId}) async {
    // This method will be implemented later
  }

  /// Load recently collected artworks (last 7 days)
  /// [forceReload] : If true, reload data even if it has been initialized already
  Future<void> loadRecentlyCollectedArtworks({bool forceReload = false}) async {
    // Skip if already initialized and not forcing reload
    if (_recentlyCollectedInitialized &&
        !forceReload &&
        _recentlyCollectedArtworks.isNotEmpty) {
      return;
    }
    try {
      _isLoadingRecentlyCollected = true;
      _hasErrorRecentlyCollected = false;
      _errorRecentlyCollected = null;
      notifyListeners();

      final artworks = await _artworkService.getRecentlyCollectedArtworks();
      _recentlyCollectedArtworks = artworks;

      _isLoadingRecentlyCollected = false;
      _recentlyCollectedInitialized = true;
      _lastRecentlyCollectedUpdate = DateTime.now();
      notifyListeners();
    } catch (e) {
      _hasErrorRecentlyCollected = true;
      _errorRecentlyCollected = e.toString();
      _isLoadingRecentlyCollected = false;
      notifyListeners();
      if (kDebugMode) {
        print('Error loading recently collected artworks: $e');
      }
    }
  }

  // This method will be implemented later
  Future<bool> collectArtwork(int artworkId, int userId) async {
    // For now, always return true
    return true;
  }

  // Reset error state
  void resetError() {
    _hasErrorStillToCollect = false;
    _errorStillToCollect = null;
    _hasErrorRecentlyCollected = false;
    _errorRecentlyCollected = null;
    notifyListeners();
  }

  // Force refresh homepage data
  Future<void> refreshAllData(int userId) async {
    await Future.wait([
      loadStillToCollectArtworks(
          userId: userId, refresh: true, forceReload: true),
      loadRecentlyCollectedArtworks(forceReload: true)
    ]);
  }
}
