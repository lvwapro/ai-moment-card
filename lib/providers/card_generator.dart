import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:ai_poetry_card/models/poetry_card.dart';
import 'package:ai_poetry_card/services/ai_poetry_service.dart';
import 'package:ai_poetry_card/services/card_design_service.dart';

class CardGenerator extends ChangeNotifier {
  final AIPoetryService _poetryService = AIPoetryService();
  final CardDesignService _designService = CardDesignService();

  bool _isGenerating = false;
  String? _currentPoetry;
  CardTemplate? _selectedTemplate;

  bool get isGenerating => _isGenerating;
  String? get currentPoetry => _currentPoetry;
  CardTemplate? get selectedTemplate => _selectedTemplate;

  Future<PoetryCard> generateCard(File image, PoetryStyle style, {String? userDescription}) async {
    _isGenerating = true;
    notifyListeners();

    try {
      // 1. 生成AI文案
      final poetry = await _poetryService.generatePoetry(image, style, userDescription: userDescription);
      _currentPoetry = poetry;

      // 2. 分析图片并选择最佳模板
      final template = await _designService.selectBestTemplate(image, poetry);
      _selectedTemplate = template;

      // 3. 生成二维码数据
      final qrCodeData = _generateQrCodeData(poetry);

      // 4. 创建卡片对象
      final card = PoetryCard(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        image: image,
        poetry: poetry,
        style: style,
        template: template,
        createdAt: DateTime.now(),
        qrCodeData: qrCodeData,
        metadata: {
          'generatedAt': DateTime.now().toIso8601String(),
          'imageSize': '${image.lengthSync()}',
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

  void clearCurrentGeneration() {
    _currentPoetry = null;
    _selectedTemplate = null;
    notifyListeners();
  }
}
