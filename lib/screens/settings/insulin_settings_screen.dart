import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/insulin_rule.dart';
import '../../providers/settings_provider.dart';

class InsulinSettingsScreen extends StatefulWidget {
  const InsulinSettingsScreen({super.key});

  @override
  State<InsulinSettingsScreen> createState() => _InsulinSettingsScreenState();
}

class _InsulinSettingsScreenState extends State<InsulinSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _glucoseStartController = TextEditingController();
  final TextEditingController _glucoseEndController = TextEditingController();
  final TextEditingController _insulinController = TextEditingController();
  String _comparisonType = 'lessThan';

  void _addRule() {
    if (_formKey.currentState!.validate()) {
      final glucoseStart = double.tryParse(_glucoseStartController.text) ?? 0;
      final glucoseEnd = _glucoseEndController.text.isNotEmpty
          ? double.tryParse(_glucoseEndController.text)
          : null;
      final insulin = double.tryParse(_insulinController.text) ?? 0;

      final rule = InsulinRule(
        comparisonType: _comparisonType,
        glucoseStart: glucoseStart,
        glucoseEnd: glucoseEnd,
        insulin: insulin,
      );

      Provider.of<SettingsProvider>(context, listen: false).addInsulinRule(rule);

      _glucoseStartController.clear();
      _glucoseEndController.clear();
      _insulinController.clear();
    }
  }

  String _comparisonSymbol(String type) {
    switch (type) {
      case 'lessThan':
        return '<';
      case 'lessThanOrEqual':
        return '≤';
      case 'equal':
        return '=';
      case 'greaterThanOrEqual':
        return '≥';
      case 'greaterThan':
        return '>';
      case 'between':
        return '↔';
      default:
        return '?';
    }
  }

  @override
  Widget build(BuildContext context) {
    final rawRules = context.watch<SettingsProvider>().insulinRules;
    final rules = rawRules.map((e) => InsulinRule.fromJson(e)).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Insulin Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Row(
                children: [
                  DropdownButton<String>(
                    value: _comparisonType,
                    items: const [
                      DropdownMenuItem(value: 'lessThan', child: Text('<')),
                      DropdownMenuItem(value: 'lessThanOrEqual', child: Text('≤')),
                      DropdownMenuItem(value: 'equal', child: Text('=')),
                      DropdownMenuItem(value: 'greaterThanOrEqual', child: Text('≥')),
                      DropdownMenuItem(value: 'greaterThan', child: Text('>')),
                      DropdownMenuItem(value: 'between', child: Text('↔')),
                    ],
                    onChanged: (val) => setState(() => _comparisonType = val!),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _glucoseStartController,
                      decoration: const InputDecoration(labelText: 'Glucose From'),
                      keyboardType: TextInputType.number,
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Enter value' : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _glucoseEndController,
                      decoration: const InputDecoration(labelText: 'To (optional)'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _insulinController,
                      decoration: const InputDecoration(labelText: 'Insulin'),
                      keyboardType: TextInputType.number,
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Enter value' : null,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: _addRule,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: rules.length,
                itemBuilder: (context, index) {
                  final rule = rules[index];
                  final range = rule.glucoseEnd != null
                      ? '${rule.glucoseStart}–${rule.glucoseEnd}'
                      : '${rule.glucoseStart}';
                  return Card(
                    child: ListTile(
                      title: Text(
                        '${_comparisonSymbol(rule.comparisonType)} $range → ${rule.insulin}U',
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => context
                            .read<SettingsProvider>()
                            .removeInsulinRule(rule.toJson()),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}