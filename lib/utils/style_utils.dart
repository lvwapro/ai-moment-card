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
      case PoetryStyle.romanticDream:
        return LanguageService.to.getText('浪漫梦幻');
      case PoetryStyle.freshNatural:
        return LanguageService.to.getText('清新自然');
      case PoetryStyle.urbanFashion:
        return LanguageService.to.getText('都市时尚');
      case PoetryStyle.nostalgicRetro:
        return LanguageService.to.getText('怀旧复古');
      case PoetryStyle.motivationalPositive:
        return LanguageService.to.getText('励志正能量');
      case PoetryStyle.mysteriousDark:
        return LanguageService.to.getText('神秘暗黑');
      case PoetryStyle.cuteSweet:
        return LanguageService.to.getText('可爱甜美');
      case PoetryStyle.coolEdgy:
        return LanguageService.to.getText('酷炫个性');
    }
  }

  /// 获取所有风格（完整列表）
  static List<PoetryStyle> getAllStyles() => PoetryStyle.values;

  /// 获取所有风格选项的配置数据
  static List<Map<String, dynamic>> getStyleOptions() {
    return getAllStyles()
        .map((style) => {
              'style': style,
              'title': getStyleDisplayName(style),
            })
        .toList();
  }

  /// 随机获取指定数量的风格（用于首页换一批）
  /// 第一个始终是默认风格（现代诗意），其余随机
  static List<Map<String, dynamic>> getRandomStyles(int count) {
    final allStyles = getAllStyles();
    // 移除默认风格
    final otherStyles =
        allStyles.where((style) => style != PoetryStyle.modernPoetic).toList();
    // 打乱其他风格
    otherStyles.shuffle();
    // 第一个是默认风格，其余是随机风格
    final selected = [PoetryStyle.modernPoetic, ...otherStyles.take(count - 1)];

    return selected
        .map((style) => {
              'style': style,
              'title': getStyleDisplayName(style),
            })
        .toList();
  }

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
