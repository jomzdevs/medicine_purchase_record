import 'package:flutter/material.dart';
import 'package:medicine_records/screens/forms/medicine_form.dart';
import '../../db/databasehelper.dart';
import '../../model/medicinemodel.dart';
import '../details/medicine_detail.dart';

class MedicineListScreen extends StatefulWidget {
  const MedicineListScreen({super.key});

  @override
  State<MedicineListScreen> createState() => _MedicineListScreenState();
}

class _MedicineListScreenState extends State<MedicineListScreen> {
  late Future<List<Medicine>> _medicinesFuture;

  @override
  void initState() {
    super.initState();
    _refreshMedicines();
  }

  Future<void> _refreshMedicines() async {
    setState(() {
      _medicinesFuture = DatabaseHelper.instance.readAllMedicines();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medicines'),
      ),
      body: FutureBuilder<List<Medicine>>(
        future: _medicinesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No medicines found'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final medicine = snapshot.data![index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text(medicine.name),
                    subtitle: Text(medicine.dosage),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              MedicineDetailScreen(medicineId: medicine.id!),
                        ),
                      );
                      _refreshMedicines();
                    },
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const MedicineFormScreen(),
            ),
          );
          _refreshMedicines();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
