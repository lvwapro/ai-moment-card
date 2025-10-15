import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../services/revenue_cat_service.dart';
import 'package:ai_poetry_card/services/language_service.dart';

class UserInfoCardWidget extends StatelessWidget {
  const UserInfoCardWidget({super.key});

  @override
  Widget build(BuildContext context) => Consumer<AppState>(
        builder: (context, appState, child) => Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).primaryColor.withOpacity(0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).primaryColor.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Icon(
                  appState.isPremium ? Icons.diamond : Icons.person,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appState.isPremium
                          ? context.l10n('专业版用户')
                          : context.l10n('免费版用户'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18, // 字体大小
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      appState.isPremium
                          ? context.l10n('享受无限创作体验')
                          : context.l10n('试用版用户'),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14, // 字体大小
                      ),
                    ),
                    if (!appState.isPremium) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: LinearProgressIndicator(
                              value: appState.usedCount /
                                  appState.totalLimit.toDouble(),
                              backgroundColor: Colors.white.withOpacity(0.3),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                  Colors.white),
                              minHeight: 6,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${appState.usedCount}/${appState.totalLimit}',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 12, // 字体大小
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              if (!appState.isPremium)
                TextButton(
                  onPressed: () => _showUpgradeDialog(context),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.white.withOpacity(0.2),
                  ),
                  child: Text(
                    context.l10n('升级'),
                    style: const TextStyle(fontSize: 14), // 按钮字体
                  ),
                ),
            ],
          ),
        ),
      );

  Future<void> _showUpgradeDialog(BuildContext context) async {
    final appState = Provider.of<AppState>(context, listen: false);
    final revenueCatService = RevenueCatService();

    // 显示loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      ),
    );

    // 打开付费墙
    final success = await revenueCatService.showIAPPaywall();

    // 关闭loading
    if (context.mounted) {
      Navigator.pop(context);
    }

    if (success) {
      // 刷新VIP状态
      await appState.refreshVipStatus();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n('升级成功！')),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      // 如果RevenueCat未启用，显示提示
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n('支付功能开发中...')),
          ),
        );
      }
    }
  }
}
