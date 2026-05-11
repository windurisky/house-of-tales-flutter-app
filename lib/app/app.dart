import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/l10n/app_localizations.dart';
import '../core/theme/app_theme.dart';
import 'providers.dart';
import 'router.dart';

class HouseOfTalesApp extends ConsumerWidget {
  const HouseOfTalesApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final language = ref.watch(uiLanguageProvider);

    return MaterialApp.router(
      title: 'House of Tales',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      locale: Locale(language.name),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: router,
    );
  }
}
