import 'package:flutter/material.dart';
import '../utils/localization_extension.dart';

class EmptyStateWidget extends StatelessWidget {
  final bool hasCards;
  final String searchQuery;

  const EmptyStateWidget({
    super.key,
    required this.hasCards,
    required this.searchQuery,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              hasCards ? Icons.search_off : Icons.auto_awesome,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 24),
            Text(
              hasCards ? context.l10n('没有找到相关卡片') : context.l10n('还没有创作过卡片'),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.grey.shade600,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              hasCards
                  ? context.l10n('尝试调整搜索条件或筛选器')
                  : context.l10n('开始创作你的第一张诗意卡片吧'),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade500,
                  ),
              textAlign: TextAlign.center,
            ),
            if (!hasCards) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.add),
                label: Text(context.l10n('开始创作')),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
