class Support {
  int? id;
  String name;
  double currentPrice;
  String? supplier;

  Support({
    this.id,
    required this.name,
    required this.currentPrice,
    this.supplier,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'currentPrice': currentPrice,
      'supplier': supplier,
    };
  }

  factory Support.fromMap(Map<String, dynamic> map) {
    return Support(
      id: map['id'] as int?,
      name: map['name'] as String? ?? '',
      currentPrice: (map['currentPrice'] as num?)?.toDouble() ?? 0.0,
      supplier: map['supplier'] as String?,
    );
  }
  // Supabase Serialization
  Map<String, dynamic> toSupabaseMap() {
    return {
      // 'id': id,
      'name': name,
      'current_price': currentPrice,
      'supplier': supplier,
    };
  }

  factory Support.fromSupabaseMap(Map<String, dynamic> map) {
    return Support(
      id: map['id'] as int?,
      name: map['name'] as String? ?? '',
      currentPrice: (map['current_price'] as num?)?.toDouble() ?? 0.0,
      supplier: map['supplier'] as String?,
    );
  }
}
