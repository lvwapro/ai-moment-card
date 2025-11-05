import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../models/poetry_card.dart';
import '../../providers/app_state.dart';
import '../../services/language_service.dart';
import '../preview/multi_platform_preview_dialog.dart';

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

                    // 常用文案（默认平台）- 显示在最顶部
                    ..._buildDefaultPlatformSection(context),

                    // 原诗（含诗词信息）
                    if (widget.card.content != null &&
                        widget.card.content!.isNotEmpty)
                      _buildPoetrySection(context),

                    // 对联展示（如果有）
                    if (widget.card.duilian != null)
                      _buildDuilianSection(context),

                    // 其他平台文案（排除常用文案）
                    ..._buildOtherPlatformSections(context),
                  ],
                ),
              ),
          ],
        ),
      );

  // 对联部分（包含横批、上联、下联和解析）
  Widget _buildDuilianSection(BuildContext context) {
    final duilian = widget.card.duilian!;

    // 构建对联文本（用于复制）
    final duilianText =
        '${duilian.horizontal}\n${duilian.upper}\n${duilian.lower}${duilian.analysis != null ? '\n\n${duilian.analysis}' : ''}';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题栏
          Row(
            children: [
              Icon(Icons.menu_book, size: 18, color: Colors.grey[700]),
              const SizedBox(width: 8),
              Text(
                context.l10n('对联'),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              const Spacer(),
              // 对联预览按钮
              IconButton(
                icon: const Icon(Icons.visibility_outlined, size: 18),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                tooltip: context.l10n('对联预览'),
                onPressed: () => _showDuilianPreview(context),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.copy, size: 18),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                tooltip: context.l10n('复制'),
                onPressed: () => _copyToClipboard(context, duilianText),
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
                // 横批
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    duilian.horizontal,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // 上联和下联
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 上联
                    Expanded(
                      child: Text(
                        duilian.upper,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.8,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // 下联
                    Expanded(
                      child: Text(
                        duilian.lower,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.8,
                        ),
                      ),
                    ),
                  ],
                ),
                // 解析（如果有）
                if (duilian.analysis != null &&
                    duilian.analysis!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n('解析'),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        duilian.analysis!,
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.6,
                          color: Colors.grey[700],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 将诗词内容按句分割（根据标点符号：。，；、！？等）
  List<String> _splitPoetryIntoSentences(String content) {
    // 按标点符号分割，保留标点符号
    final sentences = <String>[];
    final buffer = StringBuffer();

    for (int i = 0; i < content.length; i++) {
      final char = content[i];
      buffer.write(char);

      // 检查是否是句末标点符号
      if (char == '。' ||
          char == '，' ||
          char == '；' ||
          char == '！' ||
          char == '？' ||
          char == '\n') {
        final sentence = buffer.toString().trim();
        if (sentence.isNotEmpty) {
          sentences.add(sentence);
        }
        buffer.clear();
      }
    }

    // 处理最后剩余的文本
    final remaining = buffer.toString().trim();
    if (remaining.isNotEmpty) {
      sentences.add(remaining);
    }

    // 如果没有找到标点符号，按换行符分割
    if (sentences.isEmpty) {
      return content
          .split('\n')
          .where((line) => line.trim().isNotEmpty)
          .toList();
    }

    return sentences;
  }

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
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 诗词标题
                if (widget.card.title != null) ...[
                  Text(
                    widget.card.title!,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                ],
                // 作者和朝代
                if (widget.card.author != null || widget.card.time != null) ...[
                  Text(
                    [
                      if (widget.card.author != null) widget.card.author,
                      if (widget.card.time != null) widget.card.time,
                    ].join(' · '),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                ],
                // 诗词内容（每句居中展示，整体往右移动一点）
                if (widget.card.content != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Column(
                      children: _splitPoetryIntoSentences(widget.card.content!)
                          .where((sentence) => sentence.trim().isNotEmpty)
                          .map((sentence) => Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: Text(
                                  sentence.trim(),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    height: 1.2,
                                    letterSpacing: 0.5,
                                    color: Colors.black87,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ))
                          .toList(),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建常用文案（默认平台）部分
  List<Widget> _buildDefaultPlatformSection(BuildContext context) {
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

    // 只处理常用文案（默认平台）
    final widgets = <Widget>[];
    final defaultData = platformData[defaultPlatform];
    if (defaultData != null) {
      final defaultContent = defaultData['content'] as String?;
      if (defaultContent != null && defaultContent.isNotEmpty) {
        widgets.add(
          _buildDefaultCopywritingSection(
            context,
            title: defaultData['title'] as String,
            content: defaultContent,
            icon: defaultData['icon'] as IconData,
            platform: defaultPlatform,
          ),
        );
      }
    }

    return widgets;
  }

  /// 构建常用文案的特殊样式widget
  Widget _buildDefaultCopywritingSection(
    BuildContext context, {
    required String title,
    required String content,
    required IconData icon,
    required PlatformType platform,
  }) =>
      Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),

                const SizedBox(width: 8),
                // 常用文案标签
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    context.l10n('常用文案'),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),

                const Spacer(),
                // 朋友圈文案添加预览按钮
                if (platform == PlatformType.pengyouquan) ...[
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
                if (platform == PlatformType.xiaohongshu) ...[
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
                if (platform == PlatformType.weibo) ...[
                  IconButton(
                    icon: const Icon(Icons.visibility_outlined, size: 18),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    tooltip: context.l10n('微博预览'),
                    onPressed: () => _showWeiboPreview(context),
                  ),
                  const SizedBox(width: 8),
                ],
                // 抖音文案添加预览按钮
                if (platform == PlatformType.douyin) ...[
                  IconButton(
                    icon: const Icon(Icons.visibility_outlined, size: 18),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    tooltip: context.l10n('抖音预览'),
                    onPressed: () => _showDouyinPreview(context),
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
            const SizedBox(height: 12),
            Text(
              content,
              style: TextStyle(
                fontSize: 15,
                height: 1.6,
                fontWeight: FontWeight.w500,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
      );

  /// 构建其他平台文案列表（排除常用文案）
  List<Widget> _buildOtherPlatformSections(BuildContext context) {
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

    // 定义固定的平台顺序（排除对联）
    final allPlatforms = [
      PlatformType.shiju,
      PlatformType.pengyouquan,
      PlatformType.xiaohongshu,
      PlatformType.weibo,
      PlatformType.douyin,
    ];

    // 构建其他平台文案列表（排除常用文案）
    final widgets = <Widget>[];
    for (final platform in allPlatforms) {
      // 跳过常用文案（默认平台）
      if (platform == defaultPlatform) {
        continue;
      }

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
              isDouyin: platform == PlatformType.douyin,
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
    bool isDouyin = false,
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
                // 抖音文案添加预览按钮
                if (isDouyin) ...[
                  IconButton(
                    icon: const Icon(Icons.visibility_outlined, size: 18),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    tooltip: context.l10n('抖音预览'),
                    onPressed: () => _showDouyinPreview(context),
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
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.transparent,
        pageBuilder: (context, animation, secondaryAnimation) =>
            MultiPlatformPreviewDialog.single(
          card: widget.card,
          platform: PlatformType.pengyouquan,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }

  void _showXiaohongshuPreview(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.transparent,
        pageBuilder: (context, animation, secondaryAnimation) =>
            MultiPlatformPreviewDialog.single(
          card: widget.card,
          platform: PlatformType.xiaohongshu,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }

  /// 显示微博预览
  void _showWeiboPreview(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.transparent,
        pageBuilder: (context, animation, secondaryAnimation) =>
            MultiPlatformPreviewDialog.single(
          card: widget.card,
          platform: PlatformType.weibo,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }

  /// 显示抖音预览
  void _showDouyinPreview(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.transparent,
        pageBuilder: (context, animation, secondaryAnimation) =>
            MultiPlatformPreviewDialog.single(
          card: widget.card,
          platform: PlatformType.douyin,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }

  /// 显示对联预览
  void _showDuilianPreview(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.transparent,
        pageBuilder: (context, animation, secondaryAnimation) =>
            MultiPlatformPreviewDialog.single(
          card: widget.card,
          platform: PlatformType.duilian,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) =>
      '${dateTime.year}年${dateTime.month}月${dateTime.day}日 ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
}
