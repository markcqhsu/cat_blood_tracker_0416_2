import 'package:flutter/material.dart';
import '../models/insulin_rule.dart';

class SettingsProvider with ChangeNotifier {
  final List<InsulinRule> _insulinRules = [];

  List<InsulinRule> get insulinRules => _insulinRules;

  // void addInsulinRule(InsulinRule rule) {
  //   _insulinRules.add(rule);
  //   notifyListeners();
  // }

  // void removeInsulinRule(int index) {
  //   _insulinRules.removeAt(index);
  //   notifyListeners();
  // }
}