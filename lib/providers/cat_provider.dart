import 'package:flutter/material.dart';
import '../models/cat_profile.dart';

class CatProvider with ChangeNotifier {
  final List<CatProfile> _cats = [];
  CatProfile? selectedCat;

  List<CatProfile> get cats => _cats;
  String? get selectedCatId => selectedCat?.id;

  CatProfile? getCatById(String id) {
    try {
      return _cats.firstWhere(
        (c) => c.id == id,
        orElse: () => throw StateError('Cat not found'),
      );
    } catch (_) {
      return null;
    }
  }

  bool get hasCats => _cats.isNotEmpty;

  void addCat(CatProfile cat) {
    _cats.add(cat);
    if (_cats.length == 1) {
      selectedCat = cat;
    }
    notifyListeners();
  }

  void updateCat(CatProfile cat) {
    final index = _cats.indexWhere((c) => c.id == cat.id);
    if (index != -1) {
      _cats[index] = cat;
      notifyListeners();
    }
  }

  void deleteCat(CatProfile cat) {
    _cats.removeWhere((c) => c.id == cat.id);
    notifyListeners();
  }

  void selectCat(CatProfile? cat) {
    selectedCat = cat;
    notifyListeners();
  }

  void setSelectedCat(String? id) {
    if (id == null) return;
    final match = _cats.firstWhere(
      (c) => c.id == id,
      orElse: () => _cats.first,
    );
    selectedCat = match;
    notifyListeners();
  }

  void removeCat(CatProfile cat) {
    _cats.remove(cat);
    notifyListeners();
  }
}
