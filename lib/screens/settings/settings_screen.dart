import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/settings_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  double _lower = 0;
  double _upper = 0;
  Color _selectedColor = Colors.green;

  double _bgStart = 0;
  double _bgEnd = 0;
  double _insulinAmount = 0;
  String _comparison = '<';

  final _availableColors = <Color>[Colors.green, Colors.orange, Colors.red, Colors.blue, Colors.purple];

  void _addColorRange() {
    if (_lower >= 0 && _upper > _lower) {
      final settings = context.read<SettingsProvider>();
      settings.addColorRange(_lower, _upper, _selectedColor.value.toRadixString(16));
      setState(() {
        _lower = 0;
        _upper = 0;
      });
    }
  }

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
            const Text('Blood Glucose Color Ranges', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Lower'),
                    onChanged: (val) => _lower = double.tryParse(val) ?? 0,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Upper'),
                    onChanged: (val) => _upper = double.tryParse(val) ?? 0,
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButton<Color>(
                  value: _selectedColor,
                  onChanged: (color) => setState(() => _selectedColor = color!),
                  items: _availableColors.map((color) => DropdownMenuItem(
                    value: color,
                    child: Container(width: 24, height: 24, color: color),
                  )).toList(),
                ),
                IconButton(
                  onPressed: _addColorRange,
                  icon: const Icon(Icons.add),
                )
              ],
            ),
            const SizedBox(height: 10),
            ...settings.colorRanges.map((r) => ListTile(
              title: Text('BG: ${r["start"]} - ${r["end"]}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 20, height: 20, color: Color(int.parse(r['color'], radix: 16))),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => settings.removeColorRange(r),
                  ),
                ],
              ),
            )),
            const Divider(height: 32),
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
          ],
        ),
      ),
    );
  }
}