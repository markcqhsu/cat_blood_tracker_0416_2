// chart_settings_screen.dart
import 'package:flutter/material.dart';

class ChartSettingsScreen extends StatelessWidget {
  const ChartSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chart Settings'),
      ),
      body: Center(child: Text('Chart Settings Content')),
    );
  }
}