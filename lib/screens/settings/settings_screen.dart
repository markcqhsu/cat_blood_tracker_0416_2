import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import '../../providers/settings_provider.dart';
import '../../providers/cat_provider.dart';
import 'dart:io';
import 'dart:convert';
import '../../providers/entry_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  double _bgStart = 0;
  double _bgEnd = 0;
  double _insulinAmount = 0;
  String _comparison = '<';
  String _newCatName = '';

  final List<Map<String, dynamic>> _limitRanges = [];

  final _availableColors = <Color>[Colors.green, Colors.orange, Colors.red, Colors.blue, Colors.purple];

  // Optionally add persistence later

  double _tempLower = 0;
  double _tempUpper = 0;
  Color _tempLowerColor = Colors.green;
  Color _tempUpperColor = Colors.red;

  void _addInsulinRule() {
    final settings = context.read<SettingsProvider>();
    settings.addInsulinRule(
      bgStart: _bgStart,
      bgEnd: _comparison == '<' ? null : _bgEnd,
      comparison: _comparison,
      insulin: _insulinAmount,
    );
    setState(() {
      _bgStart = 0;
      _bgEnd = 0;
      _insulinAmount = 0;
      _comparison = '<';
    });
  }

  void _addLimitRange() {
    final settings = context.read<SettingsProvider>();
    settings.addLimitRange(
      lower: _tempLower,
      upper: _tempUpper,
      lowerColor: _tempLowerColor,
      upperColor: _tempUpperColor,
    );
    setState(() {
      _tempLower = 0;
      _tempUpper = 0;
      _tempLowerColor = Colors.green;
      _tempUpperColor = Colors.red;
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Manage Cats', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(labelText: 'Cat Name'),
                    onChanged: (val) => setState(() => _newCatName = val),
                  ),
                ),
                IconButton(
                  onPressed: _newCatName.trim().isEmpty ? null : () {
                    context.read<CatProvider>().addCat(_newCatName.trim());
                    setState(() => _newCatName = '');
                  },
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ...context.watch<CatProvider>().cats.map((cat) => ListTile(
              title: Text(cat.name),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => context.read<CatProvider>().removeCat(cat),
              ),
            )),
            const SizedBox(height: 24),
            const Text('Auto Insulin Rules', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Row(
              children: [
                DropdownButton<String>(
                  value: _comparison,
                  items: ['<', '>'].map((op) => DropdownMenuItem(value: op, child: Text(op))).toList(),
                  onChanged: (val) => setState(() => _comparison = val!),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'BG Start'),
                    onChanged: (val) => _bgStart = double.tryParse(val) ?? 0,
                  ),
                ),
                if (_comparison == '>') ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'BG End'),
                      onChanged: (val) => _bgEnd = double.tryParse(val) ?? 0,
                    ),
                  ),
                ],
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Insulin (U)'),
                    onChanged: (val) => _insulinAmount = double.tryParse(val) ?? 0,
                  ),
                ),
                IconButton(
                  onPressed: _addInsulinRule,
                  icon: const Icon(Icons.add),
                )
              ],
            ),
            const SizedBox(height: 10),
            ...settings.insulinRules.map((r) => ListTile(
              title: Text(r['comparison'] == '<'
                  ? 'BG < ${r["bgStart"]} → ${r["insulin"]}U'
                  : 'BG ${r["bgStart"]} - ${r["bgEnd"]} → ${r["insulin"]}U'),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => settings.removeInsulinRule(r),
              ),
            )),
            const SizedBox(height: 32),
            const Text('Chart Limit Ranges', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(child: Text('Lower Limit')),
                    const SizedBox(width: 8),
                    const Expanded(child: Text('Upper Limit')),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          hintText: 'e.g. 80',
                        ),
                        onChanged: (val) => _tempLower = double.tryParse(val) ?? 0,
                      ),
                    ),
                    const SizedBox(width: 4),
                    DropdownButton<Color>(
                      value: _tempLowerColor,
                      onChanged: (color) => setState(() => _tempLowerColor = color!),
                      items: _availableColors.map((color) => DropdownMenuItem(
                        value: color,
                        child: Container(width: 24, height: 24, color: color),
                      )).toList(),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          hintText: 'e.g. 180',
                        ),
                        onChanged: (val) => _tempUpper = double.tryParse(val) ?? 0,
                      ),
                    ),
                    const SizedBox(width: 4),
                    DropdownButton<Color>(
                      value: _tempUpperColor,
                      onChanged: (color) => setState(() => _tempUpperColor = color!),
                      items: _availableColors.map((color) => DropdownMenuItem(
                        value: color,
                        child: Container(width: 24, height: 24, color: color),
                      )).toList(),
                    ),
                    IconButton(
                      onPressed: _addLimitRange,
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...settings.limitRanges.map((range) => Card(
              child: ListTile(
                title: Text('Range: ${range['lower']} - ${range['upper']}'),
                subtitle: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text('Lower:', style: TextStyle(fontSize: 12)),
                    const SizedBox(width: 4),
                    Container(width: 20, height: 20, color: range['lowerColor']),
                    const SizedBox(width: 16),
                    const Text('Upper:', style: TextStyle(fontSize: 12)),
                    const SizedBox(width: 4),
                    Container(width: 20, height: 20, color: range['upperColor']),
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => settings.removeLimitRange(range),
                ),
              ),
            )),
            const SizedBox(height: 32),
            const Text('Backup & Export', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.backup),
                  label: const Text('Backup Locally'),
                  onPressed: () {
                    // TODO: Implement local backup functionality
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Local backup initiated')));
                  },
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.file_download),
                  label: const Text('Export CSV'),
                  onPressed: () async {
                    try {
                      final entries = context.read<EntryProvider>().entries;
                      final rows = [
                        ['Date', 'Blood Glucose', 'Insulin Dose', 'Weight', 'Cat ID']
                      ];
                      for (final e in entries) {
                        rows.add([
                          e.dateTime.toIso8601String(),
                          e.bloodGlucose.toString(),
                          e.insulinDose.toString(),
                          e.weight?.toString() ?? '',
                          e.catID.toString(),
                        ]);
                      }

                      final csvString = const ListToCsvConverter().convert(rows);

                      final result = await FilePicker.platform.getDirectoryPath();

                      if (result != null) {
                        final outputPath = '$result/dm_export.csv';
                        final file = File(outputPath);
                        await file.parent.create(recursive: true); // ensure the directory exists
                        await file.writeAsBytes(utf8.encode(csvString)); // write as bytes

                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('CSV exported to $outputPath')),
                        );
                      } else {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Export cancelled')),
                        );
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('CSV export failed: $e')),
                      );
                    }
                  },
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.file_copy),
                  label: const Text('Export JSON'),
                  onPressed: () {
                    // TODO: Implement JSON export
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('JSON export started')));
                  },
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text('Export PDF'),
                  onPressed: () {
                    // TODO: Implement PDF export
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('PDF export started')));
                  },
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.table_chart),
                  label: const Text('Export Excel'),
                  onPressed: () {
                    // TODO: Implement Excel export
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Excel export started')));
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}