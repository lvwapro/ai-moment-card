import 'dart:io';
import 'nearby_place.dart';

/// 对联数据类
class Duilian {
  final String horizontal; // 横批
  final String upper; // 上联
  final String lower; // 下联
  final String? analysis; // 解析

  Duilian({
    required this.horizontal,
    required this.upper,
    required this.lower,
    this.analysis,
  });

  Map<String, dynamic> toJson() {
    return {
      'horizontal': horizontal,
      'upper': upper,
      'lower': lower,
      if (analysis != null) 'analysis': analysis,
    };
  }

  factory Duilian.fromJson(Map<String, dynamic> json) {
    return Duilian(
      horizontal: json['horizontal'] as String,
      upper: json['upper'] as String,
      lower: json['lower'] as String,
      analysis: json['analysis'] as String?,
    );
  }
}

enum PoetryStyle {
  modernPoetic, // 现代诗意（默认首选）
  classicalElegant, // 古风雅韵
  humorousPlayful, // 幽默俏皮
  warmLiterary, // 文艺暖心
  minimalTags, // 极简摘要
  sciFiImagination, // 科幻想象
  deepPhilosophical, // 深沉哲思
  blindBox, // 盲盒模式
  romanticDream, // 浪漫梦幻
  freshNatural, // 清新自然
  urbanFashion, // 都市时尚
  nostalgicRetro, // 怀旧复古
  motivationalPositive, // 励志正能量
  mysteriousDark, // 神秘暗黑
  cuteSweet, // 可爱甜美
  coolEdgy, // 酷炫个性
}

class PoetryCard {
  final String id;
  final File image;
  final String poetry; // 默认显示的文案（通常是朋友圈）
  final PoetryStyle style;
  final DateTime createdAt;

  // 图片相关字段
  final String? generatedAt;
  final String? imageSize;
  final String? localImagePath; // 首图本地路径
  final List<String>? localImagePaths; // 所有本地图片路径
  final List<String>? cloudImageUrls; // 所有云端图片 URL

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
  final Duilian? duilian; // 对联

  // 选中的地点信息（单个地址）
  final NearbyPlace? selectedPlace;

  // 选中的情绪标签
  final String? moodTag;

  PoetryCard({
    required this.id,
    required this.image,
    required this.poetry,
    required this.style,
    required this.createdAt,
    this.generatedAt,
    this.imageSize,
    this.localImagePath,
    this.localImagePaths,
    this.cloudImageUrls,
    this.title,
    this.author,
    this.time,
    this.content,
    this.shiju,
    this.weibo,
    this.xiaohongshu,
    this.pengyouquan,
    this.douyin,
    this.duilian,
    this.selectedPlace,
    this.moodTag,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'imagePath': image.path,
        'poetry': poetry,
        'style': style.name,
        'createdAt': createdAt.toIso8601String(),
        if (generatedAt != null) 'generatedAt': generatedAt,
        if (imageSize != null) 'imageSize': imageSize,
        if (localImagePath != null) 'localImagePath': localImagePath,
        if (localImagePaths != null) 'localImagePaths': localImagePaths,
        if (cloudImageUrls != null) 'cloudImageUrls': cloudImageUrls,
        'title': title,
        'author': author,
        'time': time,
        'content': content,
        'shiju': shiju,
        'weibo': weibo,
        'xiaohongshu': xiaohongshu,
        'pengyouquan': pengyouquan,
        'douyin': douyin,
        'duilian': duilian?.toJson(),
        'selectedPlace': selectedPlace?.toJson(),
        'moodTag': moodTag,
      };

  factory PoetryCard.fromJson(Map<String, dynamic> json) {
    final selectedPlaceJson = json['selectedPlace'] as Map<String, dynamic>?;

    // 处理图片路径列表
    List<String>? localImagePaths;
    if (json['localImagePaths'] is List) {
      localImagePaths = (json['localImagePaths'] as List)
          .map((e) => e.toString())
          .where((s) => s.isNotEmpty)
          .toList();
    }

    List<String>? cloudImageUrls;
    if (json['cloudImageUrls'] is List) {
      cloudImageUrls = (json['cloudImageUrls'] as List)
          .map((e) => e.toString())
          .where((s) => s.isNotEmpty)
          .toList();
    }

    return PoetryCard(
      id: json['id'],
      image: File(json['imagePath']),
      poetry: json['poetry'],
      style: PoetryStyle.values.firstWhere(
        (e) => e.name == json['style'],
        orElse: () => PoetryStyle.blindBox,
      ),
      createdAt: DateTime.parse(json['createdAt']),
      generatedAt: json['generatedAt'] as String?,
      imageSize: json['imageSize'] as String?,
      localImagePath: json['localImagePath'] as String?,
      localImagePaths: localImagePaths,
      cloudImageUrls: cloudImageUrls,
      title: json['title'],
      author: json['author'],
      time: json['time'],
      content: json['content'],
      shiju: json['shiju'],
      weibo: json['weibo'],
      xiaohongshu: json['xiaohongshu'],
      pengyouquan: json['pengyouquan'],
      douyin: json['douyin'],
      duilian: json['duilian'] != null
          ? Duilian.fromJson(json['duilian'] as Map<String, dynamic>)
          : null,
      selectedPlace: selectedPlaceJson != null
          ? NearbyPlace.fromJson(selectedPlaceJson)
          : null,
      moodTag: json['moodTag'] as String?,
    );
  }

  PoetryCard copyWith({
    String? id,
    File? image,
    String? poetry,
    PoetryStyle? style,
    DateTime? createdAt,
    String? generatedAt,
    String? imageSize,
    String? localImagePath,
    List<String>? localImagePaths,
    List<String>? cloudImageUrls,
    String? title,
    String? author,
    String? time,
    String? content,
    String? shiju,
    String? weibo,
    String? xiaohongshu,
    String? pengyouquan,
    String? douyin,
    Duilian? duilian,
    NearbyPlace? selectedPlace,
    String? moodTag,
  }) =>
      PoetryCard(
        id: id ?? this.id,
        image: image ?? this.image,
        poetry: poetry ?? this.poetry,
        style: style ?? this.style,
        createdAt: createdAt ?? this.createdAt,
        generatedAt: generatedAt ?? this.generatedAt,
        imageSize: imageSize ?? this.imageSize,
        localImagePath: localImagePath ?? this.localImagePath,
        localImagePaths: localImagePaths ?? this.localImagePaths,
        cloudImageUrls: cloudImageUrls ?? this.cloudImageUrls,
        title: title ?? this.title,
        author: author ?? this.author,
        time: time ?? this.time,
        content: content ?? this.content,
        shiju: shiju ?? this.shiju,
        weibo: weibo ?? this.weibo,
        xiaohongshu: xiaohongshu ?? this.xiaohongshu,
        pengyouquan: pengyouquan ?? this.pengyouquan,
        douyin: douyin ?? this.douyin,
        duilian: duilian ?? this.duilian,
        selectedPlace: selectedPlace ?? this.selectedPlace,
        moodTag: moodTag ?? this.moodTag,
      );

  /// 获取首图路径（单张）
  /// 优先从 localImagePath 获取并检查是否有效
  /// 如果无效，则直接使用 image.path
  String getFirstImagePath() {
    // 1. 优先检查本地首图
    if (localImagePath != null && localImagePath!.isNotEmpty) {
      try {
        if (File(localImagePath!).existsSync()) {
          print('📸 getFirstImagePath: 使用本地首图 - $localImagePath');
          return localImagePath!;
        }
      } catch (e) {
        // 文件检查失败，继续下一步
      }
    }

    // 2. 直接使用 image.path
    print('📸 getFirstImagePath: 使用 image.path - ${image.path}');
    return image.path;
  }

  /// 获取本地图片路径列表（用于展示）
  /// 从 localImagePaths 获取，检查是否存在
  /// 如果不存在，则获取对应 index 的 cloudImageUrls
  List<String> getLocalImagePaths() {
    final List<String> result = [];

    if (localImagePaths != null) {
      for (int i = 0; i < localImagePaths!.length; i++) {
        final localPath = localImagePaths![i];
        if (localPath.isNotEmpty) {
          // 检查本地文件是否存在
          if (File(localPath).existsSync()) {
            result.add(localPath);
          } else {
            // 本地文件不存在，尝试获取对应的云端 URL
            if (cloudImageUrls != null && i < cloudImageUrls!.length) {
              final cloudUrl = cloudImageUrls![i];
              if (cloudUrl.isNotEmpty) {
                result.add(cloudUrl);
              }
            }
          }
        }
      }
    }

    return result;
  }
}
