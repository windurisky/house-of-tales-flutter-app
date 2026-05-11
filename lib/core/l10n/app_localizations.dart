import 'package:flutter/material.dart';

class AppLocalizations {
  const AppLocalizations(this.locale);

  final Locale locale;
  bool get isId => locale.languageCode == 'id';

  static const supportedLocales = [Locale('en'), Locale('id')];

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  String get appName => 'House of Tales';
  String get welcomeTitle =>
      isId ? 'Cerita tenang untuk keluarga' : 'Gentle stories for families';
  String get welcomeBody => isId
      ? 'Masuk sebagai orang tua, siapkan profil anak, lalu baca cerita bilingual yang aman.'
      : 'Sign in as a parent, set up a child profile, and read safe bilingual stories.';
  String get parentSignIn =>
      isId ? 'Masuk sebagai orang tua' : 'Parent sign in';
  String get startMockSession =>
      isId ? 'Mulai sesi mock' : 'Start mock session';
  String get onboardingTitle =>
      isId ? 'Siapkan profil anak' : 'Set up your child profile';
  String get childName => isId ? 'Nama anak' : 'Child name';
  String get childAge => isId ? 'Usia' : 'Age';
  String get chooseAvatar => isId ? 'Pilih avatar' : 'Choose avatar';
  String get finishOnboarding => isId ? 'Mulai membaca' : 'Start reading';
  String get homeTitle => isId ? 'Rak cerita hari ini' : 'Today’s story shelf';
  String get profile => isId ? 'Profil' : 'Profile';
  String get stories => isId ? 'Cerita' : 'Stories';
  String get retry => isId ? 'Coba lagi' : 'Retry';
  String get read => isId ? 'Baca' : 'Read';
  String get continueReading => isId ? 'Lanjutkan' : 'Continue';
  String get readAgain => isId ? 'Baca lagi' : 'Read again';
  String get preview => isId ? 'Pratinjau' : 'Preview';
  String get fullAccess => isId ? 'Akses penuh' : 'Full access';
  String get parentSafe => isId ? 'Aman untuk orang tua' : 'Parent safe';
  String get subscriptionExplainer => isId
      ? 'Pratinjau gratis tersedia. Aksi pembayaran masih dimatikan sampai disetujui.'
      : 'Free preview is available. Payment actions stay disabled until approved.';
  String get unlockDisabled =>
      isId ? 'Pembayaran belum aktif' : 'Payments not enabled';
  String get readerGateTitle =>
      isId ? 'Lanjutkan dengan akses keluarga' : 'Continue with family access';
  String get readerGateBody => isId
      ? 'Halaman 1–2 tetap bisa dibaca. Halaman berikutnya menunggu trial/subscription aktif.'
      : 'Pages 1–2 stay readable. Later pages wait for an active trial or subscription.';
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'id'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async =>
      AppLocalizations(locale);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
