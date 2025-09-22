import 'package:flutter/material.dart';
import '../models/poetry_card.dart';
import '../screens/card_detail_screen.dart';

class HistoryCardWidget extends StatelessWidget {
  final PoetryCard card;
  final bool isCompact;

  const HistoryCardWidget({
    super.key,
    required this.card,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CardDetailScreen(card: card),
          ),
        );
      },
      child: Container(
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
        ),
        child: isCompact ? _CompactView(card: card) : _CardListView(card: card),
      ),
    );
  }
}

class _CompactView extends StatelessWidget {
  final PoetryCard card;

  const _CompactView({required this.card});

  @override
  Widget build(BuildContext context) {
    return Column(
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
              child: Image.file(
                card.image,
                fit: BoxFit.cover,
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
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
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
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _getStyleName(card.style),
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      _formatDate(card.createdAt),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade500,
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
}

class _CardListView extends StatelessWidget {
  final PoetryCard card;

  const _CardListView({required this.card});

  @override
  Widget build(BuildContext context) {
    return Padding(
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
              child: Image.file(
                card.image,
                fit: BoxFit.cover,
              ),
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
                  style: Theme.of(context).textTheme.titleMedium,
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
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _getStyleName(card.style),
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _getTemplateName(card.template),
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _formatDate(card.createdAt),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade500,
                      ),
                ),
              ],
            ),
          ),

          // 箭头
          Icon(
            Icons.chevron_right,
            color: Colors.grey.shade400,
          ),
        ],
      ),
    );
  }
}

String _getStyleName(PoetryStyle style) {
  switch (style) {
    case PoetryStyle.modernPoetic:
      return '现代诗意';
    case PoetryStyle.classicalElegant:
      return '古风雅韵';
    case PoetryStyle.humorousPlayful:
      return '幽默俏皮';
    case PoetryStyle.warmLiterary:
      return '文艺暖心';
    case PoetryStyle.minimalTags:
      return '极简摘要';
    case PoetryStyle.sciFiImagination:
      return '科幻想象';
    case PoetryStyle.deepPhilosophical:
      return '深沉哲思';
    case PoetryStyle.blindBox:
      return '盲盒';
  }
}

String _getTemplateName(CardTemplate template) {
  switch (template) {
    case CardTemplate.minimal:
      return '极简';
    case CardTemplate.elegant:
      return '优雅';
    case CardTemplate.romantic:
      return '浪漫';
    case CardTemplate.vintage:
      return '复古';
    case CardTemplate.nature:
      return '自然';
    case CardTemplate.urban:
      return '都市';
  }
}

String _formatDate(DateTime date) {
  final now = DateTime.now();
  final difference = now.difference(date);

  if (difference.inDays > 0) {
    return '${difference.inDays}天前';
  } else if (difference.inHours > 0) {
    return '${difference.inHours}小时前';
  } else if (difference.inMinutes > 0) {
    return '${difference.inMinutes}分钟前';
  } else {
    return '刚刚';
  }
}
