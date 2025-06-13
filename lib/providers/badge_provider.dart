import 'package:flutter/foundation.dart';
import '../models/badge_model.dart';
import '../services/badge/badge_service.dart';

class BadgeProvider extends ChangeNotifier {
  final BadgeService _badgeService;

  BadgeProvider(this._badgeService);

  List<BadgeModel> _badges = [];
  bool _isLoading = false;
  String? _error;

  List<BadgeModel> get badges => _badges;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<BadgeModel> get obtainedBadges => _badges.where((badge) => badge.obtained).toList();
  List<BadgeModel> get notObtainedBadges => _badges.where((badge) => !badge.obtained).toList();

  Future<void> loadUserBadges({bool forceReload = false}) async {
    if (_isLoading && !forceReload) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _badges = await _badgeService.getUserBadges();
      _error = null;
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) {
        debugPrint('Error loading badges: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearBadges() {
    _badges = [];
    _error = null;
    notifyListeners();
  }
}