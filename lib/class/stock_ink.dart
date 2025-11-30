class StockInk {
  final int? id;
  final String color;
  final String? type;
  final double quantityKg;
  final String? supplier;
  final DateTime? createdAt;

  StockInk({
    this.id,
    required this.color,
    this.type,
    this.quantityKg = 0.0,
    this.supplier,
    this.createdAt,
  });

  factory StockInk.fromMap(Map<String, dynamic> map) {
    return StockInk(
      id: map['id'],
      color: map['color'] ?? '',
      type: map['type'],
      quantityKg: (map['quantity_kg'] ?? 0).toDouble(),
      supplier: map['supplier'],
      createdAt:
          map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
    );
  }

  Map<String, dynamic> toSupabaseMap() {
    return {
      if (id != null) 'id': id,
      'color': color,
      'type': type,
      'quantity_kg': quantityKg,
      'supplier': supplier,
    };
  }
}
