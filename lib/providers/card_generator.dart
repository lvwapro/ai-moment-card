import 'dart:io';
import 'dart:math';
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
      {String? userDescription}) async {
    _isGenerating = true;
    notifyListeners();

    try {
      // 1. 检查图片文件是否存在，如果不存在则生成默认图片
      File safeImage;
      if (await image.exists()) {
        safeImage = image;
      } else {
        // 如果原图片不存在，生成默认图片
        final userProfile = _userProfileService?.currentProfile;
        safeImage = await DefaultImageService.generateDefaultImage(
          interests: userProfile?.interests,
          personality: userProfile?.personalityTypes.isNotEmpty == true
              ? userProfile!.personalityTypes.map((p) => p.name).join('、')
              : null,
        );
      }

      // 2. 生成AI文案
      final userProfile = _userProfileService?.getUserDescription();
      final poetry = await _poetryService.generatePoetry(
        safeImage,
        style,
        userDescription: userDescription,
        userProfile: userProfile,
      );
      _currentPoetry = poetry;

      // 3. 生成二维码数据
      final qrCodeData = _generateQrCodeData(poetry);

      // 4. 创建卡片对象
      final card = PoetryCard(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        image: safeImage,
        poetry: poetry,
        style: style,
        createdAt: DateTime.now(),
        qrCodeData: qrCodeData,
        metadata: {
          'generatedAt': DateTime.now().toIso8601String(),
          'imageSize': '${safeImage.lengthSync()}',
        },
      );

      return card;
    } finally {
      _isGenerating = false;
      notifyListeners();
    }
  }

  String _generateQrCodeData(String poetry) {
    // 生成包含隐藏诗句的二维码数据
    final hiddenPoems = [
      '时光荏苒，岁月如诗',
      '每一个瞬间都值得被珍藏',
      '生活如诗，诗意如画',
      '在平凡中发现美好',
      '用心感受，用爱记录',
    ];

    final random = Random();
    final hiddenPoem = hiddenPoems[random.nextInt(hiddenPoems.length)];

    return 'poetry://card?poem=${Uri.encodeComponent(hiddenPoem)}&time=${DateTime.now().millisecondsSinceEpoch}';
  }

  /// 使用默认图片生成卡片
  Future<PoetryCard> generateCardWithDefaultImage(PoetryStyle style,
      {String? userDescription}) async {
    _isGenerating = true;
    notifyListeners();

    try {
      // 1. 生成默认图片（基于用户信息）
      final userProfile = _userProfileService?.currentProfile;
      final defaultImage = await DefaultImageService.generateDefaultImage(
        interests: userProfile?.interests,
        personality: userProfile?.personalityTypes.isNotEmpty == true
            ? userProfile!.personalityTypes.map((p) => p.name).join('、')
            : null,
      );

      // 2. 生成AI文案（基于用户描述或随机生成）
      final userDescriptionText = _userProfileService?.getUserDescription();
      final poetry = await _poetryService.generatePoetry(
        defaultImage,
        style,
        userDescription: userDescription,
        userProfile: userDescriptionText,
      );
      _currentPoetry = poetry;

      // 3. 生成二维码数据
      final qrCodeData = _generateQrCodeData(poetry);

      // 4. 创建卡片对象
      final card = PoetryCard(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        image: defaultImage,
        poetry: poetry,
        style: style,
        createdAt: DateTime.now(),
        qrCodeData: qrCodeData,
        metadata: {
          'generatedAt': DateTime.now().toIso8601String(),
          'imageSize': '${defaultImage.lengthSync()}',
          'isDefaultImage': true,
        },
      );

      return card;
    } finally {
      _isGenerating = false;
      notifyListeners();
    }
  }

  /// 重新生成文案（保持图片和风格不变）
  Future<String> regeneratePoetry(File image, PoetryStyle style,
      {String? userDescription}) async {
    _isGenerating = true;
    notifyListeners();

    try {
      // 检查图片文件是否存在，如果不存在则生成默认图片
      File safeImage;
      if (await image.exists()) {
        safeImage = image;
      } else {
        // 如果原图片不存在，生成默认图片
        final userProfile = _userProfileService?.currentProfile;
        safeImage = await DefaultImageService.generateDefaultImage(
          interests: userProfile?.interests,
          personality: userProfile?.personalityTypes.isNotEmpty == true
              ? userProfile!.personalityTypes.map((p) => p.name).join('、')
              : null,
        );
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
