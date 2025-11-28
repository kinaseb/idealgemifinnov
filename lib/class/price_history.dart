class PriceHistory {
  int? id;
  int supportId;
  double price;
  DateTime date;
  String? supplier;

  PriceHistory({
    this.id,
    required this.supportId,
    required this.price,
    required this.date,
    this.supplier,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'supportId': supportId,
      'price': price,
      'date': date.toIso8601String(),
      'supplier': supplier,
    };
  }

  factory PriceHistory.fromMap(Map<String, dynamic> map) {
    return PriceHistory(
      id: map['id'],
      supportId: map['supportId'],
      price: map['price'],
      date: DateTime.parse(map['date']),
      supplier: map['supplier'],
    );
  }
}
