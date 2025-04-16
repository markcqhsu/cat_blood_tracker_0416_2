import 'package:flutter/material.dart';

class SettingsProvider extends ChangeNotifier {
  final List<Map<String, dynamic>> _insulinRules = [];
  final List<Map<String, dynamic>> _limitRanges = [];
  double _lowerLimit = 70;
  double _upperLimit = 180;

  List<Map<String, dynamic>> get insulinRules => _insulinRules;
  List<Map<String, dynamic>> get limitRanges => _limitRanges;
  double get lowerLimit => _lowerLimit;
  double get upperLimit => _upperLimit;

  void setLowerLimit(double value) {
    _lowerLimit = value;
    notifyListeners();
  }

  void setUpperLimit(double value) {
    _upperLimit = value;
    notifyListeners();
  }

  void addInsulinRule({
    required String comparison,
    required double bgStart,
    double? bgEnd,
    required double insulin,
  }) {
    _insulinRules.add({
      'comparison': comparison,
      'bgStart': bgStart,
      'bgEnd': bgEnd,
      'insulin': insulin,
    });
    notifyListeners();
  }

  void removeInsulinRule(Map<String, dynamic> rule) {
    _insulinRules.remove(rule);
    notifyListeners();
  }

  double? getAutoInsulinDose(int bgValue) {
    for (final rule in _insulinRules) {
      if (rule['comparison'] == '<' && bgValue < rule['bgStart']) {
        return rule['insulin'];
      }
      if (rule['comparison'] == '>' &&
          bgValue >= rule['bgStart'] &&
          rule['bgEnd'] != null &&
          bgValue <= rule['bgEnd']) {
        return rule['insulin'];
      }
    }
    return null;
  }

  void addLimitRange({
    required double lower,
    required double upper,
    required Color lowerColor,
    required Color upperColor,
  }) {
    _limitRanges.add({
      'lower': lower,
      'upper': upper,
      'lowerColor': lowerColor,
      'upperColor': upperColor,
    });
    notifyListeners();
  }

  void removeLimitRange(Map<String, dynamic> range) {
    _limitRanges.remove(range);
    notifyListeners();
  }
}