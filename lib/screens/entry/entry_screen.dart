import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/glucose_entry.dart';
import '../../providers/entry_provider.dart';
import '../../providers/settings_provider.dart';

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
    if (widget.entryToEdit != null) {
      _editingEntry = widget.entryToEdit;
      _selectedDateTime = _editingEntry!.dateTime;
      _bgController.text = _editingEntry!.bloodGlucose.toString();
      _insulinValue = _editingEntry!.insulinDose;
      _weightController.text = _editingEntry!.weight?.toString() ?? '';
    }
  }

  void _autoFillInsulin() {
    final bg = int.tryParse(_bgController.text);
    if (bg != null) {
      final settings = context.read<SettingsProvider>();
      final autoDose = settings.getAutoInsulinDose(bg);
      if (autoDose != null && autoDose != _insulinValue) {
        setState(() => _insulinValue = autoDose);
      }
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

      final entry = GlucoseEntry(
        dateTime: _selectedDateTime,
        bloodGlucose: bg,
        insulinDose: _insulinValue,
        weight: weight,
      );

      final provider = Provider.of<EntryProvider>(context, listen: false);
      if (_editingEntry != null) {
        provider.updateEntry(_editingEntry!, entry);
      } else {
        provider.addEntry(entry);
      }

      await Future.delayed(const Duration(milliseconds: 300));
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_editingEntry != null ? 'Entry updated!' : 'Entry saved successfully!')),
      );

      Navigator.of(context).pop();
    }
  }

  void _deleteEntry() {
    if (_editingEntry != null) {
      final provider = Provider.of<EntryProvider>(context, listen: false);
      provider.deleteEntry(_editingEntry!);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Entry deleted.')),
      );
      Navigator.of(context).pop();
    }
  }

  Future<void> _pickDateTime() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (pickedDate == null) return;

    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
    );
    if (pickedTime == null) return;

    setState(() {
      _selectedDateTime = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text(_editingEntry != null ? 'Edit Entry' : 'New Entry'),
        actions: [
          if (_editingEntry != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteEntry,
            )
        ],
      ),
      body: SingleChildScrollView(
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat('yyyy/MM/dd HH:mm').format(_selectedDateTime),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  ElevatedButton.icon(
                    onPressed: _pickDateTime,
                    icon: const Icon(Icons.calendar_today, size: 18),
                    label: const Text('Pick Date/Time'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      textStyle: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _bgController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Blood Glucose (mg/dL)'),
                          validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<double>(
                          value: _insulinValue,
                          onChanged: (value) => setState(() => _insulinValue = value ?? 0),
                          decoration: const InputDecoration(labelText: 'Insulin Dose (units)'),
                          items: List.generate(21, (i) => (i * 0.25)).map((dose) {
                            return DropdownMenuItem(
                              value: dose,
                              child: Text(dose.toString()),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _weightController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Cat Weight (kg)'),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _submitForm,
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(45),
                            backgroundColor: Colors.teal.shade600,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: Text(_editingEntry != null ? 'Update Entry' : 'Save Entry'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}