import 'package:flutter/foundation.dart';
import '../../models/badge_model.dart';
import '../api/api_service.dart';

class BadgeService {
  final ApiService _apiService;

  BadgeService(this._apiService);

  /// Get all badges with status for the current user
  Future<List<BadgeModel>> getUserBadges() async {
    try {
      final response =
          await _apiService.get('/api/users/me/badges/all-with-status');

      if (response.statusCode == 200) {
        final List<dynamic> badgesJson = response.data;
        return badgesJson.map((json) => BadgeModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load badges: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching user badges: $e');
      }
      rethrow;
    }
  }
}
