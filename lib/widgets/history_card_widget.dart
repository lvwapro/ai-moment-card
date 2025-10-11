import 'dart:io';
import 'package:flutter/material.dart';
import '../models/poetry_card.dart';
import 'common/fallback_background.dart';
import '../screens/card_detail_screen.dart';
import 'package:ai_poetry_card/services/language_service.dart';
import '../utils/style_utils.dart';
import '../theme/app_theme.dart';

class HistoryCardWidget extends StatelessWidget {
  final PoetryCard card;
  final bool isCompact;
  final bool isSelected;
  final bool showSelection;
  final VoidCallback? onSelectionChanged;

  const HistoryCardWidget({
    super.key,
    required this.card,
    this.isCompact = false,
    this.isSelected = false,
    this.showSelection = false,
    this.onSelectionChanged,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () {
          if (showSelection && onSelectionChanged != null) {
            onSelectionChanged!();
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CardDetailScreen(card: card),
              ),
            );
          }
        },
        onLongPress: showSelection
            ? null
            : () {
                onSelectionChanged?.call();
              },
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
            border: null,
          ),
          child: Stack(
            children: [
              isCompact
                  ? _CompactView(
                      card: card,
                      showSelection: showSelection,
                      isSelected: isSelected,
                    )
                  : _CardListView(
                      card: card,
                      showSelection: showSelection,
                      isSelected: isSelected,
                    ),
              // 右下角选择标记
              if (showSelection && isSelected)
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Container(
                    width: 24,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.grey, // 背景改为灰色
                      borderRadius: BorderRadius.circular(8), // 减少圆角
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.check,
                        color: Colors.white, // 勾选图标改为白色
                        size: 12, // 减小图标尺寸以适应容器
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
}

class _CompactView extends StatelessWidget {
  final PoetryCard card;
  final bool showSelection;
  final bool isSelected;

  const _CompactView({
    required this.card,
    required this.showSelection,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 图片
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: _buildHistoryCardImage(card, context),
              ),
            ),
          ),

          // 信息
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 文字内容
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          card.poetry,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context).primaryColor,
                                  ),
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            Text(
                              StyleUtils.getStyleDisplayName(card.style),
                              style: const TextStyle(
                                color: AppTheme.chipText,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              _formatDate(context, card.createdAt),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Theme.of(context).primaryColor,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
}

class _CardListView extends StatelessWidget {
  final PoetryCard card;
  final bool showSelection;
  final bool isSelected;

  const _CardListView({
    required this.card,
    required this.showSelection,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // 缩略图
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _buildHistoryCardImage(card, context),
              ),
            ),

            const SizedBox(width: 16),

            // 内容
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    card.poetry,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).primaryColor,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12), // 标签上方较大间距
                  Row(
                    children: [
                      Text(
                        StyleUtils.getStyleDisplayName(card.style),
                        style: const TextStyle(
                          color: AppTheme.chipText,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
                  const SizedBox(height: 4), // 标签下方较小间距
                  Text(
                    _formatDate(context, card.createdAt),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).primaryColor,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}

String _formatDate(BuildContext context, DateTime date) {
  final now = DateTime.now();
  final difference = now.difference(date);

  if (difference.inDays > 0) {
    return '${difference.inDays} ${context.l10n('天前')}';
  } else if (difference.inHours > 0) {
    return '${difference.inHours} ${context.l10n('小时前')}';
  } else if (difference.inMinutes > 0) {
    return '${difference.inMinutes} ${context.l10n('分钟前')}';
  } else {
    return context.l10n('刚刚');
  }
}

/// 构建历史卡片图片，支持本地文件和网络URL，优先使用本地图片
Widget _buildHistoryCardImage(PoetryCard card, BuildContext context) {
  // 首先尝试同步获取本地图片
  final localPaths = card.metadata['localImagePaths'] as List<dynamic>?;

  if (localPaths != null && localPaths.isNotEmpty) {
    for (var path in localPaths) {
      try {
        final localFile = File(path.toString());
        if (localFile.existsSync()) {
          return RepaintBoundary(
            child: Image(
              image: FileImage(localFile),
              fit: BoxFit.cover,
              gaplessPlayback: true,
              errorBuilder: (context, error, stackTrace) {
                return _buildFallbackImage(context);
              },
            ),
          );
        }
      } catch (e) {
        // 继续尝试下一个
      }
    }
  }

  // 如果没有本地图片，使用FutureBuilder异步加载
  return FutureBuilder<ImageProvider?>(
    key: ValueKey('${card.id}_async'), // 使用不同的key
    future: _getHistoryCardImageProvider(card),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return _buildFallbackImage(context);
      }

      if (snapshot.hasData && snapshot.data != null) {
        return RepaintBoundary(
          child: Image(
            image: snapshot.data!,
            fit: BoxFit.cover,
            gaplessPlayback: true,
            errorBuilder: (context, error, stackTrace) {
              return _buildFallbackImage(context);
            },
          ),
        );
      } else {
        return _buildFallbackImage(context);
      }
    },
  );
}

Widget _buildFallbackImage(BuildContext context) {
  return Container(
    color: Theme.of(context).primaryColor.withOpacity(0.1),
    child: FallbackBackgrounds.historyCard(),
  );
}

/// 智能获取图片Provider：优先本地图片，其次云端图片
Future<ImageProvider?> _getHistoryCardImageProvider(PoetryCard card) async {
  // 1. 优先尝试本地图片路径
  final localPaths = card.metadata['localImagePaths'] as List<dynamic>?;
  if (localPaths != null && localPaths.isNotEmpty) {
    for (var path in localPaths) {
      try {
        final localFile = File(path.toString());
        if (await localFile.exists()) {
          return FileImage(localFile);
        }
      } catch (e) {
        // 继续尝试下一个
      }
    }
  }

  // 2. 尝试云端图片URL
  final cloudUrls = card.metadata['cloudImageUrls'] as List<dynamic>?;
  if (cloudUrls != null && cloudUrls.isNotEmpty) {
    for (var url in cloudUrls) {
      if (url.toString().startsWith('http')) {
        return NetworkImage(
          url.toString(),
          headers: {
            'Cache-Control': 'max-age=86400', // 缓存1天
          },
        );
      }
    }
  }

  // 3. 使用卡片当前的图片路径
  if (card.image.path.startsWith('http')) {
    return NetworkImage(
      card.image.path,
      headers: {
        'Cache-Control': 'max-age=86400', // 缓存1天
      },
    );
  } else {
    // 检查本地文件是否存在
    try {
      if (await card.image.exists()) {
        return FileImage(card.image);
      }
    } catch (e) {
      // 忽略错误
    }
  }

  // 4. 都不可用，返回null使用备用背景
  return null;
}
