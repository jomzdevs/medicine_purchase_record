import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../model/medicinemodel.dart';
import '../model/purchasemodel.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('medicine_tracker.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE medicines(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        dosage TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE purchases(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        medicine_id INTEGER NOT NULL,
        medicine_name TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        price REAL NOT NULL,
        purchase_date INTEGER NOT NULL,
        pharmacy TEXT NOT NULL,
        FOREIGN KEY (medicine_id) REFERENCES medicines (id)
          ON DELETE CASCADE
      )
    ''');
  }

  // Medicine CRUD operations
  Future<int> createMedicine(Medicine medicine) async {
    final db = await instance.database;
    return await db.insert('medicines', medicine.toMap());
  }

  Future<Medicine?> readMedicine(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      'medicines',
      columns: ['id', 'name', 'description', 'dosage'],
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Medicine.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<List<Medicine>> readAllMedicines() async {
    final db = await instance.database;
    final result = await db.query('medicines');
    return result.map((map) => Medicine.fromMap(map)).toList();
  }

  Future<int> updateMedicine(Medicine medicine) async {
    final db = await instance.database;
    return await db.update(
      'medicines',
      medicine.toMap(),
      where: 'id = ?',
      whereArgs: [medicine.id],
    );
  }

  Future<int> deleteMedicine(int id) async {
    final db = await instance.database;
    return await db.delete(
      'medicines',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Purchase CRUD operations
  Future<int> createPurchase(Purchase purchase) async {
    final db = await instance.database;
    return await db.insert('purchases', purchase.toMap());
  }

  Future<Purchase?> readPurchase(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      'purchases',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Purchase.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<List<Purchase>> readAllPurchases() async {
    final db = await instance.database;
    final result = await db.query('purchases', orderBy: 'purchase_date DESC');
    return result.map((map) => Purchase.fromMap(map)).toList();
  }

  Future<List<Purchase>> readPurchasesByMedicine(int medicineId) async {
    final db = await instance.database;
    final result = await db.query(
      'purchases',
      where: 'medicine_id = ?',
      whereArgs: [medicineId],
      orderBy: 'purchase_date DESC',
    );
    return result.map((map) => Purchase.fromMap(map)).toList();
  }

  Future<int> updatePurchase(Purchase purchase) async {
    final db = await instance.database;
    return await db.update(
      'purchases',
      purchase.toMap(),
      where: 'id = ?',
      whereArgs: [purchase.id],
    );
  }

  Future<int> deletePurchase(int id) async {
    final db = await instance.database;
    return await db.delete(
      'purchases',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
