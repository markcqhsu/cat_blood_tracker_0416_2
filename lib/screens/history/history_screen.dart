import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../models/cat_profile.dart';
import '../../providers/entry_provider.dart';
import '../../providers/cat_provider.dart' as cp;
import '../../models/glucose_entry.dart';
import '../entry/entry_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _selectedRange = 'All';
  final List<String> _ranges = ['All', '7 days', '30 days', 'Custom'];
  DateTime? _startDate;
  DateTime? _endDate;
  String? _selectedCatId;

  bool _inRange(DateTime time) {
    if (_selectedRange == 'All') {
      return true;
    }
    if (_selectedRange == '7 days') {
      return time.isAfter(DateTime.now().subtract(const Duration(days: 7)));
    } else if (_selectedRange == '30 days') {
      return time.isAfter(DateTime.now().subtract(const Duration(days: 30)));
    } else if (_selectedRange == 'Custom') {
      if (_startDate != null && _endDate != null) {
        return time.isAfter(_startDate!.subtract(const Duration(seconds: 1))) &&
            time.isBefore(_endDate!.add(const Duration(days: 1)));
      }
      return false;
    }
    return true;
  }

  Future<void> _selectCustomDateRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 1),
      initialDateRange:
          _startDate != null && _endDate != null
              ? DateTimeRange(start: _startDate!, end: _endDate!)
              : null,
    );
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  Future<bool> _confirmDelete(BuildContext context, GlucoseEntry entry) async {
    if (!mounted) return false;
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Delete Entry'),
            content: const Text('Are you sure you want to delete this entry?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
    if (confirmed == true) {
      if (!mounted) return false;
      context.read<EntryProvider>().deleteEntry(entry);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Entry deleted.')));
      return true;
    }
    return false;
  }

  void _editEntry(BuildContext context, GlucoseEntry entry) {
    if (!mounted) return;
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => EntryScreen(entryToEdit: entry)));
  }

  Widget _buildStatCard(
    String label,
    String value, {
    bool isHigh = false,
    bool isLow = false,
  }) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color:
                isHigh
                    ? Colors.red
                    : isLow
                    ? Colors.blue
                    : null,
            fontSize: 18,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final catProvider = context.watch<cp.CatProvider>();
    final cats = catProvider.cats;
    final allEntries = context.watch<EntryProvider>().entries;
    final entries =
        allEntries
            .where(
              (e) =>
                  _inRange(e.dateTime) &&
                  (_selectedCatId == null || e.catID == _selectedCatId),
            )
            .toList();

    final avgBg =
        entries.isEmpty
            ? 0
            : entries.map((e) => e.bloodGlucose).reduce((a, b) => a + b) /
                entries.length;
    final avgInsulin =
        entries.isEmpty
            ? 0
            : entries.map((e) => e.insulinDose).reduce((a, b) => a + b) /
                entries.length;
    final high =
        entries.isEmpty
            ? 0
            : entries
                .map((e) => e.bloodGlucose)
                .reduce((a, b) => a > b ? a : b);
    final low =
        entries.isEmpty
            ? 0
            : entries
                .map((e) => e.bloodGlucose)
                .reduce((a, b) => a < b ? a : b);

    final screenHeight = MediaQuery.of(context).size.height;

    final grouped = <String, List<GlucoseEntry>>{};
    for (var e in entries) {
      final dateKey = DateFormat('yyyy-MM-dd').format(e.dateTime);
      grouped.putIfAbsent(dateKey, () => []).add(e);
    }

    final groupedEntries =
        grouped.entries.toList()
          ..sort((a, b) => b.key.compareTo(a.key)); // newest date first

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 700),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 50.0),
                child: Center(
                  child: Text(
                    AppLocalizations.of(context)?.historyTitle ?? 'History',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String?>(
                        value: _selectedCatId,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.pets),
                        ),
                        hint: Text(
                          AppLocalizations.of(context)?.catFilter ?? 'Cat',
                        ),
                        items: [
                          DropdownMenuItem(
                            value: null,
                            child: Text(
                              AppLocalizations.of(context)?.catFilterAll ??
                                  'All',
                            ),
                          ),
                          ...cats.map(
                            (cat) => DropdownMenuItem(
                              value: cat.id,
                              child: Text(cat.name),
                            ),
                          ),
                        ],
                        onChanged:
                            (value) => setState(() => _selectedCatId = value),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedRange,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        items:
                            _ranges
                                .map(
                                  (r) => DropdownMenuItem(
                                    value: r,
                                    child: Text(r),
                                  ),
                                )
                                .toList(),
                        onChanged: (value) async {
                          if (value != null) {
                            if (value == 'Custom') {
                              await _selectCustomDateRange();
                              if (_startDate == null || _endDate == null) {
                                return;
                              }
                            }
                            setState(() {
                              _selectedRange = value;
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatCard(
                      AppLocalizations.of(context)?.avgBg ?? 'Avg BG',
                      avgBg.toStringAsFixed(0),
                    ),
                    _buildStatCard(
                      AppLocalizations.of(context)?.avgInsulin ?? 'Avg Insulin',
                      avgInsulin.toStringAsFixed(1),
                    ),
                    _buildStatCard(
                      AppLocalizations.of(context)?.high ?? 'High',
                      high.toString(),
                      isHigh: true,
                    ),
                    _buildStatCard(
                      AppLocalizations.of(context)?.low ?? 'Low',
                      low.toString(),
                      isLow: true,
                    ),
                  ],
                ),
              ),
              const Divider(),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  itemCount: groupedEntries.length,
                  itemBuilder: (context, index) {
                    final dateKey = groupedEntries[index].key;
                    final entryList = groupedEntries[index].value;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: double.infinity,
                          color: Colors.grey.shade100,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          child: Text(
                            dateKey ==
                                    DateFormat(
                                      'yyyy-MM-dd',
                                    ).format(DateTime.now())
                                ? '${AppLocalizations.of(context)?.today ?? "Today"} - ${DateFormat.yMMMMd().format(DateTime.now())}'
                                : DateFormat.yMMMMd().format(
                                  DateTime.parse(dateKey),
                                ),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        ...entryList.map((entry) {
                          final catColor =
                              Colors
                                  .primaries[entry.catID.hashCode %
                                      Colors.primaries.length]
                                  .shade100;
                          final catName =
                              cats
                                  .firstWhere(
                                    (c) => c.id == entry.catID,
                                    orElse:
                                        () => CatProfile(
                                          id: 'unknown',
                                          name: 'Unknown',
                                        ),
                                  )
                                  .name;
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            child: Row(
                              crossAxisAlignment:
                                  CrossAxisAlignment.center, // ⬅ 加這行
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: catColor,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    catName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ListTile(
                                    title: Text(
                                      '${entry.bloodGlucose} mg/dL',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: Text(
                                      '• Insulin: ${entry.insulinDose}',
                                    ),
                                    trailing: Text(
                                      DateFormat(
                                        'HH:mm',
                                      ).format(entry.dateTime),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            // child: Row(
                            //   crossAxisAlignment: CrossAxisAlignment.start,
                            //   children: [
                            //     Container(
                            //       padding: const EdgeInsets.symmetric(
                            //         horizontal: 8,
                            //         vertical: 4,
                            //       ),
                            //       decoration: BoxDecoration(
                            //         color: catColor,
                            //         borderRadius: BorderRadius.circular(8),
                            //       ),
                            //       child: Text(
                            //         catName,
                            //         style: const TextStyle(
                            //           fontWeight: FontWeight.bold,
                            //         ),
                            //       ),
                            //     ),
                            //     const SizedBox(width: 8),
                            //     Expanded(
                            //       child: ListTile(
                            //         title: Text(
                            //           '${entry.bloodGlucose} mg/dL',
                            //           style: const TextStyle(
                            //             fontWeight: FontWeight.bold,
                            //           ),
                            //         ),
                            //         subtitle: Text(
                            //           '• Insulin: ${entry.insulinDose}',
                            //         ),
                            //         trailing: Text(
                            //           DateFormat(
                            //             'HH:mm',
                            //           ).format(entry.dateTime),
                            //         ),
                            //       ),
                            //     ),
                            //   ],
                            // ),
                          );
                        }),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
