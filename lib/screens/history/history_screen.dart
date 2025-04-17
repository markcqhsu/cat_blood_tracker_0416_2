import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
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
      initialDateRange: _startDate != null && _endDate != null
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
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Entry'),
        content: const Text('Are you sure you want to delete this entry?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed == true) {
      context.read<EntryProvider>().deleteEntry(entry);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Entry deleted.')),
      );
      return true;
    }
    return false;
  }

  void _editEntry(BuildContext context, GlucoseEntry entry) {
    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EntryScreen(entryToEdit: entry),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final catProvider = context.watch<cp.CatProvider>();
    final cats = catProvider.cats;
    final allEntries = context.watch<EntryProvider>().entries;
    final entries = allEntries
        .where((e) => _inRange(e.dateTime) && (_selectedCatId == null || e.catID == _selectedCatId))
        .toList();

    final screenHeight = MediaQuery.of(context).size.height;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 700),
        child: Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: screenHeight * 0.12,
            bottom: 32,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  'History',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              const SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Cat'),
                  const SizedBox(height: 4),
                  DropdownButtonFormField<String?>(
                    value: _selectedCatId,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    hint: const Text('All'),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('All')),
                      ...cats.map((cat) => DropdownMenuItem(
                        value: cat.id,
                        child: Text(cat.name),
                      )),
                    ],
                    onChanged: (value) => setState(() => _selectedCatId = value),
                  ),
                  const SizedBox(height: 12),
                  const Text('Time'),
                  const SizedBox(height: 4),
                  DropdownButtonFormField<String>(
                    value: _selectedRange,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    items: _ranges.map((r) {
                      return DropdownMenuItem(
                        value: r,
                        child: Text(r),
                      );
                    }).toList(),
                  onChanged: (value) async {
                    if (value != null) {
                      if (value == 'Custom') {
                        await _selectCustomDateRange();
                        if (_startDate == null || _endDate == null) return;
                      }
                      setState(() {
                        _selectedRange = value;
                      });
                    }
                  },
                  ),
                  if (_selectedRange == 'Custom' && _startDate != null && _endDate != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text('${DateFormat('MM/dd').format(_startDate!)} - ${DateFormat('MM/dd').format(_endDate!)}'),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  itemCount: entries.length,
                  itemBuilder: (context, index) {
                    final entry = entries[index];
                    return Dismissible(
                      key: ValueKey(entry.dateTime.toIso8601String()),
                      direction: DismissDirection.endToStart,
                      confirmDismiss: (_) => _confirmDelete(context, entry),
                      background: Container(
                        alignment: Alignment.centerRight,
                        color: Colors.red.shade400,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      child: Card(
                        elevation: 1,
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                cats.firstWhere((c) => c.id == entry.catID, orElse: () => CatProfile(id: '', name: 'Unknown')).name,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(DateFormat('yyyy/MM/dd HH:mm').format(entry.dateTime)),
                            ],
                          ),
                          subtitle: Text('BG: ${entry.bloodGlucose} • Insulin: ${entry.insulinDose} • Weight: ${entry.weight ?? '-'}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _editEntry(context, entry),
                          ),
                        ),
                      ),
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