import 'package:flutter/material.dart';
import '../languages/zh.dart';
import '../languages/en.dart';

/// 多语言扩展
/// 为BuildContext添加便捷的多语言方法
extension LocalizationExtension on BuildContext {
  /// 获取本地化文本
  /// 直接传入中文文本，自动根据语言环境返回对应翻译
  String l10n(String chineseText) {
    final locale = Localizations.localeOf(this);
    if (locale.languageCode == 'zh') {
      return ChineseTranslations.getText(chineseText);
    } else {
      return EnglishTranslations.getText(chineseText);
    }
  }

  /// 检查是否为中文环境
  bool get isChinese {
    return Localizations.localeOf(this).languageCode == 'zh';
  }

  /// 获取当前语言环境
  Locale get currentLocale {
    return Localizations.localeOf(this);
  }
}
