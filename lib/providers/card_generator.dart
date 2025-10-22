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

  /// 获取附近地点列表（供用户选择）
  Future<List<NearbyPlace>?> fetchNearbyPlaces() async {
    try {
      final location = await _locationService.getCurrentLocation();
      if (location == null) {
        print('⚠️ 位置获取失败');
        return null;
      }

      print('✅ 位置获取成功: (${location.longitude}, ${location.latitude})');

      final nearbyData = await _networkService.getNearbyPlaces(
        longitude: location.longitude,
        latitude: location.latitude,
        radius: 1000,
      );

      if (nearbyData != null) {
        final nearbyResponse = NearbyPlacesResponse.fromJson(nearbyData);
        if (nearbyResponse.places.isNotEmpty) {
          final places = nearbyResponse.places.take(20).toList();
          print('✅ 获取到${places.length}个附近地点');
          return places;
        }
      }

      return null;
    } catch (e) {
      print('❌ 获取附近地点失败: $e');
      return null;
    }
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
      List<String>? cloudImageUrls,
      NearbyPlace? selectedPlace,
      String? moodTag}) async {
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

      // 2. 生成AI文案
      print('🚀 开始生成AI文案...');
      final userProfile = _userProfileService?.getUserDescription();
      
      // 获取位置描述（如果有选中的地点）
      final locationDescription = selectedPlace != null
          ? '${selectedPlace.name}${selectedPlace.address.isNotEmpty ? "（${selectedPlace.address}）" : ""}'
          : null;

      final poetryData = await _poetryService.generatePoetryData(
        safeImage,
        style,
        userDescription: userDescription,
        userProfile: userProfile,
        location: locationDescription,
      );

      final poetry = poetryData['pengyouquan'] ??
          poetryData['xiaohongshu'] ??
          poetryData['weibo'] ??
          poetryData['douyin'] ??
          '生成失败';
      _currentPoetry = poetry;
      print('✅ AI文案生成完成');

      // 3. 将本地图片保存到持久化目录
      List<String> persistentImagePaths = [];
      if (localImagePaths != null && localImagePaths.isNotEmpty) {
        for (var tempPath in localImagePaths) {
          final persistentPath = await _savePersistentImage(tempPath);
          persistentImagePaths.add(persistentPath);
        }
      }

      // 4. 创建卡片对象（包含所有平台文案和选中的地点）
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
        // 添加用户选中的地点
        selectedPlace: selectedPlace,
        // 添加用户选中的情绪标签
        moodTag: moodTag,
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
