import 'dart:io';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/language_service.dart';
import '../../screens/privacy_policy_screen.dart';
import '../settings_card_widget.dart';

/// 关于部分
class AboutSection extends StatelessWidget {
  const AboutSection({super.key});

  @override
  Widget build(BuildContext context) => SettingsCardWidget(
        title: context.l10n('关于'),
        children: [
          SettingItemWidget(
            icon: Icons.info,
            title: context.l10n('版本信息'),
            subtitle: 'v1.0.0',
          ),
          SettingItemWidget(
            icon: Icons.feedback,
            title: context.l10n('意见反馈'),
            subtitle: context.l10n('告诉我们你的想法'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _openFeedback(context),
          ),
          SettingItemWidget(
            icon: Icons.privacy_tip,
            title: context.l10n('隐私政策'),
            subtitle: context.l10n('了解我们如何保护你的隐私'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PrivacyPolicyScreen(),
                ),
              );
            },
          ),
        ],
      );

  /// 打开意见反馈
  Future<void> _openFeedback(BuildContext context) async {
    try {
      // 邮件反馈
      final Uri emailUri = Uri(
        scheme: 'mailto',
        path: 'feedback@example.com',
        queryParameters: {
          'subject': context.l10n('AI诗意卡片 - 用户反馈'),
          'body': context.l10n(
              '请在此处输入您的反馈意见...\n\n---\n版本：v1.0.0\n设备：${Platform.operatingSystem}'),
        },
      );

      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      } else {
        // 如果无法打开邮件，显示备用选项
        if (context.mounted) {
          _showFeedbackDialog(context);
        }
      }
    } catch (e) {
      if (context.mounted) {
        _showFeedbackDialog(context);
      }
    }
  }

  /// 显示反馈对话框（备用方案）
  void _showFeedbackDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n('意见反馈')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(context.l10n('感谢您的反馈！')),
            const SizedBox(height: 16),
            Text(
              context.l10n('请通过以下方式联系我们：'),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const SelectableText('Email: feedback@example.com'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n('关闭')),
          ),
        ],
      ),
    );
  }
}
