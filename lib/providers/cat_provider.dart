import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:cat_blood_tracker_0416/models/cat.dart';

class CatProvider extends ChangeNotifier {
  final List<CatProfile> _cats = [];
  CatProfile? _selectedCat;

  List<CatProfile> get cats => _cats;
  CatProfile? get selectedCat => _selectedCat;

  void addCat(CatProfile cat) {
    _cats.add(cat);
    notifyListeners();
  }

  void updateCat(CatProfile cat) {
    final index = _cats.indexWhere((c) => c.id == cat.id);
    if (index != -1) {
      _cats[index] = cat;
      notifyListeners();
    }
  }

  void removeCat(CatProfile cat) {
    _cats.removeWhere((c) => c.id == cat.id);
    notifyListeners();
  }

  void selectCat(CatProfile? cat) {
    _selectedCat = cat;
    notifyListeners();
  }
}