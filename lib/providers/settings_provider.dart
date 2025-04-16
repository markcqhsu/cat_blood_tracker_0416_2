import 'package:flutter/material.dart';

class SettingsProvider extends ChangeNotifier {
  final List<Map<String, dynamic>> _colorRanges = [];
  final List<Map<String, dynamic>> _insulinRules = [];
  double _lowerLimit = 70;
  double _upperLimit = 180;

  List<Map<String, dynamic>> get colorRanges => _colorRanges;
  List<Map<String, dynamic>> get insulinRules => _insulinRules;
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

  void addColorRange(double start, double end, String color) {
    _colorRanges.add({
      'start': start,
      'end': end,
      'color': color,
    });
    notifyListeners();
  }

  void removeColorRange(Map<String, dynamic> range) {
    _colorRanges.remove(range);
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

  String? getColorForBG(int bgValue) {
    for (final r in _colorRanges) {
      if (bgValue >= r['start'] && bgValue <= r['end']) {
        return r['color'];
      }
    }
    return null;
  }
}