import '../models/cat_profile.dart';
import '../models/glucose_entry.dart';
import '../providers/cat_provider.dart';
import '../providers/entry_provider.dart';
import 'package:flutter/material.dart';

class MockDataSeeder {
  static void seed(CatProvider catProvider, EntryProvider entryProvider) {
    debugPrint('Seeding mock data...');

    // Add test cats
    final cat1 = CatProfile(id: '1', name: 'Mimi', weight: 4.5, age: 3);
    final cat2 = CatProfile(id: '2', name: 'Luna', weight: 3.8, age: 2);
    catProvider.addCat(cat1);
    catProvider.addCat(cat2);

    final now = DateTime.now();

    // Add glucose entries for Mimi
    for (int i = 0; i < 5; i++) {
      final date = now.subtract(Duration(days: i));
      entryProvider.addEntry(
        GlucoseEntry(
          id: 'mimi_${i}_am',
          catID: cat1.id,
          dateTime: DateTime(date.year, date.month, date.day, 8, 0),
          bloodGlucose: 100 + i * 5,
          insulinDose: 1,
          weight: cat1.weight,
        ),
      );
      entryProvider.addEntry(
        GlucoseEntry(
          id: 'mimi_${i}_pm',
          catID: cat1.id,
          dateTime: DateTime(date.year, date.month, date.day, 20, 0),
          bloodGlucose: 150 + i * 5,
          insulinDose: 2,
          weight: cat1.weight,
        ),
      );
    }

    // Add glucose entries for Luna
    for (int i = 0; i < 5; i++) {
      final date = now.subtract(Duration(days: i));
      entryProvider.addEntry(
        GlucoseEntry(
          id: 'luna_${i}_am',
          catID: cat2.id,
          dateTime: DateTime(date.year, date.month, date.day, 8, 0),
          bloodGlucose: 110 + i * 3,
          insulinDose: 1,
          weight: cat2.weight,
        ),
      );
      entryProvider.addEntry(
        GlucoseEntry(
          id: 'luna_${i}_pm',
          catID: cat2.id,
          dateTime: DateTime(date.year, date.month, date.day, 20, 0),
          bloodGlucose: 140 + i * 4,
          insulinDose: 2,
          weight: cat2.weight,
        ),
      );
    }
  }
}
