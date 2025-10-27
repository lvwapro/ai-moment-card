import 'package:flutter/material.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../services/revenue_cat_service.dart';
import '../services/stripe_payment_service.dart';
import '../services/language_service.dart';
import '../theme/app_theme.dart';

/// 升级VIP服务 - 统一管理升级流程
class UpgradeService {
  static final UpgradeService _instance = UpgradeService._internal();
  factory UpgradeService() => _instance;
  UpgradeService._internal();

  /// 显示升级VIP对话框
  /// [context] - 上下文
  /// [showFeatures] - 是否显示功能列表（默认true）
  Future<void> showUpgradeDialog(
    BuildContext context, {
    bool showFeatures = true,
  }) async {
    if (showFeatures) {
      // 显示带功能列表的对话框
      await _showUpgradeDialogWithFeatures(context);
    } else {
      // 直接执行升级
      await _handleUpgrade(context);
    }
  }

  /// 显示带功能列表的升级对话框
  Future<void> _showUpgradeDialogWithFeatures(BuildContext context) async =>
      showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Row(
            children: [
              Image.asset(
                'assets/vip.png',
                height: 24,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 8),
              Text(context.l10n('升级专业版')),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFeatureItem(
                  dialogContext, Icons.all_inclusive, context.l10n('无限生成')),
              const SizedBox(height: 8),
              _buildFeatureItem(
                  dialogContext, Icons.font_download, context.l10n('独家字体')),
              const SizedBox(height: 8),
              _buildFeatureItem(
                  dialogContext, Icons.stars, context.l10n('高级模板')),
              const SizedBox(height: 8),
              _buildFeatureItem(
                  dialogContext, Icons.support_agent, context.l10n('优先支持')),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(context.l10n('稍后')),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(dialogContext);
                _handleUpgrade(context);
              },
              child: Text(context.l10n('立即升级')),
            ),
          ],
        ),
      );

  /// 构建功能项
  Widget _buildFeatureItem(BuildContext context, IconData icon, String text) =>
      Row(
        children: [
          Icon(icon, color: AppTheme.primaryColor, size: 20),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(fontSize: 15),
          ),
        ],
      );

  /// 处理升级VIP流程
  Future<void> _handleUpgrade(BuildContext context) async {
    try {
      if (Platform.isIOS) {
        final result = await RevenueCatService().showIAPPaywall();
        if (context.mounted && result['success'] == true) {
          // 更新AppState的会员状态
          final appState = Provider.of<AppState>(context, listen: false);
          await appState.setPremium(result['isPremium'] ?? false);

          // 显示成功提示
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.l10n('恭喜您成为专业版用户！')),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else if (Platform.isAndroid) {
        await StripePaymentService().openStripePayment(context);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${context.l10n('升级失败')}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
