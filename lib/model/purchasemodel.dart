class Purchase {
  final int? id;
  final int medicineId;
  final String medicineName;
  final int quantity;
  final double price;
  final DateTime purchaseDate;
  final String pharmacy;

  Purchase({
    this.id,
    required this.medicineId,
    required this.medicineName,
    required this.quantity,
    required this.price,
    required this.purchaseDate,
    required this.pharmacy,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'medicine_id': medicineId,
      'medicine_name': medicineName,
      'quantity': quantity,
      'price': price,
      'purchase_date': purchaseDate.millisecondsSinceEpoch,
      'pharmacy': pharmacy,
    };
  }

  factory Purchase.fromMap(Map<String, dynamic> map) {
    return Purchase(
      id: map['id'],
      medicineId: map['medicine_id'],
      medicineName: map['medicine_name'],
      quantity: map['quantity'],
      price: map['price'],
      purchaseDate: DateTime.fromMillisecondsSinceEpoch(map['purchase_date']),
      pharmacy: map['pharmacy'],
    );
  }
}
