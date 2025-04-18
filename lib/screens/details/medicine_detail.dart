import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../db/databasehelper.dart';
import '../../model/medicinemodel.dart';
import '../../model/purchasemodel.dart';
import '../forms/medicine_form.dart';
import '../forms/purchased_form.dart';

class MedicineDetailScreen extends StatefulWidget {
  final int medicineId;

  const MedicineDetailScreen({super.key, required this.medicineId});

  @override
  State<MedicineDetailScreen> createState() => _MedicineDetailScreenState();
}

class _MedicineDetailScreenState extends State<MedicineDetailScreen> {
  late Future<Medicine?> _medicineFuture;
  late Future<List<Purchase>> _purchasesFuture;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  Future<void> _refreshData() async {
    setState(() {
      _medicineFuture = DatabaseHelper.instance.readMedicine(widget.medicineId);
      _purchasesFuture =
          DatabaseHelper.instance.readPurchasesByMedicine(widget.medicineId);
    });
  }

  Future<void> _deleteMedicine(int id) async {
    await DatabaseHelper.instance.deleteMedicine(id);
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medicine Details'),
        actions: [
          FutureBuilder<Medicine?>(
            future: _medicineFuture,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return PopupMenuButton<String>(
                  onSelected: (value) async {
                    if (value == 'edit') {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              MedicineFormScreen(medicine: snapshot.data),
                        ),
                      );
                      _refreshData();
                    } else if (value == 'delete') {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Delete Medicine'),
                          content: const Text(
                              'Are you sure you want to delete this medicine? All purchase records for this medicine will also be deleted.'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                _deleteMedicine(snapshot.data!.id!);
                              },
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Text('Edit'),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('Delete'),
                    ),
                  ],
                );
              } else {
                return Container();
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder<Medicine?>(
              future: _medicineFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData) {
                  return const Center(child: Text('Medicine not found'));
                } else {
                  final medicine = snapshot.data!;
                  return Card(
                    margin: const EdgeInsets.all(16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            medicine.name,
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 8),
                          Text('Dosage: ${medicine.dosage}'),
                          const SizedBox(height: 8),
                          const SizedBox(height: 8),
                          Text('Description: ${medicine.description}'),
                        ],
                      ),
                    ),
                  );
                }
              },
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Purchase History',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            FutureBuilder<List<Purchase>>(
              future: _purchasesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('No purchase records found'),
                    ),
                  );
                } else {
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final purchase = snapshot.data![index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: ListTile(
                          title: Text(
                              '${purchase.quantity} units - \$${purchase.price.toStringAsFixed(2)}'),
                          subtitle: Text(
                            'Date: ${DateFormat('MMM dd, yyyy').format(purchase.purchaseDate)}\nPharmacy: ${purchase.pharmacy}',
                          ),
                          isThreeLine: true,
                        ),
                      );
                    },
                  );
                }
              },
            ),
            const SizedBox(height: 80), // Space for FAB
          ],
        ),
      ),
      floatingActionButton: FutureBuilder<Medicine?>(
        future: _medicineFuture,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return FloatingActionButton(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        PurchaseFormScreen(medicine: snapshot.data!),
                  ),
                );
                _refreshData();
              },
              child: const Icon(Icons.add),
            );
          } else {
            return Container();
          }
        },
      ),
    );
  }
}
