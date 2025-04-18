import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../models/backup_config.dart';
import '../models/glucose_entry.dart';
import '../providers/cat_provider.dart';

class BackupProvider with ChangeNotifier {
  final BackupConfig _config = BackupConfig();

  BackupConfig get config => _config;

  void toggleAutoBackup(bool value) {
    _config.autoBackup = value;
    notifyListeners();
  }

  void setFrequency(String frequency) {
    _config.frequency = frequency;
    notifyListeners();
  }

  void setLocation(String location) {
    _config.location = location;
    notifyListeners();
  }

  Future<void> performBackup(
    BuildContext context,
    List<GlucoseEntry> entries,
    CatProvider catProvider,
  ) async {
    try {
      final now = DateTime.now();
      final formatter = DateFormat('yyyyMMdd_HHmmss');
      final filename = 'glucose_backup_${formatter.format(now)}.csv';

      String targetDirPath = _config.location;
      if (targetDirPath.isEmpty || targetDirPath == 'Internal Storage') {
        final appDir = await getApplicationDocumentsDirectory();
        targetDirPath = p.join(appDir.path, 'Backup');
      }

      final dir = Directory(targetDirPath);
      await dir.create(recursive: true); // ensure the folder exists
      final path = p.join(dir.path, filename);
      final file = File(path);

      final csvContent = StringBuffer();
      csvContent.writeln('Pet Name,Blood Glucose,Insulin,Time,Weight');

      for (final entry in entries) {
        final petName =
            catProvider.getCatById(entry.catId)?.name ?? entry.catId;
        final glucose = entry.bloodGlucose;
        final insulin = entry.insulin ?? '';
        final time = entry.dateTime.toIso8601String();
        final weight = entry.weight?.toString() ?? '';
        csvContent.writeln('$petName,$glucose,$insulin,$time,$weight');
      }

      await file.writeAsString(csvContent.toString());
      debugPrint('Backup saved to $path');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Backup saved to $path')));
    } catch (e) {
      debugPrint('Backup failed: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Backup failed: $e')));
    }
  }

  Future<void> uploadToGoogleDrive(File file) async {
    debugPrint('Preparing to upload ${file.path} to Google Drive...');
    // TODO: integrate Google Sign-In and Drive API
    // Reference: https://pub.dev/packages/googleapis
  }
}
