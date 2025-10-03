import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../providers/history_manager.dart';
import '../models/poetry_card.dart';
import '../widgets/settings_card_widget.dart';
import '../widgets/user_info_card_widget.dart';
import 'package:ai_poetry_card/services/language_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(context.l10n('设置'))),
        body: ListView(
          children: [
            const UserInfoCardWidget(),
            const SizedBox(height: 16),
            _PreferencesSection(),
            const SizedBox(height: 16),
            _DataSection(),
            const SizedBox(height: 16),
            _AboutSection(),
            const SizedBox(height: 32),
          ],
        ),
      );
}

class _PreferencesSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Consumer<AppState>(
        builder: (context, appState, child) => SettingsCardWidget(
          title: context.l10n('偏好设置'),
          children: [
            SettingItemWidget(
              icon: Icons.style,
              title: context.l10n('默认文案风格'),
              subtitle: appState.getStyleDisplayName(appState.selectedStyle),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showStyleSelector(context, appState),
            ),
            SettingItemWidget(
              icon: Icons.qr_code,
              title: context.l10n('显示二维码'),
              subtitle: context.l10n('在卡片上显示二维码'),
              trailing: Switch(
                value: appState.showQrCode,
                onChanged: (value) {
                  appState.setShowQrCode(value);
                },
              ),
            ),
          ],
        ),
      );

  void _showStyleSelector(BuildContext context, AppState appState) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('选择默认风格', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              ...PoetryStyle.values.map((style) => ListTile(
                    title: Text(appState.getStyleDisplayName(style)),
                    subtitle: Text(appState.getStyleDescription(style)),
                    leading: Radio<PoetryStyle>(
                      value: style,
                      groupValue: appState.selectedStyle,
                      onChanged: (value) {
                        if (value != null) {
                          appState.setSelectedStyle(value);
                        }
                        Navigator.pop(context);
                      },
                    ),
                    onTap: () {
                      appState.setSelectedStyle(style);
                      Navigator.pop(context);
                    },
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

class _DataSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Consumer<HistoryManager>(
        builder: (context, historyManager, child) => SettingsCardWidget(
          title: context.l10n('数据管理'),
          children: [
            SettingItemWidget(
              icon: Icons.history,
              title: context.l10n('历史记录'),
              subtitle: context.l10n('共 ${historyManager.totalCount} 张卡片'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pushNamed(context, '/history');
              },
            ),
            SettingItemWidget(
              icon: Icons.download,
              title: context.l10n('导出数据'),
              subtitle: context.l10n('导出所有卡片数据'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(
                    SnackBar(content: Text(context.l10n('导出功能开发中...'))));
              },
            ),
            SettingItemWidget(
              icon: Icons.delete_forever,
              title: '清空历史',
              subtitle: context.l10n('删除所有历史记录'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showClearHistoryDialog(context, historyManager),
            ),
          ],
        ),
      );

  void _showClearHistoryDialog(
    BuildContext context,
    HistoryManager historyManager,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n('清空历史记录')),
        content: Text(context.l10n('确定要清空所有历史记录吗？此操作不可撤销。')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n('取消')),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              historyManager.clearHistory();
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(context.l10n('历史记录已清空'))));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(context.l10n('清空')),
          ),
        ],
      ),
    );
  }
}

class _AboutSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) => SettingsCardWidget(
        title: '关于',
        children: [
          const SettingItemWidget(
              icon: Icons.info, title: '版本信息', subtitle: 'v1.0.0'),
          SettingItemWidget(
            icon: Icons.feedback,
            title: '意见反馈',
            subtitle: context.l10n('告诉我们你的想法'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(
                  SnackBar(content: Text(context.l10n('反馈功能开发中...'))));
            },
          ),
          SettingItemWidget(
            icon: Icons.privacy_tip,
            title: '隐私政策',
            subtitle: '了解我们如何保护你的隐私',
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(
                  SnackBar(content: Text(context.l10n('隐私政策页面开发中...'))));
            },
          ),
        ],
      );
}
