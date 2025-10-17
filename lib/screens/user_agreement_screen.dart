import 'package:flutter/material.dart';
import 'package:ai_poetry_card/services/language_service.dart';

class UserAgreementScreen extends StatelessWidget {
  const UserAgreementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n('用户协议')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n('迹见文案用户协议'),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              title: context.l10n('服务条款'),
              content: context.l10n(
                  '欢迎使用迹见文案。使用本应用前，请您仔细阅读并理解本协议。一旦您开始使用本应用，即表示您已同意本协议的所有条款。'),
            ),
            _buildSection(
              context,
              title: context.l10n('服务内容'),
              content: context
                  .l10n('本应用提供基于AI技术的文案生成服务，包括但不限于：诗意文案生成、多平台文案创作、图片识别与描述等功能。'),
            ),
            _buildSection(
              context,
              title: context.l10n('用户责任'),
              content: context.l10n(
                  '用户应合法使用本应用，不得利用本应用生成违法、违规或侵犯他人权益的内容。用户对使用本应用生成的内容负有完全责任。'),
            ),
            _buildSection(
              context,
              title: context.l10n('知识产权'),
              content: context.l10n(
                  '本应用及其所有相关内容（包括但不限于软件、图标、文字、图片）的知识产权归开发者所有。用户生成的内容归用户所有。'),
            ),
            _buildSection(
              context,
              title: context.l10n('免责声明'),
              content: context
                  .l10n('AI生成的内容仅供参考，我们不对内容的准确性、完整性或适用性作出保证。用户应自行判断并承担使用风险。'),
            ),
            _buildSection(
              context,
              title: context.l10n('协议修改'),
              content:
                  context.l10n('我们保留随时修改本协议的权利。修改后的协议将在应用内公布，继续使用即视为接受修改后的协议。'),
            ),
            const SizedBox(height: 24),
            Text(
              context.l10n('最后更新：2025年10月'),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required String content,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
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
