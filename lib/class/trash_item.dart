import 'dart:convert';

class TrashItem {
  final int id;
  final String entityType;
  final int entityId;
  final Map<String, dynamic> entityData;
  final DateTime deletedAt;
  final String? deletedBy;
  final Map<String, dynamic>? relatedData;

  TrashItem({
    required this.id,
    required this.entityType,
    required this.entityId,
    required this.entityData,
    required this.deletedAt,
    this.deletedBy,
    this.relatedData,
  });

  factory TrashItem.fromMap(Map<String, dynamic> map) {
    return TrashItem(
      id: map['id'] as int,
      entityType: map['entityType'] as String,
      entityId: map['entityId'] as int,
      entityData:
          jsonDecode(map['entityData'] as String) as Map<String, dynamic>,
      deletedAt: DateTime.parse(map['deletedAt'] as String),
      deletedBy: map['deletedBy'] as String?,
      relatedData: map['relatedData'] != null
          ? jsonDecode(map['relatedData'] as String) as Map<String, dynamic>
          : null,
    );
  }

  String get displayName {
    switch (entityType) {
      case 'client':
        return entityData['name'] as String? ?? 'Client inconnu';
      case 'article':
        return entityData['name'] as String? ?? 'Article inconnu';
      case 'support':
        return entityData['name'] as String? ?? 'Support inconnu';
      case 'machine':
        return entityData['reference'] as String? ?? 'Machine inconnue';
      case 'repeat':
        return entityData['reference'] as String? ?? 'Repeat inconnu';
      default:
        return 'Élément inconnu';
    }
  }

  String get entityTypeLabel {
    switch (entityType) {
      case 'client':
        return 'Client';
      case 'article':
        return 'Article';
      case 'support':
        return 'Support';
      case 'machine':
        return 'Machine';
      case 'repeat':
        return 'Repeat';
      default:
        return entityType;
    }
  }

  int get relatedCount {
    if (relatedData == null) return 0;
    int count = 0;
    relatedData!.forEach((key, value) {
      if (value is List) count += value.length;
    });
    return count;
  }
}
