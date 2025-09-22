import 'dart:io';

enum PoetryStyle {
  modernPoetic, // 现代诗意（默认首选）
  classicalElegant, // 古风雅韵
  humorousPlayful, // 幽默俏皮
  warmLiterary, // 文艺暖心
  minimalTags, // 极简摘要
  sciFiImagination, // 科幻想象
  deepPhilosophical, // 深沉哲思
  blindBox, // 盲盒模式
}

enum CardTemplate {
  minimal, // 极简
  elegant, // 优雅
  romantic, // 浪漫
  vintage, // 复古
  nature, // 自然
  urban, // 都市
}

class PoetryCard {
  final String id;
  final File image;
  final String poetry;
  final PoetryStyle style;
  final CardTemplate template;
  final DateTime createdAt;
  final String? qrCodeData;
  final Map<String, dynamic> metadata;

  PoetryCard({
    required this.id,
    required this.image,
    required this.poetry,
    required this.style,
    required this.template,
    required this.createdAt,
    this.qrCodeData,
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imagePath': image.path,
      'poetry': poetry,
      'style': style.name,
      'template': template.name,
      'createdAt': createdAt.toIso8601String(),
      'qrCodeData': qrCodeData,
      'metadata': metadata,
    };
  }

  factory PoetryCard.fromJson(Map<String, dynamic> json) {
    return PoetryCard(
      id: json['id'],
      image: File(json['imagePath']),
      poetry: json['poetry'],
      style: PoetryStyle.values.firstWhere(
        (e) => e.name == json['style'],
        orElse: () => PoetryStyle.blindBox,
      ),
      template: CardTemplate.values.firstWhere(
        (e) => e.name == json['template'],
        orElse: () => CardTemplate.minimal,
      ),
      createdAt: DateTime.parse(json['createdAt']),
      qrCodeData: json['qrCodeData'],
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }

  PoetryCard copyWith({
    String? id,
    File? image,
    String? poetry,
    PoetryStyle? style,
    CardTemplate? template,
    DateTime? createdAt,
    String? qrCodeData,
    Map<String, dynamic>? metadata,
  }) {
    return PoetryCard(
      id: id ?? this.id,
      image: image ?? this.image,
      poetry: poetry ?? this.poetry,
      style: style ?? this.style,
      template: template ?? this.template,
      createdAt: createdAt ?? this.createdAt,
      qrCodeData: qrCodeData ?? this.qrCodeData,
      metadata: metadata ?? this.metadata,
    );
  }
}
