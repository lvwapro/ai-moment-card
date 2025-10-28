import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/poetry_card.dart';
import '../providers/app_state.dart';
import '../services/language_service.dart';
import 'moments_preview_widget.dart';
import 'xiaohongshu_preview_widget.dart';
import 'weibo_preview_widget.dart';

/// 卡片信息展示组件
class CardInfoWidget extends StatefulWidget {
  final PoetryCard card;
  final Function(PoetryCard)? onPoetryUpdated;

  const CardInfoWidget({
    super.key,
    required this.card,
    this.onPoetryUpdated,
  });

  @override
  State<CardInfoWidget> createState() => _CardInfoWidgetState();
}

class _CardInfoWidgetState extends State<CardInfoWidget> {
  bool _isExpanded = true; // 默认展开

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题栏（可点击折叠）
            GestureDetector(
              onTap: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 20,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        context.l10n('卡片信息'),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                    Icon(
                      _isExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: Theme.of(context).primaryColor,
                    ),
                  ],
                ),
              ),
            ),
            // 内容区域（可折叠）
            if (_isExpanded)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 基本信息 - 如果有情绪标签则显示（不受设置影响）
                    if (widget.card.moodTag != null &&
                        widget.card.moodTag!.isNotEmpty)
                      Column(
                        children: [
                          _buildInfoRow(
                              context.l10n('氛围标签'), widget.card.moodTag!),
                          const SizedBox(height: 8),
                        ],
                      ),
                    _buildInfoRow(context.l10n('创建时间'),
                        _formatDateTime(widget.card.createdAt)),

                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),

                    // 各平台文案展示
                    Text(
                      context.l10n('各平台文案'),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                    ),
                    const SizedBox(height: 16),

                    // 原诗（含诗词信息）
                    if (widget.card.content != null &&
                        widget.card.content!.isNotEmpty)
                      _buildPoetrySection(context),

                    // 根据默认平台显示文案（按设置的顺序）
                    ..._buildPlatformSections(context),
                  ],
                ),
              ),
          ],
        ),
      );

  // 诗词部分（包含标题、作者、朝代和内容）
  Widget _buildPoetrySection(BuildContext context) {
    // 构建完整的诗词文本（包含标题、作者、朝代和内容）
    String fullPoetryText = '';
    if (widget.card.title != null || widget.card.author != null) {
      fullPoetryText = '《${widget.card.title ?? ""}》'
          '${widget.card.author != null ? " · ${widget.card.author}" : ""}'
          '${widget.card.time != null ? " · ${widget.card.time}" : ""}\n\n';
    }
    fullPoetryText += widget.card.content!;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题栏
          Row(
            children: [
              Icon(Icons.auto_stories, size: 18, color: Colors.grey[700]),
              const SizedBox(width: 8),
              Text(
                context.l10n('原诗'),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.copy, size: 18),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                tooltip: context.l10n('复制'),
                onPressed: () => _copyToClipboard(context, fullPoetryText),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 诗词标题和作者信息
                if (widget.card.title != null ||
                    widget.card.author != null) ...[
                  Text(
                    '《${widget.card.title ?? ""}》'
                    '${widget.card.author != null ? " · ${widget.card.author}" : ""}'
                    '${widget.card.time != null ? " · ${widget.card.time}" : ""}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                // 诗词内容
                Text(
                  widget.card.content!,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.8,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 根据默认平台设置构建平台文案列表
  List<Widget> _buildPlatformSections(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);
    final defaultPlatform = appState.defaultPlatform;

    // 定义平台信息映射
    final platformData = {
      PlatformType.shiju: {
        'content': widget.card.shiju,
        'title': context.l10n('诗句'),
        'icon': Icons.format_quote,
      },
      PlatformType.pengyouquan: {
        'content': widget.card.pengyouquan,
        'title': context.l10n('朋友圈'),
        'icon': Icons.chat_bubble_outline,
      },
      PlatformType.xiaohongshu: {
        'content': widget.card.xiaohongshu,
        'title': context.l10n('小红书'),
        'icon': Icons.menu_book,
      },
      PlatformType.weibo: {
        'content': widget.card.weibo,
        'title': context.l10n('微博'),
        'icon': Icons.public,
      },
      PlatformType.douyin: {
        'content': widget.card.douyin,
        'title': context.l10n('抖音'),
        'icon': Icons.music_note,
      },
    };

    // 将默认平台放在第一位，其他平台按顺序排列
    final orderedPlatforms = <PlatformType>[
      defaultPlatform,
      ...PlatformType.values.where((p) => p != defaultPlatform),
    ];

    // 构建widget列表（不显示默认标签，只按顺序排列）
    final widgets = <Widget>[];
    for (final platform in orderedPlatforms) {
      final data = platformData[platform];
      if (data != null) {
        final content = data['content'] as String?;
        if (content != null && content.isNotEmpty) {
          widgets.add(
            _buildCopywritingSection(
              context,
              title: data['title'] as String,
              content: content,
              icon: data['icon'] as IconData,
              isPengyouquan: platform == PlatformType.pengyouquan,
              isXiaohongshu: platform == PlatformType.xiaohongshu,
              isWeibo: platform == PlatformType.weibo,
            ),
          );
        }
      }
    }

    return widgets;
  }

  Widget _buildCopywritingSection(
    BuildContext context, {
    required String title,
    required String content,
    required IconData icon,
    bool isPengyouquan = false,
    bool isXiaohongshu = false,
    bool isWeibo = false,
  }) =>
      Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: Colors.grey[700]),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                const Spacer(),
                // 朋友圈文案添加预览按钮
                if (isPengyouquan) ...[
                  IconButton(
                    icon: const Icon(Icons.visibility_outlined, size: 18),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    tooltip: context.l10n('朋友圈预览'),
                    onPressed: () => _showMomentsPreview(context),
                  ),
                  const SizedBox(width: 8),
                ],
                // 小红书文案添加预览按钮
                if (isXiaohongshu) ...[
                  IconButton(
                    icon: const Icon(Icons.visibility_outlined, size: 18),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    tooltip: context.l10n('小红书预览'),
                    onPressed: () => _showXiaohongshuPreview(context),
                  ),
                  const SizedBox(width: 8),
                ],
                // 微博文案添加预览按钮
                if (isWeibo) ...[
                  IconButton(
                    icon: const Icon(Icons.visibility_outlined, size: 18),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    tooltip: context.l10n('微博预览'),
                    onPressed: () => _showWeiboPreview(context),
                  ),
                  const SizedBox(width: 8),
                ],
                IconButton(
                  icon: const Icon(Icons.copy, size: 18),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  tooltip: context.l10n('复制'),
                  onPressed: () => _copyToClipboard(context, content),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Text(
                content,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      );

  Widget _buildInfoRow(String label, String value) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 80,
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ),
            Expanded(
              child: Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).primaryColor,
                    ),
              ),
            ),
          ],
        ),
      );

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.l10n('已复制到剪贴板')),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.green,
      ),
    );
  }

  /// 显示朋友圈预览
  void _showMomentsPreview(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => MomentsPreviewWidget(card: widget.card),
    );
  }

  void _showXiaohongshuPreview(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => XiaohongshuPreviewWidget(card: widget.card),
    );
  }

  /// 显示微博预览
  void _showWeiboPreview(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => WeiboPreviewWidget(card: widget.card),
    );
  }

  String _formatDateTime(DateTime dateTime) =>
      '${dateTime.year}年${dateTime.month}月${dateTime.day}日 ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
}
