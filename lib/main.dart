import 'package:flutter/material.dart';
import 'package:front/screens/landing_page.dart';
import 'package:front/utils/constants.dart';
import 'package:front/l10n/app_localizations.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Artventuria',
      debugShowCheckedModeBanner: false,
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
      home: const LandingPage(),
    );
  }
}
