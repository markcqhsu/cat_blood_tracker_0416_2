import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../models/insulin_rule.dart' as model;
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
  int? _editingIndex;

  void _addRule() {
    if (_formKey.currentState!.validate()) {
      final glucoseStart = double.tryParse(_glucoseStartController.text) ?? 0;
      final glucoseEnd =
          _glucoseEndController.text.isNotEmpty
              ? double.tryParse(_glucoseEndController.text)
              : null;
      final insulinStr = _insulinController.text;
      if (insulinStr.isEmpty || double.tryParse(insulinStr) == null) return;
      final insulin = double.parse(insulinStr);

      final rule = model.InsulinRuleModel(
        comparisonType: _comparisonType,
        glucoseStart: glucoseStart,
        glucoseEnd: glucoseEnd,
        insulin: insulin,
      );

      final provider = Provider.of<SettingsProvider>(context, listen: false);
      if (_editingIndex != null &&
          _editingIndex! < provider.insulinRules.length) {
        provider.updateInsulinRule(_editingIndex!, rule);
        _editingIndex = null;
      } else {
        provider.addInsulinRule(rule);
      }

      _glucoseStartController.clear();
      _glucoseEndController.clear();
      _insulinController.clear();
    }
  }

  void _autoFillInsulin(String value) {
    final bg = double.tryParse(value);
    if (bg == null) return;

    final rules =
        context
            .read<SettingsProvider>()
            .insulinRules
            .map(
              (e) => model.InsulinRuleModel.fromJson(e as Map<String, dynamic>),
            )
            .toList();
    rules.sort((a, b) => a.glucoseStart!.compareTo(b.glucoseStart!));

    for (final rule in rules) {
      final start = rule.glucoseStart!;
      final end = rule.glucoseEnd ?? double.infinity;
      if (bg >= start && bg <= end) {
        _insulinController.text = rule.insulin.toString();
        return;
      }
    }

    _insulinController.clear();
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
    final rules =
        rawRules
            .map(
              (e) => model.InsulinRuleModel.fromJson(e as Map<String, dynamic>),
            )
            .toList();
    rules.sort((a, b) => a.glucoseStart!.compareTo(b.glucoseStart!));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)?.bloodGlucose ?? 'Blood Glucose',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Rule Setup Card
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)?.bloodGlucose ??
                          'Blood Glucose',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ConstrainedBox(
                            constraints: const BoxConstraints(
                              minWidth: double.infinity,
                            ),
                            child: Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: [
                                SizedBox(
                                  width: 150,
                                  child: TextFormField(
                                    controller: _glucoseStartController,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      labelText:
                                          AppLocalizations.of(
                                            context,
                                          )?.bloodGlucose ??
                                          'Blood Glucose',
                                      hintText:
                                          AppLocalizations.of(
                                            context,
                                          )?.enterBloodGlucose ??
                                          'Enter Blood Glucose',
                                    ),
                                    validator: (v) {
                                      if (v == null || v.isEmpty)
                                        return 'Enter value';
                                      if (double.tryParse(v) == null)
                                        return 'Enter a valid number';
                                      return null;
                                    },
                                  ),
                                ),
                                SizedBox(
                                  width: 150,
                                  child: TextFormField(
                                    controller: _glucoseEndController,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      labelText:
                                          AppLocalizations.of(
                                            context,
                                          )?.bloodGlucose ??
                                          'Blood Glucose',
                                      hintText:
                                          AppLocalizations.of(
                                            context,
                                          )?.enterBloodGlucose ??
                                          'Enter Blood Glucose',
                                    ),
                                    validator: (v) {
                                      if (v == null || v.isEmpty)
                                        return 'Enter value';
                                      if (double.tryParse(v) == null)
                                        return 'Enter a valid number';
                                      return null;
                                    },
                                  ),
                                ),
                                SizedBox(
                                  width: 150,
                                  child: TextFormField(
                                    controller: _insulinController,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      labelText:
                                          AppLocalizations.of(
                                            context,
                                          )?.insulinDose ??
                                          'Insulin Dose',
                                      hintText:
                                          AppLocalizations.of(
                                            context,
                                          )?.insulinDose ??
                                          'Insulin Dose',
                                    ),
                                    validator: (v) {
                                      if (v == null || v.isEmpty)
                                        return 'Enter value';
                                      if (double.tryParse(v) == null)
                                        return 'Enter a valid number';
                                      return null;
                                    },
                                  ),
                                ),
                                ElevatedButton.icon(
                                  onPressed: _addRule,
                                  icon: const Icon(Icons.add),
                                  label: Text(
                                    AppLocalizations.of(context)?.saveRecord ??
                                        'Save Record',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Existing Rules Card
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)?.recentRecords ??
                          'Recent Records',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: rules.length,
                      itemBuilder: (context, index) {
                        final rule = rules[index];
                        final range =
                            rule.glucoseEnd != null
                                ? '${rule.glucoseStart!.toInt()} - ${rule.glucoseEnd!.toInt()}'
                                : '${rule.glucoseStart!.toInt()}';
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: ListTile(
                            onTap: () {
                              setState(() {
                                _glucoseStartController.text =
                                    rule.glucoseStart!.toString();
                                _glucoseEndController.text =
                                    rule.glucoseEnd?.toString() ?? '';
                                _insulinController.text =
                                    rule.insulin.toString();
                                _comparisonType =
                                    'between'; // default assumption
                                _editingIndex = index;
                              });
                            },
                            title: Text(
                              '${AppLocalizations.of(context)?.insulinDose ?? 'Insulin Dose'}: ${rule.insulin.toInt()}U',
                            ),
                            leading: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade100,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                rule.glucoseEnd != null
                                    ? '${rule.glucoseStart.toInt()} - ${rule.glucoseEnd!.toInt()} mg/dL'
                                    : '${rule.glucoseStart.toInt()} mg/dL',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                context
                                    .read<SettingsProvider>()
                                    .removeInsulinRule(rule);
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Instructions Card
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Instructions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      '• Fill in the glucose range (min to max) and corresponding insulin dose.',
                    ),
                    Text(
                      '• You can set multiple rules to cover various glucose levels.',
                    ),
                    Text(
                      '• To delete a rule, tap the trash icon on the right.',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
