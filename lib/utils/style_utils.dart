import '../models/poetry_card.dart';
import 'package:ai_poetry_card/services/language_service.dart';

/// 风格工具类 - 统一管理风格相关的显示和操作
class StyleUtils {
  /// 获取风格的显示名称
  static String getStyleDisplayName(PoetryStyle style) {
    switch (style) {
      case PoetryStyle.modernPoetic:
        return LanguageService.to.getText('现代诗意');
      case PoetryStyle.classicalElegant:
        return LanguageService.to.getText('古风雅韵');
      case PoetryStyle.humorousPlayful:
        return LanguageService.to.getText('幽默俏皮');
      case PoetryStyle.warmLiterary:
        return LanguageService.to.getText('文艺暖心');
      case PoetryStyle.minimalTags:
        return LanguageService.to.getText('极简摘要');
      case PoetryStyle.sciFiImagination:
        return LanguageService.to.getText('科幻想象');
      case PoetryStyle.deepPhilosophical:
        return LanguageService.to.getText('深沉哲思');
      case PoetryStyle.blindBox:
        return LanguageService.to.getText('盲盒');
    }
  }

  /// 获取所有风格选项的配置数据
  static List<Map<String, dynamic>> getStyleOptions() => [
        {
          'style': PoetryStyle.blindBox,
          'title': getStyleDisplayName(PoetryStyle.blindBox),
        },
        {
          'style': PoetryStyle.modernPoetic,
          'title': getStyleDisplayName(PoetryStyle.modernPoetic),
        },
        {
          'style': PoetryStyle.classicalElegant,
          'title': getStyleDisplayName(PoetryStyle.classicalElegant),
        },
        {
          'style': PoetryStyle.humorousPlayful,
          'title': getStyleDisplayName(PoetryStyle.humorousPlayful),
        },
        {
          'style': PoetryStyle.warmLiterary,
          'title': getStyleDisplayName(PoetryStyle.warmLiterary),
        },
        {
          'style': PoetryStyle.minimalTags,
          'title': getStyleDisplayName(PoetryStyle.minimalTags),
        },
        {
          'style': PoetryStyle.sciFiImagination,
          'title': getStyleDisplayName(PoetryStyle.sciFiImagination),
        },
        {
          'style': PoetryStyle.deepPhilosophical,
          'title': getStyleDisplayName(PoetryStyle.deepPhilosophical),
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
