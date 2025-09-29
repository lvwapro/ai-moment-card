import 'package:flutter/material.dart';
import '../models/poetry_card.dart';
import 'common/fallback_background.dart';
import '../screens/card_detail_screen.dart';
import '../utils/localization_extension.dart';
import '../utils/style_utils.dart';

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
            border: showSelection && isSelected
                ? Border.all(color: Theme.of(context).primaryColor, width: 2)
                : null,
          ),
          child: Stack(
            children: [
              isCompact ? _CompactView(card: card) : _CardListView(card: card),
              if (showSelection)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Theme.of(context).primaryColor
                          : Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? Theme.of(context).primaryColor
                            : Colors.grey.shade400,
                        width: 2,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 16,
                          )
                        : null,
                  ),
                ),
            ],
          ),
        ),
      );
}

class _CompactView extends StatelessWidget {
  final PoetryCard card;

  const _CompactView({required this.card});

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
                child: FutureBuilder<bool>(
                  future: card.image.exists(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Container(
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    if (snapshot.hasData && snapshot.data == true) {
                      return Image.file(
                        card.image,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return FallbackBackgrounds.historyCard();
                        },
                      );
                    } else {
                      return FallbackBackgrounds.historyCard();
                    }
                  },
                ),
              ),
            ),
          ),

          // 信息
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    card.poetry,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).primaryColor,
                        ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color:
                              Theme.of(context).primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          StyleUtils.getStyleDisplayName(context, card.style),
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        _formatDate(context, card.createdAt),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).primaryColor,
                            ),
                      ),
                    ],
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

  const _CardListView({required this.card});

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
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color:
                              Theme.of(context).primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          StyleUtils.getStyleDisplayName(context, card.style),
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatDate(context, card.createdAt),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).primaryColor,
                        ),
                  ),
                ],
              ),
            ),

            // 箭头
            Icon(
              Icons.chevron_right,
              color: Theme.of(context).primaryColor,
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

/// 构建历史卡片图片，支持本地文件和网络URL
Widget _buildHistoryCardImage(PoetryCard card, BuildContext context) {
  // 检查是否是URL（以http开头）
  if (card.image.path.startsWith('http')) {
    return Image.network(
      card.image.path,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          color: Theme.of(context).primaryColor.withOpacity(0.1),
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return FallbackBackgrounds.historyCard();
      },
    );
  } else {
    // 本地文件
    return FutureBuilder<bool>(
      future: card.image.exists(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasData && snapshot.data == true) {
          return Image.file(
            card.image,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return FallbackBackgrounds.historyCard();
            },
          );
        } else {
          return FallbackBackgrounds.historyCard();
        }
      },
    );
  }
}
