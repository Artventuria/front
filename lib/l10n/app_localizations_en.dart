// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get landingPage1Title => 'Discover & Collect Art 🔍';

  @override
  String get landingPage1Subtitle =>
      'Scan NFC tags in museums to find masterpieces.';

  @override
  String get landingPage2Title => 'Build Your Personal Museum 🏛️';

  @override
  String get landingPage2Subtitle =>
      'Each scan adds art to your unique collection. Create your digital museum!';

  @override
  String get landingPage3Title => 'Unlock Rewards & Climb Ranks ⭐';

  @override
  String get landingPage3Subtitle =>
      'Earn points and badges as you explore. Level up and show off your art-hunting skills!';

  @override
  String get landingPage4Title => 'Compete Nationally & Globally 🏆';

  @override
  String get landingPage4Subtitle =>
      'Become the world\'s top art hunter! Step into Artventuria and prove it.';

  @override
  String get signInTitle => 'Welcome to Artventuria';

  @override
  String get signInSubtitle =>
      'Sign in or create your account to begin your artistic adventure.';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get signInButton => 'Sign In';

  @override
  String get noAccount => 'Don\'t have an account? Sign up';

  @override
  String get forgotPassword => 'Forgotten password ?';

  @override
  String get emailRequired => 'Please enter your email';

  @override
  String get emailInvalid => 'Please enter a valid email';

  @override
  String get passwordRequired => 'Please enter your password';

  @override
  String get passwordTooShort => 'Password must be at least 6 characters';

  @override
  String get exploreButton => 'Let\'s explore!';
}
