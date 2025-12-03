class MachineType {
  final int? id;
  final String name;
  final String? description;

  MachineType({
    this.id,
    required this.name,
    this.description,
  });

  // Local SQLite Serialization
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
    };
  }

  factory MachineType.fromMap(Map<String, dynamic> map) {
    return MachineType(
      id: map['id'] as int?,
      name: map['name'] as String? ?? '',
      description: map['description'] as String?,
    );
  }

  // Supabase Serialization
  Map<String, dynamic> toSupabaseMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'description': description,
    };
  }

  factory MachineType.fromSupabaseMap(Map<String, dynamic> map) {
    return MachineType(
      id: map['id'] as int?,
      name: map['name'] as String? ?? '',
      description: map['description'] as String?,
    );
  }

  @override
  String toString() => name;
}
