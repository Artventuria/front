import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../providers/auth_provider.dart';
import '../providers/artwork_provider.dart';
import '../providers/leaderboard_provider.dart';
import '../providers/user_collection_provider.dart';
import '../providers/user_profile_provider.dart';
import '../providers/badge_provider.dart';
import 'api/api_service.dart';
import 'auth/auth_service.dart';
import 'storage/storage_service.dart';
import 'badge/badge_service.dart';

/// Service locator for dependency injection
class ServiceLocator {
  // Private constructor to prevent instantiation
  ServiceLocator._();

  // Services instances
  static final StorageService _storageService = StorageService();
  static late final ApiService _apiService;
  static late final AuthService _authService;
  static late final BadgeService _badgeService;

  // Initialize all services
  static Future<void> initialize() async {
    _apiService = ApiService(_storageService);
    _authService = AuthService(_apiService, _storageService);
    _badgeService = BadgeService(_apiService);
  }

  // Provider list for dependency injection
  static List<SingleChildWidget> get providers => [
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(_authService),
        ),
        ChangeNotifierProvider<ArtworkProvider>(
          create: (_) => ArtworkProvider.create(_storageService, _apiService),
        ),
        ChangeNotifierProvider<UserCollectionProvider>(
          create: (_) => UserCollectionProvider(_apiService),
        ),
        ChangeNotifierProvider<LeaderboardProvider>(
          create: (_) => LeaderboardProvider.create(_apiService),
        ),
        ChangeNotifierProvider<UserProfileProvider>(
          create: (_) => UserProfileProvider(_apiService),
        ),
        ChangeNotifierProvider<BadgeProvider>(
          create: (_) => BadgeProvider(_badgeService),
        ),
      ];

  // Service getters
  static StorageService get storageService => _storageService;
  static ApiService get apiService => _apiService;
  static AuthService get authService => _authService;
  static BadgeService get badgeService => _badgeService;
}
