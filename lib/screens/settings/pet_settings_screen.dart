import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cat_provider.dart';
import '../../models/cat_profile.dart';

class PetSettingsScreen extends StatefulWidget {
  @override
  _PetSettingsScreenState createState() => _PetSettingsScreenState();
}

class _PetSettingsScreenState extends State<PetSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  void _saveSettings() {
    if (_formKey.currentState!.validate()) {
      final catProvider = context.read<CatProvider>();

      if (catProvider.selectedCat != null) {
        // Update existing cat
        final selectedCat = catProvider.selectedCat!;
        selectedCat.name = _nameController.text;
        selectedCat.weight = _weightController.text.isEmpty ? 0.0 : double.tryParse(_weightController.text) ?? 0.0;
        selectedCat.age = _ageController.text.isEmpty ? 0 : int.tryParse(_ageController.text) ?? 0;
        catProvider.updateCat(selectedCat);
      } else {
        // Add new cat
        final newCat = CatProfile(
          id: UniqueKey().toString(),
          name: _nameController.text,
          weight: _weightController.text.isEmpty ? 0.0 : double.tryParse(_weightController.text) ?? 0.0,
          age: _ageController.text.isEmpty ? 0 : int.tryParse(_ageController.text) ?? 0,
        );
        catProvider.addCat(newCat);
      }

      _nameController.clear();
      _weightController.clear();
      _ageController.clear();
      catProvider.selectCat(null); // clear selection
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pet info saved')),
      );
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pet Info Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'Enter Pet Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Please enter name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _weightController,
                decoration: InputDecoration(
                  hintText: 'Enter Weight (kg)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return null;
                  final parsed = double.tryParse(value);
                  return parsed == null ? 'Invalid weight' : null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _ageController,
                decoration: InputDecoration(
                  hintText: 'Enter Age',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return null;
                  final parsed = int.tryParse(value);
                  return parsed == null ? 'Invalid age' : null;
                },
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saveSettings,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: Colors.teal,
                ),
                child: const Text('Save', style: TextStyle(fontSize: 16)),
              ),
              const SizedBox(height: 32),
              Consumer<CatProvider>(
                builder: (context, catProvider, child) {
                  return Column(
                    children: catProvider.cats.map((cat) {
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        color: catProvider.selectedCat == cat ? Colors.lightBlue.shade50 : null,
                        child: ListTile(
                          title: Text(cat.name),
                          subtitle: Text('Weight: ${cat.weight}, Age: ${cat.age}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () {
                                  _nameController.text = cat.name;
                                  _weightController.text = cat.weight.toString();
                                  _ageController.text = cat.age.toString();
                                  catProvider.selectCat(cat);
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => catProvider.removeCat(cat),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
