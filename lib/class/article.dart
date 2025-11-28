class Article {
  int? id;
  int clientId;
  String name;
  String dimensions;
  int? supportId;

  Article({
    this.id,
    required this.clientId,
    required this.name,
    required this.dimensions,
    this.supportId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'clientId': clientId,
      'name': name,
      'dimensions': dimensions,
      'supportId': supportId,
    };
  }

  factory Article.fromMap(Map<String, dynamic> map) {
    return Article(
      id: map['id'] as int?,
      clientId: map['clientId'] as int? ?? 0,
      name: map['name'] as String? ?? '',
      dimensions: map['dimensions'] as String? ?? '',
      supportId: map['supportId'] as int?,
    );
  }
}
