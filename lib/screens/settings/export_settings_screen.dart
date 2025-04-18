import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/backup_provider.dart';
import '../../providers/export_provider.dart';
import '../../providers/entry_provider.dart';
import '../../models/export_format.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../providers/cat_provider.dart';
import 'package:file_picker/file_picker.dart';

class ExportSettingsScreen extends StatefulWidget {
  const ExportSettingsScreen({super.key});

  @override
  State<ExportSettingsScreen> createState() => _ExportSettingsScreenState();
}

class _ExportSettingsScreenState extends State<ExportSettingsScreen> {
  String selectedCatId = 'All';
  String selectedTimeFilter = 'All Time';
  DateTimeRange? customRange;

  @override
  Widget build(BuildContext context) {
    final backup = context.watch<BackupProvider>();
    final export = context.watch<ExportProvider>();
    final catProvider = context.watch<CatProvider>();
    final List<DropdownMenuItem<String>> catItems = [
      const DropdownMenuItem(value: 'All', child: Text('All')),
      ...catProvider.cats.map(
        (cat) => DropdownMenuItem(value: cat.id, child: Text(cat.name)),
      ),
    ];
    final entries = context.watch<EntryProvider>().entries;
    final filtered =
        entries.where((entry) {
          final matchRole =
              selectedCatId == 'All' || entry.catId == selectedCatId;
          final matchTime = switch (selectedTimeFilter) {
            'All Time' => true,
            'Today' => entry.timestamp.isAfter(
              DateTime.now().subtract(const Duration(days: 1)),
            ),
            'This Week' => entry.timestamp.isAfter(
              DateTime.now().subtract(const Duration(days: 7)),
            ),
            'This Month' => entry.timestamp.isAfter(
              DateTime.now().subtract(const Duration(days: 30)),
            ),
            'Custom' =>
              customRange != null &&
                  entry.timestamp.isAfter(
                    customRange!.start.subtract(const Duration(days: 1)),
                  ) &&
                  entry.timestamp.isBefore(
                    customRange!.end.add(const Duration(days: 1)),
                  ),
            _ => true,
          };
          return matchRole && matchTime;
        }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)?.dataManagement ?? 'Data Management',
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 1. Role Filter
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)?.roleFilter ?? 'Role Filter',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    isExpanded: true,
                    value: selectedCatId,
                    items: catItems,
                    onChanged: (value) {
                      setState(() {
                        selectedCatId = value!;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          const Divider(color: Colors.grey),

          // 2. Time Filter
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)?.timeFilter ?? 'Time Filter',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Builder(
                    builder: (context) {
                      final timeFilterLabels = [
                        AppLocalizations.of(context)?.allTime ?? 'All Time',
                        AppLocalizations.of(context)?.today ?? 'Today',
                        AppLocalizations.of(context)?.thisWeek ?? 'This Week',
                        AppLocalizations.of(context)?.thisMonth ?? 'This Month',
                      ];
                      return Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (var label in timeFilterLabels)
                            ChoiceChip(
                              label: Text(label),
                              selected: selectedTimeFilter == label,
                              onSelected: (_) {
                                setState(() {
                                  selectedTimeFilter = label;
                                  customRange = null;
                                });
                              },
                            ),
                          ActionChip(
                            label: Text(
                              AppLocalizations.of(context)?.custom ?? 'Custom',
                            ),
                            onPressed: () async {
                              final picked = await showDateRangePicker(
                                context: context,
                                firstDate: DateTime(2020),
                                lastDate: DateTime.now(),
                              );
                              if (picked != null) {
                                setState(() {
                                  selectedTimeFilter =
                                      AppLocalizations.of(context)?.custom ??
                                      'Custom';
                                  customRange = picked;
                                });
                              }
                            },
                          ),
                          if (selectedTimeFilter ==
                                  (AppLocalizations.of(context)?.custom ??
                                      'Custom') &&
                              customRange != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                '${customRange!.start.toLocal().toString().split(' ')[0]} - ${customRange!.end.toLocal().toString().split(' ')[0]}',
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const Divider(color: Colors.grey),

          // 3. Local Backup
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)?.localBackup ?? 'Local Backup',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Column(
                    children: [
                      SwitchListTile(
                        title: Text(
                          AppLocalizations.of(context)?.autoBackup ??
                              'Auto Backup',
                        ),
                        subtitle: Text(
                          AppLocalizations.of(context)?.autoBackupDescription ??
                              'System will back up your data locally based on frequency.',
                        ),
                        value: backup.config.autoBackup,
                        onChanged: backup.toggleAutoBackup,
                        contentPadding: EdgeInsets.zero,
                      ),
                      const Divider(color: Colors.grey),
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText:
                              AppLocalizations.of(context)?.backupFrequency ??
                              'Backup Frequency',
                          labelStyle: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        value: backup.config.frequency,
                        items:
                            ['Daily', 'Weekly', 'Monthly'].map((f) {
                              return DropdownMenuItem(value: f, child: Text(f));
                            }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            backup.setFrequency(value);
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            AppLocalizations.of(context)?.backupLocation ??
                                'Backup Location',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () async {
                          final pickedDirectory =
                              await FilePicker.platform.getDirectoryPath();
                          if (pickedDirectory != null) {
                            backup.setLocation(pickedDirectory);
                          }
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            vertical: 12.0,
                            horizontal: 12.0,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Text(
                            backup.config.location == 'Internal Storage'
                                ? AppLocalizations.of(
                                      context,
                                    )?.backupInternalStorage ??
                                    'Internal Storage'
                                : backup.config.location,
                            textAlign: TextAlign.left,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        await backup.performBackup(
                          context,
                          filtered,
                          catProvider,
                        );
                      },
                      child: Text(
                        AppLocalizations.of(context)?.backupNow ?? 'Backup Now',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Divider(color: Colors.grey),

          // 4. Export Options
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)?.exportOptions ??
                        'Export Options',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children:
                        ExportFormat.values.map((f) {
                          return ChoiceChip(
                            label: Text(f.name.toUpperCase()),
                            selected: export.selectedFormat == f,
                            onSelected: (_) => export.selectFormat(f),
                          );
                        }).toList(),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        await export.exportData(filtered);
                      },
                      child: Text(
                        AppLocalizations.of(context)?.exportNow ?? 'Export Now',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
