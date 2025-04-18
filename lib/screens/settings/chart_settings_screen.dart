import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/chart_settings_provider.dart';
import '../../models/chart_limit.dart';
import '../../providers/cat_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ChartSettingsScreen extends StatefulWidget {
  const ChartSettingsScreen({super.key});

  @override
  _ChartSettingsScreenState createState() => _ChartSettingsScreenState();
}

class _ChartSettingsScreenState extends State<ChartSettingsScreen> {
  final TextEditingController _lowerLimitController = TextEditingController();
  final TextEditingController _upperLimitController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final catProvider = context.watch<CatProvider>();
    final chartSettingsProvider = context.watch<ChartSettingsProvider>();
    final selectedCatId = catProvider.selectedCatId;
    final selectedCat = catProvider.getCatById(selectedCatId ?? '');
    final limits =
        chartSettingsProvider.limitRecords
            .where((e) => e.catId == selectedCatId)
            .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)?.insulinChartTitle ??
              'Insulin Chart Range Settings',
        ),
      ),
      body:
          selectedCat == null
              ? Center(
                child: Text(
                  AppLocalizations.of(context)?.pleaseAddPet ??
                      'Please add a pet before configuring chart ranges.',
                ),
              )
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // 1. 寵物選擇
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: selectedCatId,
                          items:
                              catProvider.cats.map((cat) {
                                return DropdownMenuItem<String>(
                                  value: cat.id,
                                  child: Text(cat.name),
                                );
                              }).toList(),
                          onChanged: (id) {
                            catProvider.setSelectedCat(id);
                          },
                        ),
                      ),
                    ),

                    // 2. 範圍設定：下限 -> 上限
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLocalizations.of(context)?.lowerLimit ??
                                  'Lower Limit Warning',
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _lowerLimitController,
                                    keyboardType: TextInputType.number,
                                    onChanged: (value) {
                                      if (double.tryParse(value) == null &&
                                          value.isNotEmpty) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Please enter a valid number',
                                            ),
                                          ),
                                        );
                                      }
                                      chartSettingsProvider.setLowerLimit(
                                        value,
                                      );
                                    },
                                    decoration: InputDecoration(
                                      labelText:
                                          AppLocalizations.of(context)?.value ??
                                          'Value',
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.green,
                                    border: Border.all(color: Colors.black12),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              AppLocalizations.of(context)?.upperLimit ??
                                  'Upper Limit Warning',
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _upperLimitController,
                                    keyboardType: TextInputType.number,
                                    onChanged: (value) {
                                      if (double.tryParse(value) == null &&
                                          value.isNotEmpty) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Please enter a valid number',
                                            ),
                                          ),
                                        );
                                      }
                                      chartSettingsProvider.setUpperLimit(
                                        value,
                                      );
                                    },
                                    decoration: InputDecoration(
                                      labelText:
                                          AppLocalizations.of(context)?.value ??
                                          'Value',
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.red,
                                    border: Border.all(color: Colors.black12),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    // 3. 儲存按鈕
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.lightBlue,
                          ),
                          onPressed: () {
                            chartSettingsProvider.saveLimits(selectedCatId);
                            setState(() {
                              _lowerLimitController.clear();
                              _upperLimitController.clear();
                            });
                          },
                          child: Text(
                            AppLocalizations.of(context)?.saveSettings ??
                                'Save Settings',
                          ),
                        ),
                      ),
                    ),

                    // 4. 已設定的紀錄
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: limits.length,
                      itemBuilder: (ctx, index) {
                        final r = limits[index];
                        final catName =
                            catProvider.getCatById(r.catId)?.name ?? 'Unknown';
                        return Dismissible(
                          key: ValueKey(r),
                          direction: DismissDirection.endToStart,
                          onDismissed: (_) {
                            chartSettingsProvider.delete(r);
                          },
                          background: Container(color: Colors.red),
                          child: Card(
                            child: ListTile(
                              title: Text('$catName'),
                              subtitle: Row(
                                children: [
                                  Icon(
                                    Icons.circle,
                                    size: 12,
                                    color: r.upperColor,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${AppLocalizations.of(context)?.upper ?? 'Upper'}: ${r.upper}',
                                  ),
                                  const SizedBox(width: 16),
                                  Icon(
                                    Icons.circle,
                                    size: 12,
                                    color: r.lowerColor,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${AppLocalizations.of(context)?.lower ?? 'Lower'}: ${r.lower}',
                                  ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit),
                                    onPressed: () {
                                      _lowerLimitController.text =
                                          r.lower.toString();
                                      _upperLimitController.text =
                                          r.upper.toString();
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete),
                                    onPressed: () {
                                      chartSettingsProvider.delete(r);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
    );
  }
}
