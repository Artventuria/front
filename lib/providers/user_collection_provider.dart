import 'package:flutter/foundation.dart';

import '../models/user_profile.dart';
import '../models/artwork/artwork_model.dart';
import '../services/api/api_service.dart';
import '../services/api/api_response.dart';

class UserCollectionProvider extends ChangeNotifier {
  final ApiService _apiService;

  UserCollectionProvider(this._apiService);

  // Separate loading and error flags for each data type
  bool _isLoadingProfile = false;
  bool _isLoadingArtworks = false;
  bool _isError = false;
  String? _errorMessage;
  UserProfile? _userProfile;
  List<ArtworkModel> _collectedArtworks = [];
  bool _isInitialized = false;
  int _totalArtworksCount = 0;
  bool _hasMoreArtworks = true;

  // Pagination
  static const int _limit = 10;
  int _offset = 0;

  // Getters
  bool get isLoadingProfile => _isLoadingProfile;
  bool get isLoadingArtworks => _isLoadingArtworks;
  // A general isLoading for the whole page initial load
  bool get isLoading =>
      _isLoadingProfile || (_isLoadingArtworks && _collectedArtworks.isEmpty);
  bool get isError => _isError;
  String? get errorMessage => _errorMessage;
  UserProfile? get userProfile => _userProfile;
  List<ArtworkModel> get collectedArtworks => _collectedArtworks;
  bool get isInitialized => _isInitialized;
  bool get hasMoreArtworks => _hasMoreArtworks;
  int get totalArtworksCount => _totalArtworksCount;

  // Load user profile data
  Future<void> loadUserProfile() async {
    if (_isLoadingProfile) return;
    _isLoadingProfile = true;
    _isError = false;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.get('/api/users/me');
      final apiResponse = ApiResponse.fromDioResponse(response);
      if (apiResponse.data != null) {
        _userProfile = UserProfile.fromJson(apiResponse.data);
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

      final apiResponse = ApiResponse.fromDioResponse(response);
      if (apiResponse.data != null) {
        final List<dynamic> artworksJson = apiResponse.data;
        final List<ArtworkModel> newArtworks =
            artworksJson.map((json) => ArtworkModel.fromJson(json)).toList();

        // Get total count from headers
        final totalCountHeader = apiResponse.headers?['x-total-count'];
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
}
