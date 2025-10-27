import 'dart:io';
import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import 'vip_service.dart';

/// RevenueCat 购买系统服务
class RevenueCatService {
  static final RevenueCatService _instance = RevenueCatService._internal();
  factory RevenueCatService() => _instance;
  RevenueCatService._internal();

  final VipService _vipService = VipService();

  // 初始化状态
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  /// 初始化 RevenueCat 购买系统
  /// [uid] 用户ID，从外部传入
  Future<void> initPurchaseSDK(String uid) async {
    if (_isInitialized) {
      print('RevenueCat 已经初始化过了');
      return;
    }

    WidgetsFlutterBinding.ensureInitialized();
    try {
      await Purchases.setLogLevel(LogLevel.debug);

      PurchasesConfiguration? configuration;

      if (Platform.isIOS) {
        configuration =
            PurchasesConfiguration("appl_fsALmSkZBnAhaDtBrHakpGOXmVn");
      } else {
        print('不支持的平台: ${Platform.operatingSystem}');
        return;
      }
      configuration.appUserID = uid;

      await Purchases.configure(configuration);

      _isInitialized = true;
      print('RevenueCat 初始化成功，用户ID: $uid');
    } catch (e) {
      print('RevenueCat 初始化失败: $e');
      _isInitialized = false;
    }
  }

  /// 显示应用内购买付费墙
  /// 返回购买结果，同时返回更新后的会员状态（用于更新AppState）
  Future<Map<String, dynamic>> showIAPPaywall() async {
    if (!_isInitialized) {
      print('RevenueCat 未初始化');
      return {'success': false, 'isPremium': false};
    }

    PaywallResult? paywallResult;
    try {
      paywallResult = await RevenueCatUI.presentPaywall();
    } catch (e) {
      print('Paywall error: $e');
      return {'success': false, 'isPremium': false};
    }

    if (paywallResult == PaywallResult.purchased) {
      try {
        CustomerInfo customerInfo = await Purchases.getCustomerInfo();
        if (customerInfo.entitlements.all["Pro"]?.isActive ?? false) {
          print('VIP购买成功');
          // 购买成功后刷新服务器端会员状态
          final vipStatus = await _vipService.refreshVipStatus();
          final isPremium = vipStatus?.isPremium ?? false;
          return {'success': true, 'isPremium': isPremium};
        }
      } catch (e) {
        print('获取用户信息失败: $e');
      }
    } else if (paywallResult == PaywallResult.cancelled) {
      print('用户取消购买');
    } else if (paywallResult == PaywallResult.error) {
      print('购买失败');
    }

    return {'success': false, 'isPremium': false};
  }

  /// 恢复购买
  /// 返回购买结果，同时返回更新后的会员状态（用于更新AppState）
  Future<Map<String, dynamic>> restorePurchases() async {
    try {
      if (!_isInitialized) {
        print('RevenueCat 未初始化');
        return {'success': false, 'isPremium': false};
      }

      await Purchases.restorePurchases();
      CustomerInfo customerInfo = await Purchases.getCustomerInfo();
      if (customerInfo.entitlements.all["Pro"]?.isActive ?? false) {
        print('恢复购买成功');
        // 恢复购买成功后也刷新会员状态
        final vipStatus = await _vipService.refreshVipStatus();
        final isPremium = vipStatus?.isPremium ?? false;
        return {'success': true, 'isPremium': isPremium};
      }
      print('恢复购买完成，但未找到有效订阅');
      return {'success': false, 'isPremium': false};
    } catch (e) {
      print('恢复购买失败: $e');
      return {'success': false, 'isPremium': false};
    }
  }

  /// 检查用户是否为会员
  Future<bool> isPremiumUser() async {
    try {
      if (!_isInitialized) {
        print('RevenueCat 未初始化');
        return false;
      }

      CustomerInfo customerInfo = await Purchases.getCustomerInfo();
      return customerInfo.entitlements.all["Pro"]?.isActive ?? false;
    } catch (e) {
      print('检查会员状态失败: $e');
      return false;
    }
  }

  /// 获取用户信息
  Future<CustomerInfo?> getCustomerInfo() async {
    try {
      if (!_isInitialized) {
        print('RevenueCat 未初始化');
        return null;
      }

      return await Purchases.getCustomerInfo();
    } catch (e) {
      print('获取用户信息失败: $e');
      return null;
    }
  }
}
