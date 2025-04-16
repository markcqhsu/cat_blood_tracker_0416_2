import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/settings_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _lowerLimitController = TextEditingController();
  final _upperLimitController = TextEditingController();
  final _colorController = TextEditingController();

  final _bgStartController = TextEditingController();
  final _bgEndController = TextEditingController();
  final _insulinController = TextEditingController();
  String _comparison = '<';

  @override
  void dispose() {
    _lowerLimitController.dispose();
    _upperLimitController.dispose();
    _colorController.dispose();
    _bgStartController.dispose();
    _bgEndController.dispose();
    _insulinController.dispose();
    super.dispose();
  }

  void _addColorRange() {
    final lower = double.tryParse(_lowerLimitController.text);
    final upper = double.tryParse(_upperLimitController.text);
    final color = _colorController.text;
    if (lower != null && upper != null && color.isNotEmpty) {
      context.read<SettingsProvider>().addColorRange(lower, upper, color);
      _lowerLimitController.clear();
      _upperLimitController.clear();
      _colorController.clear();
    }
  }

  void _addInsulinRule() {
    final bgStart = double.tryParse(_bgStartController.text);
    final bgEnd = double.tryParse(_bgEndController.text);
    final insulin = double.tryParse(_insulinController.text);
    if (bgStart != null && insulin != null) {
      context.read<SettingsProvider>().addInsulinRule(
        comparison: _comparison,
        bgStart: bgStart,
        bgEnd: _comparison == '>' ? bgEnd : null,
        insulin: insulin,
      );
      _bgStartController.clear();
      _bgEndController.clear();
      _insulinController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SettingsProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Color Ranges', style: TextStyle(fontWeight: FontWeight.bold)),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _lowerLimitController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Lower'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _upperLimitController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Upper'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _colorController,
                    decoration: const InputDecoration(labelText: 'Color (hex)'),
                  ),
                ),
                IconButton(
                  onPressed: _addColorRange,
                  icon: const Icon(Icons.add_circle, color: Colors.teal),
                )
              ],
            ),
            const SizedBox(height: 10),
            ...provider.colorRanges.map((r) => ListTile(
                  title: Text('BG: ${r["start"]}-${r["end"]} → ${r["color"]}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => provider.removeColorRange(r),
                  ),
                )),
            const Divider(height: 32),
            const Text('Auto Insulin Rules', style: TextStyle(fontWeight: FontWeight.bold)),
            Row(
              children: [
                DropdownButton<String>(
                  value: _comparison,
                  items: ['<', '>']
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (val) => setState(() => _comparison = val!),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _bgStartController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'BG Start'),
                  ),
                ),
                if (_comparison == '>') ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _bgEndController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'BG End'),
                    ),
                  ),
                ],
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _insulinController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Insulin (U)'),
                  ),
                ),
                IconButton(
                  onPressed: _addInsulinRule,
                  icon: const Icon(Icons.add_circle, color: Colors.teal),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ...provider.insulinRules.map((r) => ListTile(
                  title: Text(r["comparison"] == '<'
                      ? 'BG < ${r["bgStart"]} → ${r["insulin"]}U'
                      : 'BG ${r["bgStart"]}-${r["bgEnd"]} → ${r["insulin"]}U'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => provider.removeInsulinRule(r),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}