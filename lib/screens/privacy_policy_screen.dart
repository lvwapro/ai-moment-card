import 'package:flutter/material.dart';
import 'package:ai_poetry_card/services/language_service.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n('隐私政策')),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection(
            context,
            title: context.l10n('数据收集'),
            content:
                context.l10n('我们收集的信息包括：\n• 您上传的照片\n• 生成的文案内容\n• 应用使用统计数据'),
          ),
          _buildSection(
            context,
            title: context.l10n('数据使用'),
            content: context
                .l10n('我们使用收集的数据用于：\n• 提供AI文案生成服务\n• 改进产品体验\n• 技术支持和问题排查'),
          ),
          _buildSection(
            context,
            title: context.l10n('数据存储'),
            content: context.l10n(
                '• 本地数据：存储在您的设备上\n• 云端数据：使用腾讯云COS服务存储\n• 我们采用行业标准的安全措施保护您的数据'),
          ),
          _buildSection(
            context,
            title: context.l10n('数据共享'),
            content: context.l10n('我们不会向第三方出售或共享您的个人数据。'),
          ),
          _buildSection(
            context,
            title: context.l10n('您的权利'),
            content: context.l10n('您有权：\n• 随时删除您的历史记录\n• 导出您的数据\n• 停止使用本应用'),
          ),
          _buildSection(
            context,
            title: context.l10n('联系我们'),
            content: context.l10n('如有任何问题或疑虑，请通过意见反馈功能联系我们。'),
          ),
          const SizedBox(height: 16),
          Text(
            context.l10n('最后更新：2025年10月'),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context,
      {required String title, required String content}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  height: 1.6,
                ),
          ),
        ],
      ),
    );
  }
}
