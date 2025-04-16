import 'package:flutter/material.dart';
import '../models/glucose_entry.dart';

class EntryProvider extends ChangeNotifier {
  final List<GlucoseEntry> _entries = [];

  List<GlucoseEntry> get entries => _entries;

  void addEntry(GlucoseEntry entry) {
    _entries.add(entry);
    notifyListeners();
  }

  void updateEntry(GlucoseEntry oldEntry, GlucoseEntry newEntry) {
    final index = _entries.indexOf(oldEntry);
    if (index != -1) {
      _entries[index] = newEntry;
      notifyListeners();
    }
  }

  void deleteEntry(GlucoseEntry entry) {
    _entries.remove(entry);
    notifyListeners();
  }

  List<GlucoseEntry> getLatestEntries([int count = 3]) {
    return _entries.reversed.take(count).toList();
  }
}