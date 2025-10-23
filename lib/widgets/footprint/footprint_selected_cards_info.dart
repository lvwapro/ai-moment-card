import 'package:flutter/material.dart';
import '../../models/poetry_card.dart';
import '../../screens/card_detail_screen.dart';
import '../../services/language_service.dart';
import '../../theme/app_theme.dart';

/// 选中卡片的信息卡片（支持多个卡片和聚合）
class FootprintSelectedCardsInfo extends StatelessWidget {
  final List<PoetryCard> cards;
  final VoidCallback onClose;

  const FootprintSelectedCardsInfo({
    super.key,
    required this.cards,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    if (cards.isEmpty) return const SizedBox.shrink();

    // 统计唯一位置数量
    final uniqueLocations = <String>{};
    for (var card in cards) {
      if (card.selectedPlace != null) {
        uniqueLocations.add(card.selectedPlace!.name);
      }
    }

    // 如果是聚合的多个位置，显示"已聚合N个足迹"
    final isCluster = uniqueLocations.length > 1;
    final titleText = isCluster
        ? context
            .l10n('已聚合 {0} 个足迹')
            .replaceAll('{0}', uniqueLocations.length.toString())
        : cards.first.selectedPlace!.name;

    return Container(
      constraints: const BoxConstraints(maxHeight: 300),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 位置信息和关闭按钮
          Row(
            children: [
              Icon(
                isCluster ? Icons.layers : Icons.location_on,
                color: AppTheme.primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  cards.length > 1
                      ? '$titleText (${cards.length}${context.l10n('篇')})'
                      : titleText,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: onClose,
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 卡片列表
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: cards.length,
              separatorBuilder: (context, index) => const Divider(height: 16),
              itemBuilder: (context, index) {
                final card = cards[index];
                return _buildCardItem(context, card, isCluster);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardItem(
    BuildContext context,
    PoetryCard card,
    bool isCluster,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CardDetailScreen(
              card: card,
              isResultMode: false,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 如果是聚合点，显示具体位置名称
            if (isCluster && card.selectedPlace != null) ...[
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 14,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      card.selectedPlace!.name,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
            ],
            Text(
              card.poetry,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  _formatDate(context, card.createdAt),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const Spacer(),
                Text(
                  context.l10n('点击查看详情'),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 12,
                  color: AppTheme.primaryColor,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 格式化日期
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
}
