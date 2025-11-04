import 'dart:io';
import 'dart:math';
import 'package:ai_poetry_card/models/poetry_card.dart';
import 'package:ai_poetry_card/services/network_service.dart';
import 'package:ai_poetry_card/services/location_service.dart';
import 'package:ai_poetry_card/services/cos_upload_service.dart';
import 'package:ai_poetry_card/services/language_service.dart';
import 'package:dio/dio.dart';

// 自定义配额超限异常
class QuotaExceededException implements Exception {
  final String message;
  QuotaExceededException(this.message);

  @override
  String toString() => message;
}

class AIPoetryService {
  final NetworkService _networkService = NetworkService();
  final LocationService _locationService = LocationService();

  // 真实的AI文案生成服务 - 返回包含所有平台文案的数据
  Future<Map<String, dynamic>> generatePoetryData(File image, PoetryStyle style,
      {String? userDescription, String? userProfile, String? location}) async {
    try {
      // 1. 获取图片URL
      String imageUrl = await _getImageUrl(image);

      // 2. 获取位置信息
      double latitude = 39.9163;
      double longitude = 116.3972;

      try {
        final location = await _locationService.getCurrentLocation();
        if (location != null) {
          latitude = location.latitude;
          longitude = location.longitude;
        }
      } catch (e) {
        // 使用默认位置
      }

      // 3. 获取当前语言
      final language = LanguageService.to.getCurrentLanguage();

      // 4. 将风格转换为category
      final category = _styleToCategory(style);

      // 5. 构建请求数据
      final requestData = {
        'imageUrl': imageUrl,
        'latitude': latitude,
        'longitude': longitude,
        'language': language,
        'description': userDescription ?? '',
        'category': category,
        'location': location ?? '', // 添加位置文字描述
      };

      print('📤 =========== 文案生成请求参数 ===========');
      print('📍 图片URL: $imageUrl');
      print('📍 经度: $longitude');
      print('📍 纬度: $latitude');
      print('📍 语言: $language');
      print('📍 用户描述: ${userDescription ?? "无"}');
      print('📍 风格分类: $category');
      print('📍 位置描述: ${location ?? "无"}');
      print('📤 完整请求数据: $requestData');
      print('📤 =========================================');

      // 6. 调用API生成文案
      final response = await _networkService.post(
        'api/copywriting/generate',
        data: requestData,
        options: Options(
          sendTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 60),
        ),
      );

      print('📥 响应数据: ${response.data}');

      // 7. 解析响应
      // 先检查是否是配额已超错误
      final code = response.data?['code'];
      if (code == 'QUOTA_EXCEEDED') {
        print('⚠️ 配额已超: ${response.data?['message'] ?? '当日生成次数已达上限'}');
        throw QuotaExceededException(
          response.data?['message'] ?? '当日生成次数已达上限，请升级会员解锁无限次数',
        );
      }

      // 再检查是否成功
      if (response.data != null && response.data['success'] == true) {
        final data = response.data['data'];

        // 返回完整的数据结构
        final result = {
          'title': data['title'],
          'author': data['author'],
          'time': data['time'],
          'content': data['content'],
          'shiju': data['shiju'],
          'weibo': data['weibo'],
          'xiaohongshu': data['xiaohongshu'],
          'pengyouquan': data['pengyouquan'],
          'douyin': data['douyin'],
        };
        
        // 添加对联数据（如果存在）
        if (data['duilian'] != null) {
          result['duilian'] = data['duilian'];
          print('✅ 对联数据: ${data['duilian']}');
        } else {
          print('⚠️ API响应中没有对联数据');
        }
        
        return result;
      } else {
        print('API返回错误: ${response.data?['message'] ?? response.data}');
        return _getFallbackPoetryData(style);
      }
    } catch (e) {
      // 如果是配额异常，直接抛出
      if (e is QuotaExceededException) {
        rethrow;
      }

      print('生成文案异常: $e');
      // 出错时返回备用文案数据
      return _getFallbackPoetryData(style);
    }
  }

  // 兼容旧接口 - 仅返回默认文案（朋友圈）
  Future<String> generatePoetry(File image, PoetryStyle style,
      {String? userDescription, String? userProfile, String? location}) async {
    final data = await generatePoetryData(image, style,
        userDescription: userDescription,
        userProfile: userProfile,
        location: location);

    // 优先返回朋友圈文案
    return data['pengyouquan'] ??
        data['xiaohongshu'] ??
        data['weibo'] ??
        data['douyin'] ??
        _getFallbackPoetry(style);
  }

  // 获取图片URL
  Future<String> _getImageUrl(File image) async {
    // 如果图片路径是URL，直接返回
    if (image.path.startsWith('http://') || image.path.startsWith('https://')) {
      return image.path;
    }

    // 否则上传到COS并返回URL
    try {
      final uploadResult = await CosUploadService.instance.uploadFile(
        filePath: image.path,
        onProgress: (completed, total) {
          // 静默上传，不打印进度
        },
      );

      if (uploadResult['success'] == true) {
        print('图片上传成功: ${uploadResult['url']}');
        return uploadResult['url'];
      } else {
        throw Exception(uploadResult['error']);
      }
    } catch (e) {
      print('上传图片失败: $e');
      rethrow;
    }
  }

  // 将风格转换为category
  String _styleToCategory(PoetryStyle style) {
    switch (style) {
      case PoetryStyle.modernPoetic:
        return 'modern';
      case PoetryStyle.classicalElegant:
        return 'classical';
      case PoetryStyle.humorousPlayful:
        return 'humorous';
      case PoetryStyle.warmLiterary:
        return 'warm';
      case PoetryStyle.minimalTags:
        return 'minimal';
      case PoetryStyle.sciFiImagination:
        return 'scifi';
      case PoetryStyle.deepPhilosophical:
        return 'philosophical';
      case PoetryStyle.blindBox:
        return 'random';
      case PoetryStyle.romanticDream:
        return 'romantic';
      case PoetryStyle.freshNatural:
        return 'fresh';
      case PoetryStyle.urbanFashion:
        return 'urban';
      case PoetryStyle.nostalgicRetro:
        return 'nostalgic';
      case PoetryStyle.motivationalPositive:
        return 'motivational';
      case PoetryStyle.mysteriousDark:
        return 'mysterious';
      case PoetryStyle.cuteSweet:
        return 'cute';
      case PoetryStyle.coolEdgy:
        return 'cool';
    }
  }

  // 获取备用文案数据（API失败时使用）
  Map<String, dynamic> _getFallbackPoetryData(PoetryStyle style) {
    final fallbackText = _getFallbackPoetry(style);
    return {
      'title': '离线文案',
      'author': 'AI助手',
      'time': '现代',
      'content': fallbackText,
      'shiju': fallbackText,
      'weibo': fallbackText,
      'xiaohongshu': fallbackText,
      'pengyouquan': fallbackText,
      'douyin': fallbackText,
    };
  }

  // 获取备用文案（API失败时使用）
  String _getFallbackPoetry(PoetryStyle style) {
    final random = Random();
    final fallbackPoems = _getRandomPoetryList(style);
    return fallbackPoems[random.nextInt(fallbackPoems.length)];
  }

  List<String> _getRandomPoetryList(PoetryStyle style) {
    switch (style) {
      case PoetryStyle.modernPoetic:
        return [
          '落日熔金，潮汐私语，世界沉入温柔的尾声',
          '时光如诗，岁月如歌',
          '在平凡中寻找不平凡',
        ];
      case PoetryStyle.classicalElegant:
        return [
          '碧海衔落日，余晖镀金波。孤云随雁远，心共晚风和',
          '山重水复疑无路，柳暗花明又一村',
          '落红不是无情物，化作春泥更护花',
        ];
      case PoetryStyle.humorousPlayful:
        return [
          '太阳下班了，我也挺饿的，海鲜面能不能多加个蛋？',
          '今天也要加油鸭！',
          '生活就像巧克力，你永远不知道下一颗是什么味道',
        ];
      case PoetryStyle.warmLiterary:
        return [
          '把一天的烦恼，都丢进海里喂鱼',
          '你是我心中的诗',
          '爱如春风，温柔如水',
        ];
      case PoetryStyle.minimalTags:
        return [
          '#落日 #海岸 #黄昏',
          '#生活 #美好 #瞬间',
          '#诗意 #时光 #记忆',
        ];
      case PoetryStyle.sciFiImagination:
        return [
          '恒星为这片海域提供了今日最后一次能源灌注',
          '神秘是生活的调味剂',
          '未知中藏着惊喜',
        ];
      case PoetryStyle.deepPhilosophical:
        return [
          '思考是灵魂的对话',
          '智慧在静默中生长',
          '人生如棋，步步为营',
        ];
      case PoetryStyle.blindBox:
        return [
          '落日熔金，潮汐私语，世界沉入温柔的尾声',
          '碧海衔落日，余晖镀金波。孤云随雁远，心共晚风和',
          '太阳下班了，我也挺饿的，海鲜面能不能多加个蛋？',
          '把一天的烦恼，都丢进海里喂鱼',
        ];
      case PoetryStyle.romanticDream:
        return [
          '星河入梦，月光如诗',
          '遇见你，是最美的意外',
          '爱是永恒的浪漫',
        ];
      case PoetryStyle.freshNatural:
        return [
          '微风拂面，绿意盎然',
          '自然的美好，治愈心灵',
          '呼吸清新，感受自然',
        ];
      case PoetryStyle.urbanFashion:
        return [
          '都市霓虹，时尚节奏',
          '街头风景，现代生活',
          '潮流前线，个性表达',
        ];
      case PoetryStyle.nostalgicRetro:
        return [
          '旧时光，老相片',
          '回忆是最美的珍藏',
          '岁月如歌，温暖依旧',
        ];
      case PoetryStyle.motivationalPositive:
        return [
          '每一天都是新的开始',
          '相信自己，勇敢前行',
          '阳光总在风雨后',
        ];
      case PoetryStyle.mysteriousDark:
        return [
          '暗夜星辰，神秘未知',
          '黑暗中的光',
          '探索未知的勇气',
        ];
      case PoetryStyle.cuteSweet:
        return [
          '甜甜的笑容，暖暖的心',
          '可爱是一种态度',
          '软萌时光，治愈系',
        ];
      case PoetryStyle.coolEdgy:
        return [
          '酷炫姿态，个性表达',
          '做自己，不随波逐流',
          '独特是最好的标签',
        ];
    }
  }
}
