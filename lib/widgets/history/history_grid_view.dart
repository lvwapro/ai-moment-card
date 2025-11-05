import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';

import '../../models/poetry_card.dart';
import '../../providers/history_manager.dart';
import 'history_card_widget.dart';

/// 网格视图
class HistoryGridView extends StatelessWidget {
  final List<PoetryCard> cards;
  final bool isMultiSelectMode;
  final Future<bool> Function(BuildContext, PoetryCard) onDelete;

  const HistoryGridView({
    super.key,
    required this.cards,
    required this.isMultiSelectMode,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) => GridView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100), // 底部留100空间给导航栏
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
            builder: (context, historyManager, child) => Slidable(
              key: ValueKey('${card.id}_grid_slidable'),
              enabled: !isMultiSelectMode, // 多选模式下禁用滑动
              endActionPane: ActionPane(
                motion: const ScrollMotion(),
                extentRatio: 0.48,
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
              child: HistoryCardWidget(
                key: ValueKey('grid_card_${card.id}'),
                card: card,
                isCompact: true,
                showSelection: isMultiSelectMode,
                isSelected: historyManager.isCardSelected(card.id),
                onSelectionChanged: () {
                  historyManager.toggleCardSelection(card.id);
                },
                onLongPressDelete: () {
                  onDelete(context, card);
                },
              ),
            ),
          );
        },
      );
}
