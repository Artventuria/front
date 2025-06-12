import 'package:flutter/foundation.dart';

import '../models/user_profile.dart';
import '../models/artwork/artwork_model.dart';
import '../services/api/api_service.dart';

class UserProfileProvider extends ChangeNotifier {
  final ApiService _apiService;

  UserProfileProvider(this._apiService);

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

  // Current user ID
  int? _currentUserId;

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
  int? get currentUserId => _currentUserId;

  // Load user profile data
  Future<void> loadUserProfile(int userId) async {
    _currentUserId = userId;
    
    if (_isLoadingProfile) return;
    _isLoadingProfile = true;
    _isError = false;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.get('/api/users/$userId');
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
    if (_currentUserId == null) {
      _isError = true;
      _errorMessage = 'No user selected';
      notifyListeners();
      return;
    }
    
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
        '/api/artworks/user/$_currentUserId/collection',
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

  // Search in user's collection
  Future<void> searchInCollection(String query, {bool reset = false}) async {
    if (_currentUserId == null) {
      _hasErrorSearch = true;
      _errorSearch = 'No user selected';
      notifyListeners();
      return;
    }
    
    if (query.isEmpty) {
      _searchResults = [];
      _hasMoreSearchResults = false;
      _hasErrorSearch = false;
      _errorSearch = null;
      notifyListeners();
      return;
    }

    if (_isLoadingSearch || (!_hasMoreSearchResults && !reset)) return;

    if (reset) {
      _searchOffset = 0;
      _searchResults = [];
      _hasMoreSearchResults = true;
    }

    _isLoadingSearch = true;
    _hasErrorSearch = false;
    _errorSearch = null;
    notifyListeners();

    try {
      final response = await _apiService.get(
        '/api/artworks/user/$_currentUserId/collection/search',
        queryParameters: {
          'query': query,
          'limit': _limit,
          'offset': _searchOffset,
        },
      );

      if (response.data != null) {
        final List<dynamic> artworksJson = response.data;
        final List<ArtworkModel> newArtworks =
            artworksJson.map((json) => ArtworkModel.fromJson(json)).toList();

        if (reset) {
          _searchResults = newArtworks;
        } else {
          // Filter out duplicates when appending
          final existingIds = _searchResults.map((a) => a.id).toSet();
          final uniqueNewArtworks = newArtworks
              .where((artwork) => !existingIds.contains(artwork.id))
              .toList();
          _searchResults.addAll(uniqueNewArtworks);
        }

        // Update pagination state
        _searchOffset += newArtworks.length;
        _hasMoreSearchResults = newArtworks.length == _limit;
      } else {
        _hasErrorSearch = true;
        _errorSearch = 'Failed to search collection';
      }
    } catch (e) {
      _hasErrorSearch = true;
      _errorSearch = 'An error occurred while searching';
      if (kDebugMode) {
        debugPrint('Error searching collection: $e');
      }
    } finally {
      _isLoadingSearch = false;
      notifyListeners();
    }
  }

  // Refresh all data (profile and artworks) for a specific user
  Future<void> refreshAllData(int userId) async {
    _currentUserId = userId;
    
    // Reset any existing data
    resetData();
    
    // We can run them in parallel now
    await Future.wait([
      loadUserProfile(userId),
      loadCollectedArtworks(reset: true),
    ]);
  }

  // Reset state when changing viewed user
  void resetData() {
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
    
    // Reset search results too
    _searchResults = [];
    _isLoadingSearch = false;
    _hasMoreSearchResults = true;
    _searchOffset = 0;
    _hasErrorSearch = false;
    _errorSearch = null;
    
    notifyListeners();
  }
  
  /// Reset error state
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
}
