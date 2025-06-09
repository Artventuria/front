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
  List<ArtworkModel> _searchResults = [];
  bool _isLoadingStillToCollect = false;
  bool _isLoadingRecentlyCollected = false;
  bool _isLoadingSearch = false;
  bool _hasErrorStillToCollect = false;
  bool _hasErrorRecentlyCollected = false;
  bool _hasErrorSearch = false;
  String? _errorStillToCollect;
  String? _errorRecentlyCollected;
  String? _errorSearch;
  String? _nextPageCursor;
  int _searchOffset = 0;
  bool _hasMoreSearchResults = true;

  // Flags to track if data has been loaded at least once
  bool _stillToCollectInitialized = false;
  bool _recentlyCollectedInitialized = false;
  DateTime? _lastStillToCollectUpdate;
  DateTime? _lastRecentlyCollectedUpdate;

  // Getters
  List<ArtworkModel> get stillToCollectArtworks => _stillToCollectArtworks;
  List<ArtworkModel> get recentlyCollectedArtworks =>
      _recentlyCollectedArtworks;
  List<ArtworkModel> get searchResults => _searchResults;

  bool get isLoading =>
      _isLoadingStillToCollect ||
      _isLoadingRecentlyCollected ||
      _isLoadingSearch;
  bool get isLoadingStillToCollect => _isLoadingStillToCollect;
  bool get isLoadingRecentlyCollected => _isLoadingRecentlyCollected;
  bool get isLoadingSearch => _isLoadingSearch;

  bool get hasErrorSearch => _hasErrorSearch;
  String? get errorSearch => _errorSearch;
  bool get hasMoreSearchResults => _hasMoreSearchResults;

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

  /// Method to refresh all data from scratch
  Future<void> refreshAllData(int userId) async {
    await Future.wait([
      // Use refresh: true to completely reset the list
      // and forceReload: true to ignore initialization check
      loadStillToCollectArtworks(
        userId: userId,
        forceReload: true,
        refresh: true,
      ),
      loadRecentlyCollectedArtworks(forceReload: true),
    ]);
  }

  /// Check if an artwork is in the user's collection
  /// [artworkId] : ID of the artwork to check
  /// Returns true if the artwork is in the collection, false otherwise
  Future<bool> isArtworkInCollection(String artworkId) async {
    try {
      return await _artworkService.isArtworkInCollection(artworkId);
    } catch (e) {
      if (kDebugMode) {
        print('Error checking if artwork is in collection: $e');
      }
      return false;
    }
  }

  /// Get the number of collectors of an artwork
  /// [artworkId] : ID of the artwork to check
  /// Returns the number of collectors
  Future<int> getArtworkCollectorsCount(String artworkId) async {
    try {
      return await _artworkService.getArtworkCollectorsCount(artworkId);
    } catch (e) {
      if (kDebugMode) {
        print('Error getting artwork collectors count: $e');
      }
      return 0;
    }
  }

  /// Search artworks by artist or title
  /// [query] : Search term (artist or artwork name)
  /// [resetResults] : If true, reset previous results (for a new search)
  Future<void> searchArtworks({
    required String query,
    bool resetResults = false,
  }) async {
    if (query.isEmpty) {
      _searchResults = [];
      _hasMoreSearchResults = false;
      notifyListeners();
      return;
    }

    try {
      if (resetResults) {
        _searchResults = [];
        _searchOffset = 0;
        _hasMoreSearchResults = true;
      }

      _isLoadingSearch = true;
      _hasErrorSearch = false;
      _errorSearch = null;
      notifyListeners();

      // Call the search service with pagination
      final results = await _artworkService.searchArtworks(
        query: query,
        limit: 10,
        offset: _searchOffset,
      );

      // Update results and state
      if (results.isEmpty) {
        _hasMoreSearchResults = false;
      } else {
        _searchOffset += results.length;
        _searchResults =
            resetResults ? results : [..._searchResults, ...results];
      }

      _isLoadingSearch = false;
      notifyListeners();
    } catch (e) {
      _hasErrorSearch = true;
      _errorSearch = e.toString();
      _isLoadingSearch = false;
      notifyListeners();
      if (kDebugMode) {
        print('Error searching artworks: $e');
      }
    }
  }
}
