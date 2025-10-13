import 'dart:io';
import 'nearby_place.dart';

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
  final String poetry; // 默认显示的文案（通常是朋友圈）
  final PoetryStyle style;
  final DateTime createdAt;
  final Map<String, dynamic> metadata;

  // AI 生成的各平台文案
  final String? title; // 诗词标题
  final String? author; // 作者
  final String? time; // 朝代/时期
  final String? content; // 完整诗词内容
  final String? shiju; // 精选诗句
  final String? weibo; // 微博文案
  final String? xiaohongshu; // 小红书文案
  final String? pengyouquan; // 朋友圈文案
  final String? douyin; // 抖音文案

  // 附近地点信息
  final List<NearbyPlace>? nearbyPlaces;

  PoetryCard({
    required this.id,
    required this.image,
    required this.poetry,
    required this.style,
    required this.createdAt,
    this.metadata = const {},
    this.title,
    this.author,
    this.time,
    this.content,
    this.shiju,
    this.weibo,
    this.xiaohongshu,
    this.pengyouquan,
    this.douyin,
    this.nearbyPlaces,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imagePath': image.path,
      'poetry': poetry,
      'style': style.name,
      'createdAt': createdAt.toIso8601String(),
      'metadata': metadata,
      'title': title,
      'author': author,
      'time': time,
      'content': content,
      'shiju': shiju,
      'weibo': weibo,
      'xiaohongshu': xiaohongshu,
      'pengyouquan': pengyouquan,
      'douyin': douyin,
      'nearbyPlaces': nearbyPlaces?.map((p) => p.toJson()).toList(),
    };
  }

  factory PoetryCard.fromJson(Map<String, dynamic> json) {
    final nearbyPlacesList = json['nearbyPlaces'] as List?;

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
      title: json['title'],
      author: json['author'],
      time: json['time'],
      content: json['content'],
      shiju: json['shiju'],
      weibo: json['weibo'],
      xiaohongshu: json['xiaohongshu'],
      pengyouquan: json['pengyouquan'],
      douyin: json['douyin'],
      nearbyPlaces: nearbyPlacesList
          ?.map((p) => NearbyPlace.fromJson(p as Map<String, dynamic>))
          .toList(),
    );
  }

  PoetryCard copyWith({
    String? id,
    File? image,
    String? poetry,
    PoetryStyle? style,
    DateTime? createdAt,
    Map<String, dynamic>? metadata,
    String? title,
    String? author,
    String? time,
    String? content,
    String? shiju,
    String? weibo,
    String? xiaohongshu,
    String? pengyouquan,
    String? douyin,
    List<NearbyPlace>? nearbyPlaces,
  }) {
    return PoetryCard(
      id: id ?? this.id,
      image: image ?? this.image,
      poetry: poetry ?? this.poetry,
      style: style ?? this.style,
      createdAt: createdAt ?? this.createdAt,
      metadata: metadata ?? this.metadata,
      title: title ?? this.title,
      author: author ?? this.author,
      time: time ?? this.time,
      content: content ?? this.content,
      shiju: shiju ?? this.shiju,
      weibo: weibo ?? this.weibo,
      xiaohongshu: xiaohongshu ?? this.xiaohongshu,
      pengyouquan: pengyouquan ?? this.pengyouquan,
      douyin: douyin ?? this.douyin,
      nearbyPlaces: nearbyPlaces ?? this.nearbyPlaces,
    );
  }
}
