import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ai_poetry_card/models/poetry_card.dart';

// 平台类型枚举
enum PlatformType {
  douyin, // 抖音
  xiaohongshu, // 小红书
  weibo, // 微博
  pengyouquan, // 朋友圈
  shiju, // 诗句
}

// 字体类型枚举
enum FontFamily {
  system, // 系统默认字体
  jiangxiZhuokai, // 江西拙楷
  jiangchengLvdongsong, // 江城律动宋
}

class AppState extends ChangeNotifier {
  static const String _usedCountKey = 'used_count';
  static const String _isPremiumKey = 'is_premium';
  static const String _selectedStyleKey = 'selected_style';
  static const String _showQrCodeKey = 'show_qr_code';
  static const String _defaultPlatformKey = 'default_platform';
  static const String _showStyleOnCardKey = 'show_style_on_card';
  static const String _selectedFontKey = 'selected_font';

  // 用户状态
  bool _isPremium = false;
  int _usedCount = 0;
  PoetryStyle? _selectedStyle; // 改为nullable，允许未选中状态
  bool _showQrCode = false; // 默认不显示二维码
  PlatformType _defaultPlatform = PlatformType.pengyouquan; // 默认朋友圈
  bool _showStyleOnCard = false; // 默认不显示风格
  FontFamily _selectedFont = FontFamily.jiangxiZhuokai; // 默认江西拙楷

  // 限制设置
  static const int freeTrialLimit = 30; // 免费用户限制改为30次
  static const int premiumLimit = 999;

  // Getters
  bool get isPremium => _isPremium;
  int get usedCount => _usedCount;
  int get totalLimit => _isPremium ? premiumLimit : freeTrialLimit;
  int get remainingUsage => totalLimit - _usedCount;
  bool get canGenerate => _isPremium || _usedCount < freeTrialLimit;
  PoetryStyle? get selectedStyle => _selectedStyle; // nullable getter
  bool get showQrCode => _showQrCode;
  PlatformType get defaultPlatform => _defaultPlatform;
  bool get showStyleOnCard => _showStyleOnCard;
  FontFamily get selectedFont => _selectedFont;

  // 获取字体名称（null表示使用系统默认字体）
  String? get fontFamilyName {
    switch (_selectedFont) {
      case FontFamily.system:
        return null; // 系统默认字体
      case FontFamily.jiangxiZhuokai:
        return 'JiangxiZhuokai';
      case FontFamily.jiangchengLvdongsong:
        return 'JiangchengLvdongsong';
    }
  }

  AppState() {
    _loadSettings();
    _refreshVipStatus();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    _isPremium = prefs.getBool(_isPremiumKey) ?? false;
    _usedCount = prefs.getInt(_usedCountKey) ?? 0;
    _showQrCode = prefs.getBool(_showQrCodeKey) ?? false;
    _showStyleOnCard = prefs.getBool(_showStyleOnCardKey) ?? false;

    final styleStr = prefs.getString(_selectedStyleKey);
    if (styleStr != null && styleStr.isNotEmpty) {
      try {
        _selectedStyle = PoetryStyle.values.firstWhere(
          (e) => e.name == styleStr,
        );
      } catch (e) {
        _selectedStyle = null; // 如果找不到，设为null
      }
    } else {
      _selectedStyle = null; // 默认未选中
    }

    final platformStr = prefs.getString(_defaultPlatformKey);
    if (platformStr != null) {
      _defaultPlatform = PlatformType.values.firstWhere(
        (e) => e.name == platformStr,
        orElse: () => PlatformType.pengyouquan,
      );
    }

    final fontStr = prefs.getString(_selectedFontKey);
    if (fontStr != null) {
      _selectedFont = FontFamily.values.firstWhere(
        (e) => e.name == fontStr,
        orElse: () => FontFamily.jiangxiZhuokai,
      );
    }

    notifyListeners();
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isPremiumKey, _isPremium);
    await prefs.setInt(_usedCountKey, _usedCount);
    // 保存风格，如果是null则保存空字符串
    await prefs.setString(_selectedStyleKey, _selectedStyle?.name ?? '');
    await prefs.setBool(_showQrCodeKey, _showQrCode);
    await prefs.setString(_defaultPlatformKey, _defaultPlatform.name);
    await prefs.setBool(_showStyleOnCardKey, _showStyleOnCard);
    await prefs.setString(_selectedFontKey, _selectedFont.name);
  }

  Future<void> incrementUsage() async {
    if (canGenerate) {
      _usedCount++;
      await _saveSettings();
      notifyListeners();
    }
  }

  Future<void> setPremium(bool isPremium) async {
    _isPremium = isPremium;
    await _saveSettings();
    notifyListeners();
  }

  Future<void> setSelectedStyle(PoetryStyle? style) async {
    _selectedStyle = style;
    await _saveSettings();
    notifyListeners();
  }

  Future<void> setShowQrCode(bool show) async {
    _showQrCode = show;
    await _saveSettings();
    notifyListeners();
  }

  Future<void> setDefaultPlatform(PlatformType platform) async {
    _defaultPlatform = platform;
    await _saveSettings();
    notifyListeners();
  }

  Future<void> setShowStyleOnCard(bool show) async {
    _showStyleOnCard = show;
    await _saveSettings();
    notifyListeners();
  }

  Future<void> setSelectedFont(FontFamily font) async {
    _selectedFont = font;
    await _saveSettings();
    notifyListeners();
  }

  /// 获取平台的显示名称
  static String getPlatformDisplayName(PlatformType platform) {
    switch (platform) {
      case PlatformType.douyin:
        return '抖音';
      case PlatformType.xiaohongshu:
        return '小红书';
      case PlatformType.weibo:
        return '微博';
      case PlatformType.pengyouquan:
        return '朋友圈';
      case PlatformType.shiju:
        return '诗句';
    }
  }

  /// 获取字体的显示名称
  static String getFontDisplayName(FontFamily font) {
    switch (font) {
      case FontFamily.system:
        return '系统默认';
      case FontFamily.jiangxiZhuokai:
        return '江西拙楷';
      case FontFamily.jiangchengLvdongsong:
        return '江城律动宋';
    }
  }

  /// 刷新 VIP 状态
  Future<void> _refreshVipStatus() async {
    try {
      final isVip = false;
      if (_isPremium != isVip) {
        _isPremium = isVip;
        await _savePremiumStatus();
        notifyListeners();
      }
    } catch (e) {
      print('刷新 VIP 状态失败: $e');
    }
  }

  /// 手动刷新 VIP 状态
  Future<void> refreshVipStatus() async {
    await _refreshVipStatus();
  }

  /// 保存会员状态
  Future<void> _savePremiumStatus() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isPremiumKey, _isPremium);
  }
}
