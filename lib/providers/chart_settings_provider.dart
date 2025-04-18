import 'package:flutter/material.dart';
import '../models/chart_limit.dart';

class ChartSettingsProvider extends ChangeNotifier {
  final List<ChartLimit> _limits = [];

  double _lowerLimit = 0;
  double _upperLimit = 0;

  Color _lowerColor = Colors.green;
  Color _upperColor = Colors.red;

  List<ChartLimit> get all => _limits;

  List<ChartLimit> getRecordsFor(String? catId) {
    return _limits.where((e) => e.catId == catId).toList();
  }

  void add(ChartLimit newLimit) {
    _limits.add(newLimit);
    notifyListeners();
  }

  void update(int index, ChartLimit updated) {
    _limits[index] = updated;
    notifyListeners();
  }

  void delete(ChartLimit target) {
    _limits.remove(target);
    notifyListeners();
  }

  void setLowerLimit(String value) {
    _lowerLimit = double.tryParse(value) ?? 0;
  }

  void setUpperLimit(String value) {
    _upperLimit = double.tryParse(value) ?? 0;
  }

  void saveLimits(String? catId) {
    if (catId == null) return;
    _limits.removeWhere((e) => e.catId == catId);
    _limits.add(
      ChartLimit(
        catId: catId,
        lower: _lowerLimit,
        upper: _upperLimit,
        lowerColor: _lowerColor,
        upperColor: _upperColor,
      ),
    );
    notifyListeners();
  }

  List<ChartLimit> get limitRecords => _limits;
}
