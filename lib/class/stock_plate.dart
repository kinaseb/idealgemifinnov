class StockPlate {
  final int? id;
  final int? clientId;
  final int? articleId;
  final String? type;
  final String? location;
  final String status;
  final DateTime? createdAt;

  // Optional: Joined fields for display
  final String? clientName;
  final String? articleName;

  StockPlate({
    this.id,
    this.clientId,
    this.articleId,
    this.type,
    this.location,
    this.status = 'Good',
    this.createdAt,
    this.clientName,
    this.articleName,
  });

  factory StockPlate.fromMap(Map<String, dynamic> map) {
    return StockPlate(
      id: map['id'],
      clientId: map['client_id'],
      articleId: map['article_id'],
      type: map['type'],
      location: map['location'],
      status: map['status'] ?? 'Good',
      createdAt:
          map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
      clientName: map['clients'] != null ? map['clients']['name'] : null,
      articleName: map['articles'] != null ? map['articles']['name'] : null,
    );
  }

  Map<String, dynamic> toSupabaseMap() {
    return {
      if (id != null) 'id': id,
      'client_id': clientId,
      'article_id': articleId,
      'type': type,
      'location': location,
      'status': status,
    };
  }
}
