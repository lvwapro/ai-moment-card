import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/history_manager.dart';
import '../models/poetry_card.dart';
import '../widgets/history_filter_bar.dart';
import '../widgets/history_card_widget.dart';
import '../widgets/empty_state_widget.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _searchQuery = '';
  PoetryStyle? _selectedStyle;
  CardTemplate? _selectedTemplate;
  bool _isGridView = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          _buildFilterBar(),
          _buildHistoryList(),
        ],
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text('灵感长廊'),
      actions: [
        IconButton(
          icon: Icon(_isGridView ? Icons.list : Icons.grid_view),
          onPressed: () {
            setState(() {
              _isGridView = !_isGridView;
            });
          },
        ),
        PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'clear':
                _showClearHistoryDialog();
                break;
              case 'export':
                _exportHistory();
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'export',
              child: ListTile(
                leading: Icon(Icons.download),
                title: Text('导出历史'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'clear',
              child: ListTile(
                leading: Icon(Icons.delete_forever, color: Colors.red),
                title: Text('清空历史', style: TextStyle(color: Colors.red)),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFilterBar() {
    return HistoryFilterBar(
      searchQuery: _searchQuery,
      selectedStyle: _selectedStyle,
      selectedTemplate: _selectedTemplate,
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
      onTemplateChanged: (template) {
        setState(() {
          _selectedTemplate = template;
        });
      },
    );
  }

  Widget _buildHistoryList() {
    return Expanded(
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
              ? _GridView(cards: filteredCards)
              : _ListGridView(cards: filteredCards);
        },
      ),
    );
  }

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

    // 模板过滤
    if (_selectedTemplate != null) {
      cards =
          cards.where((card) => card.template == _selectedTemplate).toList();
    }

    return cards;
  }

  void _showClearHistoryDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清空历史记录'),
        content: const Text('确定要清空所有历史记录吗？此操作不可撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Provider.of<HistoryManager>(context, listen: false)
                  .clearHistory();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('清空'),
          ),
        ],
      ),
    );
  }

  void _exportHistory() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('导出功能开发中...')),
    );
  }
}

class _ListGridView extends StatelessWidget {
  final List<PoetryCard> cards;

  const _ListGridView({required this.cards});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: cards.length,
      itemBuilder: (context, index) {
        final card = cards[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: HistoryCardWidget(card: card),
        );
      },
    );
  }
}

class _GridView extends StatelessWidget {
  final List<PoetryCard> cards;

  const _GridView({required this.cards});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
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
        return HistoryCardWidget(
          card: card,
          isCompact: true,
        );
      },
    );
  }
}
