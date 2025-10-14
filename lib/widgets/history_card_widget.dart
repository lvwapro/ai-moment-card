import 'dart:io';
import 'package:flutter/material.dart';
import '../models/poetry_card.dart';
import 'common/fallback_background.dart';
import '../screens/card_detail_screen.dart';

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
          child: isCompact
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
  Widget build(BuildContext context) => Stack(
        children: [
          Column(
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
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(context).primaryColor,
                                  ),
                            ),
                            const Spacer(),
                            Row(
                              children: [
                                if (card.nearbyPlaces != null &&
                                    card.nearbyPlaces!.isNotEmpty) ...[
                                  Icon(
                                    Icons.location_on,
                                    size: 14,
                                    color: Colors.grey[600],
                                  ),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      card.nearbyPlaces!.first.name,
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                ],
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
          ),

          // 右上角勾勾
          if (showSelection && isSelected)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.grey[600],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.check,
                  size: 14,
                  color: Colors.white,
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
  Widget build(BuildContext context) => Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 图片区域 - 大图展示
              AspectRatio(
                aspectRatio: 16 / 9,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: _buildHistoryCardImage(card, context),
                ),
              ),

              // 文字信息区域
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(16),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 诗词内容
                    Text(
                      card.poetry,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).primaryColor,
                          ),
                    ),

                    // 位置信息
                    if (card.nearbyPlaces != null &&
                        card.nearbyPlaces!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              card.nearbyPlaces!.first.name,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
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
        ],
      );
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
