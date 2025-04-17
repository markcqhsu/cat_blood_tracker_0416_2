// import_settings_screen.dart
import 'package:flutter/material.dart';

class ImportSettingsScreen extends StatelessWidget {
  const ImportSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Import Settings'),
      ),
      body: Center(child: Text('Import Settings Content')),
    );
  }
}