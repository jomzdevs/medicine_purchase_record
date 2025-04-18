import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../db/databasehelper.dart';
import '../../model/medicinemodel.dart';
import '../../model/purchasemodel.dart';

class PurchaseFormScreen extends StatefulWidget {
  final Medicine medicine;
  final Purchase? purchase;

  const PurchaseFormScreen({
    super.key,
    required this.medicine,
    this.purchase,
  });

  @override
  State<PurchaseFormScreen> createState() => _PurchaseFormScreenState();
}

class _PurchaseFormScreenState extends State<PurchaseFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();
  final _pharmacyController = TextEditingController();
  DateTime _purchaseDate = DateTime.now();

  bool get isEditing => widget.purchase != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _quantityController.text = widget.purchase!.quantity.toString();
      _priceController.text = widget.purchase!.price.toString();
      _pharmacyController.text = widget.purchase!.pharmacy;
      _purchaseDate = widget.purchase!.purchaseDate;
    }
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _priceController.dispose();
    _pharmacyController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _purchaseDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _purchaseDate) {
      setState(() {
        _purchaseDate = picked;
      });
    }
  }

  Future<void> _savePurchase() async {
    if (_formKey.currentState!.validate()) {
      final purchase = Purchase(
        id: isEditing ? widget.purchase!.id : null,
        medicineId: widget.medicine.id!,
        medicineName: widget.medicine.name,
        quantity: int.parse(_quantityController.text),
        price: double.parse(_priceController.text),
        purchaseDate: _purchaseDate,
        pharmacy: _pharmacyController.text,
      );

      if (isEditing) {
        await DatabaseHelper.instance.updatePurchase(purchase);
      } else {
        await DatabaseHelper.instance.createPurchase(purchase);
      }

      if (!mounted) return;
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Purchase' : 'Add Purchase'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Medicine: ${widget.medicine.name}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text('Dosage: ${widget.medicine.dosage}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(
                  labelText: 'Quantity',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter quantity';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Price (\$)',
                  border: OutlineInputBorder(),
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter price';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _pharmacyController,
                decoration: const InputDecoration(
                  labelText: 'Pharmacy',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter pharmacy name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () => _selectDate(context),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Purchase Date',
                    border: OutlineInputBorder(),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(DateFormat('MMM dd, yyyy').format(_purchaseDate)),
                      const Icon(Icons.calendar_today),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _savePurchase,
                child: Text(isEditing ? 'Update' : 'Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
