import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/glucose_entry.dart';
import '../../providers/entry_provider.dart';
import '../../providers/settings_provider.dart';
import '../../models/insulin_rule.dart' as model;
import '../../providers/cat_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// import '../../models/cat.dart';

class EntryScreen extends StatefulWidget {
  final GlucoseEntry? entryToEdit;
  const EntryScreen({super.key, this.entryToEdit});

  @override
  State<EntryScreen> createState() => _EntryScreenState();
}

class _EntryScreenState extends State<EntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _bgController = TextEditingController();
  final _weightController = TextEditingController();

  DateTime _selectedDateTime = DateTime.now();
  double _insulinValue = 0;
  GlucoseEntry? _editingEntry;

  @override
  void initState() {
    super.initState();
    _bgController.addListener(_autoFillInsulin);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final catProvider = context.read<CatProvider>();
      if (widget.entryToEdit != null) {
        _editingEntry = widget.entryToEdit;
        _selectedDateTime = _editingEntry!.dateTime;
        _bgController.text = _editingEntry!.bloodGlucose.toString();
        _insulinValue = _editingEntry!.insulinDose;
        _weightController.text = _editingEntry!.weight?.toString() ?? '';
      }
      if (catProvider.selectedCat == null && catProvider.cats.isNotEmpty) {
        catProvider.selectCat(catProvider.cats.first);
      }
    });
  }

  void _autoFillInsulin() {
    final bg = double.tryParse(_bgController.text);
    if (bg != null) {
      final settings = context.read<SettingsProvider>();
      final List<model.InsulinRuleModel> rules =
          settings.insulinRules
              .map(
                (e) =>
                    e is Map<String, dynamic>
                        ? model.InsulinRuleModel.fromJson(
                          e as Map<String, dynamic>,
                        )
                        : e,
              )
              .toList()
            ..sort((a, b) => a.glucoseStart.compareTo(b.glucoseStart));

      for (final rule in rules) {
        if (bg >= rule.glucoseStart &&
            bg <= (rule.glucoseEnd ?? double.infinity)) {
          setState(() => _insulinValue = rule.insulin);
          return;
        }
      }

      setState(() => _insulinValue = 0);
    }
  }

  @override
  void dispose() {
    _bgController.removeListener(_autoFillInsulin);
    _bgController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final bg = int.tryParse(_bgController.text);
      final weight = double.tryParse(_weightController.text);
      if (bg == null) return;

      final selectedCat = context.read<CatProvider>().selectedCat;
      if (selectedCat == null) {
        showDialog(
          context: context,
          builder:
              (_) => AlertDialog(
                title: const Text('Missing Information'),
                content: const Text('Please select a cat.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('OK'),
                  ),
                ],
              ),
        );
        return;
      }

      final entry = GlucoseEntry(
        id: _editingEntry?.id,
        dateTime: _selectedDateTime,
        bloodGlucose: bg,
        insulinDose: _insulinValue,
        weight: weight,
        catID: selectedCat.id,
      );

      final provider = Provider.of<EntryProvider>(context, listen: false);
      if (_editingEntry != null) {
        provider.updateEntry(entry);
      } else {
        provider.addEntry(entry);
      }

      await Future.delayed(const Duration(milliseconds: 300));
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _editingEntry != null
                ? 'Entry updated!'
                : 'Entry saved successfully!',
          ),
        ),
      );

      await Future.delayed(const Duration(milliseconds: 200));
      if (!mounted) return;
      if (mounted && Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }

      _bgController.clear();
      _weightController.clear();
      setState(() => _insulinValue = 0);
    }
  }

  // void _deleteEntry() async {
  //   if (_editingEntry != null) {
  //     final provider = Provider.of<EntryProvider>(context, listen: false);
  //     provider.deleteEntry(_editingEntry!);
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('Entry deleted.')),
  //     );
  //     await Future.delayed(const Duration(milliseconds: 200));
  //     if (!mounted) return;
  //     if (mounted && Navigator.canPop(context)) {
  //       Navigator.of(context).pop();
  //     }
  //   }
  // }

  // Future<void> _pickDateTime() async {
  //   final pickedDate = await showDatePicker(
  //     context: context,
  //     initialDate: _selectedDateTime,
  //     firstDate: DateTime(2020),
  //     lastDate: DateTime(2100),
  //   );
  //   if (pickedDate == null) return;

  //   final pickedTime = await showTimePicker(
  //     context: context,
  //     initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
  //   );
  //   if (!mounted || pickedTime == null) return;

  //   setState(() {
  //     _selectedDateTime = DateTime(
  //       pickedDate.year,
  //       pickedDate.month,
  //       pickedDate.day,
  //       pickedTime.hour,
  //       pickedTime.minute,
  //     );
  //   });
  // }

  void _loadEntryForEdit(GlucoseEntry entry) {
    setState(() {
      _editingEntry = entry;
      _selectedDateTime = entry.dateTime;
      _bgController.text = entry.bloodGlucose.toString();
      _insulinValue = entry.insulinDose;
      _weightController.text = entry.weight?.toString() ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final catProvider = context.watch<CatProvider>();
    final selectedCat = catProvider.selectedCat;
    final cats = catProvider.cats;
    // final screenHeight = MediaQuery.of(context).size.height;
    final latestEntries =
        context
            .watch<EntryProvider>()
            .entries
            .where((entry) => entry.catID == selectedCat?.id)
            .where(
              (entry) => entry.dateTime.isAfter(
                DateTime.now().subtract(Duration(days: 7)),
              ),
            )
            .toList()
          ..sort((a, b) => b.dateTime.compareTo(a.dateTime));

    return Scaffold(
      appBar: AppBar(
        title: const Padding(
          padding: EdgeInsets.only(top: 16.0),
          child: Center(
            child: Text(
              'DM Tracker',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🐱 Section 1: Select Pet
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: DropdownButtonFormField<String>(
                  value: selectedCat?.id,
                  onChanged: (id) {
                    if (id != null) {
                      final selected = cats.firstWhere((cat) => cat.id == id);
                      context.read<CatProvider>().selectCat(selected);
                    }
                  },
                  items:
                      cats
                          .map(
                            (cat) => DropdownMenuItem(
                              value: cat.id,
                              child: Text(cat.name),
                            ),
                          )
                          .toList(),
                  decoration: InputDecoration(
                    labelText:
                        AppLocalizations.of(context)?.selectPet ?? 'Select Pet',
                    border: const OutlineInputBorder(),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 🕓 Section 2: Date & Time Picker
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _selectedDateTime,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2100),
                          );
                          if (date != null) {
                            setState(() {
                              _selectedDateTime = DateTime(
                                date.year,
                                date.month,
                                date.day,
                                _selectedDateTime.hour,
                                _selectedDateTime.minute,
                              );
                            });
                          }
                        },
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Date',
                            border: OutlineInputBorder(),
                          ),
                          child: Text(
                            DateFormat('yyyy/MM/dd').format(_selectedDateTime),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.fromDateTime(
                              _selectedDateTime,
                            ),
                          );
                          if (time != null) {
                            setState(() {
                              _selectedDateTime = DateTime(
                                _selectedDateTime.year,
                                _selectedDateTime.month,
                                _selectedDateTime.day,
                                time.hour,
                                time.minute,
                              );
                            });
                          }
                        },
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Time',
                            border: OutlineInputBorder(),
                          ),
                          child: Text(
                            DateFormat('HH:mm').format(_selectedDateTime),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 💉 Section 3: Record Data
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _bgController,
                        keyboardType: TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                        ],
                        decoration: InputDecoration(
                          labelText:
                              AppLocalizations.of(context)?.bloodGlucose ??
                              'Blood Glucose (mg/dL)',
                          hintText:
                              AppLocalizations.of(context)?.enterBloodGlucose ??
                              'Enter blood glucose',
                          border: const OutlineInputBorder(),
                        ),
                        validator:
                            (value) =>
                                value == null || value.isEmpty
                                    ? 'Required'
                                    : null,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<double>(
                        value: _insulinValue,
                        items:
                            List.generate(21, (i) => (i * 0.25))
                                .map(
                                  (v) => DropdownMenuItem(
                                    value: v,
                                    child: Text(v.toString()),
                                  ),
                                )
                                .toList(),
                        onChanged:
                            (val) => setState(() => _insulinValue = val ?? 0),
                        decoration: InputDecoration(
                          labelText:
                              AppLocalizations.of(context)?.insulin ??
                              'Insulin Dose (unit)',
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _weightController,
                        keyboardType: TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                        ],
                        decoration: InputDecoration(
                          labelText:
                              AppLocalizations.of(context)?.weight ??
                              'Weight (kg)',
                          hintText:
                              AppLocalizations.of(context)?.enterWeight ??
                              'Enter weight',
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _submitForm,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(45),
                        ),
                        child: Text(
                          _editingEntry != null
                              ? AppLocalizations.of(context)?.updateEntry ??
                                  'Update Entry'
                              : AppLocalizations.of(context)?.saveEntry ??
                                  'Save Entry',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 🕘 Section 4: Recent Records
            Text(
              AppLocalizations.of(context)?.latestRecords ?? 'Recent Records',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),
            ...latestEntries
                .take(3)
                .map(
                  (entry) => Card(
                    child: ListTile(
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            cats.firstWhere((c) => c.id == entry.catID).name,
                          ),
                          Text(
                            DateFormat(
                              'yyyy/MM/dd HH:mm',
                            ).format(entry.dateTime),
                          ),
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Blood Glucose: ${entry.bloodGlucose} mg/dL'),
                          Text('Insulin: ${entry.insulinDose} unit'),
                          if (entry.weight != null)
                            Text(
                              'Weight: ${entry.weight!.toStringAsFixed(1)} kg',
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
          ],
        ),
      ),
      // body: SingleChildScrollView(
      //   child: Padding(
      //     padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      //     child: Column(
      //       crossAxisAlignment: CrossAxisAlignment.start,
      //       children: [
      //         const SizedBox(height: 4),
      //         Center(
      //           child: Text(
      //             'DM Tracker',
      //             style: TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
      //           ),
      //         ),
      //         const SizedBox(height: 8),
      //         const Padding(
      //           padding: EdgeInsets.only(left: 4, bottom: 4),
      //           child: Text(
      //             'Please select the pet you want to record.',
      //             style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      //           ),
      //         ),
      //         Card(
      //           elevation: 4,
      //           shape: RoundedRectangleBorder(
      //             borderRadius: BorderRadius.circular(12),
      //           ),
      //           child: Padding(
      //             padding: const EdgeInsets.all(16.0),
      //             child: Container(
      //               decoration: BoxDecoration(
      //                 color: Colors.white,
      //                 borderRadius: BorderRadius.circular(12),
      //               ),
      //               child: DropdownButtonFormField<String>(
      //                 isExpanded: true,
      //                 value: selectedCat?.id,
      //                 onChanged: (catId) {
      //                   if (cats.isNotEmpty) {
      //                     final selected = cats.firstWhere(
      //                       (cat) => cat.id == catId,
      //                       orElse: () => cats.first,
      //                     );
      //                     context.read<CatProvider>().selectCat(selected);
      //                   }
      //                 },
      //                 decoration: const InputDecoration(
      //                   border: OutlineInputBorder(
      //                     borderRadius: BorderRadius.all(Radius.circular(12)),
      //                   ),
      //                   contentPadding: EdgeInsets.symmetric(horizontal: 16),
      //                   labelText: 'Select Cat',
      //                 ),
      //                 items:
      //                     cats
      //                         .map(
      //                           (cat) => DropdownMenuItem(
      //                             value: cat.id,
      //                             child: Text(cat.name),
      //                           ),
      //                         )
      //                         .toList(),
      //               ),
      //             ),
      //           ),
      //         ),
      //         const SizedBox(height: 16),
      //         Card(
      //           elevation: 4,
      //           shape: RoundedRectangleBorder(
      //             borderRadius: BorderRadius.circular(12),
      //           ),
      //           child: Padding(
      //             padding: const EdgeInsets.all(16.0),
      //             child: Form(
      //               key: _formKey,
      //               child: Column(
      //                 children: [
      //                   Container(
      //                     padding: const EdgeInsets.symmetric(vertical: 8.0),
      //                     decoration: BoxDecoration(
      //                       borderRadius: BorderRadius.circular(12),
      //                     ),
      //                     child: TextFormField(
      //                       controller: _bgController,
      //                       keyboardType: TextInputType.numberWithOptions(
      //                         decimal: true,
      //                       ),
      //                       inputFormatters: [
      //                         FilteringTextInputFormatter.allow(
      //                           RegExp(r'[0-9.]'),
      //                         ),
      //                       ],
      //                       decoration: const InputDecoration(
      //                         border: OutlineInputBorder(
      //                           borderRadius: BorderRadius.all(
      //                             Radius.circular(12),
      //                           ),
      //                         ),
      //                         hintText: 'Blood Glucose (mg/dL)',
      //                         contentPadding: EdgeInsets.symmetric(
      //                           horizontal: 16,
      //                         ),
      //                         labelText: 'Blood Glucose',
      //                       ),
      //                       validator:
      //                           (value) =>
      //                               value == null || value.isEmpty
      //                                   ? 'Required'
      //                                   : null,
      //                     ),
      //                   ),
      //                   const SizedBox(height: 12),
      //                   Container(
      //                     padding: const EdgeInsets.symmetric(vertical: 8.0),
      //                     decoration: BoxDecoration(
      //                       borderRadius: BorderRadius.circular(12),
      //                     ),
      //                     child: DropdownButtonFormField<double>(
      //                       isExpanded: true,
      //                       value: _insulinValue,
      //                       onChanged:
      //                           (value) =>
      //                               setState(() => _insulinValue = value ?? 0),
      //                       decoration: const InputDecoration(
      //                         border: OutlineInputBorder(
      //                           borderRadius: BorderRadius.all(
      //                             Radius.circular(12),
      //                           ),
      //                         ),
      //                         contentPadding: EdgeInsets.symmetric(
      //                           horizontal: 16,
      //                         ),
      //                         labelText: 'Insulin Dose',
      //                       ),
      //                       items:
      //                           List.generate(21, (i) => (i * 0.25)).map((
      //                             dose,
      //                           ) {
      //                             return DropdownMenuItem(
      //                               value: dose,
      //                               child: Text(dose.toString()),
      //                             );
      //                           }).toList(),
      //                     ),
      //                   ),
      //                   const SizedBox(height: 12),
      //                   Container(
      //                     padding: const EdgeInsets.symmetric(vertical: 8.0),
      //                     decoration: BoxDecoration(
      //                       borderRadius: BorderRadius.circular(12),
      //                     ),
      //                     child: TextFormField(
      //                       controller: _weightController,
      //                       keyboardType: TextInputType.numberWithOptions(
      //                         decimal: true,
      //                       ),
      //                       inputFormatters: [
      //                         FilteringTextInputFormatter.allow(
      //                           RegExp(r'[0-9.]'),
      //                         ),
      //                       ],
      //                       decoration: const InputDecoration(
      //                         border: OutlineInputBorder(
      //                           borderRadius: BorderRadius.all(
      //                             Radius.circular(12),
      //                           ),
      //                         ),
      //                         hintText: 'Cat Weight (kg)',
      //                         contentPadding: EdgeInsets.symmetric(
      //                           horizontal: 16,
      //                         ),
      //                         labelText: 'Weight',
      //                       ),
      //                     ),
      //                   ),
      //                   const SizedBox(height: 20),
      //                   ElevatedButton(
      //                     onPressed: _submitForm,
      //                     style: ElevatedButton.styleFrom(
      //                       minimumSize: const Size.fromHeight(45),
      //                       backgroundColor: Colors.teal.shade600,
      //                       foregroundColor: Colors.white,
      //                       shape: RoundedRectangleBorder(
      //                         borderRadius: BorderRadius.circular(8),
      //                       ),
      //                     ),
      //                     child: Text(
      //                       _editingEntry != null
      //                           ? 'Update Entry'
      //                           : 'Save Entry',
      //                     ),
      //                   ),
      //                 ],
      //               ),
      //             ),
      //           ),
      //         ),
      //         const SizedBox(height: 20),
      //         const Text(
      //           'Latest 3 Entries',
      //           style: TextStyle(fontWeight: FontWeight.w600, fontSize: 26),
      //         ),
      //         if (latestEntries.isNotEmpty)
      //           ...latestEntries
      //               .take(3)
      //               .map(
      //                 (entry) => InkWell(
      //                   onTap: () async {
      //                     final shouldEdit = await showDialog<bool>(
      //                       context: context,
      //                       builder:
      //                           (context) => AlertDialog(
      //                             title: const Text('Edit Entry'),
      //                             content: const Text(
      //                               'Do you want to edit this entry?',
      //                             ),
      //                             actions: [
      //                               TextButton(
      //                                 onPressed:
      //                                     () =>
      //                                         Navigator.of(context).pop(false),
      //                                 child: const Text('Cancel'),
      //                               ),
      //                               TextButton(
      //                                 onPressed:
      //                                     () => Navigator.of(context).pop(true),
      //                                 child: const Text('Edit'),
      //                               ),
      //                             ],
      //                           ),
      //                     );
      //                     if (shouldEdit == true) {
      //                       _loadEntryForEdit(entry);
      //                     }
      //                   },
      //                   child: Card(
      //                     child: ListTile(
      //                       title: Column(
      //                         crossAxisAlignment: CrossAxisAlignment.start,
      //                         children: [
      //                           Text(
      //                             cats
      //                                 .firstWhere((c) => c.id == entry.catID)
      //                                 .name,
      //                             style: const TextStyle(
      //                               fontWeight: FontWeight.bold,
      //                             ),
      //                           ),
      //                           Text(
      //                             DateFormat(
      //                               'yyyy/MM/dd HH:mm',
      //                             ).format(entry.dateTime),
      //                           ),
      //                         ],
      //                       ),
      //                       subtitle: Text(
      //                         'BG: ${entry.bloodGlucose} • Insulin: ${entry.insulinDose} • Weight: ${entry.weight?.toStringAsFixed(1) ?? '-'}',
      //                       ),
      //                     ),
      //                   ),
      //                 ),
      //               )
      //         else
      //           const Text('No recent entries.'),
      //       ],
      //     ),
      //   ),
      // ),
    );
  }
}
