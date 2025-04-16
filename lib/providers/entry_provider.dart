import 'package:flutter/material.dart';
import '../models/glucose_entry.dart';

class EntryProvider extends ChangeNotifier {
  final List<GlucoseEntry> _entries = [];

  List<GlucoseEntry> get entries =>
      List.unmodifiable(_entries..sort((a, b) => b.dateTime.compareTo(a.dateTime)));

  void addEntry(GlucoseEntry entry) {
    _entries.add(entry);
    _entries.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    notifyListeners();
  }

  void updateEntry(GlucoseEntry updatedEntry) {
    final index = _entries.indexWhere((e) => e.id == updatedEntry.id);
    if (index != -1) {
      _entries[index] = updatedEntry;
      notifyListeners();
    }
  }

  void deleteEntry(GlucoseEntry entry) {
    _entries.removeWhere((e) => e.id == entry.id);
    notifyListeners();
  }

  void clearEntries() {
    _entries.clear();
    notifyListeners();
  }

  List<GlucoseEntry> getLatestEntries([int count = 3]) {
    final sorted = List<GlucoseEntry>.from(_entries)
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
    return sorted.take(count).toList();
  }
}