import 'package:flutter/material.dart';
import '../models/export_format.dart';

class ExportProvider with ChangeNotifier {
  ExportFormat? selectedFormat;

  void selectFormat(ExportFormat format) {
    selectedFormat = format;
    notifyListeners();
  }

  Future<void> exportData(List<dynamic> data) async {
    if (selectedFormat == null) return;

    switch (selectedFormat!) {
      case ExportFormat.csv:
        // TODO: convert and save as CSV
        debugPrint('Exporting as CSV');
        break;
      case ExportFormat.txt:
        debugPrint('Exporting as TXT');
        break;
      case ExportFormat.excel:
        debugPrint('Exporting as Excel');
        break;
      case ExportFormat.pdf:
        debugPrint('Exporting as PDF');
        break;
    }
  }
}
