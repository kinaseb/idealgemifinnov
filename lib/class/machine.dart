class Machine {
  final int? id;
  final int typeId;
  final String reference;
  final double laizeMin;
  final double laizeMax;
  final int? nbrStations; // For impression machines
  final int? nbrStationsDecoupe; // For impression machines with cutting
  final String? photo;
  final String? notes;

  // Joined field from machine_types table
  final String? typeName;

  Machine({
    this.id,
    required this.typeId,
    required this.reference,
    required this.laizeMin,
    required this.laizeMax,
    this.nbrStations,
    this.nbrStationsDecoupe,
    this.photo,
    this.notes,
    this.typeName,
  });

  // Local SQLite Serialization
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'typeId': typeId,
      'reference': reference,
      'laizeMin': laizeMin,
      'laizeMax': laizeMax,
      'nbrStations': nbrStations,
      'nbrStationsDecoupe': nbrStationsDecoupe,
      'photo': photo,
      'notes': notes,
    };
  }

  factory Machine.fromMap(Map<String, dynamic> map) {
    return Machine(
      id: map['id'] as int?,
      typeId: map['typeId'] as int? ?? 0,
      reference: map['reference'] as String? ?? '',
      laizeMin: (map['laizeMin'] as num?)?.toDouble() ?? 0.0,
      laizeMax: (map['laizeMax'] as num?)?.toDouble() ?? 0.0,
      nbrStations: map['nbrStations'] as int?,
      nbrStationsDecoupe: map['nbrStationsDecoupe'] as int?,
      photo: map['photo'] as String?,
      notes: map['notes'] as String?,
      typeName: map['typeName'] as String?,
    );
  }

  // Supabase Serialization
  Map<String, dynamic> toSupabaseMap() {
    return {
      if (id != null) 'id': id,
      'type_id': typeId,
      'reference': reference,
      'laize_min': laizeMin,
      'laize_max': laizeMax,
      'nbr_stations': nbrStations,
      'nbr_stations_decoupe': nbrStationsDecoupe,
      'photo': photo,
      'notes': notes,
    };
  }

  factory Machine.fromSupabaseMap(Map<String, dynamic> map) {
    return Machine(
      id: map['id'] as int?,
      typeId: map['type_id'] as int? ?? 0,
      reference: map['reference'] as String? ?? '',
      laizeMin: (map['laize_min'] as num?)?.toDouble() ?? 0.0,
      laizeMax: (map['laize_max'] as num?)?.toDouble() ?? 0.0,
      nbrStations: map['nbr_stations'] as int?,
      nbrStationsDecoupe: map['nbr_stations_decoupe'] as int?,
      photo: map['photo'] as String?,
      notes: map['notes'] as String?,
      typeName: map['machine_types'] != null
          ? map['machine_types']['name'] as String?
          : null,
    );
  }

  String get displayName {
    final specs = <String>[];
    specs.add('Laize: ${laizeMin.toInt()}-${laizeMax.toInt()}mm');
    if (nbrStations != null) {
      specs.add('Stations: $nbrStations');
      if (nbrStationsDecoupe != null) {
        specs.add('+$nbrStationsDecoupe découpe');
      }
    }
    return '$reference (${specs.join(', ')})';
  }

  @override
  String toString() => reference;
}
