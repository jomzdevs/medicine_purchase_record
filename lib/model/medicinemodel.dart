class Medicine {
  final int? id;
  final String name;
  final String description;
  final String dosage;

  Medicine({
    this.id,
    required this.name,
    required this.description,
    required this.dosage,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'dosage': dosage,
    };
  }

  factory Medicine.fromMap(Map<String, dynamic> map) {
    return Medicine(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      dosage: map['dosage'],
    );
  }
}
