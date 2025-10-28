import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../services/upgrade_service.dart';
import '../services/network_service.dart';
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
                            fontSize: 18,
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
                            fontSize: 14,
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
                                  backgroundColor:
                                      Colors.white.withOpacity(0.3),
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                  minHeight: 6,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${appState.usedCount}/${appState.totalLimit}',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                        // UID 信息（在使用次数下方）
                        if (_uid.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const SizedBox(width: 6),
                              Text(
                                'UID: ',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.6),
                                  fontSize: 11,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  _uid,
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
                                onTap: () => _copyUid(context),
                                child: Icon(
                                  Icons.copy,
                                  size: 14,
                                  color: Colors.white.withOpacity(0.7),
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
                              'assets/vip.png',
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

  void _copyUid(BuildContext context) {
    Clipboard.setData(ClipboardData(text: _uid));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.l10n('UID已复制到剪贴板')),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.green,
      ),
    );
  }
}
