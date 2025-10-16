import 'dart:io';
import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import 'vip_service.dart';
import 'stripe_payment_service.dart';
import 'init_service.dart';

/// RevenueCat 购买系统服务（整合 Stripe 支付）
class RevenueCatService {
  static final RevenueCatService _instance = RevenueCatService._internal();
  factory RevenueCatService() => _instance;
  RevenueCatService._internal();

  // VIP服务实例
  final VipService _vipService = VipService();

  // Stripe支付服务实例
  final StripePaymentService _stripeService = StripePaymentService();

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
            PurchasesConfiguration("appl_vlhSRAemssgCrZsSdUkEQftJFAK");
      } else if (Platform.isAndroid) {
        configuration =
            PurchasesConfiguration("goog_jlCggYxWElLGwSqROBlMCQJooyf");
      } else {
        print('不支持的平台: ${Platform.operatingSystem}');
        return;
      }

      configuration.appUserID = uid;

      await Purchases.configure(configuration);

      _isInitialized = true;
      print('RevenueCat 初始化成功，用户ID: $uid');

      // 检查配置状态
      try {
        final offerings = await Purchases.getOfferings();
        print(
            'RevenueCat 产品配置检查: ${offerings.all.isNotEmpty ? "已配置" : "未配置产品"}');
      } catch (e) {
        print('RevenueCat 产品配置检查失败: $e');
      }
    } catch (e) {
      print('RevenueCat 初始化失败: $e');
      _isInitialized = false;
    }
  }

  /// 显示应用内购买付费墙（根据平台自动选择支付方式）
  /// [context] 必需参数，用于显示对话框和跳转
  Future<bool> showIAPPaywall({required BuildContext context}) async {
    // ==================== TODO: 临时修改 - 让iOS也使用Stripe测试 ====================
    // 正式版应该是: if (Platform.isAndroid)
    // ==================== Android 和 iOS 都使用 Stripe 支付 ====================
    if (Platform.isAndroid || Platform.isIOS) {
      // 临时修改
      print('💳 使用 Stripe 支付 (Platform: ${Platform.operatingSystem})');

      try {
        // 获取用户信息
        final userInfo = await InitService.getUserInfo();
        final data = userInfo?['data'] as Map<String, dynamic>?;

        // 尝试获取 uid 或 deviceId
        String? uid = data?['uid'] as String?;
        if (uid == null || uid.isEmpty) {
          uid = data?['deviceId'] as String?;
        }
        if (uid == null || uid.isEmpty) {
          uid = data?['_id'] as String?;
        }

        if (uid == null || uid.isEmpty) {
          print('❌ 无法获取用户ID');
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('用户信息获取失败，请重试'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return false;
        }

        print('✅ 使用UID进行Stripe支付: $uid');

        // 调用 Stripe 支付
        await _stripeService.openStripePayment(uid, context);

        // Stripe 支付是异步的，返回 false（实际结果通过对话框处理）
        return false;
      } catch (e) {
        print('❌ Stripe 支付启动失败: $e');
        return false;
      }
    }

    // ==================== iOS 使用 RevenueCat 内购 ====================
    print('🍎 iOS平台 - 使用 RevenueCat 内购');

    if (!_isInitialized) {
      print('❌ RevenueCat 未初始化');
      return false;
    }

    // 检查是否有可用的产品
    try {
      final offerings = await Purchases.getOfferings();
      if (offerings.all.isEmpty) {
        print('❌ RevenueCat 错误: 没有配置任何产品，请在 RevenueCat Dashboard 中配置产品');
        return false;
      }
    } catch (e) {
      print('❌ RevenueCat 产品检查失败: $e');
      return false;
    }

    // 显示 RevenueCat 付费墙
    PaywallResult? paywallResult;
    try {
      paywallResult = await RevenueCatUI.presentPaywall();
    } catch (e) {
      print('❌ Paywall 显示失败: $e');
      return false;
    }

    // 处理购买结果
    if (paywallResult == PaywallResult.purchased) {
      try {
        CustomerInfo customerInfo = await Purchases.getCustomerInfo();
        if (customerInfo.entitlements.all["Pro"]?.isActive ?? false) {
          print('✅ VIP购买成功');
          // 购买成功后刷新服务器端会员状态
          await _vipService.refreshVipStatus();
          return true;
        }
      } catch (e) {
        print('❌ 获取用户信息失败: $e');
      }
    } else if (paywallResult == PaywallResult.cancelled) {
      print('⚠️ 用户取消购买');
    } else if (paywallResult == PaywallResult.error) {
      print('❌ 购买失败');
    }

    return false;
  }

  /// 恢复购买
  Future<bool> restorePurchases() async {
    try {
      if (!_isInitialized) {
        print('RevenueCat 未初始化');
        return false;
      }

      await Purchases.restorePurchases();
      CustomerInfo customerInfo = await Purchases.getCustomerInfo();
      if (customerInfo.entitlements.all["Pro"]?.isActive ?? false) {
        print('恢复购买成功');
        // 恢复购买成功后也刷新会员状态
        await _vipService.refreshVipStatus();
        return true;
      }
      print('恢复购买完成，但未找到有效订阅');
      return false;
    } catch (e) {
      print('恢复购买失败: $e');
      return false;
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
