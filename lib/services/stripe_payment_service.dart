import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ai_poetry_card/services/vip_service.dart';
import 'package:ai_poetry_card/services/language_service.dart';
import 'package:ai_poetry_card/providers/app_state.dart';
import 'package:provider/provider.dart';
import 'package:ai_poetry_card/services/network_service.dart';

/// Stripe 支付服务（仅Android）
class StripePaymentService {
  static final StripePaymentService _instance =
      StripePaymentService._internal();
  factory StripePaymentService() => _instance;
  StripePaymentService._internal();

  final VipService _vipService = VipService();
  static const String _stripePaymentUrl =
      'https://buy.stripe.com/3cIcN5aae8sUe9oeNwaAw06?client_reference_id=';

  /// 打开 Stripe 支付页面
  Future<void> openStripePayment(BuildContext context) async {
    // 获取用户 ID
    final uid = await NetworkService().getSavedDeviceId();
    try {
      final uri = Uri.parse('$_stripePaymentUrl$uid');
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        Future.delayed(
          const Duration(seconds: 2),
          () => _showPaymentConfirmationDialog(context),
        );
      } else {
        _showDialog(
          context,
          context.l10n('操作失败'),
          context.l10n('无法打开支付页面，请检查网络连接'),
          Colors.red,
        );
      }
    } catch (e) {
      print('打开支付链接失败: $e');
      _showDialog(
        context,
        context.l10n('操作失败'),
        '${context.l10n('打开支付页面失败')}: $e',
        Colors.red,
      );
    }
  }

  /// 显示支付确认对话框
  void _showPaymentConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n('支付确认')),
        content: Text(context.l10n('您是否已完成支付？')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(context.l10n('未完成')),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _verifyPayment(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: Text(context.l10n('已完成')),
          ),
        ],
      ),
    );
  }

  /// 验证支付状态
  Future<void> _verifyPayment(BuildContext context) async {
    _showLoadingDialog(context);

    try {
      final vipStatus = await _vipService.refreshVipStatus();
      if (context.mounted) Navigator.pop(context);

      if (vipStatus?.isPremium ?? false) {
        final appState = Provider.of<AppState>(context, listen: false);
        await appState.setPremium(true);
        _showDialog(
          context,
          context.l10n('支付成功'),
          context.l10n('恭喜您成为专业版用户！现在可以享受无限创作体验。'),
          Colors.green,
        );
      } else {
        _showDialog(
          context,
          context.l10n('支付处理中'),
          context.l10n('您的支付正在处理中，可能需要几分钟时间生效。\n\n如果长时间未到账，请联系客服处理。'),
          Colors.orange,
        );
      }
    } catch (e) {
      if (context.mounted) Navigator.pop(context);
      print('❌ 验证支付失败: $e');
      _showDialog(
        context,
        context.l10n('操作失败'),
        '${context.l10n('验证支付状态失败')}: $e',
        Colors.red,
      );
    }
  }

  /// 显示加载对话框
  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Text(context.l10n('正在验证支付状态...')),
          ],
        ),
      ),
    );
  }

  /// 统一对话框显示
  void _showDialog(
    BuildContext context,
    String title,
    String content,
    Color color,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(
              color == Colors.green
                  ? Icons.check_circle
                  : (color == Colors.orange ? Icons.info : Icons.error),
              color: color,
            ),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: Text(content),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
            ),
            child: Text(
              color == Colors.orange ? context.l10n('知道了') : context.l10n('确定'),
            ),
          ),
        ],
      ),
    );
  }
}
