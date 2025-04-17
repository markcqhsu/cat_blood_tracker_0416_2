import 'package:flutter/material.dart';
import 'package:cat_blood_tracker_0416/models/insulin_rule.dart';

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

  void addInsulinRule(InsulinRule rule) {
    _insulinRules.add(rule.toJson());
    notifyListeners();
  }

  void removeInsulinRule(Map<String, dynamic> rule) {
    _insulinRules.remove(rule);
    notifyListeners();
  }

  double? getAutoInsulinDose(int bgValue) {
    for (final rule in _insulinRules) {
      final comparisonType = rule['comparisonType'];
      final double start = rule['glucoseStart'];
      final double? end = rule['glucoseEnd'];
      final double insulin = rule['insulin'];

      if (comparisonType == 'lessThan' && bgValue < start) {
        return insulin;
      }
      if (comparisonType == 'greaterThanOrEqual' && bgValue >= start && (end == null || bgValue <= end)) {
        return insulin;
      }
      if (comparisonType == 'between' && end != null && bgValue >= start && bgValue <= end) {
        return insulin;
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