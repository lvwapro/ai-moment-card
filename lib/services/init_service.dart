import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'network_service.dart';
import 'revenue_cat_service.dart';
import 'vip_service.dart';

class InitService {
  static final NetworkService _networkService = NetworkService();
  static final RevenueCatService _revenueCatService = RevenueCatService();
  static final VipService _vipService = VipService();

  /// 应用初始化 - 只调用用户初始化
  static Future<Map<String, dynamic>?> initApp() async {
    try {
      print('开始应用初始化...');

      // 1. 首先生成Token并设置认证信息
      final authSuccess = await _networkService.initializeAuth();
      if (!authSuccess) {
        print('认证初始化失败，无法继续初始化');
        return null;
      }

      // 2. 调用用户初始化API
      final userInitResult = await initUser();
      if (userInitResult == null) {
        print('用户初始化失败，无法继续初始化');
        return null;
      }

      // 3. 保存用户信息到本地
      await _saveUserInfo(userInitResult);

      // 4. 异步初始化 RevenueCat，不阻塞主流程
      _initRevenueCatAsync();

      // 5. 异步刷新会员状态
      _refreshVipStatusAsync();

      return userInitResult;
    } catch (e) {
      print('应用初始化异常: $e');
      return null;
    }
  }

  /// 异步初始化 RevenueCat，失败不影响主流程
  static void _initRevenueCatAsync() async {
    try {
      final deviceId = await _networkService.getDeviceId();
      await _revenueCatService.initPurchaseSDK(deviceId);
      print('RevenueCat 异步初始化成功');
    } catch (e) {
      print('RevenueCat 异步初始化失败: $e');
      // 失败不影响主流程，继续执行
    }
  }

  /// 异步刷新会员状态
  static void _refreshVipStatusAsync() async {
    try {
      await _vipService.refreshVipStatus();
    } catch (e) {
      print('会员状态刷新失败: $e');
      // 失败不影响主流程
    }
  }

  /// 用户初始化
  static Future<Map<String, dynamic>?> initUser() async {
    try {
      print('开始用户初始化...');

      // 获取设备信息
      final bundleId = await _networkService.getBundleId();
      final deviceId = await _networkService.getDeviceId();

      print('设备信息: bundleId=$bundleId, deviceId=$deviceId');
      print('请求体中的deviceId: $deviceId');
      print('Header中的device-id: $deviceId (通过拦截器自动添加)');

      // 准备请求体
      final requestBody = {
        'bundleId': bundleId,
        'deviceId': deviceId,
      };

      print('发送用户初始化请求: $requestBody');

      // 发送POST请求
      final response =
          await _networkService.post('/api/user/init', data: requestBody);

      print('用户初始化响应状态码: ${response.statusCode}');
      print('用户初始化响应数据: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        print('用户初始化成功: $data');
        return data;
      } else {
        print('用户初始化失败: ${response.statusCode}');
        print('错误响应: ${response.data}');
        return null;
      }
    } catch (e) {
      print('用户初始化异常: $e');
      if (e.toString().contains('DioException')) {
        print('网络请求异常详情: $e');
      }
      return null;
    }
  }

  /// 保存用户信息到本地
  static Future<void> _saveUserInfo(Map<String, dynamic> userInfo) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_info', jsonEncode(userInfo));
      print('用户信息已保存到本地');
    } catch (e) {
      print('保存用户信息失败: $e');
    }
  }

  /// 获取用户信息
  static Future<Map<String, dynamic>?> getUserInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userInfoString = prefs.getString('user_info');
      if (userInfoString != null) {
        return jsonDecode(userInfoString) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('获取用户信息失败: $e');
      return null;
    }
  }
}
