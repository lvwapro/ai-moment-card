import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import '../../services/upgrade_service.dart';
import '../../services/network_service.dart';
import '../../services/invite_service.dart';
import 'package:ai_poetry_card/services/language_service.dart';

class UserInfoCardWidget extends StatefulWidget {
  const UserInfoCardWidget({super.key});

  @override
  State<UserInfoCardWidget> createState() => _UserInfoCardWidgetState();
}

class _UserInfoCardWidgetState extends State<UserInfoCardWidget> {
  String _uid = '';

  @override
  void initState() {
    super.initState();
    _loadUid();
    // 在初始化时重新加载用户信息，确保显示最新的邀请码
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<AppState>().reloadUserInfo();
      }
    });
  }

  Future<void> _loadUid() async {
    final uid = await NetworkService().getSavedDeviceId();
    if (mounted) {
      setState(() {
        _uid = uid ?? '';
      });
    }
  }

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
          child: Column(
            children: [
              Row(
                children: [
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Icon(
                                appState.isPremium
                                    ? Icons.diamond
                                    : Icons.person,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              appState.isPremium
                                  ? context.l10n('专业版用户')
                                  : context.l10n('免费版用户'),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),

                        // UID 信息
                        if (_uid.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          _buildInfoRow(
                            context,
                            'UID',
                            _uid,
                            () => _copyText(
                                context, _uid, context.l10n('UID已复制到剪贴板')),
                          ),
                        ],
                        // 邀请码信息 - 只有当我的邀请码未被别人兑换时才显示
                        if (appState.inviteCode != null &&
                            appState.inviteCode!.isNotEmpty &&
                            !appState.inviteCodeHasBeenUsed) ...[
                          const SizedBox(height: 8),
                          _buildInfoRow(
                            context,
                            context.l10n('邀请码'),
                            appState.inviteCode!,
                            () => _copyText(context, appState.inviteCode!,
                                context.l10n('邀请码已复制')),
                          ),
                        ],
                        // 兑换入口 - 只有当我还没兑换过别人的码时才显示
                        if (appState.usedCode == null) ...[
                          const SizedBox(height: 8),
                          InkWell(
                            onTap: () => _showRedeemDialog(context, appState),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const SizedBox(width: 6),
                                const Icon(Icons.card_giftcard,
                                    size: 14, color: Colors.amberAccent),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    context.l10n('兑换邀请码'),
                                    style: const TextStyle(
                                      color: Colors.amberAccent,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      decoration: TextDecoration.underline,
                                      decorationColor: Colors.amberAccent,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  if (!appState.isPremium)
                    TextButton(
                      onPressed: () =>
                          UpgradeService().showUpgradeDialog(context),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.white.withOpacity(0.2),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center, // 垂直居中对齐
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 2), // 往下移2像素
                            child: Image.asset(
                              'assets/images/vip.png',
                              height: 16,
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            context.l10n('升级'),
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      );

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value,
    VoidCallback onCopy,
  ) =>
      Row(
        children: [
          const SizedBox(width: 6),
          Text(
            '$label: ',
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 11,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 11,
                fontFamily: 'monospace',
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: onCopy,
            child: Icon(
              Icons.copy,
              size: 14,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
        ],
      );

  void _copyText(BuildContext context, String text, String successMessage) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(successMessage),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showRedeemDialog(BuildContext context, AppState appState) {
    final TextEditingController controller = TextEditingController();
    bool loading = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(context.l10n('兑换邀请码')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: context.l10n('请输入邀请码'),
                  border: const OutlineInputBorder(),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
              if (loading) ...[
                const SizedBox(height: 16),
                const CircularProgressIndicator(),
              ]
            ],
          ),
          actions: [
            TextButton(
              onPressed: loading ? null : () => Navigator.pop(context),
              child: Text(context.l10n('取消')),
            ),
            TextButton(
              onPressed: loading
                  ? null
                  : () async {
                      final code = controller.text.trim();
                      if (code.isEmpty) return;

                      // 收起键盘
                      FocusScope.of(context).unfocus();

                      setState(() => loading = true);
                      try {
                        final success =
                            await InviteService.redeemInviteCode(code);
                        if (success) {
                          appState.markRedeemedOthersCode(code);
                          await appState
                              .refreshVipStatus(); // Force refresh VIP

                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(context.l10n('恭喜！邀请码兑换成功！')),
                              backgroundColor: Colors.green,
                            ));
                          }
                        } else {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(context.l10n('兑换失败，请检查邀请码')),
                              backgroundColor: Colors.red,
                            ));
                          }
                        }
                      } catch (e) {
                        if (context.mounted) {
                          // 简化错误提示，避免显示过长的技术错误信息
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(context.l10n('兑换失败，请检查邀请码')),
                            backgroundColor: Colors.red,
                          ));
                        }
                      } finally {
                        if (context.mounted) {
                          setState(() => loading = false);
                        }
                      }
                    },
              child: Text(context.l10n('兑换')),
            ),
          ],
        ),
      ),
    );
  }
}
