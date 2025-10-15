import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ai_poetry_card/models/user_profile.dart';

class UserProfileService extends ChangeNotifier {
  static const String _profileKey = 'user_profile_v2';
  UserProfile? _currentProfile;

  UserProfile? get currentProfile => _currentProfile;
  bool get hasProfile => _currentProfile != null;
  bool get isProfileComplete => _currentProfile?.isComplete ?? false;

  UserProfileService() {
    _loadProfile();
    // 如果没有配置文件，创建一个临时的默认配置
    _createDefaultProfileIfNeeded();
  }

  /// 加载用户信息
  Future<void> _loadProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final profileJson = prefs.getString(_profileKey);

      if (profileJson != null) {
        final profileData = json.decode(profileJson) as Map<String, dynamic>;
        _currentProfile = UserProfile.fromJson(profileData);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('加载用户信息失败: $e');
    }
  }

  /// 保存用户信息
  Future<void> saveProfile(UserProfile profile) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final profileJson = json.encode(profile.toJson());

      await prefs.setString(_profileKey, profileJson);
      _currentProfile = profile;
      notifyListeners();
    } catch (e) {
      debugPrint('保存用户信息失败: $e');
      rethrow;
    }
  }

  /// 更新用户信息
  Future<void> updateProfile(UserProfile profile) async {
    final updatedProfile = profile.copyWith(
      updatedAt: DateTime.now(),
    );
    await saveProfile(updatedProfile);
  }

  /// 清除用户信息
  Future<void> clearProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_profileKey);
      _currentProfile = null;
      notifyListeners();
    } catch (e) {
      debugPrint('清除用户信息失败: $e');
    }
  }

  /// 获取用户描述文本（用于AI生成）
  String getUserDescription() {
    return _currentProfile?.userDescription ?? '';
  }

  /// 获取建议的文案风格
  List<String> getSuggestedStyles() {
    return _currentProfile?.suggestedStyles ?? ['现代诗意', '盲盒'];
  }

  /// 创建默认用户配置（临时解决方案）
  void _createDefaultProfileIfNeeded() {
    if (_currentProfile == null) {
      // 创建一个临时的默认用户配置
      _currentProfile = UserProfile(
        id: 'default_user_${DateTime.now().millisecondsSinceEpoch}',
        age: 25,
        gender: Gender.other,
        personalityTypes: [
          PersonalityType.artistic,
          PersonalityType.extroverted
        ],
        interests: ['摄影', '旅行'],
        occupation: '自由职业',
        location: '北京',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      // 异步保存默认配置
      saveProfile(_currentProfile!);
    }
  }
}
