class Client {
  int? id;
  String name;
  String? logoPath;
  String? contactInfo;

  Client({this.id, required this.name, this.logoPath, this.contactInfo});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'logoPath': logoPath,
      'contactInfo': contactInfo,
    };
  }

  factory Client.fromMap(Map<String, dynamic> map) {
    return Client(
      id: map['id'] as int?,
      name: map['name'] as String? ?? '',
      logoPath: map['logoPath'] as String?,
      contactInfo: map['contactInfo'] as String?,
    );
  }
  // Supabase Serialization
  Map<String, dynamic> toSupabaseMap() {
    return {
      // 'id': id, // Let Supabase generate ID
      'name': name,
      'logo_path': logoPath,
      'contact_info': contactInfo,
    };
  }

  factory Client.fromSupabaseMap(Map<String, dynamic> map) {
    return Client(
      id: map['id'] as int?,
      name: map['name'] as String? ?? '',
      logoPath: map['logo_path'] as String?,
      contactInfo: map['contact_info'] as String?,
    );
  }
}
