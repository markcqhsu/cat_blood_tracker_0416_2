import 'package:flutter/material.dart';
// Removed unused provider import
// import '../../providers/settings_provider.dart';
// import '../../providers/cat_provider.dart';
// import '../../providers/entry_provider.dart';
import 'package:cat_blood_tracker_0416/screens/settings/pet_settings_screen.dart';
import 'package:cat_blood_tracker_0416/screens/settings/insulin_settings_screen.dart';
import 'package:cat_blood_tracker_0416/screens/settings/chart_settings_screen.dart';
import 'package:cat_blood_tracker_0416/screens/settings/export_settings_screen.dart';
import 'package:cat_blood_tracker_0416/screens/settings/import_settings_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Settings',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PetSettingsScreen()),
                  );
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text('Pet Info Settings', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                        Icon(Icons.chevron_right),
                      ],
                    ),
                    const Divider(thickness: 1),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => InsulinSettingsScreen()),
                  );
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text('Insulin Settings', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                        Icon(Icons.chevron_right),
                      ],
                    ),
                    const Divider(thickness: 1),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ChartSettingsScreen()),
                  );
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text('Chart Limit Settings', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                        Icon(Icons.chevron_right),
                      ],
                    ),
                    const Divider(thickness: 1),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ExportSettingsScreen()),
                  );
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text('Backup & Export', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                        Icon(Icons.chevron_right),
                      ],
                    ),
                    const Divider(thickness: 1),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ImportSettingsScreen()),
                  );
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text('Import Settings', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                        Icon(Icons.chevron_right),
                      ],
                    ),
                    const Divider(thickness: 1),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}