class MagneticCylinder {
  final int? id;
  final int repeatId;
  final String reference;
  final int quantite;
  final DateTime? dateAchat;
  final String? etat; // 'bon', 'usé', 'à réviser', etc.
  final String? notes;

  MagneticCylinder({
    this.id,
    required this.repeatId,
    required this.reference,
    this.quantite = 1,
    this.dateAchat,
    this.etat,
    this.notes,
  });

  // Local SQLite Serialization
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'repeatId': repeatId,
      'reference': reference,
      'quantite': quantite,
      'dateAchat': dateAchat?.toIso8601String(),
      'etat': etat,
      'notes': notes,
    };
  }

  factory MagneticCylinder.fromMap(Map<String, dynamic> map) {
    return MagneticCylinder(
      id: map['id'] as int?,
      repeatId: map['repeatId'] as int? ?? 0,
      reference: map['reference'] as String? ?? '',
      quantite: map['quantite'] as int? ?? 1,
      dateAchat: map['dateAchat'] != null
          ? DateTime.parse(map['dateAchat'] as String)
          : null,
      etat: map['etat'] as String?,
      notes: map['notes'] as String?,
    );
  }

  // Supabase Serialization
  Map<String, dynamic> toSupabaseMap() {
    return {
      if (id != null) 'id': id,
      'repeat_id': repeatId,
      'reference': reference,
      'quantite': quantite,
      'date_achat': dateAchat?.toIso8601String(),
      'etat': etat,
      'notes': notes,
    };
  }

  factory MagneticCylinder.fromSupabaseMap(Map<String, dynamic> map) {
    return MagneticCylinder(
      id: map['id'] as int?,
      repeatId: map['repeat_id'] as int? ?? 0,
      reference: map['reference'] as String? ?? '',
      quantite: map['quantite'] as int? ?? 1,
      dateAchat: map['date_achat'] != null
          ? DateTime.parse(map['date_achat'] as String)
          : null,
      etat: map['etat'] as String?,
      notes: map['notes'] as String?,
    );
  }

  @override
  String toString() =>
      '$reference (Qté: $quantite, État: ${etat ?? "non spécifié"})';
}
