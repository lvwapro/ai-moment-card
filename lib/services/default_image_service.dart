import 'dart:io';
import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

enum BackgroundTemplate {
  dogInFlowers, // 花丛中的狗
  cormorantFishing, // 鸬鹚捕鱼
  traditionalView, // 传统景观
  mountainSunset, // 山峦日落
}

class DefaultImageService {
  static const int _imageWidth = 400;
  static const int _imageHeight = 400;

  /// 获取所有可用的背景模板
  static List<BackgroundTemplate> get availableTemplates =>
      BackgroundTemplate.values;

  /// 获取背景图片的asset路径
  static String _getBackgroundAssetPath(BackgroundTemplate template) {
    switch (template) {
      case BackgroundTemplate.dogInFlowers:
        return 'assets/images/backgrounds/dog_in_flowers.jpg';
      case BackgroundTemplate.cormorantFishing:
        return 'assets/images/backgrounds/misty_mountains.jpg';
      case BackgroundTemplate.traditionalView:
        return 'assets/images/backgrounds/traditional_view.jpg';
      case BackgroundTemplate.mountainSunset:
        return 'assets/images/backgrounds/mountain_sunset.jpg';
    }
  }

  /// 根据用户信息智能选择背景模板
  static BackgroundTemplate selectTemplateForUser({
    List<String>? interests,
    String? personality,
  }) {
    final random = math.Random();

    // 根据兴趣爱好选择
    if (interests != null && interests.isNotEmpty) {
      if (interests.contains('宠物')) {
        return BackgroundTemplate.dogInFlowers;
      }
      if (interests.contains('旅行') || interests.contains('摄影')) {
        return BackgroundTemplate.mountainSunset;
      }
      if (interests.contains('园艺') || interests.contains('自然')) {
        return BackgroundTemplate.dogInFlowers; // 花丛背景适合自然爱好者
      }
    }

    // 根据性格选择
    if (personality != null) {
      if (personality.contains('文艺') || personality.contains('浪漫')) {
        return BackgroundTemplate.traditionalView;
      }
      if (personality.contains('哲学') || personality.contains('深沉')) {
        return BackgroundTemplate.cormorantFishing;
      }
    }

    // 随机选择
    return availableTemplates[random.nextInt(availableTemplates.length)];
  }

  /// 生成默认图片（使用智能背景模板）
  static Future<File> generateDefaultImage({
    List<String>? interests,
    String? personality,
  }) async =>
      generateDefaultImageWithTemplate(
        interests: interests,
        personality: personality,
      );

  /// 生成带特定颜色的默认图片（保持向后兼容）
  static Future<File> generateDefaultImageWithColor(
    Color primaryColor, {
    List<String>? interests,
    String? personality,
  }) async {
    // 根据颜色选择相似的背景模板
    BackgroundTemplate? template;

    if (primaryColor.value == const Color(0xFF6B46C1).value) {
      template = BackgroundTemplate.traditionalView; // 紫色对应传统景观
    } else if (primaryColor.value == const Color(0xFF10B981).value) {
      template = BackgroundTemplate.dogInFlowers; // 绿色对应花丛
    } else if (primaryColor.value == const Color(0xFFF59E0B).value) {
      template = BackgroundTemplate.mountainSunset; // 橙色对应日落
    }

    return generateDefaultImageWithTemplate(
      template: template,
      interests: interests,
      personality: personality,
    );
  }

  /// 生成带背景模板的默认图片
  static Future<File> generateDefaultImageWithTemplate({
    BackgroundTemplate? template,
    List<String>? interests,
    String? personality,
  }) async {
    // 选择模板
    final selectedTemplate = template ??
        selectTemplateForUser(
          interests: interests,
          personality: personality,
        );

    // 尝试使用真实图片资源
    try {
      final realImageFile = await _generateFromRealImage(selectedTemplate);
      if (realImageFile != null) {
        return realImageFile;
      }
    } catch (e) {
      debugPrint('无法加载真实图片资源，使用程序化生成: $e');
    }

    // 回退到程序化生成
    return await _generateProgrammaticBackground(selectedTemplate);
  }

  /// 从真实图片资源生成背景
  static Future<File?> _generateFromRealImage(
      BackgroundTemplate template) async {
    try {
      // 加载asset图片
      final assetPath = _getBackgroundAssetPath(template);
      final byteData = await rootBundle.load(assetPath);
      final codec =
          await ui.instantiateImageCodec(byteData.buffer.asUint8List());
      final frame = await codec.getNextFrame();
      final image = frame.image;

      // 创建画布并绘制图片
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);

      // 计算缩放比例以适应目标尺寸
      final scaleX = _imageWidth / image.width;
      final scaleY = _imageHeight / image.height;
      final scale = math.max(scaleX, scaleY); // 保持宽高比，可能裁剪

      final scaledWidth = image.width * scale;
      final scaledHeight = image.height * scale;
      final offsetX = (_imageWidth - scaledWidth) / 2;
      final offsetY = (_imageHeight - scaledHeight) / 2;

      // 绘制背景图片
      canvas.drawImageRect(
        image,
        Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
        Rect.fromLTWH(offsetX, offsetY, scaledWidth, scaledHeight),
        Paint(),
      );

      // 添加文字覆盖层
      _drawTextOverlay(canvas);

      // 完成绘制
      final picture = recorder.endRecording();
      final finalImage = await picture.toImage(_imageWidth, _imageHeight);
      final finalByteData =
          await finalImage.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = finalByteData!.buffer.asUint8List();

      // 保存到应用文档目录
      final appDir = await getApplicationDocumentsDirectory();
      final imagesDir = Directory('${appDir.path}/images');
      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
      }

      final file = File(
          '${imagesDir.path}/default_bg_${template.name}_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(pngBytes);

      return file;
    } catch (e) {
      debugPrint('加载真实图片失败: $e');
      return null;
    }
  }

  /// 程序化生成背景（回退方案）
  static Future<File> _generateProgrammaticBackground(
      BackgroundTemplate template) async {
    // 创建画布
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    // 绘制背景模板
    _drawBackgroundTemplate(canvas, template);

    // 添加文字覆盖层
    _drawTextOverlay(canvas);

    // 完成绘制
    final picture = recorder.endRecording();
    final image = await picture.toImage(_imageWidth, _imageHeight);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final pngBytes = byteData!.buffer.asUint8List();

    // 保存到应用文档目录
    final appDir = await getApplicationDocumentsDirectory();
    final imagesDir = Directory('${appDir.path}/images');
    if (!await imagesDir.exists()) {
      await imagesDir.create(recursive: true);
    }

    final file = File(
        '${imagesDir.path}/default_bg_${template.name}_${DateTime.now().millisecondsSinceEpoch}.png');
    await file.writeAsBytes(pngBytes);

    return file;
  }

  /// 绘制背景模板
  static void _drawBackgroundTemplate(
      Canvas canvas, BackgroundTemplate template) {
    switch (template) {
      case BackgroundTemplate.dogInFlowers:
        _drawDogInFlowersBackground(canvas);
        break;
      case BackgroundTemplate.cormorantFishing:
        _drawCormorantFishingBackground(canvas);
        break;
      case BackgroundTemplate.traditionalView:
        _drawTraditionalViewBackground(canvas);
        break;
      case BackgroundTemplate.mountainSunset:
        _drawMountainSunsetBackground(canvas);
        break;
    }
  }

  /// 绘制花丛中的狗背景
  static void _drawDogInFlowersBackground(Canvas canvas) {
    final grassPaint = Paint()
      ..shader = ui.Gradient.linear(
        const Offset(0, 0),
        Offset(_imageWidth.toDouble(), _imageHeight.toDouble()),
        [
          const Color(0xFF7ED321).withOpacity(0.9),
          const Color(0xFF50E3C2).withOpacity(0.7),
          const Color(0xFF4A90E2).withOpacity(0.5),
        ],
        [0.0, 0.5, 1.0],
      );

    canvas.drawRect(
      Rect.fromLTWH(0, 0, _imageWidth.toDouble(), _imageHeight.toDouble()),
      grassPaint,
    );

    _drawFlowers(canvas);
  }

  /// 绘制鸬鹚捕鱼背景
  static void _drawCormorantFishingBackground(Canvas canvas) {
    final mistPaint = Paint()
      ..shader = ui.Gradient.linear(
        const Offset(0, 0),
        Offset(_imageWidth.toDouble(), _imageHeight.toDouble()),
        [
          const Color(0xFFFFE66D).withOpacity(0.8),
          const Color(0xFF4ECDC4).withOpacity(0.7),
          const Color(0xFF4A90E2).withOpacity(0.6),
        ],
        [0.0, 0.5, 1.0],
      );

    canvas.drawRect(
      Rect.fromLTWH(0, 0, _imageWidth.toDouble(), _imageHeight.toDouble()),
      mistPaint,
    );

    _drawMountainSilhouettes(canvas);
  }

  /// 绘制传统景观背景
  static void _drawTraditionalViewBackground(Canvas canvas) {
    final traditionalPaint = Paint()
      ..shader = ui.Gradient.linear(
        const Offset(0, 0),
        Offset(_imageWidth.toDouble(), _imageHeight.toDouble()),
        [
          const Color(0xFF8B4513).withOpacity(0.8),
          const Color(0xFFDEB887).withOpacity(0.7),
          const Color(0xFFF5DEB3).withOpacity(0.6),
        ],
        [0.0, 0.5, 1.0],
      );

    canvas.drawRect(
      Rect.fromLTWH(0, 0, _imageWidth.toDouble(), _imageHeight.toDouble()),
      traditionalPaint,
    );
  }

  /// 绘制山峦日落背景
  static void _drawMountainSunsetBackground(Canvas canvas) {
    final sunsetPaint = Paint()
      ..shader = ui.Gradient.linear(
        const Offset(0, 0),
        Offset(_imageWidth.toDouble(), _imageHeight.toDouble()),
        [
          const Color(0xFFFF6B6B).withOpacity(0.9),
          const Color(0xFFFFE66D).withOpacity(0.8),
          const Color(0xFF4ECDC4).withOpacity(0.6),
        ],
        [0.0, 0.3, 1.0],
      );

    canvas.drawRect(
      Rect.fromLTWH(0, 0, _imageWidth.toDouble(), _imageHeight.toDouble()),
      sunsetPaint,
    );

    _drawMountainSilhouettes(canvas);
  }

  /// 绘制文字覆盖层
  static void _drawTextOverlay(Canvas canvas) {
    final overlayPaint = Paint()..color = Colors.black.withOpacity(0.3);

    canvas.drawRect(
      Rect.fromLTWH(0, 0, _imageWidth.toDouble(), _imageHeight.toDouble()),
      overlayPaint,
    );

    // 移除"诗意瞬间"文字，只保留半透明覆盖层
  }

  /// 绘制花朵
  static void _drawFlowers(Canvas canvas) {
    final flowerPaint = Paint()
      ..color = const Color(0xFFFF6B6B).withOpacity(0.7)
      ..style = PaintingStyle.fill;

    final flowerPositions = [
      const Offset(80, 100),
      const Offset(150, 80),
      const Offset(250, 120),
      const Offset(320, 90),
      const Offset(180, 200),
    ];

    for (final pos in flowerPositions) {
      canvas.drawCircle(pos, 8, flowerPaint);
    }
  }

  /// 绘制山脉轮廓
  static void _drawMountainSilhouettes(Canvas canvas) {
    final mountainPaint = Paint()
      ..color = Colors.black.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, _imageHeight * 0.7)
      ..lineTo(_imageWidth * 0.2, _imageHeight * 0.5)
      ..lineTo(_imageWidth * 0.4, _imageHeight * 0.6)
      ..lineTo(_imageWidth * 0.6, _imageHeight * 0.4)
      ..lineTo(_imageWidth * 0.8, _imageHeight * 0.5)
      ..lineTo(_imageWidth.toDouble(), _imageHeight * 0.6)
      ..lineTo(_imageWidth.toDouble(), _imageHeight.toDouble())
      ..lineTo(0, _imageHeight.toDouble())
      ..close();

    canvas.drawPath(path, mountainPaint);
  }
}
