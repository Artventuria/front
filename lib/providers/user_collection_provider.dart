import 'package:flutter/foundation.dart';

import '../models/user_profile.dart';
import '../models/artwork/artwork_model.dart';
import '../services/api/api_service.dart';

class UserCollectionProvider extends ChangeNotifier {
  final ApiService _apiService;

  UserCollectionProvider(this._apiService);

  // User profile
  UserProfile? _userProfile;
  bool _isLoadingProfile = false;

  // Collection artworks
  List<ArtworkModel> _collectedArtworks = [];
  bool _isLoadingArtworks = false;
  int _offset = 0;
  final int _limit = 10;
  bool _hasMoreArtworks = true;
  int _totalArtworksCount = 0;

  // Search results
  List<ArtworkModel> _searchResults = [];
  bool _isLoadingSearch = false;
  bool _hasMoreSearchResults = true;
  int _searchOffset = 0;
  bool _hasErrorSearch = false;
  String? _errorSearch;

  // Error handling
  bool _isError = false;
  String? _errorMessage;

  // Initialization status
  bool _isInitialized = false;

  // Getters
  UserProfile? get userProfile => _userProfile;
  List<ArtworkModel> get collectedArtworks => _collectedArtworks;
  List<ArtworkModel> get searchResults => _searchResults;
  bool get isLoadingProfile => _isLoadingProfile;
  bool get isLoadingArtworks => _isLoadingArtworks;
  bool get isLoadingSearch => _isLoadingSearch;
  bool get isLoading =>
      _isLoadingProfile || (_isLoadingArtworks && _collectedArtworks.isEmpty);
  bool get hasMoreArtworks => _hasMoreArtworks;
  bool get hasMoreSearchResults => _hasMoreSearchResults;
  int get totalArtworksCount => _totalArtworksCount;
  bool get isError => _isError;
  bool get hasErrorSearch => _hasErrorSearch;
  String? get errorMessage => _errorMessage;
  String? get errorSearch => _errorSearch;
  bool get isInitialized => _isInitialized;

  // Load user profile data
  Future<void> loadUserProfile() async {
    if (_isLoadingProfile) return;
    _isLoadingProfile = true;
    _isError = false;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.get('/api/users/me');
      if (response.data != null) {
        _userProfile = UserProfile.fromJson(response.data);
        _isInitialized = true;
      } else {
        _isError = true;
        _errorMessage = 'Failed to load user profile';
        if (kDebugMode) {
          debugPrint('Failed to load user profile');
        }
      }
    } catch (e) {
      _isError = true;
      _errorMessage = 'An error occurred while loading user profile';
      if (kDebugMode) {
        debugPrint('Error loading user profile: $e');
      }
    } finally {
      _isLoadingProfile = false;
      notifyListeners();
    }
  }

  // Load user collected artworks with pagination
  Future<void> loadCollectedArtworks({bool reset = false}) async {
    if (_isLoadingArtworks || (!_hasMoreArtworks && !reset)) return;

    if (reset) {
      _offset = 0;
      _collectedArtworks = [];
      _hasMoreArtworks = true;
    }

    _isLoadingArtworks = true;
    _isError = false;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.get(
        '/api/artworks/my-collection',
        queryParameters: {
          'limit': _limit,
          'offset': _offset,
        },
      );

      if (response.data != null) {
        final List<dynamic> artworksJson = response.data;
        final List<ArtworkModel> newArtworks =
            artworksJson.map((json) => ArtworkModel.fromJson(json)).toList();

        // Get total count from headers
        final totalCountHeader = response.headers.value('x-total-count');
        if (totalCountHeader != null) {
          _totalArtworksCount = int.tryParse(totalCountHeader) ?? 0;
        }

        if (reset) {
          _collectedArtworks = newArtworks;
        } else {
          // Filter out duplicates when appending
          final existingIds = _collectedArtworks.map((a) => a.id).toSet();
          final uniqueNewArtworks = newArtworks
              .where((artwork) => !existingIds.contains(artwork.id))
              .toList();
          _collectedArtworks.addAll(uniqueNewArtworks);
        }

        // Update pagination state
        _offset += newArtworks.length;
        _hasMoreArtworks = _offset < _totalArtworksCount;
        _isInitialized = true;
      } else {
        _isError = true;
        _errorMessage = 'Failed to load collection';
        if (kDebugMode) {
          debugPrint('Failed to load collection');
        }
      }
    } catch (e) {
      _isError = true;
      _errorMessage = 'An error occurred while loading collection';
      if (kDebugMode) {
        debugPrint('Error loading collection: $e');
      }
    } finally {
      _isLoadingArtworks = false;
      notifyListeners();
    }
  }

  // Refresh all data (profile and artworks)
  Future<void> refreshAllData() async {
    // We can run them in parallel now
    await Future.wait([
      loadUserProfile(),
      loadCollectedArtworks(reset: true),
    ]);
  }

  // Reset state when logging out or changing user
  void reset() {
    _isLoadingProfile = false;
    _isLoadingArtworks = false;
    _isError = false;
    _errorMessage = null;
    _userProfile = null;
    _collectedArtworks = [];
    _isInitialized = false;
    _totalArtworksCount = 0;
    _hasMoreArtworks = true;
    _offset = 0;
    notifyListeners();
  }
  
  /// Reset error state
  /// This method is consistent with other providers' error handling
  void resetError() {
    _isError = false;
    _errorMessage = null;
    notifyListeners();
  }

  void resetSearchError() {
    _hasErrorSearch = false;
    _errorSearch = null;
    notifyListeners();
  }

  /// Search artworks in user's collection
  /// [query] : Search term (artist or artwork name)
  /// [resetResults] : If true, reset previous results (for a new search)
  Future<void> searchCollectionArtworks({
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
      final response = await _apiService.get(
        '/api/artworks/my-collection/search',
        queryParameters: {
          'query': query,
          'limit': _limit,
          'offset': requestOffset,
        },
      );

      if (response.data != null) {
        final List<dynamic> artworksJson = response.data;
        final List<ArtworkModel> newArtworks =
            artworksJson.map((json) => ArtworkModel.fromJson(json)).toList();

        // Update results and state
        if (newArtworks.isEmpty) {
          _hasMoreSearchResults = false;
        } else {
          // Update offset for next request
          _searchOffset = requestOffset + newArtworks.length;
        
          if (resetResults) {
            _searchResults = newArtworks;
          } else {
            // Create a set of existing artwork IDs to check for duplicates
            final existingIds = _searchResults.map((artwork) => artwork.id).toSet();
          
            // Only add artworks that aren't already in the list
            final uniqueNewArtworks = newArtworks.where(
              (artwork) => !existingIds.contains(artwork.id)
            ).toList();
          
            if (uniqueNewArtworks.isEmpty) {
              // If no new unique artworks were found, we've reached the end
              _hasMoreSearchResults = false;
            } else {
              _searchResults = [..._searchResults, ...uniqueNewArtworks];
            }
          }
        }
      } else {
        _hasErrorSearch = true;
        _errorSearch = 'Failed to search collection';
        if (kDebugMode) {
          debugPrint('Failed to search collection');
        }
      }
    } catch (e) {
      _hasErrorSearch = true;
      _errorSearch = 'An error occurred while searching collection';
      if (kDebugMode) {
        debugPrint('Error searching collection: $e');
      }
    } finally {
      _isLoadingSearch = false;
      notifyListeners();
    }
  }
}
