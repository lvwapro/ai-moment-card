import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/poetry_card.dart';
import '../models/time_filter.dart';
import '../providers/history_manager.dart';
import '../services/language_service.dart';
import '../widgets/history/empty_state_widget.dart';
import '../widgets/history/history_filter_bar.dart';
import '../widgets/history/history_grid_view.dart';
import '../widgets/history/history_list_view.dart';

/// 历史记录页面
///
/// 功能：
/// - 展示历史卡片（列表/网格视图）
/// - 搜索和过滤
/// - 多选删除
/// - 滑动删除
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

  // ==================== AppBar ====================

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
        leading: _isMultiSelectMode ? _buildSelectAllButton() : null,
        actions: _isMultiSelectMode
            ? _buildMultiSelectActions()
            : _buildNormalActions(),
      );

  /// 全选按钮
  Widget _buildSelectAllButton() => Consumer<HistoryManager>(
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
      );

  /// 普通模式操作按钮
  List<Widget> _buildNormalActions() => [
        Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.checklist, color: Theme.of(context).primaryColor),
            onPressed: _enterMultiSelectMode,
          ),
        ),
      ];

  /// 多选模式操作按钮
  List<Widget> _buildMultiSelectActions() => [
        Consumer<HistoryManager>(
          builder: (context, historyManager, child) => IconButton(
            icon: Icon(Icons.delete, color: Theme.of(context).primaryColor),
            onPressed: historyManager.selectedCount > 0
                ? _showDeleteSelectedDialog
                : null,
          ),
        ),
        IconButton(
          icon: Icon(Icons.close, color: Theme.of(context).primaryColor),
          onPressed: _exitMultiSelectMode,
        ),
      ];

  // ==================== 过滤栏 ====================

  Widget _buildFilterBar() => HistoryFilterBar(
        searchQuery: _searchQuery,
        selectedTimeFilter: _selectedTimeFilter,
        isGridView: _isGridView,
        onSearchChanged: (query) => setState(() => _searchQuery = query),
        onTimeFilterChanged: (timeFilter) =>
            setState(() => _selectedTimeFilter = timeFilter),
        onViewModeChanged: (isGridView) =>
            setState(() => _isGridView = isGridView),
      );

  // ==================== 历史列表 ====================

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
                ? HistoryGridView(
                    cards: filteredCards,
                    isMultiSelectMode: _isMultiSelectMode,
                    onDelete: _showDeleteDialogWithResult,
                  )
                : HistoryListView(
                    cards: filteredCards,
                    isMultiSelectMode: _isMultiSelectMode,
                    onDelete: _showDeleteDialogWithResult,
                  );
          },
        ),
      );

  /// 获取过滤后的卡片
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

  // ==================== 多选模式 ====================

  void _enterMultiSelectMode() {
    setState(() => _isMultiSelectMode = true);
  }

  void _exitMultiSelectMode() {
    setState(() => _isMultiSelectMode = false);
    if (mounted) {
      Provider.of<HistoryManager>(context, listen: false).clearSelection();
    }
  }

  // ==================== 删除操作 ====================

  /// 显示批量删除对话框
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

  /// 显示单个卡片删除对话框
  Future<bool> _showDeleteDialogWithResult(
      BuildContext context, PoetryCard card) async {
    if (!mounted) return false;

    final historyManager = Provider.of<HistoryManager>(context, listen: false);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.l10n('删除卡片')),
        content: Text(context.l10n('确定要删除这张卡片吗？此操作不可撤销。')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(context.l10n('取消')),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext, true);
              historyManager.deleteCard(card.id);
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

    return confirmed ?? false;
  }
}
