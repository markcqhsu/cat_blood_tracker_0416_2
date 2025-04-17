// export_settings_screen.dart
import 'package:flutter/material.dart';

class ExportSettingsScreen extends StatelessWidget {
  const ExportSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Export Settings'),
      ),
      body: Center(child: Text('Export Settings Content')),
    );
  }
}
