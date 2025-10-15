import 'package:flutter/material.dart';
import '../models/poetry_card.dart';
import 'common/cached_card_image.dart';
import '../screens/card_detail_screen.dart';

class HistoryCardWidget extends StatelessWidget {
  final PoetryCard card;
  final bool isCompact;
  final bool isSelected;
  final bool showSelection;
  final VoidCallback? onSelectionChanged;
  final VoidCallback? onLongPressDelete;

  const HistoryCardWidget({
    super.key,
    required this.card,
    this.isCompact = false,
    this.isSelected = false,
    this.showSelection = false,
    this.onSelectionChanged,
    this.onLongPressDelete,
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
                // 如果有删除回调，则触发删除；否则触发多选
                if (onLongPressDelete != null) {
                  onLongPressDelete!();
                } else {
                  onSelectionChanged?.call();
                }
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
                    child: CachedCardImage(card: card),
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
                  child: CachedCardImage(card: card),
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
