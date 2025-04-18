import 'package:flutter/material.dart';
import 'package:cat_blood_tracker_0416/models/insulin_rule.dart';

class SettingsProvider extends ChangeNotifier {
  final List<InsulinRuleModel> _insulinRules = [];
  final List<Map<String, dynamic>> _limitRanges = [];
  double _lowerLimit = 70;
  double _upperLimit = 180;

  List<InsulinRuleModel> get insulinRules => _insulinRules;
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

  void addInsulinRule(InsulinRuleModel rule) {
    _insulinRules.add(rule);
    notifyListeners();
  }

  void removeInsulinRule(InsulinRuleModel rule) {
    _insulinRules.removeWhere(
      (r) =>
          r.comparisonType == rule.comparisonType &&
          r.glucoseStart == rule.glucoseStart &&
          r.glucoseEnd == rule.glucoseEnd &&
          r.insulin == rule.insulin,
    );
    notifyListeners();
  }

  void updateInsulinRule(int index, InsulinRuleModel newRule) {
    if (index >= 0 && index < _insulinRules.length) {
      _insulinRules[index] = newRule;
      notifyListeners();
    }
  }

  double? getAutoInsulinDose(int bgValue) {
    for (final rule in _insulinRules) {
      if (rule.comparisonType == 'lessThan' && bgValue < rule.glucoseStart) {
        return rule.insulin;
      }
      if (rule.comparisonType == 'greaterThanOrEqual' &&
          bgValue >= rule.glucoseStart &&
          (rule.glucoseEnd == null || bgValue <= rule.glucoseEnd!)) {
        return rule.insulin;
      }
      if (rule.comparisonType == 'between' &&
          rule.glucoseEnd != null &&
          bgValue >= rule.glucoseStart &&
          bgValue <= rule.glucoseEnd!) {
        return rule.insulin;
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

  List<InsulinRuleModel> convertRawRules(List<dynamic> rawRules) {
    final rules =
        rawRules.map((e) {
          if (e is InsulinRuleModel) return e;
          return InsulinRuleModel.fromJson(e as Map<String, dynamic>);
        }).toList();
    return rules;
  }

  void setRawRules(List<dynamic> rawRules) {
    _insulinRules
      ..clear()
      ..addAll(convertRawRules(rawRules));
    notifyListeners();
  }
}
