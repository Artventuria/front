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

  // State for collected artworks
  List<ArtworkModel> _collectedArtworks = [];
  bool _isLoadingCollectedArtworks = false;
  bool _hasErrorCollectedArtworks = false;
  String? _errorCollectedArtworks;
  bool _collectedArtworksInitialized = false;
  DateTime? _lastCollectedArtworksUpdate;

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

  // Getters for collected artworks
  List<ArtworkModel> get collectedArtworks => _collectedArtworks;
  bool get isLoadingCollectedArtworks => _isLoadingCollectedArtworks;
  bool get isCollectedArtworksInitialized => _collectedArtworksInitialized;
  DateTime? get lastCollectedArtworksUpdate => _lastCollectedArtworksUpdate;
  bool get hasErrorCollectedArtworks => _hasErrorCollectedArtworks;
  String? get errorCollectedArtworks => _errorCollectedArtworks;

  bool get hasError =>
      _hasErrorStillToCollect ||
      _hasErrorRecentlyCollected ||
      _hasErrorCollectedArtworks;
  bool get hasErrorStillToCollect => _hasErrorStillToCollect;
  bool get hasErrorRecentlyCollected => _hasErrorRecentlyCollected;

  String? get error =>
      _errorStillToCollect ??
      _errorRecentlyCollected ??
      _errorCollectedArtworks;
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
  Future<void> loadCollectedArtworks(
      {required int userId, bool forceReload = false}) async {
    if (_collectedArtworksInitialized &&
        !forceReload &&
        _collectedArtworks.isNotEmpty) {
      // Data already loaded and not forcing a reload, and list is not empty
      return;
    }

    _isLoadingCollectedArtworks = true;
    _hasErrorCollectedArtworks = false;
    _errorCollectedArtworks = null;
    notifyListeners();

    try {
      // Load collected artworks from the service
      final artworks =
          await _artworkService.getCollectedArtworks(userId: userId);
      _collectedArtworks = artworks;
      _collectedArtworksInitialized = true;
      _lastCollectedArtworksUpdate = DateTime.now();
    } catch (e) {
      _hasErrorCollectedArtworks = true;
      _errorCollectedArtworks = e.toString();
      if (kDebugMode) {
        debugPrint('Error loading collected artworks: $e');
      }
    } finally {
      _isLoadingCollectedArtworks = false;
      notifyListeners();
    }
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
      loadCollectedArtworks(userId: userId, forceReload: true),
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
    // Return early if query is empty
    if (query.isEmpty) {
      _searchResults = [];
      _hasMoreSearchResults = false;
      notifyListeners();
      return;
    }

    // Avoid multiple simultaneous requests
    if (_isLoadingSearch) {
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

      // Store the current offset for this request
      final requestOffset = _searchOffset;

      // Call the search service with pagination
      final results = await _artworkService.searchArtworks(
        query: query,
        limit: 10,
        offset: requestOffset,
      );

      // Update results and state
      if (results.isEmpty) {
        _hasMoreSearchResults = false;
      } else {
        // Update offset for next request
        _searchOffset = requestOffset + results.length;

        if (resetResults) {
          _searchResults = results;
        } else {
          // Create a set of existing artwork IDs to check for duplicates
          final existingIds =
              _searchResults.map((artwork) => artwork.id).toSet();

          // Only add artworks that aren't already in the list
          final uniqueNewResults = results
              .where((artwork) => !existingIds.contains(artwork.id))
              .toList();

          if (uniqueNewResults.isEmpty) {
            // If no new unique artworks were found, we've reached the end
            _hasMoreSearchResults = false;
          } else {
            _searchResults = [..._searchResults, ...uniqueNewResults];
          }
        }
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
