import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr')
  ];

  /// No description provided for @landingPage1Title.
  ///
  /// In en, this message translates to:
  /// **'Discover & Collect Art 🔍'**
  String get landingPage1Title;

  /// No description provided for @landingPage1Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Scan NFC tags in museums to find masterpieces.'**
  String get landingPage1Subtitle;

  /// No description provided for @landingPage2Title.
  ///
  /// In en, this message translates to:
  /// **'Build Your Personal Museum 🏛️'**
  String get landingPage2Title;

  /// No description provided for @landingPage2Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Each scan adds art to your unique collection. Create your digital museum!'**
  String get landingPage2Subtitle;

  /// No description provided for @landingPage3Title.
  ///
  /// In en, this message translates to:
  /// **'Unlock Rewards & Climb Ranks ⭐'**
  String get landingPage3Title;

  /// No description provided for @landingPage3Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Earn points and badges as you explore. Level up and show off your art-hunting skills!'**
  String get landingPage3Subtitle;

  /// No description provided for @landingPage4Title.
  ///
  /// In en, this message translates to:
  /// **'Compete Nationally & Globally 🏆'**
  String get landingPage4Title;

  /// No description provided for @landingPage4Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Become the world\'s top art hunter! Step into Artventuria and prove it.'**
  String get landingPage4Subtitle;

  /// No description provided for @signInTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Artventuria'**
  String get signInTitle;

  /// No description provided for @signInSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in or create your account to begin your artistic adventure.'**
  String get signInSubtitle;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @signInButton.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signInButton;

  /// No description provided for @noAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? Sign up'**
  String get noAccount;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgotten password ?'**
  String get forgotPassword;

  /// No description provided for @emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get emailRequired;

  /// No description provided for @emailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get emailInvalid;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get passwordRequired;

  /// No description provided for @noRecentArtworks.
  ///
  /// In en, this message translates to:
  /// **'No recently collected artworks'**
  String get noRecentArtworks;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordTooShort;

  /// No description provided for @exploreButton.
  ///
  /// In en, this message translates to:
  /// **'Let\'s explore!'**
  String get exploreButton;

  /// No description provided for @signUpTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Your Account'**
  String get signUpTitle;

  /// No description provided for @signUpSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Join the adventure and start building your collection.'**
  String get signUpSubtitle;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @createButton.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get createButton;

  /// No description provided for @hasAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Sign in'**
  String get hasAccount;

  /// No description provided for @usernameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your username'**
  String get usernameRequired;

  /// No description provided for @resetPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get resetPasswordTitle;

  /// No description provided for @resetPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your email and we\'ll send you a reset link.'**
  String get resetPasswordSubtitle;

  /// No description provided for @sendButton.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get sendButton;

  /// No description provided for @backToSignIn.
  ///
  /// In en, this message translates to:
  /// **'Back to Sign in'**
  String get backToSignIn;

  /// No description provided for @passwordResetSuccess.
  ///
  /// In en, this message translates to:
  /// **'If an account exists with this email, a password reset link has been sent. Please check your inbox. 📥'**
  String get passwordResetSuccess;

  /// No description provided for @newPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Create new password'**
  String get newPasswordTitle;

  /// No description provided for @newPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your password must be different from previous used passwords.'**
  String get newPasswordSubtitle;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newPassword;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPassword;

  /// No description provided for @resetButton.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get resetButton;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @passwordResetSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Your password has been reset successfully. You can now sign in with your new password. ✅'**
  String get passwordResetSuccessful;

  /// No description provided for @sessionExpired.
  ///
  /// In en, this message translates to:
  /// **'Your session has expired. Please sign in again.'**
  String get sessionExpired;

  /// No description provided for @loginErrorInvalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Email or password is incorrect'**
  String get loginErrorInvalidCredentials;

  /// No description provided for @loginErrorAccountBlocked.
  ///
  /// In en, this message translates to:
  /// **'Your account is blocked'**
  String get loginErrorAccountBlocked;

  /// No description provided for @loginErrorConnection.
  ///
  /// In en, this message translates to:
  /// **'Connection error. Please check your internet connection and try again.'**
  String get loginErrorConnection;

  /// No description provided for @loginErrorUnexpected.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred. Please try again later.'**
  String get loginErrorUnexpected;

  /// No description provided for @resetPasswordTokenExpired.
  ///
  /// In en, this message translates to:
  /// **'This reset link is no longer valid. Please request a new password reset link.'**
  String get resetPasswordTokenExpired;

  /// No description provided for @registerErrorDuplicate.
  ///
  /// In en, this message translates to:
  /// **'This email or username already exists'**
  String get registerErrorDuplicate;

  /// No description provided for @registerErrorUserExists.
  ///
  /// In en, this message translates to:
  /// **'This username already exists'**
  String get registerErrorUserExists;

  /// No description provided for @registerErrorEmailExists.
  ///
  /// In en, this message translates to:
  /// **'This email is already in use'**
  String get registerErrorEmailExists;

  /// No description provided for @registerErrorValidation.
  ///
  /// In en, this message translates to:
  /// **'Please check your information'**
  String get registerErrorValidation;

  /// No description provided for @homePageExplore.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get homePageExplore;

  /// No description provided for @homePageRecentlyCollected.
  ///
  /// In en, this message translates to:
  /// **'Recently collected'**
  String get homePageRecentlyCollected;

  /// No description provided for @homePageStillToCollect.
  ///
  /// In en, this message translates to:
  /// **'Still to collect'**
  String get homePageStillToCollect;

  /// No description provided for @options.
  ///
  /// In en, this message translates to:
  /// **'Options'**
  String get options;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @logoutConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logoutConfirmTitle;

  /// No description provided for @logoutConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get logoutConfirmMessage;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @errorLoadingArtworks.
  ///
  /// In en, this message translates to:
  /// **'Error loading artworks'**
  String get errorLoadingArtworks;

  /// No description provided for @retryButton.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retryButton;

  /// No description provided for @allCollectedCongrats.
  ///
  /// In en, this message translates to:
  /// **'Congratulations! You have collected all available artworks.'**
  String get allCollectedCongrats;

  /// No description provided for @seeMore.
  ///
  /// In en, this message translates to:
  /// **'see more'**
  String get seeMore;

  /// No description provided for @seeLess.
  ///
  /// In en, this message translates to:
  /// **'See less'**
  String get seeLess;

  /// No description provided for @viewDetails.
  ///
  /// In en, this message translates to:
  /// **'View details'**
  String get viewDetails;

  /// No description provided for @searchArtworksHint.
  ///
  /// In en, this message translates to:
  /// **'Enter an artist or artwork name'**
  String get searchArtworksHint;

  /// No description provided for @noSearchResults.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noSearchResults;

  /// No description provided for @searchArtwork.
  ///
  /// In en, this message translates to:
  /// **'Search artwork'**
  String get searchArtwork;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @detailedDescription.
  ///
  /// In en, this message translates to:
  /// **'Detailed Description'**
  String get detailedDescription;

  /// No description provided for @historicalContext.
  ///
  /// In en, this message translates to:
  /// **'Historical Context'**
  String get historicalContext;

  /// No description provided for @specifications.
  ///
  /// In en, this message translates to:
  /// **'Specifications'**
  String get specifications;

  /// No description provided for @materials.
  ///
  /// In en, this message translates to:
  /// **'Materials'**
  String get materials;

  /// No description provided for @dimensions.
  ///
  /// In en, this message translates to:
  /// **'Dimensions'**
  String get dimensions;

  /// No description provided for @tags.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get tags;

  /// No description provided for @additionalDetails.
  ///
  /// In en, this message translates to:
  /// **'Additional Details'**
  String get additionalDetails;

  /// No description provided for @externalLinks.
  ///
  /// In en, this message translates to:
  /// **'External Links'**
  String get externalLinks;

  /// No description provided for @artworkStats.
  ///
  /// In en, this message translates to:
  /// **'Artwork Stats'**
  String get artworkStats;

  /// No description provided for @rarityPoints.
  ///
  /// In en, this message translates to:
  /// **'Rarity Points'**
  String get rarityPoints;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @collected.
  ///
  /// In en, this message translates to:
  /// **'Collected'**
  String get collected;

  /// No description provided for @notCollected.
  ///
  /// In en, this message translates to:
  /// **'Not collected'**
  String get notCollected;

  /// No description provided for @loadingEllipsis.
  ///
  /// In en, this message translates to:
  /// **'...'**
  String get loadingEllipsis;

  /// No description provided for @points.
  ///
  /// In en, this message translates to:
  /// **'pts'**
  String get points;

  /// No description provided for @didYouKnow.
  ///
  /// In en, this message translates to:
  /// **'Did you know?'**
  String get didYouKnow;

  /// No description provided for @fullScreen.
  ///
  /// In en, this message translates to:
  /// **'Full screen'**
  String get fullScreen;

  /// No description provided for @notAvailable.
  ///
  /// In en, this message translates to:
  /// **'N/A'**
  String get notAvailable;

  /// No description provided for @leaderboard.
  ///
  /// In en, this message translates to:
  /// **'Leaderboard'**
  String get leaderboard;

  /// No description provided for @searchFriend.
  ///
  /// In en, this message translates to:
  /// **'Search a friend'**
  String get searchFriend;

  /// No description provided for @leaderboardLoadingError.
  ///
  /// In en, this message translates to:
  /// **'Error loading leaderboard'**
  String get leaderboardLoadingError;

  /// No description provided for @leaderboardNoData.
  ///
  /// In en, this message translates to:
  /// **'No leaderboard data available'**
  String get leaderboardNoData;

  /// No description provided for @leaderboardNoResultsFor.
  ///
  /// In en, this message translates to:
  /// **'No results found for \"{searchText}\"'**
  String leaderboardNoResultsFor(Object searchText);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
