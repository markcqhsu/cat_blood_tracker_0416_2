import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'providers/entry_provider.dart';
import 'providers/settings_provider.dart';
// import 'package:cat_blood_tracker_0416/providers/settings_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => EntryProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: const CatBgTrackerApp(),
    ),
  );
}