import 'dart:io';
import 'dart:math';
import 'package:ai_poetry_card/models/poetry_card.dart';
import 'package:ai_poetry_card/services/network_service.dart';
import 'package:ai_poetry_card/services/location_service.dart';
import 'package:ai_poetry_card/services/cos_upload_service.dart';
import 'package:ai_poetry_card/services/language_service.dart';
import 'package:dio/dio.dart';

class AIPoetryService {
  final NetworkService _networkService = NetworkService();
  final LocationService _locationService = LocationService();

  // 真实的AI文案生成服务
  Future<String> generatePoetry(File image, PoetryStyle style,
      {String? userDescription, String? userProfile}) async {
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
      };

      print('📤 请求参数: $requestData');

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
      if (response.data != null && response.data['success'] == true) {
        final data = response.data['data'];

        // 根据不同平台选择合适的文案，优先使用朋友圈文案
        String copywriting = '';
        if (data['pengyouquan'] != null &&
            data['pengyouquan'].toString().isNotEmpty) {
          copywriting = data['pengyouquan'];
        } else if (data['xiaohongshu'] != null &&
            data['xiaohongshu'].toString().isNotEmpty) {
          copywriting = data['xiaohongshu'];
        } else if (data['weibo'] != null &&
            data['weibo'].toString().isNotEmpty) {
          copywriting = data['weibo'];
        } else if (data['douyin'] != null &&
            data['douyin'].toString().isNotEmpty) {
          copywriting = data['douyin'];
        } else {
          copywriting = _getFallbackPoetry(style);
        }

        return copywriting;
      } else {
        print('API返回错误: ${response.data?['message'] ?? response.data}');
        return _getFallbackPoetry(style);
      }
    } catch (e) {
      print('生成文案异常: $e');
      // 出错时返回备用文案
      return _getFallbackPoetry(style);
    }
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
    }
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
    }
  }
}
