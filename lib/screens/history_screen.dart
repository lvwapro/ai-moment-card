import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/poetry_card.dart';
import '../models/time_filter.dart';
import '../providers/history_manager.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/history_card_widget.dart';
import '../widgets/history_filter_bar.dart';
import 'package:ai_poetry_card/services/language_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _searchQuery = '';
  TimeFilterType? _selectedTimeFilter;
  bool _isGridView = false;
  bool _isMultiSelectMode = false;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: _buildAppBar(context),
        body: Column(
          children: [
            _buildFilterBar(),
            _buildHistoryList(),
          ],
        ),
      );

  AppBar _buildAppBar(BuildContext context) => AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: _isMultiSelectMode
            ? Consumer<HistoryManager>(
                builder: (context, historyManager, child) => Text(
                  '${context.l10n('已选择 ')}${historyManager.selectedCount} ${context.l10n('项')}',
                  style: TextStyle(color: Theme.of(context).primaryColor),
                ),
              )
            : Text(
                context.l10n('灵感长廊'),
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
        automaticallyImplyLeading: false,
        leading: _isMultiSelectMode
            ? Consumer<HistoryManager>(
                builder: (context, historyManager, child) => IconButton(
                  icon: Icon(Icons.select_all,
                      color: Theme.of(context).primaryColor),
                  onPressed: () {
                    if (historyManager.selectedCount ==
                        historyManager.totalCount) {
                      historyManager.clearSelection();
                    } else {
                      historyManager.selectAllCards();
                    }
                  },
                ),
              )
            : null,
        actions: _isMultiSelectMode
            ? _buildMultiSelectActions()
            : _buildNormalActions(),
      );

  Widget _buildFilterBar() => HistoryFilterBar(
        searchQuery: _searchQuery,
        selectedTimeFilter: _selectedTimeFilter,
        isGridView: _isGridView,
        onSearchChanged: (query) {
          setState(() {
            _searchQuery = query;
          });
        },
        onTimeFilterChanged: (timeFilter) {
          setState(() {
            _selectedTimeFilter = timeFilter;
          });
        },
        onViewModeChanged: (isGridView) {
          setState(() {
            _isGridView = isGridView;
          });
        },
      );

  Widget _buildHistoryList() => Expanded(
        child: Consumer<HistoryManager>(
          builder: (context, historyManager, child) {
            final filteredCards = _getFilteredCards(historyManager);

            if (filteredCards.isEmpty) {
              return EmptyStateWidget(
                hasCards: historyManager.totalCount > 0,
                searchQuery: _searchQuery,
              );
            }

            return _isGridView
                ? _GridView(
                    cards: filteredCards,
                    isMultiSelectMode: _isMultiSelectMode,
                  )
                : _ListGridView(
                    cards: filteredCards,
                    isMultiSelectMode: _isMultiSelectMode,
                  );
          },
        ),
      );

  List<PoetryCard> _getFilteredCards(HistoryManager historyManager) {
    List<PoetryCard> cards = historyManager.cards;

    // 搜索过滤
    if (_searchQuery.isNotEmpty) {
      cards = historyManager.searchCards(_searchQuery);
    }

    // 时间过滤
    if (_selectedTimeFilter != null) {
      final timeRange = TimeFilterHelper.getTimeRange(_selectedTimeFilter!);

      if (timeRange != null) {
        cards = cards
            .where((card) =>
                TimeFilterHelper.isDateInRange(card.createdAt, timeRange))
            .toList();
      }
    }

    return cards;
  }

  List<Widget> _buildNormalActions() => [
        Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.checklist, color: Theme.of(context).primaryColor),
            onPressed: _enterMultiSelectMode,
          ),
        ),
      ];

  List<Widget> _buildMultiSelectActions() => [
        Consumer<HistoryManager>(
          builder: (context, historyManager, child) => IconButton(
            icon: Icon(Icons.delete, color: Theme.of(context).primaryColor),
            onPressed: historyManager.selectedCount > 0
                ? () => _showDeleteSelectedDialog()
                : null,
          ),
        ),
        IconButton(
          icon: Icon(Icons.close, color: Theme.of(context).primaryColor),
          onPressed: _exitMultiSelectMode,
        ),
      ];

  void _enterMultiSelectMode() {
    setState(() {
      _isMultiSelectMode = true;
    });
  }

  void _exitMultiSelectMode() {
    setState(() {
      _isMultiSelectMode = false;
    });
    if (mounted) {
      Provider.of<HistoryManager>(context, listen: false).clearSelection();
    }
  }

  void _showDeleteSelectedDialog() {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n('删除选中的卡片')),
        content: Consumer<HistoryManager>(
          builder: (context, historyManager, child) => Text(
            context
                .l10n('确定要删除选中的 ${historyManager.selectedCount} 张卡片吗？此操作不可撤销。'),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n('取消')),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              if (mounted) {
                Provider.of<HistoryManager>(context, listen: false)
                    .deleteSelectedCards();
                _exitMultiSelectMode();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(context.l10n('删除')),
          ),
        ],
      ),
    );
  }
}

class _ListGridView extends StatelessWidget {
  final List<PoetryCard> cards;
  final bool isMultiSelectMode;

  const _ListGridView({
    required this.cards,
    required this.isMultiSelectMode,
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
      padding: const EdgeInsets.all(16),
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
          builder: (context, isSelected, child) {
            return Container(
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
                          Container(
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
                                    fontFeatures: const [
                                      FontFeature.tabularFigures()
                                    ],
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
                                    fontFeatures: const [
                                      FontFeature.tabularFigures()
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
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
            );
          },
        );
      },
    );
  }

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

  String _formatYear(DateTime date) {
    return '${date.year}';
  }

  String _formatMonthDay(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$month\n/\n$day';
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

class _GridView extends StatelessWidget {
  final List<PoetryCard> cards;
  final bool isMultiSelectMode;

  const _GridView({
    required this.cards,
    required this.isMultiSelectMode,
  });

  @override
  Widget build(BuildContext context) => GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.7,
        ),
        itemCount: cards.length,
        itemBuilder: (context, index) {
          final card = cards[index];
          return Consumer<HistoryManager>(
            key: ValueKey(card.id),
            builder: (context, historyManager, child) => HistoryCardWidget(
              key: ValueKey('grid_card_${card.id}'),
              card: card,
              isCompact: true,
              showSelection: isMultiSelectMode,
              isSelected: historyManager.isCardSelected(card.id),
              onSelectionChanged: () {
                historyManager.toggleCardSelection(card.id);
              },
            ),
          );
        },
      );
}

/// 虚线边框绘制器
class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashSpace;

  DashedBorderPainter({
    required this.color,
    this.strokeWidth = 2,
    this.dashWidth = 5,
    this.dashSpace = 3,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(16),
      ));

    _drawDashedPath(canvas, path, paint);
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    final metrics = path.computeMetrics();
    for (final metric in metrics) {
      double distance = 0;
      while (distance < metric.length) {
        final segment = metric.extractPath(
          distance,
          distance + dashWidth,
        );
        canvas.drawPath(segment, paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(DashedBorderPainter oldDelegate) =>
      color != oldDelegate.color ||
      strokeWidth != oldDelegate.strokeWidth ||
      dashWidth != oldDelegate.dashWidth ||
      dashSpace != oldDelegate.dashSpace;
}
