class Article {
  int? id;
  int clientId;
  String name;
  String? photo;
  String type; // 'etiquette', 'sleeve', 'autre'
  String? typeAutre;
  int? supportId;
  double costPrice; // prix revien
  double repeat;
  int poseCount; // nbr pose
  bool amalgam;
  double width; // laize
  String machine; // 'ZJR 450', 'Alpha 240'
  int colorCount; // nbr couleur
  double sleeveCase; // etuit (0 if not sleeve)
  int labelsPerReel; // nbr etiq/bobine livraison
  String core; // mandrin

  Article({
    this.id,
    required this.clientId,
    required this.name,
    this.photo,
    required this.type,
    this.typeAutre,
    this.supportId,
    required this.costPrice,
    required this.repeat,
    required this.poseCount,
    required this.amalgam,
    required this.width,
    required this.machine,
    required this.colorCount,
    this.sleeveCase = 0.0,
    required this.labelsPerReel,
    required this.core,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'clientId': clientId,
      'name': name,
      'photo': photo,
      'type': type,
      'typeAutre': typeAutre,
      'supportId': supportId,
      'costPrice': costPrice,
      'repeat': repeat,
      'poseCount': poseCount,
      'amalgam': amalgam ? 1 : 0,
      'width': width,
      'machine': machine,
      'colorCount': colorCount,
      'sleeveCase': sleeveCase,
      'labelsPerReel': labelsPerReel,
      'core': core,
    };
  }

  factory Article.fromMap(Map<String, dynamic> map) {
    return Article(
      id: map['id'] as int?,
      clientId: map['clientId'] as int? ?? 0,
      name: map['name'] as String? ?? '',
      photo: map['photo'] as String?,
      type: map['type'] as String? ?? 'etiquette',
      typeAutre: map['typeAutre'] as String?,
      supportId: map['supportId'] as int?,
      costPrice: (map['costPrice'] as num?)?.toDouble() ?? 0.0,
      repeat: (map['repeat'] as num?)?.toDouble() ?? 0.0,
      poseCount: map['poseCount'] as int? ?? 1,
      amalgam: (map['amalgam'] as int? ?? 0) == 1,
      width: (map['width'] as num?)?.toDouble() ?? 0.0,
      machine: map['machine'] as String? ?? 'ZJR 450',
      colorCount: map['colorCount'] as int? ?? 0,
      sleeveCase: (map['sleeveCase'] as num?)?.toDouble() ?? 0.0,
      labelsPerReel: map['labelsPerReel'] as int? ?? 0,
      core: map['core'] as String? ?? '',
    );
  }
  // Supabase Serialization
  Map<String, dynamic> toSupabaseMap() {
    return {
      // 'id': id,
      'client_id': clientId,
      'name': name,
      'photo': photo,
      'type': type,
      'type_autre': typeAutre,
      'support_id': supportId,
      'cost_price': costPrice,
      'repeat': repeat,
      'pose_count': poseCount,
      'amalgam': amalgam,
      'width': width,
      'machine': machine,
      'color_count': colorCount,
      'sleeve_case': sleeveCase,
      'labels_per_reel': labelsPerReel,
      'core': core,
    };
  }

  factory Article.fromSupabaseMap(Map<String, dynamic> map) {
    return Article(
      id: map['id'] as int?,
      clientId: map['client_id'] as int? ?? 0,
      name: map['name'] as String? ?? '',
      photo: map['photo'] as String?,
      type: map['type'] as String? ?? 'etiquette',
      typeAutre: map['type_autre'] as String?,
      supportId: map['support_id'] as int?,
      costPrice: (map['cost_price'] as num?)?.toDouble() ?? 0.0,
      repeat: (map['repeat'] as num?)?.toDouble() ?? 0.0,
      poseCount: map['pose_count'] as int? ?? 1,
      amalgam: map['amalgam'] as bool? ?? false,
      width: (map['width'] as num?)?.toDouble() ?? 0.0,
      machine: map['machine'] as String? ?? 'ZJR 450',
      colorCount: map['color_count'] as int? ?? 0,
      sleeveCase: (map['sleeve_case'] as num?)?.toDouble() ?? 0.0,
      labelsPerReel: map['labels_per_reel'] as int? ?? 0,
      core: map['core'] as String? ?? '',
    );
  }
}
