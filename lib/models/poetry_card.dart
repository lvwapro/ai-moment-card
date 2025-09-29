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

class PoetryCard {
  final String id;
  final File image;
  final String poetry;
  final PoetryStyle style;
  final DateTime createdAt;
  final Map<String, dynamic> metadata;

  PoetryCard({
    required this.id,
    required this.image,
    required this.poetry,
    required this.style,
    required this.createdAt,
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imagePath': image.path,
      'poetry': poetry,
      'style': style.name,
      'createdAt': createdAt.toIso8601String(),
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
      createdAt: DateTime.parse(json['createdAt']),
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }

  PoetryCard copyWith({
    String? id,
    File? image,
    String? poetry,
    PoetryStyle? style,
    DateTime? createdAt,
    Map<String, dynamic>? metadata,
  }) {
    return PoetryCard(
      id: id ?? this.id,
      image: image ?? this.image,
      poetry: poetry ?? this.poetry,
      style: style ?? this.style,
      createdAt: createdAt ?? this.createdAt,
      metadata: metadata ?? this.metadata,
    );
  }
}
