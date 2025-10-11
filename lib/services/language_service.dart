import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../languages/zh.dart';
import '../languages/en.dart';

/// 统一语言服务
/// 管理应用的语言设置和多语言功能
class LanguageService extends ChangeNotifier {
  static final LanguageService _instance = LanguageService._internal();
  factory LanguageService() => _instance;
  static LanguageService get to => _instance;
  LanguageService._internal();

  static const String _languageKey = 'app_language';
  String _currentLanguage = 'zh'; // 默认中文（初始化时会检测系统语言）

  /// 获取当前语言
  String getCurrentLanguage() {
    return _currentLanguage;
  }

  /// 设置语言
  Future<void> setLanguage(String languageCode) async {
    try {
      if (_currentLanguage != languageCode) {
        _currentLanguage = languageCode;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_languageKey, languageCode);
        notifyListeners(); // 通知监听者语言已改变
      }
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
        // 使用用户之前保存的语言设置
        _currentLanguage = savedLanguage;
        print('从本地存储加载语言设置: $_currentLanguage');
      } else {
        // 如果没有保存的语言设置，检测系统语言
        _currentLanguage = _detectSystemLanguage();
        print('检测到系统语言: $_currentLanguage');

        // 保存检测到的语言
        await prefs.setString(_languageKey, _currentLanguage);
      }

      notifyListeners();
    } catch (e) {
      print('初始化语言设置失败: $e');
      _currentLanguage = _detectSystemLanguage(); // 失败时使用系统语言
    }
  }

  /// 检测系统语言
  String _detectSystemLanguage() {
    try {
      // 获取系统语言
      final systemLocale = ui.PlatformDispatcher.instance.locale;
      final languageCode = systemLocale.languageCode.toLowerCase();

      print('系统语言代码: $languageCode');

      // 如果是中文相关的语言代码，返回 'zh'
      if (languageCode.startsWith('zh')) {
        return 'zh';
      }

      // 其他情况返回英文
      return 'en';
    } catch (e) {
      print('检测系统语言失败: $e，使用默认中文');
      return 'zh'; // 默认使用中文
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
