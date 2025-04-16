import 'package:flutter/material.dart';
import 'screens/home/home_screen.dart';

class CatBgTrackerApp extends StatelessWidget {
  const CatBgTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cat BG Tracker',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}