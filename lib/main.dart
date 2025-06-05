import 'package:flutter/material.dart';
import 'package:front/utils/constants.dart';
import 'package:front/l10n/app_localizations.dart';
import 'package:front/services/deep_link_service.dart';
import 'package:provider/provider.dart';

import 'services/env_config_service.dart';
import 'services/service_locator.dart';
import 'widgets/auth/auth_wrapper.dart';

void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize environment configuration
  await EnvConfigService.initialize();
  
  // Initialize service locator and services
  await ServiceLocator.init();
  
  runApp(
    MultiProvider(
      providers: ServiceLocator.providers,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final DeepLinkService _deepLinkService = DeepLinkService();
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    // Initialize the deep link service after the initial build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeDeepLinks();
    });
  }

  void _initializeDeepLinks() {
    // Initialize the deep link service with the navigator context
    if (_navigatorKey.currentContext != null) {
      _deepLinkService.initialize(_navigatorKey.currentContext!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Artventuria',
      debugShowCheckedModeBanner: false,
      navigatorKey: _navigatorKey, // Navigator key for deep link service
      // i18n configuration
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      // End i18n configuration
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.purpleIndicator,
          primary: AppColors.gradientStart,
          secondary: AppColors.gradientMiddle,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
        textTheme: TextTheme(
          headlineMedium: AppTextStyles.headlineStyle,
          labelLarge: AppTextStyles.buttonTextStyle,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: Colors.transparent,
            foregroundColor: AppColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(100),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 16,
            ),
          ),
        ),
      ),
      home: const AuthWrapper(),
    );
  }
}
