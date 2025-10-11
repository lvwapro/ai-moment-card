import 'dart:io';
import 'package:flutter/material.dart';
import 'package:ai_poetry_card/models/poetry_card.dart';
import 'package:ai_poetry_card/services/ai_poetry_service.dart';
import 'package:ai_poetry_card/services/default_image_service.dart';
import 'package:ai_poetry_card/services/user_profile_service.dart';

class CardGenerator extends ChangeNotifier {
  final AIPoetryService _poetryService = AIPoetryService();
  UserProfileService? _userProfileService;

  bool _isGenerating = false;
  String? _currentPoetry;

  bool get isGenerating => _isGenerating;
  String? get currentPoetry => _currentPoetry;

  void setUserProfileService(UserProfileService userProfileService) {
    _userProfileService = userProfileService;
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

      // 2. 生成AI文案（获取所有平台的数据）
      final userProfile = _userProfileService?.getUserDescription();
      final poetryData = await _poetryService.generatePoetryData(
        safeImage,
        style,
        userDescription: userDescription,
        userProfile: userProfile,
      );

      // 优先使用朋友圈文案作为默认显示
      final poetry = poetryData['pengyouquan'] ??
          poetryData['xiaohongshu'] ??
          poetryData['weibo'] ??
          poetryData['douyin'] ??
          '生成失败';
      _currentPoetry = poetry;

      // 3. 创建卡片对象（包含所有平台文案）
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
          'localImagePaths': localImagePaths ?? [],
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
