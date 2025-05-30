// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get landingPage1Title => 'Découvre & Collectionne l\'Art 🔍';

  @override
  String get landingPage1Subtitle =>
      'Scanne les tags NFC des musées pour dénicher des chefs-d\'œuvre.';

  @override
  String get landingPage2Title => 'Crée Ton Musée Personnel 🏛️';

  @override
  String get landingPage2Subtitle =>
      'Chaque scan enrichit ta collection unique. Bâtis ton musée digital !';

  @override
  String get landingPage3Title => 'Gagne des Récompenses & Monte en Grade ⭐';

  @override
  String get landingPage3Subtitle =>
      'Obtiens des points et des badges en explorant. Progresse et révèle tes talents de chasseur d\'art !';

  @override
  String get landingPage4Title => 'Compétition Nationale & Mondiale 🏆';

  @override
  String get landingPage4Subtitle =>
      'Deviens le N°1 des chasseurs d\'art ! Entre dans Artventuria et prouve-le.';

  @override
  String get signInTitle => 'Bienvenue sur Artventuria';

  @override
  String get signInSubtitle =>
      'Connectez-vous ou créez votre compte pour commencer votre aventure artistique.';

  @override
  String get email => 'Email';

  @override
  String get password => 'Mot de passe';

  @override
  String get signInButton => 'Se connecter';

  @override
  String get noAccount => 'Pas encore de compte ? Inscrivez-vous';

  @override
  String get forgotPassword => 'Mot de passe oublié ?';

  @override
  String get emailRequired => 'Veuillez saisir votre email';

  @override
  String get emailInvalid => 'Veuillez saisir un email valide';

  @override
  String get passwordRequired => 'Veuillez saisir votre mot de passe';

  @override
  String get passwordTooShort =>
      'Le mot de passe doit contenir au moins 6 caractères';

  @override
  String get exploreButton => 'Commençons !';
}
