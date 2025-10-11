import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ai_poetry_card/providers/app_state.dart';
import 'package:ai_poetry_card/services/language_service.dart';
import '../utils/style_utils.dart';
import '../theme/app_theme.dart';

class CardPreview extends StatelessWidget {
  final File? image;
  final VoidCallback onGenerate;

  const CardPreview({
    super.key,
    this.image,
    required this.onGenerate,
  });

  @override
  Widget build(BuildContext context) => Consumer<AppState>(
        builder: (context, appState, child) => Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 标题
              Text(
                context.l10n('预览卡片'),
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                context.l10n('AI将根据你的选择生成精美的卡片'),
                style: Theme.of(context).textTheme.bodyMedium,
              ),

              const SizedBox(height: 24),

              // 卡片预览
              if (image != null) ...[
                Center(
                  child: _CardPreviewWidget(
                    image: image!,
                    style: appState.selectedStyle,
                  ),
                ),

                const SizedBox(height: 24),

                // 设置选项
                _SettingsSection(),

                const SizedBox(height: 24),

                // 生成按钮
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: appState.canGenerate ? onGenerate : null,
                    icon: const Icon(Icons.auto_awesome),
                    label: Text(
                      appState.canGenerate
                          ? context.l10n('生成卡片')
                          : context.l10n('今日使用次数已用完'),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ] else ...[
                // 没有图片时的提示
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.shadowColor,
                        spreadRadius: 1,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.image_not_supported,
                        size: 64,
                        color: AppTheme.textTertiary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        context.l10n('请先选择图片'),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        context.l10n('返回上一步选择一张照片'),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      );
}

class _CardPreviewWidget extends StatelessWidget {
  final File image;
  final dynamic style; // PoetryStyle

  const _CardPreviewWidget({
    required this.image,
    required this.style,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      height: 400,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // 背景图片
            Positioned.fill(
              child: Image.file(
                image,
                fit: BoxFit.cover,
              ),
            ),

            // 渐变遮罩
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
                  ),
                ),
              ),
            ),

            // 文案预览
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getPreviewText(context),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'PoetryFont',
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _getStyleName(context),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 水印
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  context.l10n('诗意瞬间'),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getPreviewText(BuildContext context) {
    switch (style.toString()) {
      case 'PoetryStyle.modernPoetic':
        return context.l10n('时光如诗，岁月如歌...');
      case 'PoetryStyle.classical':
        return context.l10n('山重水复疑无路...');
      case 'PoetryStyle.playful':
        return context.l10n('今天也要加油鸭！...');
      default:
        return context.l10n('AI正在创作中...');
    }
  }

  String _getStyleName(BuildContext context) {
    switch (style.toString()) {
      case 'PoetryStyle.modernPoetic':
        return context.l10n('现代诗');
      case 'PoetryStyle.classical':
        return context.l10n('古诗');
      case 'PoetryStyle.playful':
        return context.l10n('俏皮话');
      default:
        return context.l10n('诗意');
    }
  }
}

class _SettingsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppTheme.shadowColor,
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n('卡片设置'),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),

              // 显示二维码选项
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(context.l10n('显示二维码')),
                  Switch(
                    value: appState.showQrCode,
                    onChanged: (value) {
                      appState.setShowQrCode(value);
                    },
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // 风格显示
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(context.l10n('文案风格')),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      StyleUtils.getStyleDisplayName(appState.selectedStyle),
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
