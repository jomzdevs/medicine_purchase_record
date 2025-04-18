// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../db/databasehelper.dart';
import '../../model/purchasemodel.dart';
import '../details/medicine_detail.dart';

class PurchaseListScreen extends StatefulWidget {
  const PurchaseListScreen({super.key});

  @override
  State<PurchaseListScreen> createState() => _PurchaseListScreenState();
}

class _PurchaseListScreenState extends State<PurchaseListScreen> {
  late Future<List<Purchase>> _purchasesFuture;

  @override
  void initState() {
    super.initState();
    _refreshPurchases();
  }

  Future<void> _refreshPurchases() async {
    setState(() {
      _purchasesFuture = DatabaseHelper.instance.readAllPurchases();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Purchase Records'),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshPurchases,
        child: FutureBuilder<List<Purchase>>(
          future: _purchasesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Text('No purchase records found'),
              );
            } else {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final purchase = snapshot.data![index];
                  return Card(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      title: Text(purchase.medicineName),
                      subtitle: Text(
                        'Qty: ${purchase.quantity} - \$${purchase.price.toStringAsFixed(2)}\n${DateFormat('MMM dd, yyyy').format(purchase.purchaseDate)}',
                      ),
                      isThreeLine: true,
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Delete Purchase'),
                              content: const Text(
                                  'Are you sure you want to delete this purchase record?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    await DatabaseHelper.instance
                                        .deletePurchase(purchase.id!);
                                    Navigator.pop(context);
                                    _refreshPurchases();
                                  },
                                  child: const Text('Delete'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MedicineDetailScreen(
                                medicineId: purchase.medicineId),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}
