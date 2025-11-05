import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';

import '../../models/poetry_card.dart';
import '../../providers/history_manager.dart';
import '../../services/language_service.dart';
import 'history_card_widget.dart';
import 'dashed_border_painter.dart';

/// 列表视图（带时间轴）
class HistoryListView extends StatelessWidget {
  final List<PoetryCard> cards;
  final bool isMultiSelectMode;
  final Future<bool> Function(BuildContext, PoetryCard) onDelete;

  const HistoryListView({
    super.key,
    required this.cards,
    required this.isMultiSelectMode,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final groups = _groupCardsByDate(context);
    int totalCount = 0;
    for (var group in groups) {
      totalCount++; // header
      totalCount += (group['cards'] as List).length; // cards
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100), // 底部留100空间给导航栏
      itemCount: totalCount,
      itemBuilder: (context, index) {
        final itemData = _getItemAtIndexFromGroups(index, groups);

        // 日期分组标题
        if (itemData['type'] == 'header') {
          return Container(
            margin: EdgeInsets.only(bottom: 16, top: index == 0 ? 0 : 24),
            child: Text(
              itemData['title'] as String,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
                letterSpacing: 0.5,
              ),
            ),
          );
        }

        // 卡片内容
        final card = itemData['card'] as PoetryCard;
        return Selector<HistoryManager, bool>(
          selector: (context, historyManager) =>
              historyManager.isCardSelected(card.id),
          builder: (context, isSelected, child) => Slidable(
            key: ValueKey('${card.id}_slidable'),
            enabled: !isMultiSelectMode, // 多选模式下禁用滑动
            endActionPane: ActionPane(
              motion: const ScrollMotion(),
              extentRatio: 0.32,
              children: [
                CustomSlidableAction(
                  onPressed: (slidableContext) async {
                    await onDelete(context, card);
                    if (slidableContext.mounted) {
                      Slidable.of(slidableContext)?.close();
                    }
                  },
                  autoClose: false,
                  backgroundColor: Colors.transparent,
                  padding: EdgeInsets.zero,
                  child: Center(
                    child: Container(
                      height: 70,
                      margin: const EdgeInsets.symmetric(
                          vertical: 4, horizontal: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.delete,
                        size: 28,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            child: Container(
              key: ValueKey('${card.id}_list'),
              margin: const EdgeInsets.only(bottom: 20),
              child: Stack(
                children: [
                  CustomPaint(
                    painter: isMultiSelectMode && isSelected
                        ? DashedBorderPainter(
                            color: Theme.of(context).primaryColor,
                            strokeWidth: 2,
                            dashWidth: 8,
                            dashSpace: 4,
                          )
                        : null,
                    child: Padding(
                      padding: const EdgeInsets.all(3),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 左侧时间显示
                          _buildTimeColumn(context, card),
                          const SizedBox(width: 12),
                          // 右侧卡片内容
                          Expanded(
                            child: HistoryCardWidget(
                              key: ValueKey('list_card_${card.id}'),
                              card: card,
                              showSelection: isMultiSelectMode,
                              isSelected: isSelected,
                              onSelectionChanged: () {
                                Provider.of<HistoryManager>(context,
                                        listen: false)
                                    .toggleCardSelection(card.id);
                              },
                              onLongPressDelete: () async {
                                await onDelete(context, card);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 右上角勾勾
                  if (isMultiSelectMode && isSelected)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
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
              ),
            ),
          ),
        );
      },
    );
  }

  /// 构建左侧时间列
  Widget _buildTimeColumn(BuildContext context, PoetryCard card) => Container(
        width: 65,
        padding: const EdgeInsets.only(top: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 年份
            Text(
              _formatYear(card.createdAt),
              style: TextStyle(
                fontSize: 9,
                color: Colors.grey[400],
                fontWeight: FontWeight.w300,
                letterSpacing: 1.2,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(height: 6),
            // 月/日 - 大数字
            Text(
              _formatMonthDay(card.createdAt),
              style: TextStyle(
                fontSize: 22,
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.w700,
                height: 1.0,
                letterSpacing: 0.8,
                fontFeatures: const [
                  FontFeature.tabularFigures(),
                  FontFeature.liningFigures(),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // 时:分
            Text(
              _formatTime(card.createdAt),
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      );

  Map<String, dynamic> _getItemAtIndexFromGroups(
      int index, List<Map<String, dynamic>> groups) {
    int currentIndex = 0;

    for (var group in groups) {
      // 检查是否是标题
      if (currentIndex == index) {
        return {'type': 'header', 'title': group['title']};
      }
      currentIndex++;

      // 检查是否是该组的卡片
      final groupCards = group['cards'] as List<PoetryCard>;
      for (var card in groupCards) {
        if (currentIndex == index) {
          return {'type': 'card', 'card': card};
        }
        currentIndex++;
      }
    }

    return {'type': 'card', 'card': cards.first};
  }

  List<Map<String, dynamic>> _groupCardsByDate(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final weekAgo = today.subtract(const Duration(days: 7));

    Map<String, List<PoetryCard>> groups = {
      context.l10n('今天'): [],
      context.l10n('昨天'): [],
      context.l10n('本周'): [],
      context.l10n('更早'): [],
    };

    for (var card in cards) {
      final cardDate = DateTime(
        card.createdAt.year,
        card.createdAt.month,
        card.createdAt.day,
      );

      if (cardDate == today) {
        groups[context.l10n('今天')]!.add(card);
      } else if (cardDate == yesterday) {
        groups[context.l10n('昨天')]!.add(card);
      } else if (cardDate.isAfter(weekAgo)) {
        groups[context.l10n('本周')]!.add(card);
      } else {
        groups[context.l10n('更早')]!.add(card);
      }
    }

    // 只返回非空分组
    List<Map<String, dynamic>> result = [];
    groups.forEach((title, cardList) {
      if (cardList.isNotEmpty) {
        result.add({'title': title, 'cards': cardList});
      }
    });

    return result;
  }

  String _formatYear(DateTime date) => '${date.year}';

  String _formatMonthDay(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$month\n/\n$day';
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
