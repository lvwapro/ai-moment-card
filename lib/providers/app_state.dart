import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ai_poetry_card/models/poetry_card.dart';

class AppState extends ChangeNotifier {
  static const String _dailyUsageKey = 'daily_usage';
  static const String _lastUsageDateKey = 'last_usage_date';
  static const String _isPremiumKey = 'is_premium';
  static const String _selectedStyleKey = 'selected_style';
  static const String _showQrCodeKey = 'show_qr_code';

  // 用户状态
  bool _isPremium = false;
  int _dailyUsage = 0;
  DateTime? _lastUsageDate;
  PoetryStyle _selectedStyle = PoetryStyle.blindBox;
  bool _showQrCode = true;

  // 限制设置
  static const int freeDailyLimit = 3;
  static const int premiumDailyLimit = 999;

  // Getters
  bool get isPremium => _isPremium;
  int get dailyUsage => _dailyUsage;
  int get dailyLimit => _isPremium ? premiumDailyLimit : freeDailyLimit;
  int get remainingUsage => dailyLimit - _dailyUsage;
  bool get canGenerate => remainingUsage > 0;
  PoetryStyle get selectedStyle => _selectedStyle;
  bool get showQrCode => _showQrCode;

  AppState() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    _isPremium = prefs.getBool(_isPremiumKey) ?? false;
    _dailyUsage = prefs.getInt(_dailyUsageKey) ?? 0;
    _showQrCode = prefs.getBool(_showQrCodeKey) ?? true;

    final lastDateStr = prefs.getString(_lastUsageDateKey);
    if (lastDateStr != null) {
      _lastUsageDate = DateTime.parse(lastDateStr);
    }

    final styleStr = prefs.getString(_selectedStyleKey);
    if (styleStr != null) {
      _selectedStyle = PoetryStyle.values.firstWhere(
        (e) => e.name == styleStr,
        orElse: () => PoetryStyle.blindBox,
      );
    }

    // 检查是否需要重置每日使用次数
    _checkAndResetDailyUsage();

    notifyListeners();
  }

  void _checkAndResetDailyUsage() {
    final now = DateTime.now();
    if (_lastUsageDate == null ||
        now.day != _lastUsageDate!.day ||
        now.month != _lastUsageDate!.month ||
        now.year != _lastUsageDate!.year) {
      _dailyUsage = 0;
      _lastUsageDate = now;
      _saveSettings();
    }
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isPremiumKey, _isPremium);
    await prefs.setInt(_dailyUsageKey, _dailyUsage);
    await prefs.setString(
        _lastUsageDateKey, _lastUsageDate?.toIso8601String() ?? '');
    await prefs.setString(_selectedStyleKey, _selectedStyle.name);
    await prefs.setBool(_showQrCodeKey, _showQrCode);
  }

  Future<void> incrementUsage() async {
    if (canGenerate) {
      _dailyUsage++;
      _lastUsageDate = DateTime.now();
      await _saveSettings();
      notifyListeners();
    }
  }

  Future<void> setPremium(bool isPremium) async {
    _isPremium = isPremium;
    await _saveSettings();
    notifyListeners();
  }

  Future<void> setSelectedStyle(PoetryStyle style) async {
    _selectedStyle = style;
    await _saveSettings();
    notifyListeners();
  }

  Future<void> setShowQrCode(bool show) async {
    _showQrCode = show;
    await _saveSettings();
    notifyListeners();
  }

  String getStyleDisplayName(PoetryStyle style) {
    switch (style) {
      case PoetryStyle.modernPoetic:
        return '现代诗意';
      case PoetryStyle.classicalElegant:
        return '古风雅韵';
      case PoetryStyle.humorousPlayful:
        return '幽默俏皮';
      case PoetryStyle.warmLiterary:
        return '文艺暖心';
      case PoetryStyle.minimalTags:
        return '极简摘要';
      case PoetryStyle.sciFiImagination:
        return '科幻想象';
      case PoetryStyle.deepPhilosophical:
        return '深沉哲思';
      case PoetryStyle.blindBox:
        return '盲盒';
    }
  }

  String getStyleDescription(PoetryStyle style) {
    switch (style) {
      case PoetryStyle.modernPoetic:
        return '空灵抽象，富有意象和哲思';
      case PoetryStyle.classicalElegant:
        return '古典诗词韵律，典雅有文化底蕴';
      case PoetryStyle.humorousPlayful:
        return '网络热梗，轻松有趣';
      case PoetryStyle.warmLiterary:
        return '治愈系语录，温暖细腻有共鸣';
      case PoetryStyle.minimalTags:
        return '极简标签，干净版面';
      case PoetryStyle.sciFiImagination:
        return '科幻视角，未来感宏大叙事';
      case PoetryStyle.deepPhilosophical:
        return '引发思考，理性深沉';
      case PoetryStyle.blindBox:
        return '随机惊喜，未知体验';
    }
  }
}
