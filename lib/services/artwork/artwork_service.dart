import '../../models/artwork/artwork_model.dart';
import '../api/api_service.dart';
import 'package:flutter/foundation.dart';

class ArtworkService {
  final ApiService _apiService;
  String? _lastCursor;

  // Getter for the cursor
  String? get lastCursor => _lastCursor;

  ArtworkService(this._apiService);

  /// Get artworks that the user has not collected yet
  /// [userId] : User ID
  /// [limit] : Number of artworks to retrieve per page
  /// [cursor] : Pagination cursor encoded in Base64, null for the first page
  Future<List<ArtworkModel>> getStillToCollect({
    required int userId,
    int limit = 10,
    String? cursor,
  }) async {
    try {
      // Build query parameters
      final queryParams = <String, dynamic>{
        'limit': limit,
      };

      // Add cursor if it exists
      if (cursor != null) {
        queryParams['cursor'] = cursor;
      }

      // Call API with the correct endpoint
      final response = await _apiService.get(
        '/api/artworks/user/$userId/still-to-collect',
        queryParameters: queryParams,
      );

      // Extract data from the response
      // The response is directly the list of artworks, without the 'data' wrapper
      final List<dynamic> artworksJson = response.data as List<dynamic>;

      // Convert to list of ArtworkModel objects
      final artworks =
          artworksJson.map((json) => ArtworkModel.fromJson(json)).toList();

      // Reset cursor
      _lastCursor = null;

      // Find the last element with a non-null nextPageCursor
      for (var artwork in artworks) {
        if (artwork.nextPageCursor != null &&
            artwork.nextPageCursor!.isNotEmpty) {
          _lastCursor = artwork.nextPageCursor;
        }
      }

      return artworks;
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching still to collect artworks: $e');
      }
      rethrow;
    }
  }

  /// Get artworks that the user has recently collected (last 7 days)
  /// No pagination needed as all recently collected artworks are returned at once
  Future<List<ArtworkModel>> getRecentlyCollectedArtworks() async {
    try {
      // Call API
      final response = await _apiService.get(
        '/api/users/me/recently-collected-artworks',
      );

      // Extract data from the response
      final List<dynamic> artworksJson = response.data as List<dynamic>;

      // Convert to list of ArtworkModel objects
      final artworks =
          artworksJson.map((json) => ArtworkModel.fromJson(json)).toList();

      return artworks;
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching recently collected artworks: $e');
      }
      rethrow;
    }
  }

  /// Search artworks by artist or title
  /// [query] : Search term
  /// [limit] : Number of artworks to retrieve per page (default to 10)
  /// [offset] : Pagination offset (default to 0)
  Future<List<ArtworkModel>> searchArtworks({
    required String query,
    int limit = 10,
    int offset = 0,
  }) async {
    try {
      // Query parameters
      final queryParams = <String, dynamic>{
        'query': query,
        'limit': limit,
        'offset': offset,
      };

      // API call with search endpoint
      final response = await _apiService.get(
        '/api/artworks/search',
        queryParameters: queryParams,
      );

      // Extract data from the response
      final List<dynamic> artworksJson = response.data as List<dynamic>;

      // Convert to list of ArtworkModel objects
      final artworks =
          artworksJson.map((json) => ArtworkModel.fromJson(json)).toList();

      return artworks;
    } catch (e) {
      if (kDebugMode) {
        print('Error searching artworks: $e');
      }
      rethrow;
    }
  }

  /// Check if an artwork is in the user's collection
  /// [artworkId] : ID of the artwork to check
  /// Returns true if the artwork is in the collection, false otherwise
  Future<bool> isArtworkInCollection(String artworkId) async {
    try {
      // Call API with the correct endpoint
      final response = await _apiService.get(
        '/api/artworks/$artworkId/in-collection',
      );

      // The API returns a boolean directly
      return response.data.toString().toLowerCase() == 'true';
    } catch (e) {
      if (kDebugMode) {
        print('Error checking if artwork is in collection: $e');
      }
      // In case of error, consider the artwork is not in the collection
      return false;
    }
  }

  /// Get the number of collectors for an artwork
  /// [artworkId] : ID of the artwork to check
  /// Returns the number of collectors
  Future<int> getArtworkCollectorsCount(String artworkId) async {
    try {
      // Call API with the correct endpoint
      final response = await _apiService.get(
        '/api/artworks/$artworkId/collectors-count',
      );

      // The API returns an integer directly
      return int.tryParse(response.data.toString()) ?? 0;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting artwork collectors count: $e');
      }
      // In case of error, return 0
      return 0;
    }
  }

  /// Get all artworks collected by a specific user
  /// [userId] : User ID
  Future<List<ArtworkModel>> getCollectedArtworks({
    required int userId,
  }) async {
    try {
      // Call API with the correct endpoint for collected artworks by user ID
      final response = await _apiService.get(
        '/api/artworks/user/$userId/collected-artworks',
      );

      // Extract data from the response
      // Assumes the response is a direct list of artworks.
      final List<dynamic> artworksJson = response.data as List<dynamic>;

      // Convert to list of ArtworkModel objects
      final artworks =
          artworksJson.map((json) => ArtworkModel.fromJson(json)).toList();

      return artworks;
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching collected artworks for user $userId: $e');
      }
      rethrow; // Rethrow for the Provider to handle
    }
  }
}
