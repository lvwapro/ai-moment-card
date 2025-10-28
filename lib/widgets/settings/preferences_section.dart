import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import '../../theme/app_theme.dart';
import '../../services/language_service.dart';
import '../../services/upgrade_service.dart';
import '../settings_card_widget.dart';

/// 偏好设置部分
class PreferencesSection extends StatefulWidget {
  const PreferencesSection({super.key});

  @override
  State<PreferencesSection> createState() => _PreferencesSectionState();
}

class _PreferencesSectionState extends State<PreferencesSection> {
  String _getCurrentLanguageDisplay() {
    final currentLang = LanguageService.to.getCurrentLanguage();
    return currentLang == 'zh' ? '中文' : 'English';
  }

  @override
  Widget build(BuildContext context) => Consumer<AppState>(
        builder: (context, appState, child) => SettingsCardWidget(
          title: context.l10n('偏好设置'),
          children: [
            SettingItemWidget(
              icon: Icons.language,
              title: context.l10n('语言设置'),
              subtitle: _getCurrentLanguageDisplay(),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showLanguageSelector(context),
            ),
            SettingItemWidget(
              icon: Icons.font_download,
              title: context.l10n('字体设置'),
              subtitle:
                  AppState.getFontDisplayName(appState.selectedFont, context),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showFontSelector(context, appState),
            ),
            SettingItemWidget(
              icon: Icons.content_copy,
              title: context.l10n('默认显示文案'),
              subtitle: AppState.getPlatformDisplayName(
                  appState.defaultPlatform, context),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showPlatformSelector(context, appState),
            ),
            SettingItemWidget(
              icon: Icons.qr_code,
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    context.l10n('显示二维码'),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                  ),
                  const SizedBox(width: 8),
                  Image.asset(
                    'assets/vip.png',
                    height: 16,
                    fit: BoxFit.contain,
                  ),
                ],
              ),
              subtitle: context.l10n('在卡片上显示二维码'),
              trailing: Transform.scale(
                scale: 0.8, // 缩小开关尺寸
                child: Switch(
                  value: appState.showQrCode,
                  onChanged: (value) {
                    // 关闭功能需要VIP
                    if (!value && !appState.isPremium) {
                      UpgradeService().showUpgradeDialog(context);
                    } else {
                      appState.setShowQrCode(value);
                    }
                  },
                  materialTapTargetSize:
                      MaterialTapTargetSize.shrinkWrap, // 缩小点击区域
                ),
              ),
            ),
            SettingItemWidget(
              icon: Icons.label,
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    context.l10n('显示情绪标签'),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                  ),
                  const SizedBox(width: 8),
                  Image.asset(
                    'assets/vip.png',
                    height: 16,
                    fit: BoxFit.contain,
                  ),
                ],
              ),
              subtitle: context.l10n('在卡片上显示情绪标签'),
              trailing: Transform.scale(
                scale: 0.8, // 缩小开关尺寸
                child: Switch(
                  value: appState.showMoodTagOnCard,
                  onChanged: (value) {
                    // 关闭功能需要VIP
                    if (!value && !appState.isPremium) {
                      UpgradeService().showUpgradeDialog(context);
                    } else {
                      appState.setShowMoodTagOnCard(value);
                    }
                  },
                  materialTapTargetSize:
                      MaterialTapTargetSize.shrinkWrap, // 缩小点击区域
                ),
              ),
            ),
          ],
        ),
      );

  void _showLanguageSelector(BuildContext context) {
    final currentLang = LanguageService.to.getCurrentLanguage();

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n('选择语言'),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Container(
              margin: const EdgeInsets.only(bottom: 4),
              decoration: BoxDecoration(
                color: currentLang == 'zh'
                    ? Colors.white // 选中背景为白色
                    : Colors.transparent, // 未选中透明
                borderRadius: BorderRadius.circular(12),
                boxShadow: currentLang == 'zh'
                    ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null, // 选中时有阴影
              ),
              child: ListTile(
                title: Center(
                  child: Text(
                    '中文',
                    style: TextStyle(
                      color: currentLang == 'zh'
                          ? AppTheme.primaryColor
                          : const Color(0xFF666666),
                      fontWeight: currentLang == 'zh'
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ),
                onTap: () async {
                  await LanguageService.to.setLanguage('zh');
                  if (context.mounted) {
                    Navigator.pop(context);
                    setState(() {}); // 刷新界面
                  }
                },
              ),
            ),
            Container(
              margin: const EdgeInsets.only(bottom: 4),
              decoration: BoxDecoration(
                color: currentLang == 'en'
                    ? Colors.white // 选中背景为白色
                    : Colors.transparent, // 未选中透明
                borderRadius: BorderRadius.circular(12),
                boxShadow: currentLang == 'en'
                    ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null, // 选中时有阴影
              ),
              child: ListTile(
                title: Center(
                  child: Text(
                    'English',
                    style: TextStyle(
                      color: currentLang == 'en'
                          ? AppTheme.primaryColor
                          : const Color(0xFF666666),
                      fontWeight: currentLang == 'en'
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ),
                onTap: () async {
                  await LanguageService.to.setLanguage('en');
                  if (context.mounted) {
                    Navigator.pop(context);
                    setState(() {}); // 刷新界面
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFontSelector(BuildContext context, AppState appState) {
    showModalBottomSheet(
      context: context,
      builder: (sheetContext) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                context.l10n('选择字体'),
                style: Theme.of(sheetContext).textTheme.titleLarge,
              ),
            ),
            const SizedBox(height: 16),
            ...FontFamily.values.map((font) {
              final isSelected = appState.selectedFont == font;
              final fontName = AppState.getFontDisplayName(font, context);
              final isVipFont = font != FontFamily.system; // VIP字体

              // 获取字体family，系统字体为null
              String? fontFamily;
              switch (font) {
                case FontFamily.system:
                  fontFamily = null; // 系统默认字体
                  break;
                case FontFamily.jiangxiZhuokai:
                  fontFamily = 'JiangxiZhuokai';
                  break;
                case FontFamily.jiangchengLvdongsong:
                  fontFamily = 'JiangchengLvdongsong';
                  break;
              }

              return Container(
                margin: const EdgeInsets.only(bottom: 4),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white // 选中背景为白色
                      : Colors.transparent, // 未选中透明
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null, // 选中时有阴影
                ),
                child: ListTile(
                  title: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          fontName,
                          style: TextStyle(
                            fontFamily: fontFamily, // null表示使用系统默认字体
                            color: isSelected
                                ? AppTheme.primaryColor
                                : const Color(0xFF666666),
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                            fontSize: 18,
                          ),
                        ),
                        // VIP标识
                        if (isVipFont) ...[
                          const SizedBox(width: 8),
                          Image.asset(
                            'assets/vip.png',
                            height: 20,
                            fit: BoxFit.contain,
                          ),
                        ],
                      ],
                    ),
                  ),
                  onTap: () {
                    // 如果是VIP字体且用户不是VIP，显示升级弹窗
                    if (isVipFont && !appState.isPremium) {
                      Navigator.pop(sheetContext);
                      UpgradeService().showUpgradeDialog(context);
                    } else {
                      appState.setSelectedFont(font);
                      Navigator.pop(sheetContext);
                    }
                  },
                ),
              );
            }),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showPlatformSelector(BuildContext context, AppState appState) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  context.l10n('选择默认显示文案'),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              const SizedBox(height: 16),
              ...PlatformType.values.map((platform) {
                final isSelected = appState.defaultPlatform == platform;
                return Container(
                  margin: const EdgeInsets.only(bottom: 4),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white // 选中背景为白色
                        : Colors.transparent, // 未选中透明
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null, // 选中时有阴影
                  ),
                  child: ListTile(
                    title: Center(
                      child: Text(
                        AppState.getPlatformDisplayName(platform, context),
                        style: TextStyle(
                          color: isSelected
                              ? AppTheme.primaryColor // 主题色选中文字
                              : const Color(0xFF666666), // 灰色未选中文字
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ),
                    onTap: () {
                      appState.setDefaultPlatform(platform);
                      Navigator.pop(context);
                    },
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
