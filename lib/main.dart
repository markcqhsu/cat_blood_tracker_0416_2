import 'package:flutter/material.dart';
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
      child: const CatBgTrackerApp(),
    ),
  );
}
