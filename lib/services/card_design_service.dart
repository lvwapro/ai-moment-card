import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:ai_poetry_card/models/poetry_card.dart';

class CardDesignService {
  // 模拟卡片设计服务
  // 在实际应用中，这里会分析图片的色调、构图等来选择最佳模板

  Future<CardTemplate> selectBestTemplate(File image, String poetry) async {
    // 模拟分析延迟
    await Future.delayed(const Duration(milliseconds: 500));

    // 根据文案长度和风格选择模板
    return _selectTemplateByContent(poetry);
  }

  CardTemplate _selectTemplateByContent(String poetry) {
    final random = Random();

    // 根据文案长度选择模板
    if (poetry.length <= 10) {
      // 短文案适合极简模板
      return CardTemplate.minimal;
    } else if (poetry.length <= 20) {
      // 中等长度文案适合优雅或浪漫模板
      final templates = [CardTemplate.elegant, CardTemplate.romantic];
      return templates[random.nextInt(templates.length)];
    } else {
      // 长文案适合复古或自然模板
      final templates = [CardTemplate.vintage, CardTemplate.nature];
      return templates[random.nextInt(templates.length)];
    }
  }

  // 分析图片色调（模拟）
  Future<Color> analyzeImageColor(File image) async {
    // 在实际应用中，这里会使用图像处理库来分析图片的主色调
    await Future.delayed(const Duration(milliseconds: 300));

    // 模拟返回随机颜色
    final colors = [
      const Color(0xFF6B46C1), // 紫色
      const Color(0xFF10B981), // 绿色
      const Color(0xFFF59E0B), // 橙色
      const Color(0xFFEF4444), // 红色
      const Color(0xFF3B82F6), // 蓝色
    ];

    return colors[Random().nextInt(colors.length)];
  }

  // 获取模板的默认配置
  Map<String, dynamic> getTemplateConfig(CardTemplate template) {
    switch (template) {
      case CardTemplate.minimal:
        return {
          'backgroundColor': const Color(0xFFFFFFFF),
          'textColor': const Color(0xFF1F2937),
          'fontSize': 18.0,
          'fontWeight': FontWeight.w400,
          'padding': 24.0,
          'borderRadius': 8.0,
        };
      case CardTemplate.elegant:
        return {
          'backgroundColor': const Color(0xFFF8FAFC),
          'textColor': const Color(0xFF374151),
          'fontSize': 20.0,
          'fontWeight': FontWeight.w500,
          'padding': 32.0,
          'borderRadius': 16.0,
        };
      case CardTemplate.romantic:
        return {
          'backgroundColor': const Color(0xFFFDF2F8),
          'textColor': const Color(0xFF831843),
          'fontSize': 19.0,
          'fontWeight': FontWeight.w500,
          'padding': 28.0,
          'borderRadius': 20.0,
        };
      case CardTemplate.vintage:
        return {
          'backgroundColor': const Color(0xFFFEF3C7),
          'textColor': const Color(0xFF92400E),
          'fontSize': 17.0,
          'fontWeight': FontWeight.w600,
          'padding': 20.0,
          'borderRadius': 12.0,
        };
      case CardTemplate.nature:
        return {
          'backgroundColor': const Color(0xFFECFDF5),
          'textColor': const Color(0xFF065F46),
          'fontSize': 18.0,
          'fontWeight': FontWeight.w500,
          'padding': 24.0,
          'borderRadius': 16.0,
        };
      case CardTemplate.urban:
        return {
          'backgroundColor': const Color(0xFFF1F5F9),
          'textColor': const Color(0xFF1E293B),
          'fontSize': 16.0,
          'fontWeight': FontWeight.w600,
          'padding': 20.0,
          'borderRadius': 8.0,
        };
    }
  }

  // 获取模板名称
  String getTemplateName(CardTemplate template) {
    switch (template) {
      case CardTemplate.minimal:
        return '极简';
      case CardTemplate.elegant:
        return '优雅';
      case CardTemplate.romantic:
        return '浪漫';
      case CardTemplate.vintage:
        return '复古';
      case CardTemplate.nature:
        return '自然';
      case CardTemplate.urban:
        return '都市';
    }
  }

  // 获取模板描述
  String getTemplateDescription(CardTemplate template) {
    switch (template) {
      case CardTemplate.minimal:
        return '简洁大方，突出内容';
      case CardTemplate.elegant:
        return '优雅精致，彰显品味';
      case CardTemplate.romantic:
        return '浪漫温馨，充满爱意';
      case CardTemplate.vintage:
        return '复古怀旧，时光沉淀';
      case CardTemplate.nature:
        return '自然清新，回归本真';
      case CardTemplate.urban:
        return '现代都市，时尚前卫';
    }
  }
}
