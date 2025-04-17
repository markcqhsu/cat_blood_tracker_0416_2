import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/insulin_rule.dart';
import '../../providers/settings_provider.dart';

class InsulinSettingsScreen extends StatefulWidget {
  @override
  State<InsulinSettingsScreen> createState() => _InsulinSettingsScreenState();
}

class _InsulinSettingsScreenState extends State<InsulinSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _glucoseController = TextEditingController();
  final TextEditingController _insulinController = TextEditingController();
  String _condition = 'less';

  void _addRule() {
    if (_formKey.currentState!.validate()) {
      final glucose = double.tryParse(_glucoseController.text) ?? 0;
      final insulin = double.tryParse(_insulinController.text) ?? 0;
      Provider.of<SettingsProvider>(context, listen: false).addInsulinRule(
        comparison: _condition,
        bgStart: glucose,
        insulin: insulin,
      );
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
                    value: _condition,
                    items: const [
                      DropdownMenuItem(value: 'less', child: Text('<')),
                      DropdownMenuItem(value: 'greater', child: Text('>')),
                    ],
                    onChanged: (val) => setState(() => _condition = val!),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _glucoseController,
                      decoration: const InputDecoration(labelText: 'Glucose'),
                      keyboardType: TextInputType.number,
                      validator: (v) => v == null || v.isEmpty ? 'Enter value' : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _insulinController,
                      decoration: const InputDecoration(labelText: 'Insulin'),
                      keyboardType: TextInputType.number,
                      validator: (v) => v == null || v.isEmpty ? 'Enter value' : null,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: _addRule,
                  )
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: rules.length,
                itemBuilder: (context, index) {
                  final rule = rules[index];
                  return Card(
                    child: ListTile(
                      title: Text(
                        '${rule.comparison == 'less' ? '<' : '>'} ${rule.glucose} → ${rule.insulin}U',
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => context.read<SettingsProvider>().removeInsulinRule(rules[index].toJson()),
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