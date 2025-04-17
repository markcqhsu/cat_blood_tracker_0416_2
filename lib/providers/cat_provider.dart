import 'package:flutter/material.dart';
import '../models/cat_profile.dart';

class CatProvider with ChangeNotifier {
  List<CatProfile> _cats = [];
  CatProfile? selectedCat;

  List<CatProfile> get cats => _cats;

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

  void deleteCat(CatProfile cat) {
    _cats.removeWhere((c) => c.id == cat.id);
    notifyListeners();
  }

  void selectCat(CatProfile? cat) {
    selectedCat = cat;
    notifyListeners();
  }
  void removeCat(CatProfile cat) {
    _cats.remove(cat);
    notifyListeners();
  }
}

// class InsulinRule {
//   final String condition; // "greater" or "less"
//   final double glucose;
//   final int insulin;

//   InsulinRule({
//     required this.condition,
//     required this.glucose,
//     required this.insulin,
//   });

//   Map<String, dynamic> toJson() => {
//         'condition': condition,
//         'glucose': glucose,
//         'insulin': insulin,
//       };

//   factory InsulinRule.fromJson(Map<String, dynamic> json) => InsulinRule(
//         condition: json['condition'],
//         glucose: (json['glucose'] as num).toDouble(),
//         insulin: json['insulin'] as int,
//       );
// }