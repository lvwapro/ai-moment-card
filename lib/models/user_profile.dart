enum Gender {
  male,
  female,
  other,
}

enum PersonalityType {
  introverted, // 内向
  extroverted, // 外向
  artistic, // 文艺
  practical, // 实用主义
  romantic, // 浪漫主义
  humorous, // 幽默风趣
  philosophical, // 哲学思辨
  adventurous, // 冒险精神
}

class UserProfile {
  final String id;
  final int? age;
  final Gender? gender;
  final List<PersonalityType> personalityTypes;
  final List<String> interests;
  final String? occupation;
  final String? location;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserProfile({
    required this.id,
    this.age,
    this.gender,
    this.personalityTypes = const [],
    this.interests = const [],
    this.occupation,
    this.location,
    required this.createdAt,
    required this.updatedAt,
  });

  /// 检查用户信息是否完整
  bool get isComplete {
    return age != null && gender != null && personalityTypes.isNotEmpty;
  }

  /// 获取用户描述文本，用于AI生成（不包含敏感信息）
  String get userDescription {
    // 只返回兴趣爱好，不包含年龄、性别等敏感信息
    if (interests.isNotEmpty) {
      return '兴趣爱好：${interests.join('、')}';
    }

    // 如果没有兴趣爱好，返回空字符串
    return '';
  }

  /// 获取适合的文案风格建议
  List<String> get suggestedStyles {
    final suggestions = <String>[];

    if (personalityTypes.contains(PersonalityType.artistic)) {
      suggestions.add('现代诗意');
      suggestions.add('文艺暖心');
    }

    if (personalityTypes.contains(PersonalityType.humorous)) {
      suggestions.add('幽默俏皮');
    }

    if (personalityTypes.contains(PersonalityType.philosophical)) {
      suggestions.add('深沉哲思');
    }

    if (personalityTypes.contains(PersonalityType.romantic)) {
      suggestions.add('古风雅韵');
      suggestions.add('文艺暖心');
    }

    if (personalityTypes.contains(PersonalityType.practical)) {
      suggestions.add('极简摘要');
    }

    if (personalityTypes.contains(PersonalityType.adventurous)) {
      suggestions.add('科幻想象');
    }

    // 如果没有匹配的风格，返回默认建议
    if (suggestions.isEmpty) {
      suggestions.addAll(['现代诗意', '文艺暖心', '盲盒']);
    }

    return suggestions;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'age': age,
      'gender': gender?.name,
      'personalityTypes': personalityTypes.map((e) => e.name).toList(),
      'interests': interests,
      'occupation': occupation,
      'location': location,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      age: json['age'],
      gender: json['gender'] != null
          ? Gender.values.firstWhere(
              (e) => e.name == json['gender'],
              orElse: () => Gender.other,
            )
          : null,
      personalityTypes: (json['personalityTypes'] as List<dynamic>?)
              ?.map((e) => PersonalityType.values.firstWhere(
                    (type) => type.name == e,
                    orElse: () => PersonalityType.introverted,
                  ))
              .toList() ??
          [],
      interests: List<String>.from(json['interests'] ?? []),
      occupation: json['occupation'],
      location: json['location'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  UserProfile copyWith({
    String? id,
    int? age,
    Gender? gender,
    List<PersonalityType>? personalityTypes,
    List<String>? interests,
    String? occupation,
    String? location,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      personalityTypes: personalityTypes ?? this.personalityTypes,
      interests: interests ?? this.interests,
      occupation: occupation ?? this.occupation,
      location: location ?? this.location,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
