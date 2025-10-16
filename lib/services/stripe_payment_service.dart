import 'dart:io'; // ignore: unused_import - 上线时需要用于平台判断
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ai_poetry_card/services/vip_service.dart';
import 'package:ai_poetry_card/providers/app_state.dart';
import 'package:provider/provider.dart';

/// Stripe 支付服务
class StripePaymentService {
  static final StripePaymentService _instance =
      StripePaymentService._internal();
  factory StripePaymentService() => _instance;
  StripePaymentService._internal();

  final VipService _vipService = VipService();

  // Stripe 支付链接模板
  static const String _stripePaymentUrl =
      'https://buy.stripe.com/3cIcN5aae8sUe9oeNwaAw06?client_reference_id=';

  /// 打开 Stripe 支付页面（仅安卓）
  /// [uid] 用户ID
  /// [context] 用于显示对话框
  Future<void> openStripePayment(String uid, BuildContext context) async {
    // TODO: 临时修改 - 让iOS也能测试，上线前需要改回只支持Android
    // if (!Platform.isAndroid) {
    //   print('Stripe 支付仅支持安卓平台');
    //   return;
    // }

    try {
      final paymentUrl = '$_stripePaymentUrl$uid';
      print('🔄 打开 Stripe 支付链接: $paymentUrl');

      final uri = Uri.parse(paymentUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);

        // 延迟显示支付完成确认对话框
        Future.delayed(const Duration(seconds: 2), () {
          _showPaymentConfirmationDialog(context, uid);
        });
      } else {
        print('❌ 无法打开支付链接');
        _showErrorDialog(context, '无法打开支付页面，请检查网络连接');
      }
    } catch (e) {
      print('❌ 打开支付链接失败: $e');
      _showErrorDialog(context, '打开支付页面失败: $e');
    }
  }

  /// 显示支付完成确认对话框
  void _showPaymentConfirmationDialog(BuildContext context, String uid) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('支付确认'),
        content: const Text('您是否已完成支付？'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
            },
            child: const Text('未完成'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await _verifyPaymentAndRefreshStatus(context, uid);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('已完成'),
          ),
        ],
      ),
    );
  }

  /// 验证支付并刷新状态
  Future<void> _verifyPaymentAndRefreshStatus(
      BuildContext context, String uid) async {
    try {
      // 显示加载对话框
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('正在验证支付状态...'),
            ],
          ),
        ),
      );

      // 直接使用 VipService 刷新状态
      final vipStatus = await _vipService.refreshVipStatus();

      // 关闭加载对话框
      if (context.mounted) {
        Navigator.pop(context);
      }

      if (vipStatus != null && vipStatus.isPremium) {
        // 支付成功，更新 AppState 状态
        final appState = Provider.of<AppState>(context, listen: false);
        await appState.setPremium(true);

        // 显示成功对话框
        _showSuccessDialog(context);
      } else {
        // 支付验证失败 - 可能是服务器配置问题
        print('⚠️ VIP状态验证失败，可能是服务器配置问题');

        // 显示友好提示，告知用户支付可能需要时间生效
        _showPendingDialog(context);
      }
    } catch (e) {
      // 关闭加载对话框
      if (context.mounted) {
        Navigator.pop(context);
      }

      print('❌ 验证支付状态失败: $e');
      _showErrorDialog(context, '验证支付状态失败: $e');
    }
  }

  /// 显示成功对话框
  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('支付成功'),
          ],
        ),
        content: const Text('恭喜您成为专业版用户！现在可以享受无限创作体验。'),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  /// 显示支付待处理对话框
  void _showPendingDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.info, color: Colors.orange),
            SizedBox(width: 8),
            Text('支付处理中'),
          ],
        ),
        content: const Text(
          '您的支付正在处理中，可能需要几分钟时间生效。\n\n'
          '如果长时间未到账，请联系客服处理。',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
            },
            child: const Text('知道了'),
          ),
        ],
      ),
    );
  }

  /// 显示错误对话框
  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error, color: Colors.red),
            SizedBox(width: 8),
            Text('操作失败'),
          ],
        ),
        content: Text(message),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}
