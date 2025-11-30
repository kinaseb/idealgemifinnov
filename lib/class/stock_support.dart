class StockSupport {
  final int? id;
  final int? supportId;
  final int laize;
  final int longueur;
  final int? micronage; // Renamed from grammage
  final int quantity;
  final String? location;
  final DateTime? createdAt;

  // Joined field
  final String? supportName;

  StockSupport({
    this.id,
    this.supportId,
    required this.laize,
    required this.longueur,
    this.micronage,
    this.quantity = 0,
    this.location,
    this.createdAt,
    this.supportName,
  });

  factory StockSupport.fromMap(Map<String, dynamic> map) {
    return StockSupport(
      id: map['id'],
      supportId: map['support_id'],
      laize: map['laize'] ?? 0,
      longueur: map['longueur'] ?? 0,
      micronage: map['micronage'],
      quantity: map['quantity'] ?? 0,
      location: map['location'],
      createdAt:
          map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
      supportName: map['supports'] != null ? map['supports']['name'] : null,
    );
  }

  Map<String, dynamic> toSupabaseMap() {
    return {
      if (id != null) 'id': id,
      'support_id': supportId,
      'laize': laize,
      'longueur': longueur,
      'micronage': micronage,
      'quantity': quantity,
      'location': location,
    };
  }
}
