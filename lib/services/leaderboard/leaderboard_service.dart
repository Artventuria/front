import 'package:flutter/foundation.dart';
import '../../models/leaderboard_entry.dart';
import '../api/api_service.dart';

class LeaderboardService {
  final ApiService _apiService;

  LeaderboardService(this._apiService);

  /// Get global leaderboard entries
  Future<List<LeaderboardEntry>> getLeaderboard() async {
    try {
      final response = await _apiService.get('/api/leaderboard');

      final List<dynamic> entriesJson = response.data as List<dynamic>;
      final entries =
          entriesJson.map((json) => LeaderboardEntry.fromJson(json)).toList();

      return entries;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error fetching leaderboard: $e');
      }
      rethrow;
    }
  }

  /// Get current user's leaderboard position
  Future<LeaderboardEntry> getCurrentUserPosition() async {
    try {
      final response = await _apiService.get('/api/leaderboard/me');
      return LeaderboardEntry.fromJson(response.data);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error fetching user leaderboard position: $e');
      }
      rethrow;
    }
  }

  /// Get nearby leaderboard positions
  Future<List<LeaderboardEntry>> getNearbyPositions() async {
    try {
      final response = await _apiService.get('/api/leaderboard/nearby');

      final List<dynamic> entriesJson = response.data as List<dynamic>;
      final entries =
          entriesJson.map((json) => LeaderboardEntry.fromJson(json)).toList();

      return entries;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error fetching nearby leaderboard positions: $e');
      }
      rethrow;
    }
  }
}
