import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/poetry_card.dart';
import '../models/time_filter.dart';
import '../providers/history_manager.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/history_card_widget.dart';
import '../widgets/history_filter_bar.dart';
import '../utils/localization_extension.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _searchQuery = '';
  PoetryStyle? _selectedStyle;
  TimeFilterType? _selectedTimeFilter;
  DateTimeRange? _customTimeRange;
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
        title: _isMultiSelectMode
            ? Consumer<HistoryManager>(
                builder: (context, historyManager, child) => Text(
                  context.l10n('已选择 ${historyManager.selectedCount} 项'),
                  style: TextStyle(color: Theme.of(context).primaryColor),
                ),
              )
            : Text(
                context.l10n('灵感长廊'),
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
        leading: _isMultiSelectMode
            ? IconButton(
                icon: Icon(Icons.close, color: Theme.of(context).primaryColor),
                onPressed: _exitMultiSelectMode,
              )
            : IconButton(
                icon: Icon(Icons.arrow_back,
                    color: Theme.of(context).primaryColor),
                onPressed: () => Navigator.pop(context),
              ),
        actions: _isMultiSelectMode
            ? _buildMultiSelectActions()
            : _buildNormalActions(),
      );

  Widget _buildFilterBar() => HistoryFilterBar(
        searchQuery: _searchQuery,
        selectedStyle: _selectedStyle,
        selectedTimeFilter: _selectedTimeFilter,
        customTimeRange: _customTimeRange,
        isGridView: _isGridView,
        onSearchChanged: (query) {
          setState(() {
            _searchQuery = query;
          });
        },
        onStyleChanged: (style) {
          setState(() {
            _selectedStyle = style;
          });
        },
        onTimeFilterChanged: (timeFilter) {
          setState(() {
            _selectedTimeFilter = timeFilter;
          });
        },
        onCustomTimeRangeChanged: (timeRange) {
          setState(() {
            _customTimeRange = timeRange;
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

    // 风格过滤
    if (_selectedStyle != null) {
      cards = cards.where((card) => card.style == _selectedStyle).toList();
    }

    // 时间过滤
    if (_selectedTimeFilter != null) {
      DateTimeRange? timeRange;

      if (_selectedTimeFilter == TimeFilterType.custom &&
          _customTimeRange != null) {
        timeRange = _customTimeRange;
      } else {
        timeRange = TimeFilterHelper.getTimeRange(_selectedTimeFilter!);
      }

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
            icon: Icon(Icons.select_all, color: Theme.of(context).primaryColor),
            onPressed: () {
              if (historyManager.selectedCount == historyManager.totalCount) {
                historyManager.clearSelection();
              } else {
                historyManager.selectAllCards();
              }
            },
          ),
        ),
        Consumer<HistoryManager>(
          builder: (context, historyManager, child) => IconButton(
            icon: Icon(Icons.delete, color: Theme.of(context).primaryColor),
            onPressed: historyManager.selectedCount > 0
                ? () => _showDeleteSelectedDialog()
                : null,
          ),
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
  Widget build(BuildContext context) => ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: cards.length,
        itemBuilder: (context, index) {
          final card = cards[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: Consumer<HistoryManager>(
              builder: (context, historyManager, child) => HistoryCardWidget(
                card: card,
                showSelection: isMultiSelectMode,
                isSelected: historyManager.isCardSelected(card.id),
                onSelectionChanged: () {
                  historyManager.toggleCardSelection(card.id);
                },
              ),
            ),
          );
        },
      );
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
            builder: (context, historyManager, child) => HistoryCardWidget(
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
