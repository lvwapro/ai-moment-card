import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ai_poetry_card/models/poetry_card.dart';
import 'package:ai_poetry_card/models/nearby_place.dart';
import 'package:ai_poetry_card/services/ai_poetry_service.dart';
import 'package:ai_poetry_card/services/default_image_service.dart';
import 'package:ai_poetry_card/services/user_profile_service.dart';
import 'package:ai_poetry_card/services/location_service.dart';
import 'package:ai_poetry_card/services/network_service.dart';

class CardGenerator extends ChangeNotifier {
  final AIPoetryService _poetryService = AIPoetryService();
  final LocationService _locationService = LocationService();
  final NetworkService _networkService = NetworkService();
  UserProfileService? _userProfileService;

  bool _isGenerating = false;
  String? _currentPoetry;

  bool get isGenerating => _isGenerating;
  String? get currentPoetry => _currentPoetry;

  void setUserProfileService(UserProfileService userProfileService) {
    _userProfileService = userProfileService;
  }

  /// 将临时图片复制到应用的持久化目录
  Future<String> _savePersistentImage(String tempPath) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final imagesDir = Directory('${appDir.path}/images');

      // 确保目录存在
      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
      }

      // 生成唯一的文件名
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = tempPath.split('.').last;
      final fileName = 'img_$timestamp.$extension';
      final newPath = '${imagesDir.path}/$fileName';

      // 复制文件
      final tempFile = File(tempPath);
      if (await tempFile.exists()) {
        await tempFile.copy(newPath);
        print('✅ 图片已保存到持久化目录: $newPath');
        return newPath;
      } else {
        print('⚠️ 临时图片不存在: $tempPath');
        return tempPath; // 返回原路径
      }
    } catch (e) {
      print('❌ 保存图片失败: $e');
      return tempPath; // 失败时返回原路径
    }
  }

  Future<PoetryCard> generateCard(File image, PoetryStyle style,
      {String? userDescription,
      List<String>? localImagePaths,
      List<String>? cloudImageUrls}) async {
    _isGenerating = true;
    notifyListeners();

    try {
      // 1. 检查图片文件是否存在，如果不存在则生成默认图片
      File safeImage;

      if (cloudImageUrls != null && cloudImageUrls.isNotEmpty) {
        // 使用云端图片URL的第一张
        final firstCloudUrl = cloudImageUrls.first;
        safeImage = File(firstCloudUrl);
      } else if (await image.exists()) {
        // 使用传入的图片文件
        safeImage = image;
        print('🖼️ 使用传入的图片文件作为背景: ${image.path}');
      } else {
        // 生成默认图片
        final userProfile = _userProfileService?.currentProfile;
        safeImage = await DefaultImageService.generateDefaultImage(
          interests: userProfile?.interests,
          personality: userProfile?.personalityTypes.isNotEmpty == true
              ? userProfile!.personalityTypes.map((p) => p.name).join('、')
              : null,
        );
      }

      // 2. 先获取位置
      final location = await _locationService.getCurrentLocation();

      if (location == null) {
        print('⚠️ 位置获取失败，继续生成卡片（不包含地点信息）');
      } else {
        print('✅ 位置获取成功: (${location.longitude}, ${location.latitude})');
      }

      // 3. 并行请求：同时生成AI文案和获取附近地点
      print('🚀 开始并行请求：AI文案 + 附近地点...');
      final userProfile = _userProfileService?.getUserDescription();

      // 构建请求列表
      final futures = <Future>[
        // 请求1：生成AI文案（必须成功）
        _poetryService.generatePoetryData(
          safeImage,
          style,
          userDescription: userDescription,
          userProfile: userProfile,
        ),
      ];

      // 请求2：获取附近地点（可选，仅在有位置时）
      if (location != null) {
        futures.add(
          _networkService.getNearbyPlaces(
            longitude: location.longitude,
            latitude: location.latitude,
            radius: 1000,
          ),
        );
      }

      // 等待所有请求完成
      final results = await Future.wait(futures);

      // 处理AI文案结果
      final poetryData = results[0] as Map<String, dynamic>;
      final poetry = poetryData['pengyouquan'] ??
          poetryData['xiaohongshu'] ??
          poetryData['weibo'] ??
          poetryData['douyin'] ??
          '生成失败';
      _currentPoetry = poetry;
      print('✅ AI文案生成完成');

      // 处理附近地点结果（可选）
      List<NearbyPlace>? nearbyPlaces;
      if (location != null && results.length > 1) {
        try {
          final nearbyData = results[1] as Map<String, dynamic>?;
          if (nearbyData != null) {
            final nearbyResponse = NearbyPlacesResponse.fromJson(nearbyData);
            if (nearbyResponse.places.isNotEmpty) {
              nearbyPlaces = nearbyResponse.places.take(10).toList();
              print('✅ 获取到${nearbyPlaces.length}个附近地点');
            }
          } else {
            print('⚠️ 获取附近地点失败，继续生成卡片（不包含地点信息）');
          }
        } catch (e) {
          print('⚠️ 解析附近地点数据失败: $e，继续生成卡片（不包含地点信息）');
        }
      }

      print('✅ 并行请求完成！');

      // 4. 将本地图片保存到持久化目录
      List<String> persistentImagePaths = [];
      if (localImagePaths != null && localImagePaths.isNotEmpty) {
        for (var tempPath in localImagePaths) {
          final persistentPath = await _savePersistentImage(tempPath);
          persistentImagePaths.add(persistentPath);
        }
      }

      // 5. 创建卡片对象（包含所有平台文案和附近地点）
      final card = PoetryCard(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        image: safeImage,
        poetry: poetry,
        style: style,
        createdAt: DateTime.now(),
        metadata: {
          'generatedAt': DateTime.now().toIso8601String(),
          'imageSize': safeImage.path.startsWith('http')
              ? 'URL'
              : '${safeImage.lengthSync()}',
          'localImagePaths': persistentImagePaths, // 使用持久化路径
          'cloudImageUrls': cloudImageUrls ?? [],
        },
        // 添加所有平台的文案数据
        title: poetryData['title'],
        author: poetryData['author'],
        time: poetryData['time'],
        content: poetryData['content'],
        shiju: poetryData['shiju'],
        weibo: poetryData['weibo'],
        xiaohongshu: poetryData['xiaohongshu'],
        pengyouquan: poetryData['pengyouquan'],
        douyin: poetryData['douyin'],
        // 添加附近地点信息
        nearbyPlaces: nearbyPlaces,
      );

      print('✅ 卡片生成成功: ${card.id}');
      return card;
    } catch (e) {
      print('❌ CardGenerator生成失败: $e');
      print('❌ 错误类型: ${e.runtimeType}');
      rethrow; // 重新抛出错误，让调用者处理
    } finally {
      _isGenerating = false;
      notifyListeners();
    }
  }

  /// 重新生成卡片（保持图片和风格不变，重新生成所有平台文案）
  Future<PoetryCard> regenerateCard(PoetryCard originalCard) async {
    _isGenerating = true;
    notifyListeners();

    try {
      // 重新生成AI文案（获取所有平台的数据）
      final userProfile = _userProfileService?.getUserDescription();
      final poetryData = await _poetryService.generatePoetryData(
        originalCard.image,
        originalCard.style,
        userProfile: userProfile,
      );

      // 优先使用朋友圈文案作为默认显示
      final poetry = poetryData['pengyouquan'] ??
          poetryData['xiaohongshu'] ??
          poetryData['weibo'] ??
          poetryData['douyin'] ??
          '生成失败';
      _currentPoetry = poetry;

      // 创建新卡片（保持原有信息，更新文案数据）
      final newCard = originalCard.copyWith(
        poetry: poetry,
        title: poetryData['title'],
        author: poetryData['author'],
        time: poetryData['time'],
        content: poetryData['content'],
        shiju: poetryData['shiju'],
        weibo: poetryData['weibo'],
        xiaohongshu: poetryData['xiaohongshu'],
        pengyouquan: poetryData['pengyouquan'],
        douyin: poetryData['douyin'],
        metadata: {
          ...originalCard.metadata,
          'lastRegeneratedAt': DateTime.now().toIso8601String(),
        },
      );

      return newCard;
    } catch (e) {
      print('❌ 重新生成卡片失败: $e');
      rethrow;
    } finally {
      _isGenerating = false;
      notifyListeners();
    }
  }

  /// 重新生成文案（保持图片和风格不变）- 仅返回文案文本
  Future<String> regeneratePoetry(File image, PoetryStyle style,
      {String? userDescription,
      List<String>? localImagePaths,
      List<String>? cloudImageUrls}) async {
    _isGenerating = true;
    notifyListeners();

    try {
      // 优先使用云端图片URL的第一张，否则使用传入的图片文件，最后生成默认图片
      File safeImage;

      if (cloudImageUrls != null && cloudImageUrls.isNotEmpty) {
        // 使用云端图片URL的第一张
        final firstCloudUrl = cloudImageUrls.first;
        print('🖼️ 重新生成文案使用云端图片: $firstCloudUrl');
        safeImage = File(firstCloudUrl);
      } else if (await image.exists()) {
        // 使用传入的图片文件
        safeImage = image;
        print('🖼️ 重新生成文案使用传入的图片文件: ${image.path}');
      } else {
        // 生成默认图片
        final userProfile = _userProfileService?.currentProfile;
        safeImage = await DefaultImageService.generateDefaultImage(
          interests: userProfile?.interests,
          personality: userProfile?.personalityTypes.isNotEmpty == true
              ? userProfile!.personalityTypes.map((p) => p.name).join('、')
              : null,
        );
        print('🖼️ 重新生成文案使用默认图片');
      }

      // 重新生成AI文案
      final userProfile = _userProfileService?.getUserDescription();
      final poetry = await _poetryService.generatePoetry(
        safeImage,
        style,
        userDescription: userDescription,
        userProfile: userProfile,
      );
      _currentPoetry = poetry;
      return poetry;
    } finally {
      _isGenerating = false;
      notifyListeners();
    }
  }

  void clearCurrentGeneration() {
    _currentPoetry = null;
    notifyListeners();
  }
}
