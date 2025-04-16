import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import '../../providers/settings_provider.dart';
import '../../providers/cat_provider.dart';
import '../../providers/entry_provider.dart';
import 'dart:io';
import 'dart:convert';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _newCatName = '';
  double? _newCatWeight;
  int? _newCatAge;

  double _bgStart = 0;
  double _bgEnd = 0;
  double _insulinAmount = 0;
  String _comparison = '<';

  final List<Map<String, dynamic>> _limitRanges = [];
  final _availableColors = <Color>[Colors.green, Colors.orange, Colors.red, Colors.blue, Colors.purple];

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

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 16),
      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final catProvider = context.watch<CatProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle("Pet Info Settings"),
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16),
                      ),
                      onChanged: (val) => setState(() => _newCatName = val),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Weight (kg)',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (val) => setState(() => _newCatWeight = double.tryParse(val)),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Age',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (val) => setState(() => _newCatAge = int.tryParse(val)),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: _newCatName.trim().isEmpty
                          ? null
                          : () {
                              context.read<CatProvider>().addCat(
                                    _newCatName.trim(),
                                    weight: _newCatWeight,
                                    age: _newCatAge,
                                  );
                              setState(() {
                                _newCatName = '';
                                _newCatWeight = null;
                                _newCatAge = null;
                              });
                            },
                      icon: const Icon(Icons.add),
                      label: const Text('Add Cat'),
                    ),
                    const SizedBox(height: 8),
                    if (catProvider.cats.isNotEmpty)
                      DataTable(
                        columns: const [
                          DataColumn(label: Text('Name')),
                          DataColumn(label: Text('Weight')),
                          DataColumn(label: Text('Age')),
                          DataColumn(label: Text('Actions')),
                        ],
                        rows: catProvider.cats.map((cat) {
                          return DataRow(cells: [
                            DataCell(Text(cat.name)),
                            DataCell(Text(cat.weight?.toStringAsFixed(1) ?? '-')),
                            DataCell(Text(cat.age?.toString() ?? '-')),
                            DataCell(IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => context.read<CatProvider>().removeCat(cat),
                            )),
                          ]);
                        }).toList(),
                      )
                  ],
                ),
              ),
            ),
            _buildSectionTitle("Insulin Settings"),
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
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
                            decoration: const InputDecoration(
                              labelText: 'BG Start',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (val) => _bgStart = double.tryParse(val) ?? 0,
                          ),
                        ),
                        if (_comparison == '>') ...[
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              decoration: const InputDecoration(
                                labelText: 'BG End',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: (val) => _bgEnd = double.tryParse(val) ?? 0,
                            ),
                          ),
                        ],
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            decoration: const InputDecoration(
                              labelText: 'Insulin (U)',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (val) => _insulinAmount = double.tryParse(val) ?? 0,
                          ),
                        ),
                        IconButton(
                          onPressed: _addInsulinRule,
                          icon: const Icon(Icons.add),
                        ),
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
                  ],
                ),
              ),
            ),
            _buildSectionTitle("Chart Limit Settings"),
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            decoration: const InputDecoration(labelText: 'Lower', border: OutlineInputBorder()),
                            keyboardType: TextInputType.number,
                            onChanged: (val) => _tempLower = double.tryParse(val) ?? 0,
                          ),
                        ),
                        const SizedBox(width: 8),
                        DropdownButton<Color>(
                          value: _tempLowerColor,
                          onChanged: (val) => setState(() => _tempLowerColor = val!),
                          items: _availableColors.map((c) => DropdownMenuItem(value: c, child: Container(width: 24, height: 24, color: c))).toList(),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextField(
                            decoration: const InputDecoration(labelText: 'Upper', border: OutlineInputBorder()),
                            keyboardType: TextInputType.number,
                            onChanged: (val) => _tempUpper = double.tryParse(val) ?? 0,
                          ),
                        ),
                        const SizedBox(width: 8),
                        DropdownButton<Color>(
                          value: _tempUpperColor,
                          onChanged: (val) => setState(() => _tempUpperColor = val!),
                          items: _availableColors.map((c) => DropdownMenuItem(value: c, child: Container(width: 24, height: 24, color: c))).toList(),
                        ),
                        IconButton(onPressed: _addLimitRange, icon: const Icon(Icons.add)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ...settings.limitRanges.map((range) => ListTile(
                          title: Text('Range: ${range['lower']} - ${range['upper']}'),
                          subtitle: Row(
                            children: [
                              const Text('Lower: '),
                              Container(width: 20, height: 20, color: range['lowerColor']),
                              const SizedBox(width: 16),
                              const Text('Upper: '),
                              Container(width: 20, height: 20, color: range['upperColor']),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => settings.removeLimitRange(range),
                          ),
                        ))
                  ],
                ),
              ),
            ),
            _buildSectionTitle("Backup & Export"),
            Wrap(
              spacing: 16,
              runSpacing: 12,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Local backup not implemented')));
                  },
                  icon: const Icon(Icons.backup),
                  label: const Text('Backup'),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    try {
                      final entries = context.read<EntryProvider>().entries;
                      if (entries.isEmpty) return;
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
                      final csv = const ListToCsvConverter().convert(rows);
                      final path = await FilePicker.platform.getDirectoryPath();
                      if (path != null) {
                        final file = File('$path/dm_export.csv');
                        await file.parent.create(recursive: true);
                        await file.writeAsBytes(utf8.encode(csv));
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Exported to $path')));
                      }
                    } catch (e) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Export failed: $e')));
                    }
                  },
                  icon: const Icon(Icons.download),
                  label: const Text('Export CSV'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}