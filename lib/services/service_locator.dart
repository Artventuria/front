import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../providers/auth_provider.dart';
import '../providers/artwork_provider.dart';
import 'api/api_service.dart';
import 'auth/auth_service.dart';
import 'storage/storage_service.dart';

/// Service locator for dependency injection
class ServiceLocator {
  // Private constructor to prevent instantiation
  ServiceLocator._();

  // Services instances
  static final StorageService _storageService = StorageService();
  static late final ApiService _apiService;
  static late final AuthService _authService;

  // Initialize all services
  static Future<void> init() async {
    // Initialize services in the correct order
    _apiService = ApiService(_storageService);
    _authService = AuthService(_apiService, _storageService);
  }

  // Providers list for MultiProvider
  static List<SingleChildWidget> get providers => [
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(_authService),
        ),
        ChangeNotifierProvider<ArtworkProvider>(
          create: (_) => ArtworkProvider.create(_storageService, _apiService),
        ),
      ];

  // Service getters
  static StorageService get storageService => _storageService;
  static ApiService get apiService => _apiService;
  static AuthService get authService => _authService;
}
