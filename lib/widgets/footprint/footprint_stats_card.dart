import 'package:flutter/material.dart';
import '../../models/poetry_card.dart';
import '../../services/language_service.dart';
import '../../theme/app_theme.dart';

/// 足迹统计信息卡片
class FootprintStatsCard extends StatelessWidget {
  final List<PoetryCard> cards;

  const FootprintStatsCard({
    super.key,
    required this.cards,
  });

  @override
  Widget build(BuildContext context) {
    // 统计唯一位置数量
    final uniqueLocations = <String>{};
    for (var card in cards) {
      if (card.selectedPlace != null) {
        final location = card.selectedPlace!;
        uniqueLocations.add('${location.location}');
      }
    }

    return Container(
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            context,
            Icons.location_on,
            uniqueLocations.length.toString(),
            context.l10n('个足迹'),
          ),
          Container(
            width: 1,
            height: 30,
            color: Colors.grey[300],
          ),
          _buildStatItem(
            context,
            Icons.article,
            cards.length.toString(),
            context.l10n('篇创作'),
          ),
        ],
      ),
    );
  }

  /// 构建统计项
  Widget _buildStatItem(
    BuildContext context,
    IconData icon,
    String value,
    String label,
  ) =>
      Row(
        children: [
          Icon(icon, color: AppTheme.primaryColor, size: 20),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      );
}
