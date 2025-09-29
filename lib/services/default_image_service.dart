import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class DefaultImageService {
  static const int _imageWidth = 400;
  static const int _imageHeight = 400;

  /// 生成默认图片
  static Future<File> generateDefaultImage({
    List<String>? interests,
    String? personality,
  }) async {
    return _generateSimpleBackground();
  }

  /// 生成简单的默认背景
  static Future<File> _generateSimpleBackground() async {
    // 创建画布
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    // 绘制简单的渐变背景
    final backgroundPaint = Paint()
      ..shader = ui.Gradient.linear(
        const Offset(0, 0),
        Offset(_imageWidth.toDouble(), _imageHeight.toDouble()),
        [
          const Color(0xFF4A90E2).withOpacity(0.8),
          const Color(0xFF50E3C2).withOpacity(0.6),
          const Color(0xFF7ED321).withOpacity(0.4),
        ],
        [0.0, 0.5, 1.0],
      );

    canvas.drawRect(
      Rect.fromLTWH(0, 0, _imageWidth.toDouble(), _imageHeight.toDouble()),
      backgroundPaint,
    );

    // 添加半透明覆盖层
    final overlayPaint = Paint()..color = Colors.black.withOpacity(0.2);
    canvas.drawRect(
      Rect.fromLTWH(0, 0, _imageWidth.toDouble(), _imageHeight.toDouble()),
      overlayPaint,
    );

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
      '${imagesDir.path}/default_bg_${DateTime.now().millisecondsSinceEpoch}.png',
    );
    await file.writeAsBytes(pngBytes);

    return file;
  }
}
