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
}
