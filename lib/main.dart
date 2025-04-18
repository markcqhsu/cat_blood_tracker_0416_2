import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'providers/entry_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/cat_provider.dart';

void main() {
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    // Optional: log to console
    debugPrint('Flutter Error: ${details.exceptionAsString()}');
  };
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CatProvider()),
        ChangeNotifierProvider(create: (_) => EntryProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: MaterialApp(
        title: 'Cat Blood Tracker',
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en')],
        locale: const Locale('en'),
        theme: ThemeData(primarySwatch: Colors.blue),
        home: const CatBgTrackerApp(),
      ),
    ),
  );
}

// Note: New file l10n.yaml should be created in the root directory with the following content:
/*
arb-dir: lib/l10n
template-arb-file: app_en.arb
output-localization-file: app_localizations.dart
output-class: AppLocalizations
synthetic-package: false
*/
