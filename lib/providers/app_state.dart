import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/vip_service.dart';
import '../services/language_service.dart';

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
  static const String _selectedMoodTagKey = 'selected_mood_tag';
  static const String _showQrCodeKey = 'show_qr_code';
  static const String _defaultPlatformKey = 'default_platform';
  static const String _showMoodTagOnCardKey = 'show_mood_tag_on_card';
  static const String _selectedFontKey = 'selected_font';

  // 用户状态
  bool _isPremium = false;
  int _usedCount = 0;
  List<String> _selectedMoodTags = []; // 选中的情绪标签列表
  bool _showQrCode = true; // 默认显示二维码
  PlatformType _defaultPlatform = PlatformType.pengyouquan; // 默认朋友圈
  bool _showMoodTagOnCard = true; // 默认显示情绪标签
  FontFamily _selectedFont = FontFamily.system; // 默认系统字体

  // 限制设置
  static const int freeTrialLimit = 30; // 免费用户限制改为30次
  static const int premiumLimit = 999;

  // Getters
  bool get isPremium => _isPremium;
  int get usedCount => _usedCount;
  int get totalLimit => _isPremium ? premiumLimit : freeTrialLimit;
  int get remainingUsage => totalLimit - _usedCount;
  bool get canGenerate => _isPremium || _usedCount < freeTrialLimit;
  List<String> get selectedMoodTags => _selectedMoodTags; // 情绪标签列表 getter
  bool get showQrCode => _showQrCode;
  PlatformType get defaultPlatform => _defaultPlatform;
  bool get showMoodTagOnCard => _showMoodTagOnCard; // 显示情绪标签 getter
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
    _showQrCode = prefs.getBool(_showQrCodeKey) ?? true;
    _showMoodTagOnCard = prefs.getBool(_showMoodTagOnCardKey) ?? true;

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
        orElse: () => FontFamily.system,
      );
    }

    final moodTagStr = prefs.getString(_selectedMoodTagKey);
    _selectedMoodTags = moodTagStr != null && moodTagStr.isNotEmpty
        ? moodTagStr.split(',')
        : [];

    notifyListeners();
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isPremiumKey, _isPremium);
    await prefs.setInt(_usedCountKey, _usedCount);
    await prefs.setString(_selectedMoodTagKey, _selectedMoodTags.join(','));
    await prefs.setBool(_showQrCodeKey, _showQrCode);
    await prefs.setString(_defaultPlatformKey, _defaultPlatform.name);
    await prefs.setBool(_showMoodTagOnCardKey, _showMoodTagOnCard);
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

  Future<void> setSelectedMoodTags(List<String> tags) async {
    _selectedMoodTags = tags;
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

  Future<void> setShowMoodTagOnCard(bool show) async {
    _showMoodTagOnCard = show;
    await _saveSettings();
    notifyListeners();
  }

  Future<void> setSelectedFont(FontFamily font) async {
    _selectedFont = font;
    await _saveSettings();
    notifyListeners();
  }

  /// 获取平台的显示名称
  static String getPlatformDisplayName(
      PlatformType platform, BuildContext context) {
    switch (platform) {
      case PlatformType.douyin:
        return context.l10n('抖音');
      case PlatformType.xiaohongshu:
        return context.l10n('小红书');
      case PlatformType.weibo:
        return context.l10n('微博');
      case PlatformType.pengyouquan:
        return context.l10n('朋友圈');
      case PlatformType.shiju:
        return context.l10n('诗句');
    }
  }

  /// 获取字体的显示名称
  static String getFontDisplayName(FontFamily font, BuildContext context) {
    switch (font) {
      case FontFamily.system:
        return context.l10n('系统默认');
      case FontFamily.jiangxiZhuokai:
        return context.l10n('江西拙楷');
      case FontFamily.jiangchengLvdongsong:
        return context.l10n('江城律动宋');
    }
  }

  /// 刷新 VIP 状态
  Future<void> _refreshVipStatus() async {
    try {
      // 导入VipService
      final vipService = VipService();
      final vipStatus = await vipService.refreshVipStatus();

      if (vipStatus != null) {
        final isVip = vipStatus.isPremium;
        if (_isPremium != isVip) {
          _isPremium = isVip;
          await _savePremiumStatus();
          notifyListeners();
          print('✅ VIP状态已更新: ${isVip ? "Premium" : "Free"}');
        }
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
