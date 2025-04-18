import 'package:flutter/material.dart';
import '../../db/databasehelper.dart';
import '../../model/medicinemodel.dart';

class MedicineFormScreen extends StatefulWidget {
  final Medicine? medicine;

  const MedicineFormScreen({super.key, this.medicine});

  @override
  State<MedicineFormScreen> createState() => _MedicineFormScreenState();
}

class _MedicineFormScreenState extends State<MedicineFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _dosageController = TextEditingController();

  bool get isEditing => widget.medicine != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _nameController.text = widget.medicine!.name;
      _descriptionController.text = widget.medicine!.description;
      _dosageController.text = widget.medicine!.dosage;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _dosageController.dispose();

    super.dispose();
  }

  Future<void> _saveMedicine() async {
    if (_formKey.currentState!.validate()) {
      final medicine = Medicine(
        id: isEditing ? widget.medicine!.id : null,
        name: _nameController.text,
        description: _descriptionController.text,
        dosage: _dosageController.text,
      );

      if (isEditing) {
        await DatabaseHelper.instance.updateMedicine(medicine);
      } else {
        await DatabaseHelper.instance.createMedicine(medicine);
      }

      if (!mounted) return;
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Medicine' : 'Add Medicine'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Medicine Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter medicine name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _dosageController,
                decoration: const InputDecoration(
                  labelText: 'Dosage',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter dosage';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _saveMedicine,
                child: Text(isEditing ? 'Update' : 'Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
