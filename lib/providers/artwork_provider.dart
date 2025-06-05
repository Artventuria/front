import 'package:flutter/foundation.dart';

import '../models/artwork/artwork_model.dart';
import '../services/api/api_service.dart';
import '../services/storage/storage_service.dart';
import '../services/artwork/artwork_service.dart';

enum ArtworkLoadStatus { initial, loading, loaded, error, noMoreData }

class ArtworkProvider extends ChangeNotifier {
  final ArtworkService _artworkService;

  List<ArtworkModel> _stillToCollectArtworks = [];
  bool _isLoading = false;
  bool _hasError = false;
  String? _error;
  String? _nextPageCursor;

  // Getters
  List<ArtworkModel> get stillToCollectArtworks => _stillToCollectArtworks;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  String? get error => _error;
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
  Future<void> loadStillToCollectArtworks({
    required int userId,
    bool refresh = false,
    int limit = 10,
  }) async {
    try {
      if (refresh) {
        _stillToCollectArtworks = [];
        _nextPageCursor = null;
      }
      _isLoading = true;
      _hasError = false;
      _error = null;
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

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _hasError = true;
      _error = e.toString();
      _isLoading = false;
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

  // This method will be implemented later
  Future<bool> collectArtwork(int artworkId, int userId) async {
    // For now, always return true
    return true;
  }

  // Reset error state
  void resetError() {
    _hasError = false;
    _error = null;
    notifyListeners();
  }
}
