import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class CatProfile {
  final String id;
  final String name;
  final double? weight;
  final String? breed;

  CatProfile({
    required this.id,
    required this.name,
    this.weight,
    this.breed,
  });
}

class CatProvider extends ChangeNotifier {
  final List<CatProfile> _cats = [];
  CatProfile? _selectedCat;

  List<CatProfile> get cats => _cats;
  CatProfile? get selectedCat => _selectedCat;

  void addCat(String name, {double? weight, String? breed}) {
    final newCat = CatProfile(
      id: const Uuid().v4(),
      name: name,
      weight: weight,
      breed: breed,
    );
    _cats.add(newCat);
    notifyListeners();
  }

  void selectCat(CatProfile cat) {
    _selectedCat = cat;
    notifyListeners();
  }

  void removeCat(CatProfile cat) {
    _cats.remove(cat);
    if (_selectedCat?.id == cat.id) {
      _selectedCat = null;
    }
    notifyListeners();
  }
}
