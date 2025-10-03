import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../languages/zh.dart';
import '../languages/en.dart';

/// 统一语言服务
/// 管理应用的语言设置和多语言功能
class LanguageService {
  static final LanguageService _instance = LanguageService._internal();
  factory LanguageService() => _instance;
  static LanguageService get to => _instance;
  LanguageService._internal();

  static const String _languageKey = 'app_language';
  String _currentLanguage = 'en'; // 默认英语

  /// 获取当前语言
  String getCurrentLanguage() {
    return _currentLanguage;
  }

  /// 设置语言
  Future<void> setLanguage(String languageCode) async {
    try {
      _currentLanguage = languageCode;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, languageCode);
      print('语言已设置为: $languageCode');
    } catch (e) {
      print('设置语言失败: $e');
    }
  }

  /// 初始化语言设置
  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLanguage = prefs.getString(_languageKey);
      if (savedLanguage != null && savedLanguage.isNotEmpty) {
        _currentLanguage = savedLanguage;
        print('从本地存储加载语言设置: $_currentLanguage');
      } else {
        // 如果没有保存的语言设置，使用系统默认语言
        _currentLanguage = 'en'; // 可以根据需要修改为系统语言检测
        print('使用默认语言设置: $_currentLanguage');
      }
    } catch (e) {
      print('初始化语言设置失败: $e');
      _currentLanguage = 'en'; // 失败时使用默认语言
    }
  }

  /// 检查是否为中文
  bool get isChinese => _currentLanguage == 'zh';

  /// 检查是否为英文
  bool get isEnglish => _currentLanguage == 'en';

  /// 获取本地化文本
  /// 直接传入中文文本，自动根据当前语言设置返回对应翻译
  String getText(String chineseText) {
    if (_currentLanguage == 'zh') {
      return ChineseTranslations.getText(chineseText);
    } else {
      return EnglishTranslations.getText(chineseText);
    }
  }

  /// 获取当前语言环境
  Locale get currentLocale {
    return Locale(_currentLanguage);
  }
}

/// 多语言扩展
/// 为BuildContext添加便捷的多语言方法
extension LocalizationExtension on BuildContext {
  /// 获取本地化文本
  /// 直接传入中文文本，自动根据语言环境返回对应翻译
  String l10n(String chineseText) {
    return LanguageService.to.getText(chineseText);
  }

  /// 检查是否为中文环境
  bool get isChinese {
    return LanguageService.to.isChinese;
  }

  /// 获取当前语言环境
  Locale get currentLocale {
    return LanguageService.to.currentLocale;
  }
}