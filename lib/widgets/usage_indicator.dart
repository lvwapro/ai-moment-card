import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ai_poetry_card/providers/app_state.dart';

class UsageIndicator extends StatelessWidget {
  const UsageIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        final progress = appState.dailyUsage / appState.dailyLimit;
        final isNearLimit = progress > 0.8;

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '使用',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  if (appState.isPremium)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'PRO',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isNearLimit
                            ? Colors.red
                            : Theme.of(context).primaryColor,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${appState.dailyUsage}/${appState.dailyLimit}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isNearLimit ? Colors.red : null,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (appState.remainingUsage > 0)
                Text(
                  '剩余 ${appState.remainingUsage} 次',
                  style: Theme.of(context).textTheme.bodySmall,
                )
              else
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: Colors.red,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '次数已用完',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.red,
                            ),
                      ),
                    ),
                    if (!appState.isPremium)
                      TextButton(
                        onPressed: () {
                          // 跳转到升级页面
                          _showUpgradeDialog(context);
                        },
                        child: const Text('升级'),
                      ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }

  void _showUpgradeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('升级专业版'),
        content: const Text(
          '无限生成\n高级模板\n独家字体\n优先支持',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('稍后'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // 这里可以集成支付逻辑
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('支付功能开发中...')),
              );
            },
            child: const Text('升级'),
          ),
        ],
      ),
    );
  }
}
