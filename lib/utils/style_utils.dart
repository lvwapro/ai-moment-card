import 'package:flutter/material.dart';
import '../models/poetry_card.dart';
import 'localization_extension.dart';

/// 风格工具类 - 统一管理风格相关的显示和操作
class StyleUtils {
  /// 获取风格的中文显示名称
  static String getStyleDisplayName(BuildContext context, PoetryStyle style) {
    switch (style) {
      case PoetryStyle.modernPoetic:
        return context.l10n('现代诗意');
      case PoetryStyle.classicalElegant:
        return context.l10n('古风雅韵');
      case PoetryStyle.humorousPlayful:
        return context.l10n('幽默俏皮');
      case PoetryStyle.warmLiterary:
        return context.l10n('文艺暖心');
      case PoetryStyle.minimalTags:
        return context.l10n('极简摘要');
      case PoetryStyle.sciFiImagination:
        return context.l10n('科幻想象');
      case PoetryStyle.deepPhilosophical:
        return context.l10n('深沉哲思');
      case PoetryStyle.blindBox:
        return context.l10n('盲盒');
    }
  }

  /// 获取所有风格选项的配置数据
  static List<Map<String, dynamic>> getStyleOptions(BuildContext context) => [
        {
          'style': PoetryStyle.blindBox,
          'title': context.l10n('盲盒'),
        },
        {
          'style': PoetryStyle.modernPoetic,
          'title': context.l10n('现代诗意'),
        },
        {
          'style': PoetryStyle.classicalElegant,
          'title': context.l10n('古风雅韵'),
        },
        {
          'style': PoetryStyle.humorousPlayful,
          'title': context.l10n('幽默俏皮'),
        },
        {
          'style': PoetryStyle.warmLiterary,
          'title': context.l10n('文艺暖心'),
        },
        {
          'style': PoetryStyle.minimalTags,
          'title': context.l10n('极简摘要'),
        },
        {
          'style': PoetryStyle.sciFiImagination,
          'title': context.l10n('科幻想象'),
        },
        {
          'style': PoetryStyle.deepPhilosophical,
          'title': context.l10n('深沉哲思'),
        },
      ];

  /// 将风格选项按行分组（每行3个）
  static List<List<Map<String, dynamic>>> groupStylesIntoRows(
    List<Map<String, dynamic>> styles,
  ) {
    List<List<Map<String, dynamic>>> rows = [];
    for (int i = 0; i < styles.length; i += 3) {
      List<Map<String, dynamic>> row = styles.skip(i).take(3).toList();
      // 如果最后一行不足3个，用空占位符填充
      while (row.length < 3) {
        row.add({});
      }
      rows.add(row);
    }
    return rows;
  }
}
