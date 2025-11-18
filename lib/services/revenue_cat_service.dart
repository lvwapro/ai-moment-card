import 'dart:io';
import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import 'vip_service.dart';
import 'network_service.dart';

/// RevenueCat 购买系统服务
class RevenueCatService {
  static final RevenueCatService _instance = RevenueCatService._internal();
  factory RevenueCatService() => _instance;
  RevenueCatService._internal();

  final VipService _vipService = VipService();
  final NetworkService _networkService = NetworkService();

  // 初始化状态
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  // 初始化锁，防止重复初始化
  bool _isInitializing = false;

  /// 初始化 RevenueCat 购买系统
  /// [uid] 用户ID，从外部传入
  Future<void> initPurchaseSDK(String uid) async {
    if (_isInitialized) {
      print('RevenueCat 已经初始化过了');
      return;
    }

    if (_isInitializing) {
      print('RevenueCat 正在初始化中，等待完成...');
      // 等待初始化完成
      while (_isInitializing) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
      return;
    }

    _isInitializing = true;
    WidgetsFlutterBinding.ensureInitialized();
    try {
      await Purchases.setLogLevel(LogLevel.debug);

      PurchasesConfiguration? configuration;

      if (Platform.isIOS) {
        configuration =
            PurchasesConfiguration("appl_fsALmSkZBnAhaDtBrHakpGOXmVn");
      } else {
        print('不支持的平台: ${Platform.operatingSystem}');
        _isInitializing = false;
        return;
      }
      configuration.appUserID = uid;

      await Purchases.configure(configuration);

      _isInitialized = true;
      print('RevenueCat 初始化成功，用户ID: $uid');
    } catch (e) {
      print('RevenueCat 初始化失败: $e');
      _isInitialized = false;
    } finally {
      _isInitializing = false;
    }
  }

  /// 确保 RevenueCat 已初始化，如果未初始化则先初始化
  Future<bool> _ensureInitialized() async {
    if (_isInitialized) {
      return true;
    }

    if (_isInitializing) {
      // 等待初始化完成
      while (_isInitializing) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
      return _isInitialized;
    }

    try {
      print('RevenueCat 未初始化，正在自动初始化...');
      final deviceId = await _networkService.getDeviceId();
      await initPurchaseSDK(deviceId);
      return _isInitialized;
    } catch (e) {
      print('RevenueCat 自动初始化失败: $e');
      return false;
    }
  }

  /// 显示应用内购买付费墙
  /// 返回购买结果，同时返回更新后的会员状态（用于更新AppState）
  Future<Map<String, dynamic>> showIAPPaywall() async {
    // 确保 RevenueCat 已初始化
    final initialized = await _ensureInitialized();
    if (!initialized) {
      print('RevenueCat 初始化失败，无法显示付费墙');
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
          print('VIP购买成功，RevenueCat权益已激活');
          // 异步刷新服务器端会员状态（不阻塞UI更新）
          _vipService.refreshVipStatus().then((vipStatus) {
            print('服务器会员状态已同步: ${vipStatus?.isPremium ?? false}');
          }).catchError((e) {
            print('服务器会员状态同步失败: $e');
          });
          // 直接返回成功，因为RevenueCat已确认购买
          return {'success': true, 'isPremium': true};
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
      // 确保 RevenueCat 已初始化
      final initialized = await _ensureInitialized();
      if (!initialized) {
        print('RevenueCat 初始化失败，无法恢复购买');
        return {'success': false, 'isPremium': false};
      }

      await Purchases.restorePurchases();
      CustomerInfo customerInfo = await Purchases.getCustomerInfo();
      if (customerInfo.entitlements.all["Pro"]?.isActive ?? false) {
        print('恢复购买成功，RevenueCat权益已激活');
        // 异步刷新服务器端会员状态（不阻塞UI更新）
        _vipService.refreshVipStatus().then((vipStatus) {
          print('服务器会员状态已同步: ${vipStatus?.isPremium ?? false}');
        }).catchError((e) {
          print('服务器会员状态同步失败: $e');
        });
        // 直接返回成功，因为RevenueCat已确认权益激活
        return {'success': true, 'isPremium': true};
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
      // 确保 RevenueCat 已初始化
      final initialized = await _ensureInitialized();
      if (!initialized) {
        print('RevenueCat 初始化失败，无法检查会员状态');
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
      // 确保 RevenueCat 已初始化
      final initialized = await _ensureInitialized();
      if (!initialized) {
        print('RevenueCat 初始化失败，无法获取用户信息');
        return null;
      }

      return await Purchases.getCustomerInfo();
    } catch (e) {
      print('获取用户信息失败: $e');
      return null;
    }
  }
}
