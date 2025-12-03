class Repeat {
  final int? id;
  final String reference;
  final int nbrDents;
  final int quantite;
  final DateTime? dateAchat;
  final String? fournisseur;
  final String? notes;
  final DateTime? createdAt;

  // Joined data
  final bool? hasMagneticCylinder;
  final List<String>? compatibleMachines;

  Repeat({
    this.id,
    required this.reference,
    required this.nbrDents,
    this.quantite = 1,
    this.dateAchat,
    this.fournisseur,
    this.notes,
    this.createdAt,
    this.hasMagneticCylinder,
    this.compatibleMachines,
  });

  // Calculated property: développement = nbr_dents × 3.175 mm
  double get developpement => nbrDents * 3.175;

  // Get compatible print types based on magnetic cylinder availability
  List<String> get compatiblePrintTypes {
    if (hasMagneticCylinder == true) {
      return ['autocollant', 'etiquette', 'sleeve', 'flexible', 'autre'];
    } else {
      return ['sleeve', 'flexible', 'autre']; // Pas autocollant/etiquette
    }
  }

  // Check if compatible with a specific article type
  bool isCompatibleWith(String articleType) {
    return compatiblePrintTypes.contains(articleType.toLowerCase());
  }

  // Local SQLite Serialization
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'reference': reference,
      'nbrDents': nbrDents,
      'quantite': quantite,
      'dateAchat': dateAchat?.toIso8601String(),
      'fournisseur': fournisseur,
      'notes': notes,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  factory Repeat.fromMap(Map<String, dynamic> map) {
    return Repeat(
      id: map['id'] as int?,
      reference: map['reference'] as String? ?? '',
      nbrDents: map['nbrDents'] as int? ?? 0,
      quantite: map['quantite'] as int? ?? 1,
      dateAchat: map['dateAchat'] != null
          ? DateTime.parse(map['dateAchat'] as String)
          : null,
      fournisseur: map['fournisseur'] as String?,
      notes: map['notes'] as String?,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : null,
      hasMagneticCylinder: (map['hasMagneticCylinder'] as int?) == 1,
      compatibleMachines: map['compatibleMachines'] != null
          ? (map['compatibleMachines'] as String).split(',')
          : null,
    );
  }

  // Supabase Serialization
  Map<String, dynamic> toSupabaseMap() {
    return {
      if (id != null) 'id': id,
      'reference': reference,
      'nbr_dents': nbrDents,
      'quantite': quantite,
      'date_achat': dateAchat?.toIso8601String(),
      'fournisseur': fournisseur,
      'notes': notes,
    };
  }

  factory Repeat.fromSupabaseMap(Map<String, dynamic> map) {
    return Repeat(
      id: map['id'] as int?,
      reference: map['reference'] as String? ?? '',
      nbrDents: map['nbr_dents'] as int? ?? 0,
      quantite: map['quantite'] as int? ?? 1,
      dateAchat: map['date_achat'] != null
          ? DateTime.parse(map['date_achat'] as String)
          : null,
      fournisseur: map['fournisseur'] as String?,
      notes: map['notes'] as String?,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : null,
    );
  }

  @override
  String toString() =>
      '$reference (${nbrDents}T, ${developpement.toStringAsFixed(2)}mm)';
}
